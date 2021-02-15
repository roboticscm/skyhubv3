import 'package:get/get.dart';
import 'package:skyone_mobile/util/app.dart';
import 'package:skyone_mobile/util/server.dart';

class GlobalParam {
  static int connectionTimeout;

  static String serverUrl;
  static String baseApiUrl;

  static String accessToken = 'eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE2MTI2NTU0NjYsInVzZXJJZCI6MSwidXNlcm5hbWUiOiJyb290IiwiZnVsbE5hbWUiOiJUT0RPLi4uIn0.PTi56xY0myK9fXROoJ4WJOrTp4StVQXWHdJa3_VAfdGoUHV0WiYiOGdc6bS8u_mDUO2mCz0ohixpZZNsQh_Em2CLQxCAosnoml7N0LIj_bxQCQE0zGpTYjhlA_VaWcCg2Ez_y2ZLIh8JOJBxt162q48tfbOlCnYfOkwfF4ydHnE';
  static String refreshToken = 'eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsInVzZXJuYW1lIjoicm9vdCIsImZ1bGxOYW1lIjoiVE9ETy4uLiJ9.rJIQW81EeQTsYBBZbEuUKmu_oLsbn02W-ebDJJ-SoDXJU6H0qKQ58G_jWwS0vnnAbwZ9w59gVb3fmwb1ZbcNN9SRNXHw_oS3IcQ-Vm8oBeX-AZ6BGGWr-0iEROWrlIYgSLrlPh6BRUZCTEIWgGISSwxRQQzi4cDnRT7qIvZixtM';
  static int userId;

  static void load() {
    Get.put(LoginInfoController());
    serverUrl = App.storage.getString('SERVER_URL') ?? ServerConfig.defaultServerUrl;
    baseApiUrl = '$serverUrl/api/';
    connectionTimeout = App.storage.getInt('CONNECTION_TIMEOUT') ?? ServerConfig.defaultConnectionTimeout;
  }
}

class LoginInfoController extends GetX {
  RxInt branchId = RxInt();
}