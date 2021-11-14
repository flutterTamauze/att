String amPmChanger(int intTime) {
  int hours = (intTime ~/ 100);
  int min = intTime - (hours * 100);

  var ampm = hours >= 12 ? 'PM' : 'AM';
  hours = hours % 12;
  hours = hours != 0 ? hours : 12; //

  String hoursStr =
      hours < 10 ? '0$hours' : hours.toString(); // the hour '0' should be '12'
  String minStr = min < 10 ? '0$min' : min.toString();

  var strTime = '$hoursStr:$minStr$ampm';

  return strTime;
}
