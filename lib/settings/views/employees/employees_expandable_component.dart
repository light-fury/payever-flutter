import 'package:flutter/material.dart';

import '../../models/models.dart';
import '../../utils/utils.dart';


class EmployeesExpandableComponent extends StatefulWidget {
  ValueNotifier openedRow;
  Employees roleData;
  bool isOpen = false;
  IconData iconData;
  String title;

  EmployeesExpandableComponent({this.openedRow, this.roleData, this.iconData,
    this.title});

  @override
  createState() => _EmployeesExpandableComponentState();
}

class _EmployeesExpandableComponentState
    extends State<EmployeesExpandableComponent> with TickerProviderStateMixin {
  listener() {
    setState(() {
      if (widget.openedRow.value == 0) {
        widget.isOpen = !widget.isOpen;
      } else {
        widget.isOpen = false;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    widget.openedRow.addListener(listener);
  }

  @override
  Widget build(BuildContext context) {
    Widget getAppPermissionsRow() {
      return Center(
        child: Text("App Permisions"),
      );
    }

    return Container(
      width: Measurements.width - 2,
      child: Column(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.1),
            ),
            child: InkWell(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Container(
//                  child: Text(Language.getProductStrings("sections.main")),
                    child: Row(
                      children: <Widget>[
                        Icon(
                          widget.iconData,
                          size: 28,
                        ),
                        SizedBox(width: 10),
                        Text(
                          widget.title,
                          style: TextStyle(fontSize: 18),
                        ),
                      ],
                    ),
                    padding: EdgeInsets.symmetric(
                        horizontal: Measurements.width * 0.05),
                  ),
                  IconButton(
                    icon: Icon(widget.isOpen ? Icons.remove : Icons.add),
                    onPressed: () {
                      widget.openedRow.notifyListeners();
                      widget.openedRow.value = 0;
                    },
                  ),
                ],
              ),
              onTap: () {
                widget.openedRow.notifyListeners();
                widget.openedRow.value = 0;
              },
            ),
          ),
          AnimatedContainer(
              color: Colors.white.withOpacity(0.05),
//            height: widget.isOpen ? Measurements.height * 0.62 : 0,
//            height: 300,
              duration: Duration(milliseconds: 200),
              child: Container(
                child: widget.isOpen
                    ? AnimatedSize(
                        duration: Duration(milliseconds: 500),
                        curve: Curves.easeInOut,
                        vsync: this,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: Measurements.width * 0.025),
                          color: Colors.black.withOpacity(0.05),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Container(
//                                  height: Measurements.height * 0.3,
                                    child: getAppPermissionsRow(),
                                  ),
//                    Column(
//                      mainAxisAlignment: MainAxisAlignment.center,
//                      children: <Widget>[
//                      ],
//                    )
                                ],
                              )
                            ],
                          ),
                        ),
                      )
                    : Container(width: 0, height: 0),
              )),
          Container(
              color: widget.isOpen
                  ? Colors.transparent
                  : Colors.white.withOpacity(0.1),
              height: Measurements.height * 0.01,
              child: widget.isOpen
                  ? Divider(
                      color: Colors.white.withOpacity(0),
                    )
                  : Divider(
                      color: Colors.white,
                    )),
        ],
      ),
    );
  }
}
