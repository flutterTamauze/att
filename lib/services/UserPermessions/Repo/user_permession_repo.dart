import '../user_permessions.dart';

abstract class PermessionAbstract {
  addPermession(
      UserPermessions userPermessions, String userToken, String userId);
  getSingleUserPermession(String userToken, String userId);
  getPendingCompanyPermessions(int companyId, String userToken, int pageIndex);
  getFutureSinglePermession(String userId, String userToken);
  getPendingPermessionDetailsByID(int permessionId, String token);
  getShiftByShiftId(int shiftId);
}
