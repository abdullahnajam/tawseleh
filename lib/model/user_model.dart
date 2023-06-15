import 'package:cloud_firestore/cloud_firestore.dart';
class UserModel{
  String userId,phone,password,status,token;
  String firstName,lastName,profilePic,gender;
  List blockList;




  UserModel.fromMap(Map<String,dynamic> map,String key)
      : userId=key,
        phone = map['phone']??"",
        password = map['password']??"",
        gender = map['gender']??"Male",
        status = map['status']??"",
        firstName = map['firstName']??"",
        lastName = map['lastName']??"",
        blockList = map['blockList']??[],
        profilePic = map['profilePic']??"",
        token = map['token']??"";



  UserModel.fromSnapshot(DocumentSnapshot snapshot )
      : this.fromMap(snapshot.data() as Map<String, dynamic>,snapshot.reference.id);
}