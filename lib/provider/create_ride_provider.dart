import 'package:flutter/cupertino.dart';
import '../model/user_model.dart';

class CreateRideProvider extends ChangeNotifier {

  String arrival='',departure='';

  void setArrival(String value) {
    arrival = value;
    notifyListeners();
  }

  void setDeparture(String value) {
    departure = value;
    notifyListeners();
  }

  void reset(){
    arrival='';
    departure='';
  }





}
