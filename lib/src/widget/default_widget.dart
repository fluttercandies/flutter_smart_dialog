import 'package:flutter/material.dart';

class LoadingWidget extends StatelessWidget {
  const LoadingWidget({Key? key, required this.msg}) : super(key: key);

  ///loading msg
  final String msg;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        //loading animation
        CircularProgressIndicator(
          strokeWidth: 3,
          valueColor: AlwaysStoppedAnimation(Colors.white),
        ),

        //msg
        Container(
          margin: EdgeInsets.only(top: 20),
          child: Text(msg, style: TextStyle(color: Colors.white)),
        ),
      ]),
    );
  }
}

class ToastWidget extends StatelessWidget {
  ToastWidget({Key? key, required this.msg}) : super(key: key);

  ///toast msg
  final String msg;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 30, vertical: 50),
      padding: EdgeInsets.symmetric(horizontal: 25, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text('$msg', style: TextStyle(color: Colors.white)),
    );
  }
}
