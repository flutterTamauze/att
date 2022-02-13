abstract class UserHolidaysRepo {
  getPendingCompanyHolidays(int companyId, String userToken, int pageIndex);
  getFutureSingleUserHoliday(String userId, String userToken);
  getSingleUserHoliday(String userToken, String userId);
}
