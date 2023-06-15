import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tawseleh/model/user_model.dart';
import 'package:tawseleh/widgets/custom_appbar.dart';
import 'package:timeago/timeago.dart';
import '../../api/db_api.dart';
import '../../model/chat_head_model.dart';
import '../../model/chat_model.dart';
import '../../utils/constants.dart';
import '../../widgets/profile_image.dart';
import 'search_individual.dart';
import 'chat_screen.dart';

class IndividualChat extends StatefulWidget {
  const IndividualChat({Key? key}) : super(key: key);

  @override
  State<IndividualChat> createState() => _IndividualChatState();
}

class _IndividualChatState extends State<IndividualChat> {


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) =>  SearchIndividual()));
        },
        child: Icon(Icons.message,color: Colors.white,),
      ),
      body: SafeArea(
        child: Column(
          children: [
            CustomAppBar(title: 'My Chats'.tr()),
            Expanded(
              child: FutureBuilder<List<ChatHeadModel>>(
                  future: DBApi.getIndividualChats(context),
                  builder: (context, AsyncSnapshot<List<ChatHeadModel>> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    else {
                      if (snapshot.hasError) {
                        print("error ${snapshot.error}");
                        return Center(
                          child: Text("error :  ${snapshot.error}"),
                        );
                      }
                      else if (snapshot.data!.isEmpty) {

                        return Center(
                          child: Text("No Chats"),
                        );
                      }


                      else {
                        return ListView.builder(
                          itemCount: snapshot.data!.length,
                          itemBuilder: (BuildContext context,int index){
                            return Container(
                              margin: EdgeInsets.symmetric(vertical: 5),
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide( color: textColor.shade100),
                                ),
                              ),
                              child: FutureBuilder<UserModel>(
                                  future: DBApi.getUserData(snapshot.data![index].user1==FirebaseAuth.instance.currentUser!.uid?snapshot.data![index].user2:snapshot.data![index].user1),
                                  builder: (context, AsyncSnapshot<UserModel> usersnap) {
                                    if (usersnap.connectionState == ConnectionState.waiting) {
                                      return Center(
                                        child: CupertinoActivityIndicator(),
                                      );
                                    }
                                    else {
                                      if (usersnap.hasError) {
                                        print("error ${usersnap.error}");
                                        return Center(
                                          child: Text("something went wrong : ${usersnap.error}"),
                                        );
                                      }



                                      else {
                                        return ListTile(
                                          leading:  ProfilePicture(url: usersnap.data!.profilePic),
                                          trailing: SizedBox(
                                            height: 25,
                                            width: 25,
                                            child: FutureBuilder<List<ChatModel>>(
                                                future: DBApi.getUnreadMessageCount(context,snapshot.data![index].id),
                                                builder: (context, AsyncSnapshot<List<ChatModel>> unreadsnap) {
                                                  if (usersnap.connectionState == ConnectionState.waiting) {
                                                    return Container(height: 5,width: 5,);
                                                  }
                                                  else {
                                                    if (usersnap.hasError) {
                                                      print("error ${usersnap.error}");
                                                      return Center(
                                                        child: Text("something went wrong : ${usersnap.error}"),
                                                      );
                                                    }



                                                    else {
                                                      if(unreadsnap.data!=null){
                                                        return unreadsnap.data!.isNotEmpty?CircleAvatar(
                                                          child:Text(unreadsnap.data!.length.toString(),style: TextStyle(fontSize: 12),),
                                                          radius: 10,
                                                          backgroundColor: primaryColor,
                                                        ):Container(height: 6,width: 5,);
                                                      }
                                                      else{
                                                        return Container(height: 6,width: 5,);
                                                      }


                                                    }
                                                  }
                                                }
                                            ),
                                          ),
                                          title: Text(usersnap.data!.firstName),
                                          subtitle: FutureBuilder<ChatModel?>(
                                              future: DBApi.getLastMessage(snapshot.data![index].id),
                                              builder: (context, AsyncSnapshot<ChatModel?> lastChat) {
                                                if (lastChat.connectionState == ConnectionState.waiting) {
                                                  return Container(height: 5,width: 5,);
                                                }
                                                else {
                                                  if (lastChat.hasError) {
                                                    print("last error ${lastChat.error}");
                                                    return Center(
                                                      child: Text("something went wrong : ${lastChat.error}"),
                                                    );
                                                  }



                                                  else {
                                                    if(lastChat.data!=null){
                                                      return Row(
                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        children: [
                                                          if(lastChat.data!.mediaType==MediaType.audio)
                                                            Expanded(
                                                              child: Text('Audio Message',maxLines: 1,style: TextStyle(fontWeight: lastChat.data!.isRead?FontWeight.w400:FontWeight.bold),),
                                                            )
                                                          else if(lastChat.data!.mediaType==MediaType.location)
                                                            Expanded(
                                                              child: Text('Location',maxLines: 1,style: TextStyle(fontWeight: lastChat.data!.isRead?FontWeight.w400:FontWeight.bold),),
                                                            )
                                                          else if(lastChat.data!.mediaType==MediaType.image)
                                                              Expanded(
                                                                child: Text('Image',maxLines: 1,style: TextStyle(fontWeight: lastChat.data!.isRead?FontWeight.w400:FontWeight.bold),),
                                                              )
                                                          else if(lastChat.data!.mediaType==MediaType.plainText)
                                                              Expanded(
                                                                child: Text(lastChat.data!.message,maxLines: 1,style: TextStyle(fontWeight: lastChat.data!.isRead?FontWeight.w400:FontWeight.bold),),
                                                              )
                                                          else
                                                                Expanded(
                                                                  child: Text('',maxLines: 1,style: TextStyle(fontWeight: lastChat.data!.isRead?FontWeight.w400:FontWeight.bold),),
                                                                ),
                                                          Text(format(DateTime.fromMillisecondsSinceEpoch(lastChat.data!.dateTime))),

                                                        ],
                                                      );
                                                    }
                                                    else{
                                                      print('no chat');
                                                      return Container(height: 6,width: 5,);
                                                    }


                                                  }
                                                }
                                              }
                                          ),
                                          onTap: (){
                                            DBApi.changeMessageToRead(snapshot.data![index].id);
                                            Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) =>  ChatScreen(snapshot.data![index].id)));
                                          },
                                        );

                                      }
                                    }
                                  }
                              ),
                            );
                          },
                        );

                      }
                    }
                  }
              ),
            ),
          ],
        ),
      )
    );
  }
}
