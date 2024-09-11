import 'package:isar/isar.dart';


part 'habit.g.dart';

@Collection()
class Habit {
  //habit id
  Id id = Isar.autoIncrement;

  //habit name
  late  String name;

  //completed days
  List<DateTime> completedDays = [
    //DateTime (yyyy, mm, dd),
    //DateTime (2024, 01, 01),
    //DateTime (2024, 01, 02),
  ];
}