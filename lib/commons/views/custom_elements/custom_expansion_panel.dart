import 'package:flutter/material.dart';

const double _kPanelHeaderCollapsedHeight = 25;
const double _kPanelHeaderExpandedHeight = 25;

class CustomExpansionPanelList extends StatelessWidget {
  const CustomExpansionPanelList(
      {Key key,
      this.children: const <ExpansionPanel>[],
      this.expansionCallback,
      @required this.isWithCustomIcon,
      this.animationDuration: kThemeAnimationDuration})
      : assert(children != null),
        assert(animationDuration != null),
        super(key: key);

  final List<ExpansionPanel> children;

  final ExpansionPanelCallback expansionCallback;

  final Duration animationDuration;

  final bool isWithCustomIcon;

  bool _isChildExpanded(int index) {
    return children[index].isExpanded;
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> items = <Widget>[];
    const EdgeInsets kExpandedEdgeInsets = const EdgeInsets.symmetric(
        vertical: _kPanelHeaderExpandedHeight - _kPanelHeaderCollapsedHeight);

    for (int index = 0; index < children.length; index += 1) {
//      if (_isChildExpanded(index) && index != 0 && !_isChildExpanded(index - 1))
//        items.add(new Divider(
//          key: new _SaltedKey<BuildContext, int>(context, index * 2 - 1),
//          height: 5,
//          color: Colors.transparent,
//        ));

      final Widget header = Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          new Expanded(
            child: new AnimatedContainer(
              duration: animationDuration,
              curve: Curves.fastOutSlowIn,
              margin: _isChildExpanded(index)
                  ? kExpandedEdgeInsets
                  : EdgeInsets.zero,
              child: new Container(
                child: children[index].headerBuilder(
                  context,
                  children[index].isExpanded,
                ),
              ),
            ),
          ),
          Container(
            // margin: const EdgeInsetsDirectional.only(end: 8),
            child: isWithCustomIcon
                ? MyCustomExpandIcon(
                    isExpanded: _isChildExpanded(index),
                    padding: const EdgeInsets.all(16.0),
                    onPressed: (bool isExpanded) {
                      if (expansionCallback != null)
                        expansionCallback(index, isExpanded);
                    },
                  )
                : ExpandIcon(
                    isExpanded: _isChildExpanded(index),
                    padding: const EdgeInsets.all(16.0),
                    onPressed: (bool isExpanded) {
                      if (expansionCallback != null)
                        expansionCallback(index, isExpanded);
                    },
                  ),
          ),
        ],
      );

//      double _radiusValue = _isChildExpanded(index) ? 0 : 20;
      items.add(
        Container(
          key: _SaltedKey<BuildContext, int>(context, index * 2),
          child: Material(
            color: Colors.transparent,
            elevation: 0,
//            borderRadius: new BorderRadius.all(new Radius.circular(_radiusValue)),
//              decoration: i == 0
//                    ? BoxDecoration(
//                    color: Colors.white.withOpacity(0.1),
//              borderRadius: index == 0 ? BorderRadius.only(
//                        topLeft: Radius.circular(_radiusValue),
//                        topRight: Radius.circular(_radiusValue))
//                    : BorderRadius.only(topLeft: Radius.circular(0),
//                  topRight: Radius.circular(0)),
            child: Column(
              children: <Widget>[
                InkWell(
                  highlightColor: Colors.transparent,
                  onTap: () {
                    if (expansionCallback != null)
                      expansionCallback(index, _isChildExpanded(index));
                  },
                  child: Container(
                      padding: EdgeInsets.only(left: 25),
                      alignment: Alignment.centerLeft,
                      height: 50,
                      child: header),
                ),
                (index == (items.length - 1))
                    ? Container()
                    : _isChildExpanded(index)
                        ? Container()
                        : Divider(
                            color: Colors.white.withOpacity(0.5),
                          ),
                Container(
                  color: Colors.black.withOpacity(0.1),
                  child: AnimatedCrossFade(
                    firstChild: Container(height: 0.0),
                    secondChild: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                      child: Row(
                        children: <Widget>[
                          children[index].body,
                        ],
                      ),
                    ),
                    firstCurve:
                        const Interval(0.0, 0.6, curve: Curves.fastOutSlowIn),
                    secondCurve:
                        const Interval(0.4, 1.0, curve: Curves.fastOutSlowIn),
                    sizeCurve: Curves.fastOutSlowIn,
                    crossFadeState: _isChildExpanded(index)
                        ? CrossFadeState.showSecond
                        : CrossFadeState.showFirst,
                    duration: animationDuration,
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      if (_isChildExpanded(index) && index != children.length - 1)
        items.add(Divider(
          key: _SaltedKey<BuildContext, int>(context, index * 2 + 1),
          height: 1,
        ));
    }

    return new Column(
      children: items,
    );
  }
}

class _SaltedKey<S, V> extends LocalKey {
  const _SaltedKey(this.salt, this.value);

  final S salt;
  final V value;

  @override
  bool operator ==(dynamic other) {
    if (other.runtimeType != runtimeType) return false;
    final _SaltedKey<S, V> typedOther = other;
    return salt == typedOther.salt && value == typedOther.value;
  }

  @override
  int get hashCode => hashValues(runtimeType, salt, value);

  @override
  String toString() {
    final String saltString = S == String ? '<\'$salt\'>' : '<$salt>';
    final String valueString = V == String ? '<\'$value\'>' : '<$value>';
    return '[$saltString $valueString]';
  }
}

class MyCustomExpandIcon extends StatefulWidget {
  const MyCustomExpandIcon({
    Key key,
    this.isExpanded = false,
    this.size = 24.0,
    @required this.onPressed,
    this.padding = const EdgeInsets.all(8.0),
    this.color,
    this.disabledColor,
    this.expandedColor,
  })  : assert(isExpanded != null),
        assert(size != null),
        assert(padding != null),
        super(key: key);

  final bool isExpanded;
  final double size;
  final ValueChanged<bool> onPressed;
  final EdgeInsetsGeometry padding;
  final Color color;
  final Color disabledColor;
  final Color expandedColor;

  @override
  createState() => _MyCustomExpandIconState();
}

class _MyCustomExpandIconState extends State<MyCustomExpandIcon>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void didUpdateWidget(MyCustomExpandIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  void _handlePressed() {
    if (widget.onPressed != null) widget.onPressed(widget.isExpanded);
  }

//  Color get _iconColor {
//    if (widget.isExpanded && widget.expandedColor != null) {
//      return widget.expandedColor;
//    }
//
//    if (widget.color != null) {
//      return widget.color;
//    }
//
//    switch(Theme.of(context).brightness) {
//      case Brightness.light:
//        return Colors.black54;
//      case Brightness.dark:
//        return Colors.white60;
//    }
//
//    assert(false);
//    return null;
//  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMaterial(context));
    assert(debugCheckHasMaterialLocalizations(context));
    final MaterialLocalizations localizations =
        MaterialLocalizations.of(context);
    final String onTapHint = widget.isExpanded
        ? localizations.expandedIconTapHint
        : localizations.collapsedIconTapHint;

    return Semantics(
      onTapHint: widget.onPressed == null ? null : onTapHint,
      child: IconButton(
        //padding: widget.padding,
        //color: _iconColor,
        color: Colors.white,
        disabledColor: widget.disabledColor,
        onPressed: widget.onPressed == null ? null : _handlePressed,
        icon: widget.isExpanded ? Icon(Icons.remove) : Icon(Icons.add),
      ),
    );
  }
}
