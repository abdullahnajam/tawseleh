import 'package:cloud_firestore/cloud_firestore.dart';

class CityModel{
  String id,name;

  CityModel.fromMap(Map<String,dynamic> map,String key)
      : id=key,
        name = map['name']??'';



  CityModel.fromSnapshot(DocumentSnapshot snapshot )
      : this.fromMap(snapshot.data() as Map<String, dynamic>,snapshot.reference.id);
}