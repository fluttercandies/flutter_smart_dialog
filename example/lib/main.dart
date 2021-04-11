import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SmartDialogPage(),
      builder: (BuildContext context, Widget? child) {
        return FlutterSmartDialog(child: child);
      },
    );
  }
}

class SmartDialogPage extends StatelessWidget {
  final List<BtnInfo> items = [
    BtnInfo(title: 'showToast', tag: 'showToast'),
    BtnInfo(title: 'showLoading', tag: 'showLoading'),
    BtnInfo(title: '底部Dialog', tag: 'bottomDialog'),
    BtnInfo(title: '顶部Dialog', tag: 'topDialog'),
    BtnInfo(title: '靠左Dialog', tag: 'leftDialog'),
    BtnInfo(title: '靠右Dialog', tag: 'rightDialog'),
    BtnInfo(title: '穿透Dialog', tag: 'penetrateDialog'),
  ];

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      isTwiceBack: true,
      backgroundColor: Colors.white,
      appBar: AppBar(title: Text('SmartDialog')),
      body: FunctionItems(
        items: items,
        constraints: BoxConstraints(minWidth: 100, minHeight: 36),
        onItem: (String tag) {
          showFun(context, tag);
        },
      ),
    );
  }

  ///测试功能模块
  void showFun(context, tag) async {
    switch (tag) {
      case 'showToast':
        SmartDialog.showToast('toast弹窗测试toast弹窗测试toast');
        break;
      case 'showLoading':
        SmartDialog.showLoading();
        await Future.delayed(Duration(seconds: 2));
        SmartDialog.dismiss();
        break;
      case 'bottomDialog':
        SmartDialog.show(
          alignmentTemp: Alignment.bottomCenter,
          clickBgDismissTemp: true,
          onDismiss: () {
            print('==============test callback==============');
          },
          widget: _contentWidget(maxHeight: 400),
        );
        break;
      case 'topDialog':
        SmartDialog.show(
          alignmentTemp: Alignment.topCenter,
          clickBgDismissTemp: true,
          widget: _contentWidget(maxHeight: 300),
        );
        break;
      case 'leftDialog':
        SmartDialog.show(
          alignmentTemp: Alignment.centerLeft,
          clickBgDismissTemp: true,
          widget: _contentWidget(maxWidth: 260),
        );
        break;
      case 'rightDialog':
        SmartDialog.show(
          alignmentTemp: Alignment.centerRight,
          clickBgDismissTemp: true,
          widget: _contentWidget(maxWidth: 260),
        );
        break;
      case 'penetrateDialog':
        SmartDialog.show(
          alignmentTemp: Alignment.bottomCenter,
          clickBgDismissTemp: true,
          isPenetrateTemp: true,
          widget: _contentWidget(maxHeight: 400),
        );
        break;
    }
  }

  Widget _contentWidget({
    double maxWidth = double.infinity,
    double maxHeight = double.infinity,
  }) {
    return Container(
      constraints: BoxConstraints(maxHeight: maxHeight, maxWidth: maxWidth),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 20, spreadRadius: 10)
        ],
      ),
      child: ListView.builder(
        itemCount: 30,
        itemBuilder: (BuildContext context, int index) {
          return Column(children: [
            //内容
            ListTile(
              leading: Icon(Icons.bubble_chart),
              title: Text('标题---------------$index'),
            ),

            //分割线
            Container(height: 1, color: Colors.black.withOpacity(0.1)),
          ]);
        },
      ),
    );
  }
}

///按钮信息
class BtnInfo {
  BtnInfo({
    this.title,
    this.tag,
  });

  ///按钮名称
  String? title;

  ///按钮标识
  String? tag;
}

///回调一个参数
typedef ParamSingleCallback = void Function(String data);

class FunctionItems extends StatelessWidget {
  FunctionItems({
    required this.items,
    required this.onItem,
    this.constraints = const BoxConstraints(minWidth: 150, minHeight: 36.0),
    this.padding = const EdgeInsets.all(30),
  });

  ///数据源
  final List<BtnInfo> items;

  ///监听点击的按钮
  final ParamSingleCallback onItem;

  ///约束布局
  final BoxConstraints constraints;

  ///边距
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return _buildBg(
      children: items.map((e) {
        return btnFunction(
          onItem: onItem,
          data: e,
          constraints: constraints,
        );
      }).toList(),
    );
  }

  ///整体背景
  Widget _buildBg({required List<Widget> children}) {
    return Container(
      padding: padding,
      child: SingleChildScrollView(
        child: Material(
          color: Colors.white,
          child: Wrap(
            spacing: 20,
            runSpacing: 20,
            children: children,
          ),
        ),
      ),
    );
  }
}

///功能性按钮
Widget btnFunction({
  required ParamSingleCallback onItem,
  data,
  required BoxConstraints constraints,
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

typedef ScaffoldParamVoidCallback = void Function();

class BaseScaffold extends StatefulWidget {
  const BaseScaffold({
    Key? key,
    this.appBar,
    this.body,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.floatingActionButtonAnimator,
    this.persistentFooterButtons,
    this.drawer,
    this.endDrawer,
    this.bottomNavigationBar,
    this.bottomSheet,
    this.backgroundColor,
    this.resizeToAvoidBottomInset,
    this.primary = true,
    this.drawerDragStartBehavior = DragStartBehavior.start,
    this.extendBody = false,
    this.extendBodyBehindAppBar = false,
    this.drawerScrimColor,
    this.drawerEdgeDragWidth,
    this.drawerEnableOpenDragGesture = true,
    this.endDrawerEnableOpenDragGesture = true,
    this.isTwiceBack = false,
    this.isCanBack = true,
    this.onBack,
  })  : assert(primary != null),
        assert(extendBody != null),
        assert(extendBodyBehindAppBar != null),
        assert(drawerDragStartBehavior != null),
        super(key: key);

  ///系统Scaffold的属性
  final bool extendBody;
  final bool extendBodyBehindAppBar;
  final PreferredSizeWidget? appBar;
  final Widget? body;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final FloatingActionButtonAnimator? floatingActionButtonAnimator;
  final List<Widget>? persistentFooterButtons;
  final Widget? drawer;
  final Widget? endDrawer;
  final Color? drawerScrimColor;
  final Color? backgroundColor;
  final Widget? bottomNavigationBar;
  final Widget? bottomSheet;
  final bool? resizeToAvoidBottomInset;
  final bool primary;
  final DragStartBehavior drawerDragStartBehavior;
  final double? drawerEdgeDragWidth;
  final bool drawerEnableOpenDragGesture;
  final bool endDrawerEnableOpenDragGesture;

  ///增加的属性
  ///点击返回按钮提示是否退出页面,快速点击俩次才会退出页面
  final bool isTwiceBack;

  ///是否可以返回
  final bool isCanBack;

  ///监听返回事件
  final ScaffoldParamVoidCallback? onBack;

  @override
  _BaseScaffoldState createState() => _BaseScaffoldState();
}

class _BaseScaffoldState extends State<BaseScaffold> {
  DateTime? _lastPressedAt; //上次点击时间

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        appBar: widget.appBar,
        body: widget.body,
        floatingActionButton: widget.floatingActionButton,
        floatingActionButtonLocation: widget.floatingActionButtonLocation,
        floatingActionButtonAnimator: widget.floatingActionButtonAnimator,
        persistentFooterButtons: widget.persistentFooterButtons,
        drawer: widget.drawer,
        endDrawer: widget.endDrawer,
        bottomNavigationBar: widget.bottomNavigationBar,
        bottomSheet: widget.bottomSheet,
        backgroundColor: widget.backgroundColor,
        resizeToAvoidBottomInset: widget.resizeToAvoidBottomInset,
        primary: widget.primary,
        drawerDragStartBehavior: widget.drawerDragStartBehavior,
        extendBody: widget.extendBody,
        extendBodyBehindAppBar: widget.extendBodyBehindAppBar,
        drawerScrimColor: widget.drawerScrimColor,
        drawerEdgeDragWidth: widget.drawerEdgeDragWidth,
        drawerEnableOpenDragGesture: widget.drawerEnableOpenDragGesture,
        endDrawerEnableOpenDragGesture: widget.endDrawerEnableOpenDragGesture,
      ),
      onWillPop: dealWillPop,
    );
  }

  ///控件返回按钮
  Future<bool> dealWillPop() async {
    if (widget.onBack != null) {
      widget.onBack!();
    }

    //处理弹窗问题
    if (SmartDialog.instance.config.isExist) {
      SmartDialog.dismiss();
      return false;
    }

    //如果不能返回，后面的逻辑就不走了
    if (!widget.isCanBack) {
      return false;
    }

    if (widget.isTwiceBack) {
      if (_lastPressedAt == null ||
          DateTime.now().difference(_lastPressedAt!) > Duration(seconds: 1)) {
        //两次点击间隔超过1秒则重新计时
        _lastPressedAt = DateTime.now();

        //弹窗提示
        SmartDialog.showToast("再点一次退出");
        return false;
      }
      return true;
    } else {
      return true;
    }
  }
}
