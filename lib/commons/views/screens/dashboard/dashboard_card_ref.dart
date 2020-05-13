import 'dart:ui';
import 'package:flutter/material.dart';
//import 'package:url_launcher/url_launcher.dart';

//import '../../../models/models.dart';
import '../../../utils/utils.dart';
import '../../custom_elements/dashboard_card_content.dart';

class DashboardCardRef extends StatefulWidget {
  final String appName;
  final ImageProvider imageProvider;
  final Widget header;
  final Widget body;
  final bool defPad;

  DashboardCardRef(this.appName, this.imageProvider, this.header,
      {this.body, this.defPad = true});

  @override
  createState() => _DashboardCardRefState();
}

class _DashboardCardRefState extends State<DashboardCardRef>
    with TickerProviderStateMixin {
  Duration _duration = Duration(milliseconds: 300);

  _DashboardCardRefState();

  bool _open = false;
  dynamic handler;
  num pad = 0.02;
  bool isSingleActionButton;

//  _launchURL(String url) async {
//    if (await canLaunch(url)) {
//      await launch(url);
//    } else {
//      throw 'Could not launch $url';
//    }
//  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bool _isPortrait =
        Orientation.portrait == MediaQuery.of(context).orientation;
    Measurements.height = (_isPortrait
        ? MediaQuery.of(context).size.height
        : MediaQuery.of(context).size.width);
    Measurements.width = (_isPortrait
        ? MediaQuery.of(context).size.width
        : MediaQuery.of(context).size.height);
    bool _isTablet = Measurements.width < 600 ? false : true;
    return Container(
      padding: EdgeInsets.symmetric(vertical: Measurements.width * (_isTablet ?0.003:0.01)),
      child: Column(
        children: <Widget>[
          AnimatedContainer(
            duration: _duration,
            width: Measurements.width * (_isTablet ? (Measurements.width < 850?0.6: 0.5): (_isPortrait ? 0.9 : 1.3)),
            child: Container(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 8, sigmaY: 16),
                  child: Container(
                    color: Colors.black.withOpacity(0.2),
                    child: Column(
                      children: <Widget>[
                        Container(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Container(
                                padding: EdgeInsets.all(
                                    AppStyle.dashboardCardContentPadding()),
                                child: Row(
                                  children: <Widget>[
                                    Container(
                                        height: AppStyle.iconDashboardCardSize(
                                            _isTablet),
                                        child: Image(
                                            image: widget.imageProvider,
                                            height:
                                                AppStyle.iconDashboardCardSize(
                                                    _isTablet))),
                                    Padding(
                                      padding: EdgeInsets.only(
                                          right: Measurements.width *
                                              (_isTablet ? 0.01 : 0.02)),
                                    ),
                                    Text(
                                      Language.getWidgetStrings(
                                          "widgets.${widget.appName}.title"),
                                      style: TextStyle(
                                          fontSize: AppStyle
                                              .fontSizeDashboardTitle()),
                                    ),
                                  ],
                                ),
                              ),
                              widget.body != null
                                  ? InkWell(
                                      child: AnimatedContainer(
                                        padding: EdgeInsets.all(AppStyle
                                            .dashboardCardContentPadding()),
                                        duration: _duration,
                                        child: Text(Language.getWidgetStrings(!_open?"widgets.actions.more":"widgets.actions.less"),style: TextStyle(fontSize: AppStyle.fontSizeDashboardShow()),),
                                        
                                      ),
                                      onTap: () {
                                        listen();
                                      },
                                    )
                                  : Container(),
                            ],
                          ),
                        ),
                        Container(
                          constraints: BoxConstraints(minHeight: 75),
                          padding: widget.defPad
                              ? EdgeInsets.only(
                                  bottom:
                                      AppStyle.dashboardCardContentPadding(),
                                  left: AppStyle.dashboardCardContentPadding() *
                                      1.5,
                                  right:
                                      AppStyle.dashboardCardContentPadding() *
                                          1.5,
                                  top: AppStyle.dashboardCardContentPadding() /
                                      2)
                              : EdgeInsets.symmetric(
                                  vertical:
                                      AppStyle.dashboardCardContentPadding() /
                                          2),
                          child: DashboardCardPanel(
                            animationDuration: _duration,
                            child: ExpansionPanel(
                              body: widget.body ?? Container(),
                              isExpanded: _open,
                              headerBuilder:
                                  (BuildContext context, bool isExpanded) =>
                                      widget.header,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void listen() {
    setState(() {
      _open = !_open;
    });
  }
// Widget singleActionButtonWidget(BuildContext context, bool _isTablet) {
//   return InkWell(
//     radius:
//     _isTablet ? Measurements.height * 0.02 : Measurements.width * 0.07,
//     child: Container(
//         padding: EdgeInsets.symmetric(horizontal: Measurements.width * 0.02),
//         decoration: BoxDecoration(
//           shape: BoxShape.rectangle,
//           color: Colors.grey.withOpacity(0.3),
//           borderRadius: BorderRadius.circular(15),
//         ),
//         height: _isTablet
//             ? Measurements.height * 0.02
//             : Measurements.width * 0.07,
//         child: Center(
//           child:
//               Container(
//             alignment: Alignment.center,
//                  child:Text(Language.getConnectStrings("actions.open"))
//           ),
//         )),
//     onTap: () {
//       setState(() {
//         widget.handler.loadScreen(context, _isLoading);
//       });
//     },
//   );
// }

// Widget actionButtonsWidget(BuildContext context, bool _isTablet, bool isActive) {
//   return isActive
//       ? InkWell(
//         key: Key("${widget.appName}.card.open"),
//     radius: _isTablet
//         ? Measurements.height * 0.02
//         : Measurements.width * 0.07,
//     child: Container(
//         padding:
//         EdgeInsets.symmetric(horizontal: Measurements.width * 0.02),
//         decoration: BoxDecoration(
//           shape: BoxShape.rectangle,
//           color: Colors.grey.withOpacity(0.3),
//           borderRadius: BorderRadius.circular(15),
//         ),
//         height: _isTablet
//             ? Measurements.height * 0.02
//             : Measurements.width * 0.07,
//         child: Center(
//           child:
//           // _isLoading.value
//           //     ? Container(
//           //     constraints: BoxConstraints(
//           //       maxWidth: _isTablet
//           //           ? Measurements.height * 0.01
//           //           : Measurements.width * 0.04,
//           //       maxHeight: _isTablet
//           //           ? Measurements.height * 0.01
//           //           : Measurements.width * 0.04,
//           //     ),
//           //     child: CircularProgressIndicator(
//           //       strokeWidth: 2,
//           //     ))
//           //     :
//                Container(
//             alignment: Alignment.center,
//             child:Text(Language.getConnectStrings("actions.open"))

//           ),
//         )),
//     onTap: () {
//       setState(() {

//         // _isLoading.value = true;
//         widget.handler.loadScreen(context, _isLoading);
//       });
//     },
//   )
//       : Container(
//       child: InkWell(
//         child: Container(
//             height: _isTablet
//                 ? Measurements.height * 0.02
//                 : Measurements.width * 0.07,
//             child: Container(
//                 width: 100,
//                 decoration: BoxDecoration(
//                   shape: BoxShape.rectangle,
//                   color: Colors.grey.withOpacity(0.3),
//                   borderRadius: BorderRadius.circular(15),
//                 ),
//                 child: Row(
//                   mainAxisSize: MainAxisSize.max,
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: <Widget>[
//                     SvgPicture.asset(
//                       "images/launchIcon.svg",
//                       height:
//                       Measurements.width * (_isTablet ? 0.015 : 0.03),
//                       color: Colors.white.withOpacity(0.7),
//                     ),
//                     Padding(
//                       padding:
//                       EdgeInsets.only(left: Measurements.width * 0.008),
//                     ),
//                     Text(
//                       "Learn more",
//                       style: TextStyle(
//                           color: Colors.white.withOpacity(0.7)
//                           ),
//                     ),
//                   ],
//                 ))),
//         onTap: () {
//           setState(() {
//             isActive
//                 ? widget.handler.loadScreen(context, _isLoading)
//                 : _launchURL(widget.handler.learnMore());
//           });
//         },
//       ));
// }
}

// abstract class CardContract{
//   void loadScreen(BuildContext context,ValueNotifier state);
//   String learnMore();
// }
