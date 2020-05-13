import 'package:shared_preferences/shared_preferences.dart';

import '../../../models/models.dart';
import '../../../network/network.dart';
import '../../../utils/utils.dart';

abstract class LoginScreenContract {
  void onLoginSuccess(Token token);

  void onLoginError(String errorTxt);
}

class LoginScreenPresenter {
  LoginScreenContract _view;
  RestDataSource api = RestDataSource();

  LoginScreenPresenter(this._view);

  void doLogin(String username, String password) {
    api
        .login(username, password, GlobalUtils.fingerprint)
        .then((dynamic token) async {
      Token tokenData = Token.map(token);

      final preferences = await SharedPreferences.getInstance();
      preferences.setString(GlobalUtils.EMAIL, username);
      preferences.setString(GlobalUtils.PASSWORD, password);
      preferences.setString(GlobalUtils.TOKEN, tokenData.accessToken);
      preferences.setString(GlobalUtils.REFRESH_TOKEN, tokenData.refreshToken);
      preferences.setString(GlobalUtils.LAST_OPEN, DateTime.now().toString());
//      print("REFRESH TOKEN = ${tokenData.refreshToken}");
      _view.onLoginSuccess(tokenData);
    }).catchError((e) {
      print(e);
      _view.onLoginError('Please enter credentials');
    });
  }
}
