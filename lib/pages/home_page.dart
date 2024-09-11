import 'package:flutter/material.dart';
import 'package:habit_tracker/components/my-habit_tile.dart';
import 'package:habit_tracker/components/my_drawer.dart';
import 'package:habit_tracker/components/my_heat_map.dart';
import 'package:habit_tracker/database/habit_database.dart';
import 'package:provider/provider.dart';

import '../database/habit_database.dart';
import '../models/habit.dart';
import '../theme/theme_provider.dart';
import '../util/habit_util.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  @override
  void initState() {
    //read existing habits on app startup
    Provider.of<HabitDatabase>(context, listen: false).readHabits();
    super.initState();
  }

  //text controller
  final TextEditingController textController = TextEditingController();
  //create new habit
  void createNewHabit(){
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('HABITS'),
          content: TextField(
            controller: textController,
            decoration:const InputDecoration(
              hintText: "Create a new habit "
            ),
          ),
          actions: [
            //save button
            MaterialButton(
                onPressed: () {
                  //get the new habit name
                  String newHabitName = textController.text;

                  //save to db
                  context.read<HabitDatabase>().addHabit(newHabitName);

                  //pop box
                  Navigator.pop(context);

                  //clear controller
                  textController.clear();
                },
              child: const Text('Save'),
            ),

            //cancel button
            MaterialButton(onPressed: (){
              //pop box
              Navigator.pop(context);
              
              //clear controller
              textController.clear();
            },
              child: const Text('Cancel'),
            ),


          ],
        ),
    );
  }
  //create habit on and off
   void checkHabitOnOff(bool? value, Habit habit) {
    //update the habit completion status
     if (value!= null) {
       context.read<HabitDatabase>().updateHabitCompletion(habit.id, value);
     }
   }

   //edit habit box
  void editHabitBox(Habit habit) {
    //set the controller text to the habit current time
    textController.text = habit.name;

    showDialog(
        context: context,
        builder: (context) => AlertDialog(
          content: TextField(
            controller: textController,
          ),
          actions: [
            //save button
            MaterialButton(
              onPressed: () {
                //get the new habit name
                String newHabitName = textController.text;

                //save to db
                context.read<HabitDatabase>().updateHabitName(habit.id, newHabitName);

                //pop box
                Navigator.pop(context);

                //clear controller
                textController.clear();
              },
              child: const Text('Save'),
            ),

            //cancel button
            MaterialButton(onPressed: (){
              //pop box
              Navigator.pop(context);

              //clear controller
              textController.clear();
            },
              child: const Text('Cancel'),
            ),


          ],
        )
    );
  }
  //delete habit box
  void deleteHabitBox(Habit habit) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Are you sure you want to delete?"),
          actions: [
            //delete button
            MaterialButton(
              onPressed: () {

                //save to db
                context.read<HabitDatabase>().deleteHabit(habit.id);

                //pop box
                Navigator.pop(context);

              },
              child: const Text('Delete'),
            ),

            //cancel button
            MaterialButton(onPressed: (){
              //pop box
              Navigator.pop(context);
            },
              child: const Text('Cancel'),
            ),


          ],
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text("Spur"),

      ),
      drawer:const  MyDrawer(),
      floatingActionButton: FloatingActionButton(
        onPressed: createNewHabit,
        elevation:0,
        backgroundColor: Theme.of(context).colorScheme.primary,
        child:const Icon(
          Icons.add,
        ),
      ),
      body: ListView(
        children: [
          //HEAT MAP
          _buildHeatMap(),

          //HABIT LIST
          _buildHabitList(),
        ],
      ),
    );
    }
    //build heat map
  Widget _buildHeatMap() {
    //habit database
    final habitDatabase = context.watch<HabitDatabase>();

    //current habits
    List<Habit> currentHabits = habitDatabase.currentHabits;

    //return heat map UI
    return  FutureBuilder<DateTime?>(
      future: habitDatabase.getFirstLaunchDate(),
        builder: (context, snapshot) {
        // once the data is available -> build heatmap
          if(snapshot.hasData) {
            return MyHeatMap(
                startDate: snapshot.data!,
                datasets: prepHeatMapDataset(currentHabits),
            );
          }

          //handle case where no data is returned
          else{
            return Container();
          }
        },
    );
  }


  //build habit list
  //build habit list
  Widget _buildHabitList(){
    //habit db
    final habitDatabase = context.watch<HabitDatabase>();

    //current habits
    List<Habit> currentHabits = habitDatabase.currentHabits;

    //return list of habits UI
    return ListView.builder(
      itemCount: currentHabits.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index){
          //get each individual habit
          final habit = currentHabits[index];

          //check if the habit is completed today
          bool isCompletedToday = isHabitCompletedToday(habit.completedDays);

          //return habit tile UI
          return MyHabitTile(
              text: habit.name,
              isCompleted: isCompletedToday,
            onChanged: (value) => checkHabitOnOff(value, habit),
            editHabit:(context) => editHabitBox(habit) ,
            deleteHabit: (context) => deleteHabitBox(habit),
          );
        },
        );

  }
}
