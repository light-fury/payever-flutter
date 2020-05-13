import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../view_models/view_models.dart';
import '../utils/utils.dart';
import 'pos_order_section.dart';

class POSCart extends StatefulWidget {
  final PosStateModel parts;

  POSCart({@required this.parts});

  @override
  createState() => _POSCartState();
}

class _POSCartState extends State<POSCart> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        brightness: Brightness.light,
        leading: IconButton(
          icon: Icon(
            Icons.close,
            color: Colors.black,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        centerTitle: true,
        title: SvgPicture.asset(
          "assets/images/payeverlogoandname.svg",
          color: Colors.black,
        ),
        backgroundColor: Colors.white,
      ),
      body: CartBody(
        parts: widget.parts,
      ),
    );
  }
}

class CartBody extends StatefulWidget {
  final Color textColor = Colors.black.withOpacity(0.7);
  final PosStateModel parts;

//  final PosScreenParts parts;

  CartBody({@required this.parts});

  final List<DropdownMenuItem<int>> qtys = List();

  @override
  _CartBodyState createState() => _CartBodyState();
}

class _CartBodyState extends State<CartBody> {
  @override
  void initState() {
    super.initState();
//    widget.parts.openSection.addListener(listener);
    for (int i = 1; i < 100; i++) {
      final number = new DropdownMenuItem(
        value: i,
        child: Text("$i"),
      );
      widget.qtys.add(number);
    }
  }

  listener() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        // child: ListView.builder(
        //   //itemCount: widget.parts.currentCheckout.sections.length,
        //   itemCount: 2,
        //   itemBuilder: (BuildContext context, int index) {
        //     print(widget.parts.currentCheckout.sections[index].code);
        //     if(widget.parts.currentCheckout.sections[index].code == "order"){
        //       return SectionWidget(index: index,currentSection: sectionPicker(widget.parts.currentCheckout.sections[index].code,index),title: widget.parts.currentCheckout.sections[index].code.replaceAll("_", " ").toUpperCase(), parts: widget.parts,);
        //     }else{
        //       return Container();
        //     }
        //   },
        // ),
        child: ListView(
          children: <Widget>[
            SectionWidget(
              index: 0,
              currentSection: OrderSection(
                parts: widget.parts,
                index: 0,
              ),
              title: "order".toUpperCase(),
              parts: widget.parts,
            ),
          ],
        ),
      ),
    );
  }

  Widget sectionPicker(String title, int index) {
    switch (title) {
      case "order":
        return OrderSection(
          parts: widget.parts,
          index: 0,
        );
        break;
      default:
        return Text("");
    }
  }
}

class SectionWidget extends StatefulWidget {
  final PosStateModel parts;
  final Widget currentSection;
  final String title;
  final int index;

  SectionWidget(
      {@required this.parts,
      @required this.index,
      @required this.currentSection,
      @required this.title});

  @override
  _SectionWidgetState createState() => _SectionWidgetState();
}

class _SectionWidgetState extends State<SectionWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: Measurements.width * 0.05),
      child: Column(
        children: <Widget>[
          InkWell(
            onTap: () {
              if (widget.parts.openSection > widget.index)
                widget.parts.openSection = widget.index;
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Container(
                    height: Measurements.height * 0.05,
                    alignment: Alignment.center,
                    child: Text(
                      widget.title,
                      style: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.w500),
                    )),
                //line under black no white
                Icon(
                  widget.parts.openSection == widget.index
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: widget.parts.openSection < widget.index
                      ? Colors.white
                      : Colors.white,
                )
              ],
            ),
          ),
          Container(
            child: widget.parts.openSection == widget.index
                ? AnimatedContainer(
                    child: widget.currentSection,
                    duration: Duration(milliseconds: 100),
                  )
                : Container(),
          ),
          //Divider(color:Colors.black.withOpacity(0.7)),
        ],
      ),
    );
  }
}
