import 'package:flutter/cupertino.dart';
import '../model/user_model.dart';

class UserDataProvider extends ChangeNotifier {

  UserModel? userData;

  void setUserData(UserModel user) {
    this.userData = user;
    notifyListeners();
  }

  void setGender(String value) {
    userData!.gender = value;
    notifyListeners();
  }

  void setBlockList(List value) {
    userData!.blockList = value;
    notifyListeners();
  }

  void addBlockedUser(value) {
    userData!.blockList.add(value);
    notifyListeners();
  }

  void removeBlockedUser(value) {
    userData!.blockList.remove(value);
    notifyListeners();
  }

  void setImage(String value) {
    userData!.profilePic = value;
    notifyListeners();
  }

  void setFirstName(String value) {
    userData!.firstName = value;
    notifyListeners();
  }

  void setLastName(String value) {
    userData!.lastName = value;
    notifyListeners();
  }

  void setPassword(String value) {
    userData!.password = value;
    notifyListeners();
  }





}
