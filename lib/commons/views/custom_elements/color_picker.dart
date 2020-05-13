import 'package:flutter/material.dart';

class ColorButtonContainer extends StatefulWidget {
  final Color borderColor = Color(0XFF0084ff);
  final Color displayColor;
  final double size;
  final int index;
  final ColorButtonController controller;

  ColorButtonContainer(
      {@required this.size,
      @required this.displayColor,
      this.controller,
      this.index});

  @override
  createState() => _ColorButtonContainerState();
}

class _ColorButtonContainerState extends State<ColorButtonContainer> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: PhysicalModel(
        shadowColor: widget.displayColor,
        color: widget.index == widget.controller.currentIndex.value
            ? widget.borderColor
            : Colors.white,
        borderRadius: BorderRadius.circular(widget.size),
        child: Container(
          padding: EdgeInsets.all(1),
          child: PhysicalModel(
              borderRadius: BorderRadius.circular(widget.size),
              color: Colors.white,
              child:
                  ColorCircle(color: widget.displayColor, size: widget.size)),
        ),
      ),
      onTap: () {
        setState(() {
          widget.controller.currentIndex.value = widget.index;
        });
      },
    );
  }
}

class ColorCircle extends StatelessWidget {
  final Color color;
  final num size;

  ColorCircle({@required this.color, @required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(2),
      child: Container(
        height: size,
        width: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
        ),
      ),
    );
  }
}

class ColorButtonGrid extends StatefulWidget {
  final num size;
  final ColorButtonController controller;
  final List<Color> colors;

  ColorButtonGrid(
      {@required this.size, @required this.controller, @required this.colors});

  @override
  createState() => _ColorButtonGridState();
}

class _ColorButtonGridState extends State<ColorButtonGrid> {
  int quantity;
  List<ColorButtonContainer> colorVariants = List();

  listener() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    widget.controller.currentIndex.addListener(listener);
  }

  @override
  Widget build(BuildContext context) {
    colorVariants.clear();
    int index = 0;
    widget.colors.forEach((color) {
      colorVariants.add(ColorButtonContainer(
        size: widget.size,
        controller: widget.controller,
        displayColor: color,
        index: index,
      ));
      index++;
    });
    return Wrap(
      spacing: widget.size / 4,
      alignment: WrapAlignment.center,
      children: colorVariants,
    );
  }
}

class ColorButtonController {
  ValueNotifier<int> currentIndex = ValueNotifier(0);

  int get selectedIndex => currentIndex.value;
}
