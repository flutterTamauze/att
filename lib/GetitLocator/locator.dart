import 'package:get_it/get_it.dart';
import 'package:qr_users/FirebaseCloudMessaging/NotificationDataService.dart';
import 'package:qr_users/services/AllSiteShiftsData/sites_shifts_dataService.dart';
import 'package:qr_users/services/MemberData/MemberData.dart';
import 'package:qr_users/services/Reports/Services/report_data.dart';
import 'package:qr_users/services/ShiftsData.dart';
import 'package:qr_users/services/Sites_data.dart';
import 'package:qr_users/services/UserHolidays/user_holidays.dart';
import 'package:qr_users/services/UserMissions/user_missions.dart';
import 'package:qr_users/services/VacationData.dart';
import 'package:qr_users/services/api.dart';
import 'package:qr_users/services/company.dart';
import 'package:qr_users/services/permissions_data.dart';
import 'package:qr_users/services/user_data.dart';

class InitLocator {
  GetIt locator = GetIt.I;
  void intalizeLocator() {
    _setUpLocator();
    print("initialized locators");
  }

  void _setUpLocator() {
    locator.registerLazySingleton(() => UserData());
    // ignore: cascade_invocations
    locator.registerLazySingleton(() => SiteShiftsData());
    // ignore: cascade_invocations
    locator.registerLazySingleton(() => CompanyData());
    // ignore: cascade_invocations
    locator.registerLazySingleton(() => ReportsData());
    // ignore: cascade_invocations
    locator.registerLazySingleton(() => ShiftsData());
    // ignore: cascade_invocations
    locator.registerLazySingleton(() => MemberData());
    // ignore: cascade_invocations
    locator.registerLazySingleton(() => ShiftApi());
    // ignore: cascade_invocations
    locator.registerLazySingleton(() => PermissionHan());
    // ignore: cascade_invocations
    locator.registerLazySingleton(() => VacationData());
    // ignore: cascade_invocations
    locator.registerLazySingleton(() => NotificationDataService());
    // ignore: cascade_invocations
    locator.registerLazySingleton(() => UserHolidaysData());
    // ignore: cascade_invocations
    locator.registerLazySingleton(() => MissionsData());
    // ignore: cascade_invocations
    locator.registerLazySingleton(() => SiteData());
  }
}
