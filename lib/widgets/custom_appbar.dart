import 'package:flutter/material.dart';

import 'back_button.dart';

class CustomAppBar extends StatelessWidget {
  String title;

  CustomAppBar({required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      padding: const EdgeInsets.all(10),
      child: Stack(

        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: CustomBackButton(),
          ),
          Align(
            alignment: Alignment.center,
            child: Padding(
              padding: EdgeInsets.only(left: 20,right: 20),
              child: Text (title,style: TextStyle(
                  color: Colors.black,
                  fontSize: 22,
                  fontWeight: FontWeight.w800
              ),
              ),
            ),
          ),


        ],
      ),
    );
  }
}
