import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:page_transition/page_transition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../commons/views/screens/login/login.dart';
import '../../commons/views/custom_elements/custom_app_bar.dart';
import '../view_models/view_models.dart';
import '../network/network.dart';
import '../models/models.dart';
import '../utils/utils.dart';

class EditTerminal extends StatefulWidget {
  final String _wallpaper;
  final String _name;
  final String _logo;
  final String _id;
  final String _business;
  final Terminal _currentTerm;
  final Business business;

  EditTerminal(this._wallpaper, this._name, this._logo, this._id,
      this._business, this._currentTerm, this.business);

  @override
  createState() => _EditTerminalState();
}

class _EditTerminalState extends State<EditTerminal> {
  bool _isPortrait;
  bool _isTablet;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (BuildContext context, Orientation orientation) {
        _isPortrait = Orientation.portrait == orientation;
        _isTablet = Measurements.width < 600 ? false : true;

        print("_isPortrait: $_isPortrait");

        return Stack(children: <Widget>[
          Positioned(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            top: 0.0,
            child: CachedNetworkImage(
              imageUrl: widget._wallpaper,
              placeholder: (context, url) => CircularProgressIndicator(),
              errorWidget: (context, url, error) => Icon(Icons.error),
              fit: BoxFit.cover,
            ),
          ),
          Scaffold(
              appBar: CustomAppBar(
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              backgroundColor: Colors.black.withOpacity(0.2),
              body: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: EditForm(
                    widget._name,
                    widget._logo,
                    widget._id,
                    widget._business,
                    widget._currentTerm,
                    widget._wallpaper,
                    _isTablet,
                    widget.business),
              ))
        ]);
      },
    );
  }
}

class EditForm extends StatefulWidget {
  final String _name;
  final String _logo;
  final String _id;
  final String _business;
  final Business business;
  final bool _isTablet;
  final Terminal _currentTerm;
  final String _wallpaper;

  EditForm(this._name, this._logo, this._id, this._business, this._currentTerm,
      this._wallpaper, this._isTablet, this.business);

  @override
  _EditFormState createState() => _EditFormState();
}

class _EditFormState extends State<EditForm> {
  String imageBase = Env.storage + 'assets/images/';
  GlobalStateModel globalStateModel;
  String newName;
  bool _isLoading = false;
  String _logo;

  @override
  void initState() {
    super.initState();

    setState(() {
      newName = widget._name;
      _logo = widget._logo;
    });
  }

  void _submit() {
    final form = formKey.currentState;
    if (form.validate()) {
      form.save();
      PosApi api = PosApi();
      api
          .postEditTerminal(widget._id, newName, widget._logo, widget._business,
              GlobalUtils.activeToken.accessToken)
          .then((res) {
        print(res);
        widget._currentTerm.name = newName;
        widget._currentTerm.logo = widget._logo;
//        Navigator.pushReplacement(
//            context,
//            PageTransition(
//                child: NativePosScreen(
//                    terminal: widget._currentTerm,
//                    business: globalStateModel.currentBusiness),
//                type: PageTransitionType.fade));

//        Navigator.push(
//            context,
//            PageTransition(
//                child: ChangeNotifierProvider<PosStateModel>(
//                  builder: (BuildContext context) =>
//                      PosStateModel(globalStateModel, RestDatasource()),
//                  child: PosProductsListScreen(
//                      terminal: widget._currentTerm,
//                      business: globalStateModel.currentBusiness),
//                ),
//                type: PageTransitionType.fade,
//                duration: Duration(milliseconds: 50)));
      }).catchError((onError) {
        if (onError.toString().contains("401")) {
          GlobalUtils.clearCredentials();
          Navigator.pushReplacement(
              context,
              PageTransition(
                  child: LoginScreen(), type: PageTransitionType.fade));
        }
      });
    }
  }

  static final formKey = GlobalKey<FormState>();
  File _image;

  Future getImage() async {
    _isLoading = true;
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    if (image.existsSync())
      setState(() {
        _image = image;
        print("_image: $_image");
        PosApi api = PosApi();
        api
            .postTerminalImage(
                image, widget._business, GlobalUtils.activeToken.accessToken)
            .then((dynamic res) {
          _logo = res["blobName"];
          api
              .postEditTerminal(widget._id, newName, widget._logo,
                  widget._business, GlobalUtils.activeToken.accessToken)
              .then((res) {
            print(res);
            setState(() {
              _isLoading = false;
            });
          });
        }).catchError((onError) {
          setState(() {
            print(onError);
            _isLoading = false;
          });
          if (onError.toString().contains("401")) {
            GlobalUtils.clearCredentials();
            Navigator.pushReplacement(
                context,
                PageTransition(
                    child: LoginScreen(), type: PageTransitionType.fade));
          }
        });
      });
  }

  @override
  Widget build(BuildContext context) {
    globalStateModel = Provider.of<GlobalStateModel>(context);
    return OrientationBuilder(
      builder: (BuildContext context, Orientation orientation) {
        return Container(
          padding: EdgeInsets.symmetric(
              horizontal: (orientation == Orientation.portrait
                      ? Measurements.width
                      : Measurements.height) *
                  (widget._isTablet ? 0.15 : 0.05)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                height: Measurements.height * (widget._isTablet ? 0.07 : 0.08),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.15),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Center(
                      child: InkWell(
                        child: Stack(
                          alignment: Alignment.topRight,
                          children: <Widget>[
                            widget._logo != null
                                ? Center(
                                    child: CircleAvatar(
                                    backgroundColor: Colors.grey,
                                    backgroundImage:
                                        NetworkImage(imageBase + widget._logo),
                                  ))
                                : Center(
                                    child: CircleAvatar(
                                    child: Center(
                                        child: SvgPicture.asset(
                                            "images/newpicicon.svg")),
                                    backgroundColor: Colors.grey,
                                  )),
                            widget._logo != null
                                ? Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.black.withOpacity(0.3),
                                    ),
                                    child: Icon(
                                      Icons.close,
                                      color: Colors.white.withOpacity(0.7),
                                    ),
                                  )
                                : Container(),
                            _isLoading
                                ? Center(child: CircularProgressIndicator())
                                : Container(),
                          ],
                        ),
                        onTap: () {
                          if (_logo != null) {
                            setState(() {
                              _logo = null;
                            });
                          } else {
                            getImage();
                          }
                        },
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: Measurements.width * 0.03),
                    ),
                    Container(
                      width: Measurements.width * 0.5,
                      child: Form(
                        key: formKey,
                        child: Center(
                          child: TextFormField(
                              onSaved: (val) => newName = val,
                              validator: (value) {
                                if (value.isEmpty) {
                                  return 'Terminal name is required';
                                }
                                return '';
                              },
                              decoration: InputDecoration(
                                labelText: "Terminal name",
                                border: InputBorder.none,
                              ),
                              keyboardType: TextInputType.text,
                              initialValue: widget._name),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              InkWell(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(15),
                      bottomRight: Radius.circular(15),
                    ),
                  ),
                  height: Measurements.height * 0.07,
                  child: Center(
                    child: Text("Done"),
                  ),
                ),
                onTap: () {
                  print("done ${widget._id}");
                  _submit();
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
