import 'package:flutter/material.dart';

import '../utils/utils.dart';
import 'new_product.dart';

class ButtonRow extends StatefulWidget {
  final ValueNotifier openedRow;
  final NewProductScreenParts parts;

  ButtonRow(this.openedRow, this.parts);

  @override
  _ButtonRowState createState() => _ButtonRowState();
}

class _ButtonRowState extends State<ButtonRow> {
  bool service = false;
  bool digital = false;
  bool physical = true;

  @override
  void initState() {
    super.initState();
    print(widget.parts.type);
    if (!widget.parts.editMode)
      widget.parts.type = "physical";
    else {
      service = (widget.parts.type == "service");
      digital = (widget.parts.type == "digital");
      physical = (widget.parts.type == "physical");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        RaisedButton(
          elevation: 0,
          // widget.service?0:0.1,
          highlightElevation: 0,
          color: !service
              ? Colors.black.withOpacity(0.1)
              : Colors.white.withOpacity(0.2),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  bottomLeft: Radius.circular(20))),
          child: Text(
            Language.getProductStrings("category.type.service"),
            style: TextStyle(fontSize: AppStyle.fontSizeButtonTabSelect()),
          ),
          onPressed: () {
            setState(() {
              widget.parts.type = "service";
              service = true;
              digital = false;
              physical = false;
            });
          },
        ),
        Padding(
          padding: EdgeInsets.only(left: 1),
        ),
        RaisedButton(
          elevation: 0,
          // widget.digital?0:0.01,
          highlightElevation: 0,
          color: !digital
              ? Colors.black.withOpacity(0.1)
              : Colors.white.withOpacity(0.2),
          child: Text(
            Language.getProductStrings("category.type.digital"),
            style: TextStyle(fontSize: AppStyle.fontSizeButtonTabSelect()),
          ),
          onPressed: () {
            setState(() {
              widget.parts.type = "digital";
              service = false;
              digital = true;
              physical = false;
            });
          },
        ),
        Padding(
          padding: EdgeInsets.only(left: 1),
        ),
        RaisedButton(
          elevation: 0,
          // widget.physical?0:0.1,
          highlightElevation: 0,
          color: !physical
              ? Colors.black.withOpacity(0.1)
              : Colors.white.withOpacity(0.2),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                  topRight: Radius.circular(20),
                  bottomRight: Radius.circular(20))),
          child: Text(
            Language.getProductStrings("category.type.physical"),
            style: TextStyle(fontSize: AppStyle.fontSizeButtonTabSelect()),
          ),
          onPressed: () {
            setState(() {
              widget.parts.type = "physical";
              service = false;
              digital = false;
              physical = true;
            });
          },
        )
      ],
    );
  }
}
