import 'package:flutter/material.dart';

import '../../models/buttons_data.dart';
import '../../utils/utils.dart';

class AvatarDescriptionCard extends StatelessWidget {
  final ImageProvider image;
  final String imageTitle;
  final String _title;
  final String _detail;

  AvatarDescriptionCard(this.image, this._title, this._detail,
      {this.imageTitle})
      : assert(image != null || imageTitle != null);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        CircleAvatar(
          backgroundColor: imageTitle != null
              ? Colors.grey.withOpacity(0.5)
              : Colors.transparent,
          radius: AppStyle.dashboardRadius(),
          backgroundImage: image,
          child: imageTitle != null
              ? Center(child: Text(Measurements.initials(imageTitle)))
              : Container(),
        ),
        Padding(
          padding: EdgeInsets.only(left: 15),
        ),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                "$_title",
                style: TextStyle(
                    fontSize:
                        AppStyle.fontSizeDashboardAvatarDescriptionTitle(),
                    fontWeight: FontWeight.bold),
              ),
              Text(
                "$_detail",
                style: TextStyle(
                    fontSize: AppStyle
                        .fontSizeDashboardAvatarDescriptionDescription()),
              )
            ],
          ),
        )
      ],
    );
  }
}

class AvatarDescriptionCardOnButton extends StatelessWidget {
  final ImageProvider image;
  final String imageTitle;
  final String _title;
  final String _detail;

  AvatarDescriptionCardOnButton(this.image, this._title, this._detail,
      {this.imageTitle})
      : assert(image != null || imageTitle != null);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(left: 15),
        ),
        CircleAvatar(
          backgroundColor: Colors.grey.withOpacity(0.5),
          radius: AppStyle.dashboardRadiusSmall(),
          backgroundImage: image,
          child: imageTitle != null
              ? Center(child: Text(Measurements.initials(imageTitle)))
              : Container(),
        ),
        Padding(
          padding: EdgeInsets.only(left: 15),
        ),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                "$_title",
                style: TextStyle(
                    fontSize:
                        AppStyle.fontSizeDashboardAvatarDescriptionTitle(),
                    fontWeight: FontWeight.bold),
              ),
//              Text(
//                "$_detail",
//                style: TextStyle(
//                    fontSize: AppStyle
//                        .fontSizeDashboardAvatarDescriptionDescription()),
//              )
            ],
          ),
        )
      ],
    );
  }
}

class TitleAmountCardItem extends StatelessWidget {
  final Widget title;
  final Widget amountWidget;
  final String _amount;
  final String titleString;

  TitleAmountCardItem(this._amount,
      {this.title, this.titleString = "", this.amountWidget});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: (AppStyle.dashboardCardContentHeight() / 2) - 1,
      padding: EdgeInsets.symmetric(
          horizontal: AppStyle.dashboardCardContentPadding() * 1.5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Container(
            child: titleString.isNotEmpty
                ? Text(titleString,
                    style: TextStyle(
                        fontSize: AppStyle.fontSizeDashboardTitleAmount()))
                : title,
          ),
          Container(
            child: amountWidget == null
                ? Text(
                    _amount,
                    style: TextStyle(
                        fontSize: AppStyle.fontSizeDashboardTitleAmount()),
                  )
                : amountWidget,
          ),
        ],
      ),
    );
  }
}

class NoItemsCard extends StatelessWidget {
  final Widget title;
  final VoidCallback action;

  NoItemsCard(this.title, this.action);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Container(
        height: 10,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          child: Center(child: title),
          onTap: action,
        ),
      ),
    );
  }
}

class ItemsCardNButtons extends StatelessWidget {
  final List<ButtonsData> buttonsDataList;

  ItemsCardNButtons(this.buttonsDataList);

  @override
  Widget build(BuildContext context) {
    List<Widget> itemsDataList = List<Widget>();
    bool lock = true;
    for (var item in buttonsDataList) {
      itemsDataList.add(Expanded(
        flex: 1,
        child: Container(
          height: 50,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: EdgeInsets.all(10),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              child: Center(
                  child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(width: 20,child: Image(image: item.icon,)),
                  SizedBox(width: 10),
                   Measurements.width > 600 ?
                  Container(
                    child: Text(
                      item.title,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: AppStyle.fontSizeDashboardTitle(),
                        fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    )
                  ):
                  Expanded(
                      child: Text(
                    item.title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: AppStyle.fontSizeDashboardTitle(),
                      fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  )),
                ],
              )),
              onTap: item.action,
            ),
          ),
        ),
      ));
      if(lock){
        itemsDataList.add(SizedBox(width: 10,));
        lock = !lock;
      }
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal:10),
      child: Column(
        children: <Widget>[
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: itemsDataList,
            ),
          ),
        ],
      ),
    );
  }
}
