import 'package:flutter/material.dart';

const double _kPanelHeaderCollapsedHeight = 70;
const double _kPanelHeaderExpandedHeight = 70;

class DashboardCardPanel extends StatelessWidget {
  const DashboardCardPanel({
    Key key,
    @required this.child,
    this.expansionCallback,
    this.animationDuration: kThemeAnimationDuration,
  })  : assert(child != null),
        assert(animationDuration != null),
        super(key: key);

  final ExpansionPanel child;

  final ExpansionPanelCallback expansionCallback;

  final Duration animationDuration;

  bool _isChildExpanded() {
    return child.isExpanded;
  }

  @override
  Widget build(BuildContext context) {
    const EdgeInsets kExpandedEdgeInsets = const EdgeInsets.symmetric(
        vertical: _kPanelHeaderExpandedHeight - _kPanelHeaderCollapsedHeight);

    final Row header = Row(
      children: <Widget>[
        new Expanded(
          child: GestureDetector(
            onTap: () {
              if (expansionCallback != null)
                expansionCallback(0, _isChildExpanded());
            },
            child: new AnimatedContainer(
              duration: animationDuration,
              curve: Curves.fastOutSlowIn,
              margin:
                  _isChildExpanded() ? kExpandedEdgeInsets : EdgeInsets.zero,
              child: new SizedBox(
                height: _kPanelHeaderCollapsedHeight,
                child: child.headerBuilder(
                  context,
                  child.isExpanded,
                ),
              ),
            ),
          ),
        ),
      ],
    );
    return new Container(
      child: Material(
        color: Colors.transparent,
        elevation: 0,
        child: Column(
          children: <Widget>[
            header,
            AnimatedCrossFade(
              firstChild: Container(height: 0.0),
              secondChild: child.body,
              firstCurve: const Interval(0.0, 0.6, curve: Curves.fastOutSlowIn),
              secondCurve:
                  const Interval(0.4, 1.0, curve: Curves.fastOutSlowIn),
              sizeCurve: Curves.fastOutSlowIn,
              crossFadeState: _isChildExpanded()
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: animationDuration,
            ),
          ],
        ),
      ),
    );
  }
}

//class _SaltedKey<S, V> extends LocalKey {
//  const _SaltedKey(this.salt, this.value);
//
//  final S salt;
//  final V value;
//
//  @override
//  bool operator ==(dynamic other) {
//    if (other.runtimeType != runtimeType) return false;
//    final _SaltedKey<S, V> typedOther = other;
//    return salt == typedOther.salt && value == typedOther.value;
//  }
//
//  @override
//  int get hashCode => hashValues(runtimeType, salt, value);
//
//  @override
//  String toString() {
//    final String saltString = S == String ? '<\'$salt\'>' : '<$salt>';
//    final String valueString = V == String ? '<\'$value\'>' : '<$value>';
//    return '[$saltString $valueString]';
//  }
//}

class MyExpandIcon extends StatefulWidget {
  const MyExpandIcon({
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
  createState() => _MyExpandIconState();
}

class _MyExpandIconState extends State<MyExpandIcon>
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
  void didUpdateWidget(MyExpandIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  void _handlePressed() {
    if (widget.onPressed != null) widget.onPressed(widget.isExpanded);
  }

  Color get _iconColor {
    if (widget.isExpanded && widget.expandedColor != null) {
      return widget.expandedColor;
    }

    if (widget.color != null) {
      return widget.color;
    }

    switch (Theme.of(context).brightness) {
      case Brightness.light:
        return Colors.black54;
      case Brightness.dark:
        return Colors.white54;
    }

    assert(false);
    return null;
  }

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
        padding: widget.padding,
        color: _iconColor,
        disabledColor: widget.disabledColor,
        onPressed: widget.onPressed == null ? null : _handlePressed,
        icon: widget.isExpanded ? Icon(Icons.minimize) : Icon(Icons.add),
      ),
    );
  }
}
