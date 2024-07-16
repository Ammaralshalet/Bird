import 'package:flutbard/model/handle_model.dart';
import 'package:flutbard/service/bird_service.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'bird.dart';

late Box<Bird> birdBox;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(BirdAdapter());
  birdBox = await Hive.openBox<Bird>('bird');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyHome(),
    );
  }
}

class MyHome extends StatefulWidget {
  const MyHome({super.key});

  @override
  State<MyHome> createState() => _MyHomeState();
}

class _MyHomeState extends State<MyHome> {
  ValueNotifier<ResultModel> result = ValueNotifier(ResultModel());

  @override
  void initState() {
    super.initState();
    loadCachedBirds();
  }

  void loadCachedBirds() {
    if (birdBox.isNotEmpty) {
      result.value = ListOf<Bird>(
        modelList: birdBox.values.take(5).toList(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ValueListenableBuilder(
        valueListenable: result,
        builder: (context, value, child) {
          if (value is ListOf<Bird>) {
            return ListView.builder(
              itemCount: value.modelList.length,
              itemBuilder: (context, index) {
                Bird bird = value.modelList[index];
                return ListTile(
                  title: Text(bird.name),
                  leading: Image.network(bird.image),
                );
              },
            );
          } else if (value is ExceptionModel) {
            return Center(child: Text(value.message));
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          try {
            result.value = await BirdServiceImp().getAllBird();
            if (result.value is ListOf<Bird>) {
              ListOf<Bird> birds = result.value as ListOf<Bird>;

              setState(() {
                for (var birdModel in birds.modelList) {
                  birdBox.put(
                    birdModel.name,
                    Bird(
                      name: birdModel.name,
                      family: birdModel.family,
                      image: birdModel.image,
                    ),
                  );
                }
              });
            }
          } catch (e) {
            result.value = ExceptionModel(
                message: 'Failed to fetch data from the internet');
          }
        },
      ),
    );
  }
}
