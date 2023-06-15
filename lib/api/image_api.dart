import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sn_progress_dialog/progress_dialog.dart';

class ImageHandler{

  static Future uploadFileToFirebase(BuildContext context,File imageFile,String documentId) async {

    Reference firebaseStorageRef = FirebaseStorage.instance.ref().child('media/${DateTime.now().millisecondsSinceEpoch}');
    UploadTask uploadTask = firebaseStorageRef.putFile(imageFile);
    TaskSnapshot taskSnapshot = await uploadTask;
    taskSnapshot.ref.getDownloadURL().then((value)async {
      print("audio message : $value");
      await FirebaseFirestore.instance.collection('social_chat').doc(documentId).update({
        "message":value,
      });
    });
  }

  static Future<String> uploadImageToFirebase(BuildContext context,imageFile) async {
    String url="";
    final ProgressDialog pr = ProgressDialog(context: context);
    pr.show(max: 100, msg: 'Please Wait',barrierDismissible: false);
    Reference firebaseStorageRef = FirebaseStorage.instance.ref().child('uploads/${DateTime.now().millisecondsSinceEpoch}');
    UploadTask uploadTask = firebaseStorageRef.putFile(imageFile!);
    TaskSnapshot taskSnapshot = await uploadTask;
    await taskSnapshot.ref.getDownloadURL().then((value)async {
      url=value;
      print("func $url");
      pr.close();
    }).onError((error, stackTrace){
      pr.close();
      CoolAlert.show(
        context: context,
        type: CoolAlertType.error,
        text: error.toString(),
      );
    });
    return url;
  }

  static Future<File?> chooseGallery() async{
    XFile? image=await ImagePicker().pickImage(source: ImageSource.gallery);
    if(image!=null){
      return File(image.path);
    }
    else{
      return null;
    }

  }
  static Future<File?> chooseCamera() async{
    XFile? image=await ImagePicker().pickImage(source: ImageSource.camera);
    if(image!=null){
      return File(image.path);
    }
    else{
      return null;
    }
  }
  static Future imageModalBottomSheet(context,url) {
    return showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return Container(
            child: Wrap(
              children: <Widget>[
                ListTile(
                    leading: const Icon(Icons.cloud_upload),
                    title: const Text('Upload file'),
                    onTap: () => {
                      ImageHandler.chooseGallery().then((value) async{
                        if(value!=null){
                          print("not null");
                          url=await uploadImageToFirebase(context, value);


                        }
                        Navigator.pop(context);
                      })
                    }),
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: const Text('Take a photo'),
                  onTap: () => {
                    ImageHandler.chooseCamera().then((value) async{
                      if(value!=null){
                       url=await ImageHandler.uploadImageToFirebase(context, value);

                      }

                      Navigator.pop(context);
                    })
                  },
                ),
              ],
            ),
          );
        });
  }


}