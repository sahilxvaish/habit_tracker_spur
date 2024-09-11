//given a habit list of completion days
//is th ehabit completed today
import '../models/habit.dart';

bool isHabitCompletedToday(List<DateTime> completedDays) {
  final today = DateTime.now();
  return completedDays.any(
      (date) =>
          date.year == today.year &&
          date.month == today.month&&
          date.day == today.day,
  );
}

//prepare heatmap dataset
Map<DateTime, int> prepHeatMapDataset(List<Habit> habits){
  Map<DateTime, int> dataset = {};
  
  for(var habit in habits) {
    for (var date in habit.completedDays) {
      //normalize date to avoid time mismatch
      final normalizeDate = DateTime(date.year, date.month, date.day);
      
      //if the date already exists in the dataset, increment its count 
      if (dataset.containsKey(normalizeDate)){
        dataset[normalizeDate] = dataset [normalizeDate]! +1;
      }else {
        //else initialize it with a count of 1
        dataset[normalizeDate] = 1;
      }
    }
  }

  return dataset;
}