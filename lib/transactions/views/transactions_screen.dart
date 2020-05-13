import 'dart:ui';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:page_transition/page_transition.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../utils/utils.dart';
import '../view_models/view_models.dart';
import '../network/network.dart';
import '../../commons/view_models/view_models.dart';
import '../../commons/models/models.dart';
import '../../commons/views/custom_elements/custom_elements.dart';
import '../../commons/views/screens/login/login.dart';
import '../../commons/views/screens/dashboard/transaction_card.dart';
import 'transactions_details_screen.dart';

bool _isPortrait;
bool _isTablet;

class TransactionScreenInit extends StatelessWidget {
  final TransactionStateModel dashboardStateModel = TransactionStateModel();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<TransactionStateModel>(
      builder: (BuildContext context) {
        return dashboardStateModel;
      },
      child: TransactionScreen(),
    );
  }
}

class TransactionScreen extends StatefulWidget {
  @override
  createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  ValueNotifier<bool> isLoading = ValueNotifier(true);
  ValueNotifier<bool> isLoadingSearch = ValueNotifier(true);
  TransactionScreenData data;

  Business _currentBusiness;

//  bool _pos;
  bool initQueryNotEmpty = false;
  ValueNotifier<String> searching = ValueNotifier("");
  String search = "";
  bool init = true;
  String wallpaper;

  @override
  void initState() {
    super.initState();
    isLoading.addListener(listener);
    isLoadingSearch.addListener(listener);
    searching.addListener(listener);
  }

  listener() {
    setState(() {});
  }

  fetchTransactions({String search, bool init}) {
    TransactionsApi api = TransactionsApi();
    api
        .getTransactionList(
            _currentBusiness.id,
            GlobalUtils.activeToken.accessToken,
            "?orderBy=created_at&direction=desc&limit=50&query=$search&page=1&currency=${_currentBusiness.currency}",
            context)
        .then((obj) {
      data = TransactionScreenData(obj);
      if (init) isLoading.value = false;
      isLoadingSearch.value = false;
    }).catchError((onError) {
      if (onError.toString().contains("401")) {
        GlobalUtils.clearCredentials();
        Navigator.pushReplacement(
            context,
            PageTransition(
                child: LoginScreen(), type: PageTransitionType.fade));
      }
      print(onError.toString());
    });
  }

  num _quantity;

  String _currency;
  num _totalAmount;
  var f = NumberFormat("###,###,##0.00", "en_US");
  bool noTransactions = false;

//  bool isLoading = false;

  TransactionStateModel transactionsStateModel;

  @override
  Widget build(BuildContext context) {
    GlobalStateModel globalStateModel = Provider.of<GlobalStateModel>(context);
    transactionsStateModel = Provider.of<TransactionStateModel>(context);
    _currentBusiness = globalStateModel.currentBusiness;
    wallpaper = globalStateModel.currentWallpaper;

    fetchTransactions(init: init, search: transactionsStateModel.searchField);
    init = false;
    _isPortrait = Orientation.portrait == MediaQuery.of(context).orientation;
    Measurements.height = (_isPortrait
        ? MediaQuery.of(context).size.height
        : MediaQuery.of(context).size.width);
    Measurements.width = (_isPortrait
        ? MediaQuery.of(context).size.width
        : MediaQuery.of(context).size.height);
    _isTablet = Measurements.width < 600 ? false : true;
    if (data != null) {
      _quantity = isLoadingSearch.value
          ? 0
          : data.transaction.paginationData.total ?? 0;
      _currency = data.currency(globalStateModel.currentBusiness.currency);
      _totalAmount = isLoadingSearch.value
          ? 0
          : data.transaction.paginationData.amount ?? 0;
    }
    return BackgroundBase(true,
        appBar: AppBar(
          elevation: 0,
          title: !noTransactions
              ? AutoSizeText(
                  Language.getTransactionStrings("total_orders.heading")
                      .toString()
                      .replaceFirst("{{total_count}}", "${_quantity ?? 0}")
                      .replaceFirst("{{total_sum}}",
                          "${_currency ?? "€"}${f.format(_totalAmount ?? 0)}"),
                  overflow: TextOverflow.fade,
                  maxLines: 1,
                  style: TextStyle(fontSize: AppStyle.fontSizeAppBar()),
                )
              : Container(),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          leading: InkWell(
            radius: 20,
            child: Icon(IconData(58829, fontFamily: 'MaterialIcons')),
            onTap: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: Column(
          children: <Widget>[
            isLoading.value
                ? Container()
                : Container(
                    padding: EdgeInsets.only(
                        bottom: Measurements.height * 0.02,
                        left: Measurements.width * (_isTablet ? 0.01 : 0.05),
                        right: Measurements.width * (_isTablet ? 0.01 : 0.05)),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: EdgeInsets.only(
                          left:
                              Measurements.width * (_isTablet ? 0.01 : 0.025)),
                      child: TextFormField(
                        decoration: InputDecoration(
                            hintText: "Search",
                            border: InputBorder.none,
                            icon: Container(
                                child: SvgPicture.asset(
                              "assets/images/searchicon.svg",
                              height: Measurements.height * 0.0175,
                              color: Colors.white,
                            ))),
                        onFieldSubmitted: (search) {
                          transactionsStateModel.setSearchField(search);
                          isLoadingSearch.value = true;
                          data.transaction.collection.clear();
                          fetchTransactions(init: false, search: search);
                        },
                      ),
                    ),
                  ),
            isLoadingSearch.value || isLoading.value
                ? Expanded(
                    child: Center(
                    child: CircularProgressIndicator(),
                  ))
                : Expanded(
                    child: CustomList(_currentBusiness, search,
                        data.transaction.collection, data)),
          ],
        ));
    // return Stack(
    //   children: <Widget>[
    //     Positioned(
    //       height: MediaQuery.of(context).size.height,
    //       width: MediaQuery.of(context).size.width,
    //       top: 0.0,
    //       child: CachedNetworkImage(
    //         imageUrl: widget.wallpaper,
    //         placeholder: (context, url) =>  Container(),
    //         errorWidget: (context, url, error) => Icon(Icons.error),
    //         fit: BoxFit.cover,
    //       )
    //     ),
    //     BackdropFilter(
    //       filter: ImageFilter.blur(sigmaX: 25,sigmaY: 25),
    //       child: Container(
    //         child: Scaffold(
    //           backgroundColor: Colors.black.withOpacity(0.2),
    //           appBar: AppBar(
    //             elevation: 0,
    //             title: !noTransactions ?AutoSizeText(Language.getTransactionStrings("total_orders.heading").toString().replaceFirst("{{total_count}}", "${_quantity??0}").replaceFirst("{{total_sum}}", "${_currency??"€"}${f.format(_totalAmount??0)}"),overflow: TextOverflow.fade,maxLines: 1,):Container(),
    //             centerTitle: true,
    //             backgroundColor: Colors.transparent,
    //             leading:
    //             InkWell(radius: 20,child: Icon(IconData(58829, fontFamily: 'MaterialIcons')),
    //             onTap: (){
    //               Navigator.pop(context);
    //               },
    //             ),
    //           ),
    //           body:
    //             Column(
    //               children: <Widget>[
    //                 widget.isLoading.value?Container(): Container(
    //                       padding: EdgeInsets.only(bottom: Measurements.height * 0.02,left: Measurements.width* (_isTablet?0.01:0.05),right: Measurements.width* (_isTablet?0.01:0.05)),
    //                       child: Container(
    //                         decoration: BoxDecoration(
    //                           color: Colors.black.withOpacity(0.2),
    //                           borderRadius: BorderRadius.circular(12),
    //                           ),
    //                         padding:EdgeInsets.only(left: Measurements.width* (_isTablet?0.01:0.025)),
    //                         child: TextFormField(
    //                           decoration: InputDecoration(
    //                             hintText: "Search",
    //                             border: InputBorder.none,
    //                             icon: Container(child:SvgPicture.asset("assets/images/searchIcon.svg",height: Measurements.height * 0.0175,color:Colors.white,))
    //                           ),
    //                           onFieldSubmitted: (search){
    //                             widget.search = search;
    //                             widget.isLoadingSearch.value = true;
    //                             widget.data.transaction.collection.clear();
    //                             fetchTransactions(init: false,search: search);
    //                           },
    //                         ),
    //                       ),
    //                     ),
    //                 widget.isLoadingSearch.value||widget.isLoading.value? Expanded(child:Center(child:CircularProgressIndicator(),)) : Expanded(child:CustomList(widget._currentBusiness,widget.search,widget.data.transaction.collection,widget.data)),
    //               ],
    //             )
    //         ),
    //       )
    //     )
    //   ],
    // );
  }
}

class CustomList extends StatefulWidget {
  final Business currentBusiness;
  final String search;
  final List<Collection> collection;
  final TransactionScreenData data;

  CustomList(this.currentBusiness, this.search, this.collection, this.data);

  @override
  _CustomListState createState() => _CustomListState();
}

class _CustomListState extends State<CustomList> {
  ScrollController controller;
  ValueNotifier isLoading = ValueNotifier(false);

  int page = 1;
  int pageCount;

  @override
  void initState() {
    super.initState();

    controller = ScrollController()..addListener(_scrollListener);
  }

  void _scrollListener() {
    pageCount = (widget.data.transaction.paginationData.total / 50).ceil();
    if (controller.position.extentAfter < 500) {
      if (page < pageCount && !isLoading.value) {
        setState(() {
          isLoading.value = true;
        });
        page++;
        TransactionsApi()
            .getTransactionList(
                widget.currentBusiness.id,
                GlobalUtils.activeToken.accessToken,
                "?orderBy=created_at&direction=desc&limit=50&query=${widget.search}&page=$page&currency=${widget.currentBusiness.currency}",
                context)
            .then((transaction) {
          List<Collection> temp = Transaction.toMap(transaction).collection;
          if (temp.isNotEmpty) {
            setState(() {
              isLoading.value = false;
              widget.collection.addAll(temp);
            });
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {

    return ListView.builder(
      key: GlobalKeys.transactionList,
      shrinkWrap: true,
      controller: controller,
      itemCount: widget.collection.length + 1,
      itemBuilder: (BuildContext context, int index) {
        if (index == 0)
          return _isTablet
              ? TabletTableRow(null, true, null)
              : PhoneTableRow(null, true, null);
        index = index - 1;
        Key itemKey = Key('transaction.list.transaction_$index');

        return Container(
            key: itemKey,
            child: _isTablet
                ? TabletTableRow(widget.collection[index], false, widget.data)
                : PhoneTableRow(widget.collection[index], false, widget.data));
      },
    );
  }
}

class PhoneTableRow extends StatelessWidget {
  final Collection currentTransaction;
  final TransactionScreenData data;
  final bool isHeader;

  PhoneTableRow(this.currentTransaction, this.isHeader, this.data);

  final f = NumberFormat("###,###.00", "en_US");

  @override
  Widget build(BuildContext context) {
    DateTime time;
    if (currentTransaction != null)
      time = DateTime.parse(currentTransaction.createdAt);

    return InkWell(
      highlightColor: Colors.transparent,
      child: Container(
        //alignment: Alignment.topCenter,

        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            Container(
              padding: AppStyle.listRowPadding(false),
              height: AppStyle.listRowSize(false),
              child: Row(
                children: <Widget>[
                  Expanded(
//                    flex: _isPortrait ? 2 : 1.2,
                    flex: 2,
                    child: Container(
                      alignment: Alignment.centerLeft,
                      child: !isHeader
                          ? TransactionScreenParts.channelIcon(
                              currentTransaction.channel)
                          : Container(
                              child: Text(
                              Language.getTransactionStrings(
                                  "form.filter.labels.channel"),
                              style: TextStyle(
                                  fontSize: AppStyle.fontSizeListRow()),
                            )),
                    ),
                  ),
                  Expanded(
//                    flex: _isPortrait ? 2 : 1,
                    flex: 2,
                    child: Container(
                      alignment: Alignment.centerLeft,
                      child: !isHeader
                          ? TransactionScreenParts.paymentType(
                              currentTransaction.type)
                          : Container(
                              child: Text(
                                  Language.getTransactionStrings(
                                      "form.filter.labels.type"),
                                  style: TextStyle(
                                      fontSize: AppStyle.fontSizeListRow())),
                            ),
                    ),
                  ),
                  Expanded(
                    flex: _isPortrait ? 6 : 5,
                    child: Container(
                      child: !isHeader
                          ? Text(
                              currentTransaction.customerName,
                              style: TextStyle(
                                  fontSize: AppStyle.fontSizeListRow()),
                            )
                          : Text(
                              Language.getTransactionStrings(
                                  "form.filter.labels.customer_name"),
                              style: TextStyle(
                                  fontSize: AppStyle.fontSizeListRow())),
                    ),
                  ),
                  Expanded(
                    flex: _isPortrait ? 3 : 3,
                    child: Container(
                      child: !isHeader
                          ? Text(
                              "${Measurements.currency(currentTransaction.currency)}${f.format(currentTransaction.total)}",
                              style: TextStyle(
                                  fontSize: AppStyle.fontSizeListRow()),
                            )
                          : Text(
                              Language.getTransactionStrings(
                                  "form.filter.labels.total"),
                              style: TextStyle(
                                  fontSize: AppStyle.fontSizeListRow())),
                    ),
                  ),
                  Expanded(
                    flex: _isPortrait ? 0 : 4,
                    child: !_isPortrait
                        ? Container(
                            child: !isHeader
                                ? Text(
                                    "${DateFormat.d("en_US").add_MMMM().add_y().format(time)} ${DateFormat.Hm("en_US").format(time.add(Duration(hours: 2)))}",
                                    style: TextStyle(
                                        fontSize: AppStyle.fontSizeListRow()))
                                : Text(
                                    Language.getTransactionStrings(
                                        "form.filter.labels.created_at"),
                                    style: TextStyle(
                                        fontSize: AppStyle.fontSizeListRow())),
                          )
                        : Container(),
                  ),
                  Expanded(
                    flex: _isPortrait ? 0 : 3,
                    child: !_isPortrait
                        ? Container(
                            width: Measurements.width *
                                (_isPortrait ? 0.20 : 0.24),
                            child: !isHeader
                                ? Measurements.statusWidget(
                                    currentTransaction.status)
                                : AutoSizeText(
                                    Language.getTransactionStrings(
                                        "form.filter.labels.status"),
                                    style: TextStyle(
                                        fontSize: AppStyle.fontSizeListRow())),
                          )
                        : Container(),
                  ),
                  Expanded(
                    flex: 1,
                    child: !_isPortrait
                        ? Container()
                        : Container(
                            width: Measurements.width * 0.02,
                            child: !isHeader
                                ? Icon(
                                    IconData(58849,
                                        fontFamily: 'MaterialIcons'),
                                    size: Measurements.width * 0.04,
                                  )
                                : Container(),
                          ),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: Colors.white.withOpacity(0.5)),
          ],
        ),
      ),
      onTap: () {
        if (!isHeader) {
          TransactionsApi api = TransactionsApi();
          GlobalStateModel globalStateModel =
              Provider.of<GlobalStateModel>(context);
          showDialog(
              context: context,
              barrierDismissible: false,
              builder: (BuildContext context) {
                api
                    .getTransactionDetail(
                        globalStateModel.currentBusiness.id,
                        GlobalUtils.activeToken.accessToken,
                        currentTransaction.uuid,
                        context)
                    .then((obj) {
                  var td = TransactionDetails.toMap(obj);
                  Navigator.pop(context);
                  Navigator.push(
                      context,
                      PageTransition(
                          child: TransactionDetailsScreen(td),
                          type: PageTransitionType.fade));
                }).catchError((onError) {
                  if (onError.toString().contains("401")) {
                    GlobalUtils.clearCredentials();
                    Navigator.pushReplacement(
                        context,
                        PageTransition(
                            child: LoginScreen(),
                            type: PageTransitionType.fade));
                  } else {
                    Navigator.pop(context);
                    print(onError);
                  }
                });
                return Container(
                  child: Dialog(
                    backgroundColor: Colors.transparent,
                    child: Center(
                      child: Container(child: CircularProgressIndicator()),
                    ),
                  ),
                );
              });
        }
      },
    );
  }
}

class TabletTableRow extends StatelessWidget {
  final Collection currentTransaction;
  final TransactionScreenData data;
  final bool isHeader;

  TabletTableRow(this.currentTransaction, this.isHeader, this.data);

  final f = NumberFormat("###,##0.00", "en_US");

  @override
  Widget build(BuildContext context) {
    GlobalStateModel globalStateModel = Provider.of<GlobalStateModel>(context);

    DateTime time;
    if (currentTransaction != null)
      time = DateTime.parse(currentTransaction.createdAt);
    return InkWell(
      highlightColor: Colors.transparent,
      child: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            Container(
              height: AppStyle.listRowSize(true),
              padding: AppStyle.listRowPadding(true),
              child: Row(
                children: <Widget>[
                  Expanded(
                    flex: 2,
                    child: Container(
                      alignment: Alignment.center,
                      child: !isHeader
                          ? Container(
//                          alignment: _isPortrait ? Alignment.centerLeft : Alignment.center,
                              alignment: Alignment.center,
                              child: TransactionScreenParts.channelIcon(
                                  currentTransaction.channel))
                          : Container(
                              child: AutoSizeText(
                              Language.getTransactionStrings(
                                  "form.filter.labels.channel"),
                              style: TextStyle(
                                  fontSize: AppStyle.fontSizeListRow()),
                            )),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Container(
                      alignment: Alignment.center,
                      child: !isHeader
                          ? Container(
                              alignment: Alignment.center,
                              child: TransactionScreenParts.paymentType(
                                  currentTransaction.type))
                          : Container(
                              child: AutoSizeText(
                                  Language.getTransactionStrings(
                                      "form.filter.labels.type"),
                                  style: TextStyle(
                                      fontSize: AppStyle.fontSizeListRow()))),
                    ),
                  ),
                  Expanded(
                    flex: 12,
                    child: Container(
                      child: !isHeader
                          ? AutoSizeText("#${currentTransaction.originalId}",
                              style: TextStyle(
                                  fontSize: AppStyle.fontSizeListRow()))
                          : AutoSizeText(
                              Language.getTransactionStrings(
                                  "form.filter.labels.original_id"),
                              maxLines: 1,
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                  fontSize: AppStyle.fontSizeListRow())),
                    ),
                  ),
                  Expanded(
                    flex: 6,
                    child: Container(
                      child: !isHeader
                          ? AutoSizeText(currentTransaction.customerName,
                              style: TextStyle(
                                  fontSize: AppStyle.fontSizeListRow()))
                          : AutoSizeText(
                              Language.getTransactionStrings(
                                  "form.filter.labels.customer_name"),
                              maxLines: 1,
                              style: TextStyle(
                                  fontSize: AppStyle.fontSizeListRow())),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Container(
                      child: !isHeader
                          ? AutoSizeText(
                              "${Measurements.currency(currentTransaction.currency)}${f.format(currentTransaction.total)}",
                              style: TextStyle(
                                  fontSize: AppStyle.fontSizeListRow()))
                          : AutoSizeText(
                              Language.getTransactionStrings(
                                  "form.filter.labels.total"),
                              maxLines: 1,
                              style: TextStyle(
                                  fontSize: AppStyle.fontSizeListRow())),
                    ),
                  ),
                  Expanded(
                    flex: 6,
                    child: Container(
                      child: !isHeader
                          ? AutoSizeText(
                              "${DateFormat.d("en_US").add_MMMM().add_y().format(time)} ${DateFormat.Hm("en_US").format(time.add(Duration(hours: 2)))}",
                              style: TextStyle(
                                  fontSize: AppStyle.fontSizeListRow()))
                          : Text(
                              Language.getTransactionStrings(
                                  "form.filter.labels.created_at"),
                              style: TextStyle(
                                  fontSize: AppStyle.fontSizeListRow())),
                    ),
                  ),
                  Expanded(
                    flex: 4,
                    child: Container(
                      width: Measurements.width * (_isPortrait ? 0.13 : 0.15),
                      child: !isHeader
                          ? Measurements.statusWidget(currentTransaction.status)
                          : Text(Language.getTransactionStrings("form.filter.labels.status"),style: TextStyle(fontSize: AppStyle.fontSizeListRow())),
                    ),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: Colors.white.withOpacity(0.5)),
          ],
        ),
      ),
      onTap: () {
        if (!isHeader) {
          TransactionsApi api = TransactionsApi();
          showDialog(
              context: context,
              barrierDismissible: false,
              builder: (BuildContext context) {
                api
                    .getTransactionDetail(
                        globalStateModel.currentBusiness.id,
                        GlobalUtils.activeToken.accessToken,
                        currentTransaction.uuid,
                        context)
                    .then((obj) {
                  var td = TransactionDetails.toMap(obj);
                  Navigator.pop(context);
                  Navigator.push(
                      context,
                      PageTransition(
                          child: TransactionDetailsScreen(td),
                          type: PageTransitionType.fade));
                }).catchError((onError) {
                  Navigator.pop(context);
                  print(onError);
                });
                return BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                  child: Container(
                    child: Dialog(
                      backgroundColor: Colors.transparent,
                      child: Center(
                        child: Container(child: CircularProgressIndicator()),
                      ),
                    ),
                  ),
                );
              });
        }
      },
    );
  }
}

class TransactionScreenParts {
  static channelIcon(String channel) {
    double size = AppStyle.iconRowSize(_isTablet);
    return SvgPicture.asset(Measurements.channelIcon(channel), height: size);
  }

  static paymentType(String type) {
    double size = AppStyle.iconRowSize(_isTablet);
    Color _color = Colors.white.withOpacity(0.7);
    return SvgPicture.asset(
      Measurements.paymentType(type),
      height: size,
      color: _color,
    );
  }
}
