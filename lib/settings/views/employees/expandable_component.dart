import 'package:flutter/material.dart';

import '../../utils/utils.dart';

class ExpandableListView extends StatefulWidget {
//  final IconData iconData;
  final ImageProvider iconData;
  final String title;
  final bool isExpanded;
  final int openedAppRowIndex;
  final ValueNotifier openedAppRow;
  final Widget widgetList;

  const ExpandableListView(
      {Key key,
      this.iconData,
      this.title,
      this.isExpanded,
      this.openedAppRowIndex,
      this.openedAppRow,
      this.widgetList})
      : super(key: key);

  @override
  _ExpandableListViewState createState() => _ExpandableListViewState();
}

class _ExpandableListViewState extends State<ExpandableListView> {
//  ValueNotifier openedAppRowSelected;
  bool expandFlag = false;

  listener() {
    setState(() {
      if (widget.openedAppRow.value == widget.openedAppRowIndex) {
        expandFlag = !expandFlag;
      } else {
        expandFlag = false;
      }
    });
  }

  @override
  void initState() {
    super.initState();

//    if(openedAppRowSelected == null) {
//      openedAppRowSelected.value = 999;
//
//      widget.openedAppRow.value = ValueNotifier(0);
//
//    }

    if (widget.openedAppRowIndex == widget.openedAppRow.value) {
      setState(() {
        if (widget.openedAppRow.value == widget.openedAppRowIndex) {
          expandFlag = !expandFlag;
        } else {
          expandFlag = false;
        }
      });

//      setState(() {
////        expandFlag = widget.isExpanded;
//
//        expandFlag =  widget.openedAppRow.value == widget.openedAppRowIndex;
//        widget.openedAppRow.value = widget.openedAppRowIndex;
//      });

//
//
////      openedAppRowSelected.addListener(listener);
//
    }

    print("widget.openedAppRow.value: ${widget.openedAppRow.value}");

    widget.openedAppRow.addListener(listener);
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Container(
        width: Measurements.width - 2,
        child: Column(
          children: <Widget>[
            Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Container(
                    child: Row(
                      children: <Widget>[
//                      Icon(
//                        widget.iconData,
//                        size: 28,
//                      ),
                        widget.iconData != null
                            ? Image(image: widget.iconData)
                            : Container(),
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
                    icon: Icon(expandFlag ? Icons.remove : Icons.add),
                    onPressed: () {
                      print(
                          "widget.openedAppRowIndex: ${widget.openedAppRowIndex}");

                      setState(() {
                        widget.openedAppRow.value = widget.openedAppRowIndex;
                        widget.openedAppRow.notifyListeners();
                      });

                      print(
                          "widget.openedAppRow.value: ${widget.openedAppRow.value}");

//                    setState(() {
//                      expandFlag = !expandFlag;
//
//                      openedAppRowSelected = ValueNotifier(widget.openedAppRowIndex);
//
////                      widget.openedAppRow = ValueNotifier(widget.openedAppRowIndex);
//
//                    });
                    },
                  ),
                ],
              ),
            ),
            ExpandableContainer(expanded: expandFlag, child: widget.widgetList),
            Container(
                color: expandFlag
                    ? Colors.transparent
                    : Colors.white.withOpacity(0.1),
                height: Measurements.height * 0.01,
                child: expandFlag
                    ? Divider(
                        color: Colors.white.withOpacity(0),
                      )
                    : Divider(
                        color: Colors.white,
                      )),
          ],
        ),
      ),
      onTap: () {
        setState(() {
          widget.openedAppRow.value = widget.openedAppRowIndex;
          widget.openedAppRow.notifyListeners();
        });
      },
    );
  }
}

class ExpandableContainer extends StatefulWidget {
  final bool expanded;

  final Widget child;

  ExpandableContainer({
    @required this.child,
    this.expanded = true,
  });

  @override
  createState() => _ExpandableContainerState();
}

class _ExpandableContainerState extends State<ExpandableContainer>
    with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return AnimatedContainer(
      duration: Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      width: screenWidth,
      child: widget.expanded
          ? Container(
              color: Colors.white.withOpacity(0.05),
              child: AnimatedSize(
                duration: Duration(milliseconds: 500),
                curve: Curves.linear,
//                curve: Curves.easeInOut,
                vsync: this,
                child: widget.child,
              ),
            )
          : Container(width: 0, height: 0),
    );
  }
}
