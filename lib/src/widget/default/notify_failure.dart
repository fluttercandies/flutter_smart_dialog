import 'package:flutter/material.dart';

import '../../kit/view_utils.dart';

class NotifyFailure extends StatelessWidget {
  const NotifyFailure({
    Key? key,
    required this.msg,
  }) : super(key: key);

  final String msg;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: ThemeStyle.backgroundColor,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.close, size: 22, color: ThemeStyle.textColor),
        Container(
          margin: const EdgeInsets.only(top: 5),
          child: Text(msg, style: TextStyle(color: ThemeStyle.textColor)),
        ),
      ]),
    );
  }
}
