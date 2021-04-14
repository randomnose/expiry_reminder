int showDateDifference(DateTime date) {
    return DateTime(date.year, date.month, date.day)
        .difference(DateTime(
            DateTime.now().year, DateTime.now().month, DateTime.now().day))
        .inDays;
  }