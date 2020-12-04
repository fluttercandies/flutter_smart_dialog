import 'package:example/bean/btn_info.dart';
import 'package:flutter/material.dart';

///回调一个参数
typedef ParamSingleCallback<D> = void Function(D data);

class FunctionItems extends StatelessWidget {
  FunctionItems({
    this.items,
    this.onItem,
    this.constraints = const BoxConstraints(minWidth: 150, minHeight: 36.0),
    this.padding = const EdgeInsets.all(30),
  });

  ///数据源
  final List<BtnInfo> items;

  ///监听点击的按钮
  final ParamSingleCallback<String> onItem;

  ///约束布局
  final BoxConstraints constraints;

  ///边距
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return _function();
  }

  ///功能主体
  Widget _function() {
    return _buildBg(
      child: Wrap(
        spacing: 20,
        runSpacing: 20,
        children: items.map((e) {
          return btnFunction(
            onItem: onItem,
            data: e,
            constraints: constraints,
          );
        }).toList(),
      ),
    );
  }

  ///整体背景
  Widget _buildBg({child}) {
    return Container(
      padding: padding,
      child: SingleChildScrollView(
        child: Material(
          color: Colors.white,
          child: child,
        ),
      ),
    );
  }
}

///功能性按钮
Widget btnFunction({
  ParamSingleCallback<String> onItem,
  data,
  BoxConstraints constraints,
}) {
  return Container(
    padding: EdgeInsets.all(15),
    child: RawMaterialButton(
      fillColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      constraints: constraints,
      elevation: 5,
      onPressed: () {
        onItem(data.tag);
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: 15,
          horizontal: 20,
        ),
        child: Text(
          data.title,
        ),
      ),
    ),
  );
}
