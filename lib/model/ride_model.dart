import 'package:cloud_firestore/cloud_firestore.dart';
class RideModel{
  String id,userId,departureCity,arrivalCity,departureNeighbour,arrivalNeighbour,date,time,image,gender;
  int seats,startDateInMilli,endDateInMilli;
  double pricePerSeat;




  RideModel.fromMap(Map<String,dynamic> map,String key)
      : id=key,
        departureCity = map['departureCity']??"",
        userId = map['userId']??"",
        arrivalCity = map['arrivalCity']??"",
        departureNeighbour = map['departureNeighbour']??"",
        arrivalNeighbour = map['arrivalNeighbour']??"",
        date = map['date']??"Male",
        gender = map['gender']??"Male",
        time = map['time']??"",
        image = map['image']??"",
        seats = map['seats']??1,
        pricePerSeat = map['pricePerSeat']??0,
        startDateInMilli = map['startDateInMilli']??DateTime.now().millisecondsSinceEpoch,
        endDateInMilli = map['endDateInMilli']??DateTime.now().millisecondsSinceEpoch;



  RideModel.fromSnapshot(DocumentSnapshot snapshot )
      : this.fromMap(snapshot.data() as Map<String, dynamic>,snapshot.reference.id);
}