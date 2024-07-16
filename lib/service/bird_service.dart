import 'package:dio/dio.dart';
import 'package:flutbard/bird.dart';
import 'package:flutbard/model/bird_model.dart';
import 'package:flutbard/model/handle_model.dart';
import 'package:hive/hive.dart';

abstract class Service {
  Dio req = Dio();
  late Response response;
  String baseurl = "https://freetestapi.com/api/v1/";
}

abstract class BirdService extends Service {
  List<BirdModel> birds = [];
  Future<ResultModel> getAllBird();
}

class BirdServiceImp extends BirdService {
  final Box<Bird> birdBox = Hive.box<Bird>('bird');
  int currentIndex = 0;

  @override
  Future<ResultModel> getAllBird() async {
    try {
      if (birdBox.isNotEmpty) {
        print("From Cache");
        return ListOf<Bird>(modelList: getBirdsFromCache());
      } else {
        print("From Server");
        response = await req.get("${baseurl}birds");
        if (response.statusCode == 200) {
          List<BirdModel> birds = List.generate(
            response.data.length,
            (index) => BirdModel.fromMap(response.data[index]),
          );
          await store(birds);
          return ListOf<Bird>(modelList: getBirdsFromCache());
        } else {
          return ErrorModel(message: 'There Is a Problem');
        }
      }
    } catch (e) {
      return ExceptionModel(message: e.toString());
    }
  }

  Future<void> store(List<BirdModel> birds) async {
    await birdBox.clear();
    for (var bird in birds) {
      await birdBox.add(
        Bird(
          name: bird.name,
          family: bird.family,
          image: bird.image,
        ),
      );
    }
  }

  List<Bird> getBirdsFromCache() {
    final List<Bird> birds = [];
    for (int i = currentIndex;
        i < currentIndex + 5 && i < birdBox.length;
        i++) {
      birds.add(birdBox.getAt(i)!);
    }
    currentIndex += 5;
    if (currentIndex >= birdBox.length) {
      currentIndex = 0;
    }
    return birds;
  }
}
