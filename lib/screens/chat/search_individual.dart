import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tawseleh/widgets/profile_image.dart';
import '../../api/db_api.dart';
import '../../model/user_model.dart';
import '../../provider/user_provider.dart';
import '../../utils/constants.dart';
import 'chat_screen.dart';

class SearchIndividual extends StatefulWidget {
  const SearchIndividual({Key? key}) : super(key: key);

  @override
  _SearchIndividualState createState() => _SearchIndividualState();
}

class _SearchIndividualState extends State<SearchIndividual> {
  var _searchController=TextEditingController();
  String  query='';
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<UserDataProvider>(context, listen: false);
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Container(
              height: AppBar().preferredSize.height,
              color: primaryColor,
              child: Row(
                children: [
                  InkWell(
                    onTap: (){
                      Navigator.pop(context);
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(Icons.arrow_back_ios,color: Colors.white,),
                    ),
                  ),
                  Expanded(
                    child:  Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter some text';
                          }
                          return null;
                        },
                        onChanged: (value){
                          setState(() {
                            query=value;
                          });
                        },

                        controller: _searchController,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.all(15),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(7.0),
                            borderSide: BorderSide(
                              color: Colors.transparent,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(7.0),
                            borderSide: BorderSide(
                                color: Colors.transparent,
                                width: 0.5
                            ),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(7.0),
                            borderSide: BorderSide(
                              color: Colors.transparent,
                              width: 0.5,
                            ),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          hintText: 'Search'.tr(),
                          // If  you are using latest version of flutter then lable text and hint text shown like this
                          // if you r using flutter less then 1.20.* then maybe this is not working properly
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(Icons.search,color: Colors.white,),
                  )
                ],
              ),
            ),
            Expanded(
              child: FutureBuilder<List<UserModel>>(
                  future: DBApi.getSearchedUsers(context,_searchController.text),
                  builder: (context, AsyncSnapshot<List<UserModel>> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Container(
                        width: MediaQuery.of(context).size.width,
                        height: 50,
                        alignment: Alignment.center,
                        child: CupertinoActivityIndicator(),
                      );
                    }
                    else {
                      if (snapshot.hasError) {
                        print("error ${snapshot.error}");
                        return Container(
                          color: primaryColor,
                          child: Center(
                            child: Text("something went wrong"),
                          ),
                        );
                      }

                      if (snapshot.data!.isEmpty) {
                        return Center(
                          child: Text('No Users'.tr()),
                        );
                      }

                      else {
                        return ListView.builder(
                          itemCount: snapshot.data!.length,
                          itemBuilder: (BuildContext context, int index){
                            return Container(
                                margin: EdgeInsets.symmetric(vertical: 5),
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide( color: textColor.shade100),
                                  ),
                                ),
                                child: ListTile(
                                  leading:  ProfilePicture(url: snapshot.data![index].profilePic,),
                                  trailing: InkWell(
                                    onTap: (){
                                    },
                                    child: Icon(Icons.arrow_forward_ios_rounded, size: 15),
                                  ),
                                  title: Text('${snapshot.data![index].firstName} ${snapshot.data![index].lastName}'),
                                  onTap: ()async{
                                    bool exists=false;

                                    await FirebaseFirestore.instance.collection('chat_head').get().then((QuerySnapshot querySnapshot) {
                                      querySnapshot.docs.forEach((doc) {
                                        if(checkIfChatExists(doc.reference.id,FirebaseAuth.instance.currentUser!.uid,snapshot.data![index].userId)){
                                          exists=true;
                                          print('test ${snapshot.data![index].userId}');
                                          Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) =>  ChatScreen(doc.reference.id)));
                                        }
                                      });
                                    });
                                    if(!exists){
                                      await FirebaseFirestore.instance.collection('chat_head').doc("${FirebaseAuth.instance.currentUser!.uid}_${snapshot.data![index].userId}").set({
                                        "user1":FirebaseAuth.instance.currentUser!.uid,
                                        "user2":snapshot.data![index].userId,
                                        "lastCounter":0,
                                        "serverTime":FieldValue.serverTimestamp(),
                                        "timestamp":DateTime.now().millisecondsSinceEpoch,
                                      });
                                      Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) =>  ChatScreen("${FirebaseAuth.instance.currentUser!.uid}_${snapshot.data![index].userId}")));

                                    }
                                  },
                                )
                            );
                          },
                        );

                      }
                    }
                  }
              ),
            ),
            /*Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('users')
                    .where("phone",isNotEqualTo: provider.userData!.phone).snapshots(),
                builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError) {
                    print(snapshot.error.toString());
                    return Text('Something went wrong');
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }


                  if (snapshot.data!.size==0) {
                    return Center(
                      child: Text("No Users"),
                    );
                  }
                  if(snapshot.hasData){

                  }
                  return ListView(
                    padding: EdgeInsets.only(top: 10),
                    shrinkWrap: true,
                    children: snapshot.data!.docs.map((DocumentSnapshot document) {
                      Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
                      UserModel model=UserModel.fromMap(data,document.reference.id);
                      if('${model.firstName} ${model.lastName}'.toString().toLowerCase().contains(_searchController.text.toString().toLowerCase())) {
                        return Container(
                        margin: EdgeInsets.symmetric(vertical: 5),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide( color: textColor.shade100),
                          ),
                        ),
                        child: ListTile(
                          leading:  ProfilePicture(url: model.profilePic,),
                          trailing: InkWell(
                            onTap: (){
                            },
                            child: Icon(Icons.arrow_forward_ios_rounded, size: 15),
                          ),
                          title: Text('${model.firstName} ${model.lastName}'),
                          onTap: ()async{
                            bool exists=false;
                            await FirebaseFirestore.instance.collection('chat_head').get().then((QuerySnapshot querySnapshot) {
                              querySnapshot.docs.forEach((doc) {
                                if(checkIfChatExists(doc.reference.id,FirebaseAuth.instance.currentUser!.uid,model.userId)){
                                  exists=true;
                                  Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) =>  ChatScreen(doc.reference.id)));
                                }
                              });
                            });
                            if(!exists){
                              await FirebaseFirestore.instance.collection('chat_head').doc("${FirebaseAuth.instance.currentUser!.uid}_${model.userId}").set({
                                "user1":FirebaseAuth.instance.currentUser!.uid,
                                "user2":model.userId,
                                "timestamp":DateTime.now().millisecondsSinceEpoch,
                              });
                              Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) =>  ChatScreen("${FirebaseAuth.instance.currentUser!.uid}_${model.userId}")));

                            }
                          },
                        )
                      );
                      } else {
                        return Container();
                      }
                    }).toList(),
                  );
                },
              ),
            ),*/



          ],
        ),
      ),
    );
  }
}
