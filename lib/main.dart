import 'package:flutbard/bird.dart';
import 'package:flutbard/box.dart';
import 'package:flutbard/model/bird_model.dart';
import 'package:flutbard/model/handle_model.dart';
import 'package:flutbard/service/bird_service.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

late Box<BirdModel> birdBox;

main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(BirdAdapter());
  birdBox = await Hive.openBox<BirdModel>('bird');
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyHome(),
    );
  }
}

class MyHome extends StatefulWidget {
  MyHome({super.key});

  @override
  State<MyHome> createState() => _MyHomeState();
}

class _MyHomeState extends State<MyHome> {
  ValueNotifier<ResultModel> result = ValueNotifier(ResultModel());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ValueListenableBuilder(
        valueListenable: result,
        builder: (context, value, child) {
          if (value is ListOf<BirdModel>) {
            return ListView.builder(
              itemCount: birdBox.length,
              itemBuilder: (context, index) {
                Bird bird = boxBird.getAt(index);
                return ListTile(
                  title: Text(bird.name),
                  leading: Image.network(bird.image),
                );
              },
            );
          } else if (value is ExceptionModel) {
            return Text(value.message);
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(onPressed: () async {
        result.value = await BirdServiceImp().getAllBird();
        if (result.value is ListOf<BirdModel>) {
          ListOf<BirdModel> birds = result.value as ListOf<BirdModel>;

          setState(() {
            for (var birdModel in birds.modelList) {
              birdBox.put(
                birdModel.name,
                BirdModel(
                  name: birdModel.name,
                  family: birdModel.family,
                  image: birdModel.image,
                ),
              );
            }
          });
        }
      }),
    );
  }
}
