import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/src/kit/view_utils.dart';

class LoadingWidget extends StatelessWidget {
  const LoadingWidget({Key? key, required this.msg}) : super(key: key);

  ///loading msg
  final String msg;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
      decoration: BoxDecoration(
        color: ThemeStyle.backgroundColor,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        //loading animation
        CircularProgressIndicator(
          strokeWidth: 3,
          valueColor: AlwaysStoppedAnimation(ThemeStyle.textColor),
        ),

        //msg
        Container(
          margin: const EdgeInsets.only(top: 20),
          child: Text(msg, style: TextStyle(color: ThemeStyle.textColor)),
        ),
      ]),
    );
  }
}
