import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';

import '../../../network/network.dart';
import '../../../models/models.dart';
import '../../../utils/utils.dart';
import '../../../view_models/view_models.dart';
import '../../custom_elements/custom_elements.dart';

import 'dashboard_card_ref.dart';

class SimplyTutorial extends StatefulWidget {
  final String _appName;
  final ImageProvider _imageProvider;

  SimplyTutorial(this._appName, this._imageProvider);

  @override
  createState() => _SimplyTutorialCardState();
}

class _SimplyTutorialCardState extends State<SimplyTutorial> {
  GlobalStateModel globalStateModel;
  DashboardStateModel dashboardStateModel;
  List<TutorialRow> tutorialRows = List();
  bool firstTime = true;
  List<String> availableVideos = [
    "transactions",
    "pos",
    "products",
    "tutorial",
  ];

  @override
  Widget build(BuildContext context) {
    globalStateModel = Provider.of<GlobalStateModel>(context);
    dashboardStateModel = Provider.of<DashboardStateModel>(context);
    List<Tutorial> _tutorials = List();
    if (firstTime) {
      firstTime = false;
      RestDataSource()
          .getTutorials(GlobalUtils.activeToken.accessToken,
              globalStateModel.currentBusiness.id)
          .then((obj) {
        obj.forEach((_tutorial) {
          Tutorial temp = Tutorial.map(_tutorial);
          if (availableVideos.contains(temp.type)) _tutorials.add(temp);
        });
        _tutorials.sort((a, b) => b.order.compareTo(a.order));
        dashboardStateModel.tutorials.clear();
        dashboardStateModel.setTutorials(_tutorials);
        setState(() {});
      });
    } else {
      tutorialRows.clear();
      dashboardStateModel.tutorials.forEach((_tutorial) {
        tutorialRows.add(TutorialRow(
          currentTutorial: _tutorial,
          business: globalStateModel.currentBusiness,
        ));
      });
    }
    return DashboardCardRef(
      widget._appName,
      widget._imageProvider,
      tutorialRows.isEmpty
          ? Center(child: CircularProgressIndicator())
          : Head(tutorialRows),
      body: tutorialRows.isEmpty ? null : Body(tutorialRows.sublist(2)),
      defPad: false,
    );
  }
}

class Head extends StatefulWidget {
  final List<TutorialRow> _tutorials;

  Head(this._tutorials);

  @override
  createState() => _HeadState();
}

class _HeadState extends State<Head> {
  @override
  Widget build(BuildContext context) {
    if (widget._tutorials.isEmpty) return null;
    if (widget._tutorials.length == 1) return widget._tutorials[0];
    return Container(
      child: Column(
        children: <Widget>[
          widget._tutorials[0],
          Divider(height: 1, color: Colors.white.withOpacity(0.5)),
          widget._tutorials[1]
        ],
      ),
    );
  }
}

class Body extends StatefulWidget {
  final List<TutorialRow> _tutorials;

  Body(this._tutorials);

  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<Body> {
  @override
  Widget build(BuildContext context) {
    if (widget._tutorials.isEmpty) return null;
    return Container(
      child: ListView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: widget._tutorials.length,
        itemBuilder: (BuildContext context, int index) {
          return Column(
            children: <Widget>[
              Divider(height: 1, color: Colors.white.withOpacity(0.5)),
              widget._tutorials[index],
            ],
          );
        },
      ),
    );
  }
}

class TutorialRow extends StatelessWidget {
  final Tutorial currentTutorial;
  final Business business;

  TutorialRow({this.currentTutorial, this.business});

  @override
  Widget build(BuildContext context) {
    bool _isTablet = Measurements.width > 600;
    return InkWell(
      highlightColor: Colors.transparent,
      child: Column(
        children: <Widget>[
          TitleAmountCardItem(
            "",
            title: Row(
              children: <Widget>[
                SvgPicture.asset(
                  "assets/images/playvideoicon.svg",
                  height: AppStyle.iconDashboardCardSize(_isTablet),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 10),
                ),
                Text(
                  "${currentTutorial.title}",
                  style: TextStyle(
                      fontSize: AppStyle.fontSizeDashboardTitleAmount()),
                ),
              ],
            ),
            amountWidget: currentTutorial.watched
                ? SvgPicture.asset("assets/images/watchedicon.svg")
                : Container(),
          ),
        ],
      ),
      onTap: () {
        RestDataSource()
            .patchTutorials(GlobalUtils.activeToken.accessToken, business.id,
                currentTutorial.id)
            .then((_) {});
        _launchURL(currentTutorial.url);
      },
    );
  }

  _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
