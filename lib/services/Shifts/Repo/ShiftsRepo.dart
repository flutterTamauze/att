import 'package:geolocator/geolocator.dart';

abstract class ShiftsRepo {
  getLateAbsenceReport(bool isHawawi, Position location, String id);
  getFirstAvailableSchedule();
}
