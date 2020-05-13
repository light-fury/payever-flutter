import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';

import '../../../commons/views/custom_elements/custom_elements.dart';
import '../../models/models.dart';
import '../../network/network.dart';
import '../../utils/utils.dart';
import '../../view_models/view_models.dart';

class WallpaperScreen extends StatefulWidget {
  @override
  _WallpaperScreenState createState() => _WallpaperScreenState();
}

class _WallpaperScreenState extends State<WallpaperScreen> {
  @override
  Widget build(BuildContext context) {
    return BackgroundBase(
      true,
      appBar: CustomAppBar(
        onTap: () => Navigator.of(context).pop(),
        title: Text(
          "Wallpaper",
          style: TextStyle(fontSize: AppStyle.fontSizeAppBar()),
        ),
      ),
      body: CustomFutureBuilder(
        color: Colors.transparent,
        future: Provider.of<DashboardStateModel>(context).getWallpaper(),
        errorMessage: "",
        onDataLoaded: (List<WallpaperCategory> result) {
          List<Widget> bodies = List();
          List<Widget> heads = List();
          for (WallpaperCategory cat in result) {
            heads.add(Text(
              Language.getSettingsStrings("assets.product.${cat.code}"),
              style: TextStyle(fontSize: AppStyle.fontSizeTabTitle()),
              overflow: TextOverflow.ellipsis,
            ));
            bodies.add(WallpaperRow(cat.industries));
          }
          return CustomExpansionTile(
              isWithCustomIcon: true,
              scrollable: true,
              headerColor: Colors.transparent,
              widgetsBodyList: bodies,
              widgetsTitleList: heads);
        },
      ),
    );
  }
}

class WallpaperRow extends StatefulWidget {
  List<WallpaperIndustry> industries = List();

  WallpaperRow(this.industries);

  @override
  _WallpaperRowState createState() => _WallpaperRowState();
}

class _WallpaperRowState extends State<WallpaperRow> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: widget.industries.length,
        itemBuilder: (BuildContext context, int index) {
          List<WallpaperItem> items = List();
          widget.industries[index].wallapapers.forEach((_w) {
            items.add(WallpaperItem(_w));
          });
          return Container(
            child: Container(
              child: Column(
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Text(
                            Language.getSettingsStrings(
                                "assets.industry.${widget.industries[index].code}"),
                            style: TextStyle(
                                fontSize: AppStyle.fontSizeTabTitle())),
                      ],
                    ),
                  ),
                  Container(
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: Wrap(
                            alignment: WrapAlignment.start,
                            // direction: Axis.horizontal,
                            // runAlignment:WrapAlignment.spaceBetween,
                            //  crossAxisAlignment: WrapCrossAlignment.start,
                            children: items,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class WallpaperItem extends StatelessWidget {
  String id;

  WallpaperItem(this.id);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: InkWell(
        child: Container(
          height: 81,
          width: 144,
          decoration: BoxDecoration(
            image: DecorationImage(
              image:
                  CachedNetworkImageProvider(Env.storage + "/wallpapers/$id"),
              fit: BoxFit.fill,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onTap: () {
          GlobalStateModel global = Provider.of<GlobalStateModel>(context);
          EmployeesApi()
              .postWallpaper(GlobalUtils.activeToken.accessToken, id,
                  global.currentBusiness.id)
              .then((_) {
            global.setCurrentWallpaper(Env.storage + '/wallpapers/' + id,
                notify: false);
            Navigator.of(context).pop();
          });
        },
      ),
    );
  }
}
