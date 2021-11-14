// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import '../localization/language_constants.dart';
//
// class ShowAlertDialog extends StatelessWidget {
//   final String title;
//   final String content;
//   final String buttonText;
//   final BuildContext context2;
//
//   ShowAlertDialog(
//       {required this.context2,
//       required this.title,
//       required this.content,
//       required this.buttonText});
//
//   @override
//   Widget build(context2) {
//     // flutter defined function
//     showDialog(
//       context: context2,
//       builder: (context2) {
//         // return object of type Dialog
//         return AlertDialog(
//           title: Text(title),
//           content: Text(content),
//           actions: <Widget>[
//             // usually buttons at the bottom of the dialog
//             FlatButton(
//               child: Text(buttonText),
//               onPressed: () {
//                 Navigator.of(context2).pop();
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }
// }
//
// void _showDeleteDialog(
//     BuildContext context, String content, Function okFunction) {
//   // flutter defined function
//   showDialog(
//     context: context,
//     builder: (BuildContext context) {
//       // return object of type Dialog
//       return AlertDialog(
//         title: Text(getTranslatedValues(context, 'delete_package_request')),
//         content: Text(content),
//         contentTextStyle: TextStyle(color: Colors.red),
//         actions: <Widget>[
//           // usually buttons at the bottom of the dialog
//           FlatButton(
//             child: Text(getTranslatedValues(context, 'ok')),
//             onPressed: () {
//               okFunction();
//               Navigator.of(context).pop();
//             },
//             textColor: Colors.red,
//           ),
//           FlatButton(
//             child: Text(getTranslatedValues(context, 'cancel')),
//             onPressed: () {
//               Navigator.of(context).pop();
//             },
//             textColor: Colors.red,
//           ),
//         ],
//       );
//     },
//   );
// }
// // class _ShowAlertDialogState extends State<ShowAlertDialog> {
// //   @override
// //   Widget build(BuildContext context) {
// //     // TODO: implement build
// //     return null;
// //   }
//
// // }
