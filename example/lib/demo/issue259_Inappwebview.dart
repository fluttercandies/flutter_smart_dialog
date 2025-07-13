// import 'package:flutter/material.dart';
// import 'package:flutter_inappwebview/flutter_inappwebview.dart';
// import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
//
// void main() {
//   runApp(MaterialApp(
//     navigatorObservers: [FlutterSmartDialog.observer],
//     builder: FlutterSmartDialog.init(),
//     home: const MyApp(),
//   ));
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Test"),
//       ),
//       body: Center(
//         child: Builder(builder: (ctx) {
//           return ElevatedButton(
//             onPressed: () => showWebDialog(ctx),
//             child: const Text("Click"),
//           );
//         }),
//       ),
//     );
//   }
//
//   void showWebDialog(BuildContext context) {
//     SmartDialog.show(
//       clickMaskDismiss: true,
//       alignment: Alignment.bottomCenter,
//       builder: (context) => Container(
//         height: 400,
//         padding: const EdgeInsets.symmetric(horizontal: 12),
//         child: InAppWebView(
//           initialData: InAppWebViewInitialData(
//             data: _buildHtmlContent(''),
//             mimeType: 'text/html',
//             encoding: 'utf-8',
//           ),
//         ),
//       ),
//     );
//   }
//
//   String _buildHtmlContent(String content) {
//     return '''
//       <!DOCTYPE html>
//       <html>
//         <head>
//           <meta name="viewport" content="width=device-width, initial-scale=1.0">
//           <style>
//             body {
//               margin: 0;
//               padding: 0;
//               font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
//               line-height: 1.5;
//               color: #333;
//             }
//             img {
//               max-width: 100%;
//               height: auto;
//             }
//           </style>
//         </head>
//         <body>
//           $content
//         </body>
//       </html>
//     ''';
//   }
// }
