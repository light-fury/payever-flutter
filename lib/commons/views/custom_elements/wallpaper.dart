import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';

import '../../utils/utils.dart';
import '../../view_models/view_models.dart';

class BackgroundBase extends StatefulWidget {
  final bool _isBlur;
  final Widget body, endDrawer, bottomNav;
  final AppBar appBar;
  final Key currentKey;

  BackgroundBase(this._isBlur,
      {this.body,
      this.endDrawer,
      this.bottomNav,
      this.appBar,
      this.currentKey});

  @override
  _BackgroundBaseState createState() => _BackgroundBaseState();
}

class _BackgroundBaseState extends State<BackgroundBase> {
  GlobalStateModel globalStateModel;

  @override
  Widget build(BuildContext context) {
    globalStateModel = Provider.of<GlobalStateModel>(context);
    return Stack(
        //overflow: Overflow.visible,
        fit: StackFit.expand,
        children: <Widget>[
          Positioned(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            top: 0.0,
            child: Container(
              child: CachedNetworkImage(
                imageUrl: widget._isBlur
                    ? globalStateModel.currentWallpaperBlur
                    : globalStateModel.currentWallpaper,
                placeholder: (context, url) => Container(),
                errorWidget: (context, url, error) => Icon(Icons.error),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Container(
              height: Measurements.height,
              width: Measurements.width,
              child: Scaffold(
                key: widget.currentKey,
                backgroundColor: Colors.transparent,
                appBar: widget.appBar,
                endDrawer: widget.endDrawer,
                body: widget.body,
                bottomNavigationBar: widget.bottomNav,
              ),
            ),
          )
        ]);
  }
}
