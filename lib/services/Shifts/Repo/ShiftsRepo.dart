import 'package:geolocator/geolocator.dart';
import 'package:huawei_location/location/location.dart';

abstract class ShiftsRepo {
  getLateAbsenceReport(
      bool isHawawi, Location huawi, Position location, String id);
  getFirstAvailableSchedule();
}
