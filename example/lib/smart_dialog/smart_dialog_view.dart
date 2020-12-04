import 'package:example/base/base_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'smart_dialog_cubit.dart';
import 'widget/function_items.dart';

class SmartDialogPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => SmartDialogCubit(),
      child:
          BlocBuilder<SmartDialogCubit, SmartDialogState>(builder: _buildBody),
    );
  }

  Widget _buildBody(BuildContext context, SmartDialogState state) {
    return BaseScaffold(
      isTwiceBack: true,
      backgroundColor: Colors.white,
      appBar: AppBar(title: Text('SmartDialog')),
      body: FunctionItems(
        items: state.items,
        constraints: BoxConstraints(minWidth: 100, minHeight: 36),
        onItem: (String tag) {
          BlocProvider.of<SmartDialogCubit>(context).showFun(context, tag);
        },
      ),
    );
  }
}
