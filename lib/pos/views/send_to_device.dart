import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:page_transition/page_transition.dart';

import '../view_models/view_models.dart';
import '../network/network.dart';
import '../utils/utils.dart';
import 'webview_section.dart';

class SendToDevice extends StatefulWidget {
  final PosStateModel parts;
  final int index;

  SendToDevice({@required this.parts, this.index});

  @override
  createState() => _SendToDeviceState();
}

class _SendToDeviceState extends State<SendToDevice> {
  String checkoutUrl;
  String email;
  String phone;

  NumberTextInputFormatter phoneFormatter = NumberTextInputFormatter();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.light(),
      child: Form(
          key: formKey,
          child: Container(
            child: Column(
              children: <Widget>[
                Container(
                  decoration: BoxDecoration(),
                  child: TextFormField(
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(8),
                              topRight: Radius.circular(8))),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(8),
                              topRight: Radius.circular(8))),
                      hintText: "Phone number",
                    ),
                    autovalidate: true,
                    validator: (phone) {
                      String patttern = r'(^([+0#])?[0-9]{12}$)';
                      RegExp regExp = new RegExp(patttern);
                      if (phone.length == 0) {
                        return null;
                      } else if (!regExp.hasMatch(phone)) {
                        return 'Please enter valid mobile number';
                      }
                      return null;
                    },
                    onSaved: (phone) {
                      phone = phone;
                    },
                    inputFormatters: <TextInputFormatter>[
                      WhitelistingTextInputFormatter.digitsOnly,
                      phoneFormatter,
                    ],
                  ),
                ),
                Container(
                  child: TextFormField(
                    decoration: InputDecoration(
                      hintText: "E-Mail Address",
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(8),
                              bottomRight: Radius.circular(8))),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(8),
                              bottomRight: Radius.circular(8))),
                    ),
                    onSaved: (email) {
                      email = email;
                    },
                    validator: (email) {
                      if (email.isNotEmpty) if (!email.contains("@") ||
                          !email.contains(".")) {
                        return 'Enter valid email address';
                      }
                      return '';
                    },
                  ),
                ),
                Container(
                  height: Measurements.height * 0.07,
                  padding: EdgeInsets.symmetric(
                      vertical: Measurements.height * 0.01),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      InkWell(
                        child: Container(
                            height: Measurements.height * 0.06,
                            width: Measurements.width * 0.4,
                            alignment: Alignment.center,
                            child: Text(
                              "skip",
                              style: TextStyle(color: Colors.black),
                            )),
                        onTap: () {
                          widget.parts.updateOpenSection(widget.index + 1);
                        },
                      ),
                      InkWell(
                        child: Container(
                            decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(8)),
                            width: Measurements.width * 0.4,
                            alignment: Alignment.center,
                            child: Text(
                              "Continue",
                              style: TextStyle(),
                            )),
                        onTap: () {
                          if (formKey.currentState.validate()) {
                            formKey.currentState.save();
                            if (email.isNotEmpty || phone.isNotEmpty)
                              PosApi()
                                  .postStorageSimple(
                                      GlobalUtils.activeToken.accessToken,
//                                      Cart.items2MapSimple(
//                                          widget.parts.shoppingCart.items),
                                      [],
                                      null,
                                      true,
                                      true,
                                      phone.replaceAll(" ", ""),
                                      DateTime.now()
                                          .subtract(Duration(hours: 2))
                                          .add(Duration(minutes: 1))
                                          .toIso8601String(),
                                      widget.parts.currentTerminal.channelSet,
                                      true)
                                  .then((obj) {
                                print(obj);
                                //widget.parts.url = Env.Wrapper + "/pay/restore-flow-from-code/" + obj["id"];
                                Navigator.push(
                                    context,
                                    PageTransition(
                                        child: WebViewPayments(
                                          posStateModel: widget.parts,
                                        ),
                                        type: PageTransitionType.fade));
                              }).catchError((onError) {
                                print(onError);
                              });
                          }
                        },
                      )
                    ],
                  ),
                )
              ],
            ),
          )),
    );
  }
}

class NumberTextInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final int newTextLength = newValue.text.length;
    int selectionIndex = newValue.selection.end;
    int usedSubstringIndex = 0;
    final StringBuffer newText = StringBuffer();
    if (newTextLength >= 1) {
      newText.write('+');
      if (newValue.selection.end >= 1) selectionIndex++;
    }
    if ((newTextLength >= usedSubstringIndex))
      newText.write(newValue.text.substring(usedSubstringIndex));
    return TextEditingValue(
      text: newText.toString(),
      selection: TextSelection.collapsed(offset: selectionIndex),
    );
  }
}
