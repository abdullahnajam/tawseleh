import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../model/user_model.dart';

class FilterProvider extends ChangeNotifier {

  String departure='';
  String arrival='';
  double priceStart=0;
  double priceEnd=1000;
  bool allRides=false;
  //RangeValues price=RangeValues(0, 1000);
  DateTime startDate=DateTime.now().subtract(Duration(days: 1));
  DateTime endDate=DateTime.now().add(Duration(days: 7));
  DateTime startTime=DateTime.now().subtract(Duration(days: 1));
  String? gender;
  DateTime endTime=DateTime.now().add(Duration(days: 7));

  void setDeparture(String departure) {
    this.departure = departure;
    notifyListeners();
  }



  void setArrival(String value) {
    arrival = value;
    notifyListeners();
  }
  void setAllRides(bool value) {
    allRides = value;
    notifyListeners();
  }

  /*void setPriceRange(RangeValues value) {
    price = value;
    notifyListeners();
  }*/

  void setPriceStart(double value) {
    priceStart = value;
    notifyListeners();
  }
  void setPriceEnd(double value) {
    priceEnd = value;
    notifyListeners();
  }

  void setDateEnd(DateTime value) {
    endDate = value;
    notifyListeners();
  }

  void setDateStart(DateTime value) {
    startDate = value;
    notifyListeners();
  }

  void setTimeEnd(DateTime value) {
    endTime = value;
    notifyListeners();
  }

  void setTimeStart(DateTime value) {
    startTime = value;
    notifyListeners();
  }



  void setGender(String value) {
    gender = value;
    notifyListeners();
  }









}
