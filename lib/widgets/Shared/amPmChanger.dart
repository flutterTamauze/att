String amPmChanger(int intTime) {
  int hours = (intTime ~/ 100);
  final int min = intTime - (hours * 100);

  final ampm = hours >= 12 ? 'PM' : 'AM';
  hours = hours % 12;
  hours = hours != 0 ? hours : 12; //

  final String hoursStr =
      hours < 10 ? '0$hours' : hours.toString(); // the hour '0' should be '12'
  final String minStr = min < 10 ? '0$min' : min.toString();

  final strTime = '$hoursStr:$minStr$ampm';

  return strTime;
}
