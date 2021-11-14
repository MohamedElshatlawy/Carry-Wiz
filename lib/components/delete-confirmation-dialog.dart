import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../localization/language_constants.dart';

class DeleteConfirmationDialog extends StatelessWidget {
  final Function? okFunction;

  DeleteConfirmationDialog({this.okFunction});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: _buildChild(context),
    );
  }

  _buildChild(BuildContext context) => Container(
        height: 100,
        decoration: BoxDecoration(
            color: Colors.redAccent,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.all(Radius.circular(12))),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              getTranslatedValues(context, 'delete_alert'),
              style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 8,
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                FlatButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(getTranslatedValues(context, 'No')),
                  textColor: Colors.white,
                ),
                SizedBox(
                  width: 8,
                ),
                FlatButton(
                  onPressed: () => okFunction,
                  child: Text(getTranslatedValues(context, 'Yes')),
                  color: Colors.white,
                  textColor: Colors.redAccent,
                )
              ],
            )
          ],
        ),
      );
}
