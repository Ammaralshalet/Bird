import 'package:hive/hive.dart';

part 'bird.g.dart';

@HiveType(typeId: 1)
class Bird {
  Bird({required this.name, required this.family, required this.image});

  @HiveField(0)
  String name;

  @HiveField(1)
  String family;

  @HiveField(2)
  String image;
}
