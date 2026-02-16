import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:provider/provider.dart';
import 'package:thinkcreative_technologies/Configs/app_constants.dart';
import 'package:thinkcreative_technologies/Localization/language_constants.dart';
import 'package:thinkcreative_technologies/Models/userapp_settings_model.dart';
import 'package:thinkcreative_technologies/Services/my_providers/session_provider.dart';
import 'package:thinkcreative_technologies/Utils/utils.dart';
import 'package:thinkcreative_technologies/Configs/my_colors.dart';
import 'package:thinkcreative_technologies/Utils/delayed_function.dart';
import 'package:thinkcreative_technologies/Widgets/Input_box.dart';
import 'package:thinkcreative_technologies/Widgets/dialogs/CustomDialog.dart';
import 'package:thinkcreative_technologies/Widgets/dialogs/FormDialog.dart';
import 'package:thinkcreative_technologies/Widgets/dialogs/loadingDialog.dart';
import 'package:thinkcreative_technologies/Widgets/headers/sectionheaders.dart';
import 'package:thinkcreative_technologies/Widgets/my_scaffold.dart';
import 'package:thinkcreative_technologies/Utils/custom_tiles.dart';

class CustomTabSettings extends StatefulWidget {
  final String currentuserid;
  final DocumentReference docRef;
  CustomTabSettings({required this.docRef, required this.currentuserid});
  @override
  _CustomTabSettingsState createState() => _CustomTabSettingsState();
}

class _CustomTabSettingsState extends State<CustomTabSettings> {
  bool isloading = true;

  TextEditingController _controller = new TextEditingController();
  final GlobalKey<State> _keyLoader =
      new GlobalKey<State>(debugLabel: '272hu1');

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  void initState() {
    super.initState();
    fetchdata();
  }

  String error = "";
  UserAppSettingsModel? userAppSettings;
  fetchdata() async {
    await widget.docRef.get().then((dc) async {
      if (dc.exists) {
        userAppSettings = UserAppSettingsModel.fromSnapshot(dc);
        setState(() {
          isloading = false;
        });
      } else {
        setState(() {
          error = getTranslatedForCurrentUser(
              this.context, 'xxuserappsetupincompletexx');
        });
      }
    }).catchError((onError) {
      setState(() {
        error =
            "${getTranslatedForCurrentUser(this.context, 'xxuserappsetupincompletexx')}. $onError";

        isloading = false;
      });
    });
  }

  confirmchangeswitch({
    required BuildContext context,
    bool? currentlbool,
    String? toONmessage,
    String? toOFFmessage,
    required UserAppSettingsModel updatedmodel,
  }) {
    ShowConfirmDialog().open(
        context: this.context,
        subtitle: currentlbool == false
            ? toONmessage ??
                getTranslatedForCurrentUser(this.context, 'xxxxturnonxxx')
            : toOFFmessage ??
                getTranslatedForCurrentUser(this.context, 'xxxxturnoffxxx'),
        title: getTranslatedForCurrentUser(this.context, 'xxxxalertxxx'),
        rightbtnonpress: AppConstants.isdemomode == true
            ? () {
                Utils.toast(getTranslatedForCurrentUser(
                    this.context, 'xxxnotalwddemoxxaccountxx'));
              }
            : () async {
                final session =
                    Provider.of<CommonSession>(this.context, listen: false);
                Navigator.pop(this.context);
                ShowLoading().open(context: this.context, key: _keyLoader);
                await widget.docRef
                    .update(updatedmodel.toMap())
                    .then((value) async {
                  ShowLoading().close(context: this.context, key: _keyLoader);
                  setState(() {
                    userAppSettings = updatedmodel;
                  });

                  ShowSnackbar().open(
                      context: this.context,
                      scaffoldKey: _scaffoldKey,
                      status: 2,
                      time: 2,
                      label: getTranslatedForCurrentUser(
                          this.context, 'xxsuccessvalueupdatedxx'));
                  session.setUserAppSettingFromFirestore();
                }).catchError((error) {
                  ShowLoading().close(context: this.context, key: _keyLoader);
                  print('Error: $error');
                  ShowSnackbar().open(
                      context: this.context,
                      scaffoldKey: _scaffoldKey,
                      status: 1,
                      time: 3,
                      label:
                          '${getTranslatedForCurrentUser(this.context, 'xxxfailedntryagainxxx')}\n $error');
                });
              });
  }

  fieldupdate(
      {required BuildContext context,
      required UserAppSettingsModel updatedmodel,
      p}) async {
    final session = Provider.of<CommonSession>(this.context, listen: false);
    Navigator.pop(this.context);
    ShowLoading().open(context: this.context, key: _keyLoader);
    await widget.docRef.update(updatedmodel.toMap()).then((value) async {
      ShowLoading().close(context: this.context, key: _keyLoader);
      setState(() {
        userAppSettings = updatedmodel;
      });
      _controller.clear();
      ShowSnackbar().open(
          context: this.context,
          scaffoldKey: _scaffoldKey,
          status: 2,
          time: 2,
          label: getTranslatedForCurrentUser(
              this.context, 'xxsuccessvalueupdatedxx'));
      session.setUserAppSettingFromFirestore();
    }).catchError((error) {
      ShowLoading().close(context: this.context, key: _keyLoader);
      print('Error: $error');
      ShowSnackbar().open(
          context: this.context,
          scaffoldKey: _scaffoldKey,
          status: 1,
          time: 3,
          label:
              '${getTranslatedForCurrentUser(this.context, 'xxxfailedntryagainxxx')}\n $error');
    });
  }

  @override
  Widget build(BuildContext context) {
    return MyScaffold(
        scaffoldkey: _scaffoldKey,
        titlespacing: 0,
        title: getTranslatedForCurrentUser(this.context, 'xxxcustomtabsxxx'),
        body: error != ""
            ? Center(
                child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text(
                      error,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Mycolors.red),
                    )),
              )
            : isloading == true
                ? circularProgress()
                : ListView(padding: EdgeInsets.only(top: 4), children: [
                    sectionHeader(
                      // russian lang has different tag for this string
                      Utils.checkIfNull(getTranslatedForCurrentUser(
                              this.context, 'xxru13xx')) ??
                          getTranslatedForCurrentUser(
                                  this.context, 'xxxxforxxx')
                              .replaceAll('(####)',
                                  '${getTranslatedForCurrentUser(this.context, 'xxcustomersxx')}')
                              .toUpperCase(),
                    ),
                    customTile(
                        ishighlightdesc:
                            userAppSettings!.customersLandingCustomTabURL != "",
                        margin: 5,
                        iconsize: 30,
                        trailingicondata: Icons.edit_outlined,
                        title: getTranslatedForCurrentUser(
                            this.context, 'xxxxwebsiteurlxxx'),
                        subtitle: userAppSettings!
                                    .customersLandingCustomTabURL ==
                                ""
                            ? getTranslatedForCurrentUser(this.context,
                                    'xxxwebsiteurlwillbeopenedinacustomertabxxx')
                                .replaceAll('(####)',
                                    '${getTranslatedForCurrentUser(this.context, 'xxcustomerxx')}')
                            : userAppSettings!.customersLandingCustomTabURL,
                        leadingicondata: Icons.settings_applications_rounded,
                        ontap: () {
                          _controller.text =
                              userAppSettings!.customersLandingCustomTabURL!;
                          ShowFormDialog().open(
                              iscapital: false,
                              controller: _controller,
                              maxlength: 800,
                              maxlines: 4,
                              minlines: 2,
                              iscentrealign: true,
                              context: this.context,
                              title:
                                  '${getTranslatedForCurrentUser(this.context, 'xxxxwebsiteurlxxx')} ${getTranslatedForCurrentUser(this.context, 'xxxxforxxx').replaceAll('(####)', '${getTranslatedForCurrentUser(this.context, 'xxcustomersxx')}')}',
                              onpressed: AppConstants.isdemomode == true
                                  ? () {
                                      Utils.toast(getTranslatedForCurrentUser(
                                          this.context,
                                          'xxxnotalwddemoxxaccountxx'));
                                    }
                                  : () async {
                                      if (_controller.text.trim().length > 2 &&
                                          !_controller.text
                                              .trim()
                                              .startsWith("http")) {
                                        ShowSnackbar().open(
                                            context: this.context,
                                            scaffoldKey: _scaffoldKey,
                                            time: 3,
                                            label: getTranslatedForCurrentUser(
                                                this.context,
                                                'xxxplssenteravalidurlxxx'));
                                        delayedFunction(setstatefn: () {
                                          ShowSnackbar().close(
                                            context: this.context,
                                            scaffoldKey: _scaffoldKey,
                                          );
                                        });
                                      } else {
                                        await fieldupdate(
                                            context: this.context,
                                            updatedmodel: userAppSettings!.copyWith(
                                                customersLandingCustomTabURL:
                                                    _controller.text.trim(),
                                                notifcationpostedby:
                                                    widget.currentuserid,
                                                notificationtime: DateTime.now()
                                                    .millisecondsSinceEpoch,
                                                notificationtitle:
                                                    "customersLandingCustomTabURL updated",
                                                notificationdesc:
                                                    "customersLandingCustomTabURL - is set to ${_controller.text.trim()}"));
                                      }
                                    },
                              buttontext: getTranslatedForCurrentUser(
                                  this.context, 'xxupdatexx'),
                              hinttext:
                                  '${getTranslatedForCurrentUser(this.context, 'xxxxwebsiteurlxxx')}');
                        }),
                    userAppSettings!.customersLandingCustomTabURL == ""
                        ? SizedBox()
                        : customTile(
                            ishighlightdesc:
                                userAppSettings!.customerCustomTabLabel != "",
                            margin: 5,
                            iconsize: 30,
                            trailingicondata: Icons.edit_outlined,
                            title: getTranslatedForCurrentUser(
                                this.context, 'xxxcustomtablabelxxx'),
                            subtitle:
                                userAppSettings!.customerCustomTabLabel == ""
                                    ? getTranslatedForEventsAndAlerts(
                                        this.context, 'xxhomexx')
                                    : userAppSettings!.customerCustomTabLabel,
                            leadingicondata:
                                Icons.settings_applications_rounded,
                            ontap: () {
                              _controller.text =
                                  userAppSettings!.customerCustomTabLabel!;
                              ShowFormDialog().open(
                                iscapital: false,
                                controller: _controller,
                                maxlength: 800,
                                maxlines: 4,
                                minlines: 2,
                                iscentrealign: true,
                                context: this.context,
                                title:
                                    '${getTranslatedForCurrentUser(this.context, 'xxcustomersxx')} ${getTranslatedForCurrentUser(this.context, 'xxxcustomtablabelxxx')}',
                                onpressed: AppConstants.isdemomode == true
                                    ? () {
                                        Utils.toast(getTranslatedForCurrentUser(
                                            this.context,
                                            'xxxnotalwddemoxxaccountxx'));
                                      }
                                    : () async {
                                        await fieldupdate(
                                            context: this.context,
                                            updatedmodel: userAppSettings!.copyWith(
                                                customerCustomTabLabel:
                                                    _controller.text.trim(),
                                                notifcationpostedby:
                                                    widget.currentuserid,
                                                notificationtime: DateTime.now()
                                                    .millisecondsSinceEpoch,
                                                notificationtitle:
                                                    "customerCustomTabLabel updated",
                                                notificationdesc:
                                                    "customerCustomTabLabel - is set to ${_controller.text.trim()}"));
                                        // }
                                      },
                                buttontext: getTranslatedForCurrentUser(
                                    this.context, 'xxupdatexx'),
                              );
                            }),
                    userAppSettings!.customersLandingCustomTabURL == ""
                        ? SizedBox()
                        : Card(
                            elevation: 0.1,
                            margin: EdgeInsets.all(4),
                            child: InputGroup4Large(
                              title: getTranslatedForCurrentUser(
                                  this.context, 'xxxtabpositionxxx'),
                              val1: "0",
                              val1String: getTranslatedForCurrentUser(
                                  this.context, 'xxx1stxxx'),
                              val2: "1",
                              val2String: getTranslatedForCurrentUser(
                                  this.context, 'xxx2ndxxx'),
                              val3: "2",
                              val3String: getTranslatedForCurrentUser(
                                  this.context, 'xxx2ndlastxxx'),
                              val4: "3",
                              val4String: getTranslatedForCurrentUser(
                                  this.context, 'xxxlastxxx'),
                              selectedvalue: userAppSettings!
                                  .customerTabIndexPosition
                                  .toString(),
                              onChanged: AppConstants.isdemomode == true
                                  ? (val) {
                                      Utils.toast(getTranslatedForCurrentUser(
                                          this.context,
                                          'xxxnotalwddemoxxaccountxx'));
                                    }
                                  : (val) async {
                                      userAppSettings = userAppSettings!.copyWith(
                                          customerTabIndexPosition:
                                              int.tryParse(val!),
                                          notifcationpostedby:
                                              widget.currentuserid,
                                          notificationtime: DateTime.now()
                                              .millisecondsSinceEpoch,
                                          notificationtitle:
                                              "Custom tab settings updated",
                                          notificationdesc:
                                              "customerTabIndexPosition - is set to ${Utils.getCallValueText(int.tryParse(val)!)}");
                                      await widget.docRef
                                          .update(userAppSettings!.toMap())
                                          .then((value) {
                                        setState(() {});
                                        ShowSnackbar().open(
                                            context: this.context,
                                            scaffoldKey: _scaffoldKey,
                                            status: 2,
                                            time: 2,
                                            label: getTranslatedForCurrentUser(
                                                this.context,
                                                'xxsuccessvalueupdatedxx'));
                                      });
                                    },
                            ),
                          ),
                    userAppSettings!.customersLandingCustomTabURL == ""
                        ? SizedBox()
                        : customTile(
                            margin: 5,
                            iconsize: 30,
                            trailingWidget: Container(
                              margin: EdgeInsets.only(right: 3, top: 5),
                              width: 50,
                              height: 19,
                              child: FlutterSwitch(
                                  activeText: '',
                                  inactiveText: '',
                                  width: 46.0,
                                  activeColor: Mycolors.green.withOpacity(0.85),
                                  inactiveColor: Mycolors.grey,
                                  height: 19.0,
                                  valueFontSize: 12.0,
                                  toggleSize: 15.0,
                                  value: userAppSettings!
                                          .isShowHeaderCustomersTab ??
                                      false,
                                  borderRadius: 25.0,
                                  padding: 3.0,
                                  showOnOff: true,
                                  onToggle: AppConstants.isdemomode == true
                                      ? (val) {
                                          Utils.toast(
                                              getTranslatedForCurrentUser(
                                                  this.context,
                                                  'xxxnotalwddemoxxaccountxx'));
                                        }
                                      : (val) async {
                                          bool switchvalue = userAppSettings!
                                                  .isShowHeaderCustomersTab ??
                                              false;
                                          await confirmchangeswitch(
                                              context: this.context,
                                              currentlbool: switchvalue,
                                              updatedmodel: userAppSettings!.copyWith(
                                                  isShowHeaderCustomersTab:
                                                      !switchvalue,
                                                  notifcationpostedby:
                                                      widget.currentuserid,
                                                  notificationtime: DateTime
                                                          .now()
                                                      .millisecondsSinceEpoch,
                                                  notificationtitle:
                                                      "Advanced Settings updated",
                                                  notificationdesc:
                                                      "isShowHeaderCustomersTab - is set to ${Utils.getboolText(!switchvalue)}"));
                                        }),
                            ),
                            title: getTranslatedForCurrentUser(
                                this.context, 'xxxxshowheaderxxx'),
                            subtitle:
                                // russian lang has different tag for this string
                                Utils.checkIfNull(getTranslatedForCurrentUser(
                                        this.context, 'xxru16xx')) ??
                                    getTranslatedForCurrentUser(this.context,
                                            'xxxshowheaderdescxxx')
                                        .replaceAll('(####)', 'WebView'),
                            leadingicondata:
                                Icons.settings_applications_rounded),
                    userAppSettings!.customersLandingCustomTabURL == ""
                        ? SizedBox()
                        : customTile(
                            margin: 5,
                            iconsize: 30,
                            trailingWidget: Container(
                              margin: EdgeInsets.only(right: 3, top: 5),
                              width: 50,
                              height: 19,
                              child: FlutterSwitch(
                                  activeText: '',
                                  inactiveText: '',
                                  width: 46.0,
                                  activeColor: Mycolors.green.withOpacity(0.85),
                                  inactiveColor: Mycolors.grey,
                                  height: 19.0,
                                  valueFontSize: 12.0,
                                  toggleSize: 15.0,
                                  value: userAppSettings!
                                          .isShowFooterCustomersTab ??
                                      false,
                                  borderRadius: 25.0,
                                  padding: 3.0,
                                  showOnOff: true,
                                  onToggle: AppConstants.isdemomode == true
                                      ? (val) {
                                          Utils.toast(
                                              getTranslatedForCurrentUser(
                                                  this.context,
                                                  'xxxnotalwddemoxxaccountxx'));
                                        }
                                      : (val) async {
                                          bool switchvalue = userAppSettings!
                                                  .isShowFooterCustomersTab ??
                                              false;
                                          await confirmchangeswitch(
                                              context: this.context,
                                              currentlbool: switchvalue,
                                              updatedmodel: userAppSettings!.copyWith(
                                                  isShowFooterCustomersTab:
                                                      !switchvalue,
                                                  notifcationpostedby:
                                                      widget.currentuserid,
                                                  notificationtime: DateTime
                                                          .now()
                                                      .millisecondsSinceEpoch,
                                                  notificationtitle:
                                                      "Advanced Settings updated",
                                                  notificationdesc:
                                                      "isShowFooterCustomersTab - is set to ${Utils.getboolText(!switchvalue)}"));
                                        }),
                            ),
                            title: // russian lang has different tag for this string
                                Utils.checkIfNull(getTranslatedForCurrentUser(
                                        this.context, 'xxru14xx')) ??
                                    getTranslatedForCurrentUser(
                                        this.context, 'xxxshowfooterxxx'),
                            subtitle: // russian lang has different tag for this string
                                Utils.checkIfNull(getTranslatedForCurrentUser(
                                        this.context, 'xxru17xx')) ??
                                    getTranslatedForCurrentUser(this.context,
                                            'xxxshowfooterdescxxx')
                                        .replaceAll('(####)', 'WebView'),
                            leadingicondata:
                                Icons.settings_applications_rounded),
                    SizedBox(
                      height: 20,
                    ),
                    sectionHeader(
// russian lang has different tag for this string
                      Utils.checkIfNull(getTranslatedForCurrentUser(
                              this.context, 'xxru15xx')) ??
                          getTranslatedForCurrentUser(
                                  this.context, 'xxxxforxxx')
                              .replaceAll('(####)',
                                  '${getTranslatedForCurrentUser(this.context, 'xxagentsxx')}')
                              .toUpperCase(),
                    ),
                    customTile(
                        ishighlightdesc:
                            userAppSettings!.agentsLandingCustomTabURL != "",
                        margin: 5,
                        iconsize: 30,
                        trailingicondata: Icons.edit_outlined,
                        title: getTranslatedForCurrentUser(
                            this.context, 'xxxxwebsiteurlxxx'),
                        subtitle: userAppSettings!.agentsLandingCustomTabURL ==
                                ""
                            ? getTranslatedForCurrentUser(this.context,
                                    'xxxwebsiteurlwillbeopenedinacustomertabxxx')
                                .replaceAll('(####)',
                                    '${getTranslatedForCurrentUser(this.context, 'xxagentxx')}')
                            : userAppSettings!.agentsLandingCustomTabURL,
                        leadingicondata: Icons.settings_applications_rounded,
                        ontap: () {
                          _controller.text =
                              userAppSettings!.agentsLandingCustomTabURL!;
                          ShowFormDialog().open(
                              iscapital: false,
                              controller: _controller,
                              maxlength: 800,
                              maxlines: 4,
                              minlines: 2,
                              iscentrealign: true,
                              context: this.context,
                              title:
                                  '${getTranslatedForCurrentUser(this.context, 'xxxxwebsiteurlxxx')} ${getTranslatedForCurrentUser(this.context, 'xxxxforxxx').replaceAll('(####)', '${getTranslatedForCurrentUser(this.context, 'xxagentsxx')}')}',
                              onpressed: AppConstants.isdemomode == true
                                  ? () {
                                      Utils.toast(getTranslatedForCurrentUser(
                                          this.context,
                                          'xxxnotalwddemoxxaccountxx'));
                                    }
                                  : () async {
                                      if (_controller.text.trim().length > 2 &&
                                          !_controller.text
                                              .trim()
                                              .startsWith("http")) {
                                        ShowSnackbar().open(
                                            context: this.context,
                                            scaffoldKey: _scaffoldKey,
                                            time: 3,
                                            label: getTranslatedForCurrentUser(
                                                this.context,
                                                'xxxplssenteravalidurlxxx'));
                                        delayedFunction(setstatefn: () {
                                          ShowSnackbar().close(
                                            context: this.context,
                                            scaffoldKey: _scaffoldKey,
                                          );
                                        });
                                      } else {
                                        await fieldupdate(
                                            context: this.context,
                                            updatedmodel: userAppSettings!.copyWith(
                                                agentsLandingCustomTabURL:
                                                    _controller.text.trim(),
                                                notifcationpostedby:
                                                    widget.currentuserid,
                                                notificationtime: DateTime.now()
                                                    .millisecondsSinceEpoch,
                                                notificationtitle:
                                                    "agentsLandingCustomTabURL updated",
                                                notificationdesc:
                                                    "agentsLandingCustomTabURL - is set to ${_controller.text.trim()}"));
                                      }
                                    },
                              buttontext: getTranslatedForCurrentUser(
                                  this.context, 'xxupdatexx'),
                              hinttext: getTranslatedForCurrentUser(
                                  this.context, 'xxxxwebsiteurlxxx'));
                        }),
                    userAppSettings!.agentsLandingCustomTabURL == ""
                        ? SizedBox()
                        : customTile(
                            ishighlightdesc:
                                userAppSettings!.agentCustomTabLabel != "",
                            margin: 5,
                            iconsize: 30,
                            trailingicondata: Icons.edit_outlined,
                            title: getTranslatedForCurrentUser(
                                this.context, 'xxxcustomtablabelxxx'),
                            subtitle: userAppSettings!.agentCustomTabLabel == ""
                                ? getTranslatedForEventsAndAlerts(
                                    this.context, 'xxhomexx')
                                : userAppSettings!.agentCustomTabLabel,
                            leadingicondata:
                                Icons.settings_applications_rounded,
                            ontap: () {
                              _controller.text =
                                  userAppSettings!.agentCustomTabLabel!;
                              ShowFormDialog().open(
                                iscapital: false,
                                controller: _controller,
                                maxlength: 800,
                                maxlines: 4,
                                minlines: 2,
                                iscentrealign: true,
                                context: this.context,
                                title:
                                    '${getTranslatedForCurrentUser(this.context, 'xxagentsxx')} ${getTranslatedForCurrentUser(this.context, 'xxxcustomtablabelxxx')}',
                                onpressed: AppConstants.isdemomode == true
                                    ? () {
                                        Utils.toast(getTranslatedForCurrentUser(
                                            this.context,
                                            'xxxnotalwddemoxxaccountxx'));
                                      }
                                    : () async {
                                        await fieldupdate(
                                            context: this.context,
                                            updatedmodel: userAppSettings!.copyWith(
                                                agentCustomTabLabel:
                                                    _controller.text.trim(),
                                                notifcationpostedby:
                                                    widget.currentuserid,
                                                notificationtime: DateTime.now()
                                                    .millisecondsSinceEpoch,
                                                notificationtitle:
                                                    "agentCustomTabLabel updated",
                                                notificationdesc:
                                                    "agentCustomTabLabel - is set to ${_controller.text.trim()}"));
                                        // }
                                      },
                                buttontext: getTranslatedForCurrentUser(
                                    this.context, 'xxupdatexx'),
                              );
                            }),
                    userAppSettings!.agentsLandingCustomTabURL == ""
                        ? SizedBox()
                        : Card(
                            elevation: 0.1,
                            margin: EdgeInsets.all(4),
                            child: InputGroup4Large(
                              title: getTranslatedForCurrentUser(
                                  this.context, 'xxxtabpositionxxx'),
                              val1: "0",
                              val1String: getTranslatedForCurrentUser(
                                  this.context, 'xxx1stxxx'),
                              val2: "1",
                              val2String: getTranslatedForCurrentUser(
                                  this.context, 'xxx2ndxxx'),
                              val3: "2",
                              val3String: getTranslatedForCurrentUser(
                                  this.context, 'xxx2ndlastxxx'),
                              val4: "3",
                              val4String: getTranslatedForCurrentUser(
                                  this.context, 'xxxlastxxx'),
                              selectedvalue: userAppSettings!
                                  .agentTabIndexPosition
                                  .toString(),
                              onChanged: AppConstants.isdemomode == true
                                  ? (val) {
                                      Utils.toast(getTranslatedForCurrentUser(
                                          this.context,
                                          'xxxnotalwddemoxxaccountxx'));
                                    }
                                  : (val) async {
                                      userAppSettings = userAppSettings!.copyWith(
                                          agentTabIndexPosition:
                                              int.tryParse(val!),
                                          notifcationpostedby:
                                              widget.currentuserid,
                                          notificationtime: DateTime.now()
                                              .millisecondsSinceEpoch,
                                          notificationtitle:
                                              "Custom tab settings updated",
                                          notificationdesc:
                                              "agentTabIndexPosition - is set to ${Utils.getCallValueText(int.tryParse(val)!)}");
                                      await widget.docRef
                                          .update(userAppSettings!.toMap())
                                          .then((value) {
                                        setState(() {});
                                        ShowSnackbar().open(
                                            context: this.context,
                                            scaffoldKey: _scaffoldKey,
                                            status: 2,
                                            time: 2,
                                            label: getTranslatedForCurrentUser(
                                                this.context,
                                                'xxsuccessvalueupdatedxx'));
                                      });
                                    },
                            ),
                          ),
                    userAppSettings!.agentsLandingCustomTabURL == ""
                        ? SizedBox()
                        : customTile(
                            margin: 5,
                            iconsize: 30,
                            trailingWidget: Container(
                              margin: EdgeInsets.only(right: 3, top: 5),
                              width: 50,
                              height: 19,
                              child: FlutterSwitch(
                                  activeText: '',
                                  inactiveText: '',
                                  width: 46.0,
                                  activeColor: Mycolors.green.withOpacity(0.85),
                                  inactiveColor: Mycolors.grey,
                                  height: 19.0,
                                  valueFontSize: 12.0,
                                  toggleSize: 15.0,
                                  value:
                                      userAppSettings!.isShowHeaderAgentsTab ??
                                          false,
                                  borderRadius: 25.0,
                                  padding: 3.0,
                                  showOnOff: true,
                                  onToggle: AppConstants.isdemomode == true
                                      ? (val) {
                                          Utils.toast(
                                              getTranslatedForCurrentUser(
                                                  this.context,
                                                  'xxxnotalwddemoxxaccountxx'));
                                        }
                                      : (val) async {
                                          bool switchvalue = userAppSettings!
                                                  .isShowHeaderAgentsTab ??
                                              false;
                                          await confirmchangeswitch(
                                              context: this.context,
                                              currentlbool: switchvalue,
                                              updatedmodel: userAppSettings!.copyWith(
                                                  isShowHeaderAgentsTab:
                                                      !switchvalue,
                                                  notifcationpostedby:
                                                      widget.currentuserid,
                                                  notificationtime: DateTime
                                                          .now()
                                                      .millisecondsSinceEpoch,
                                                  notificationtitle:
                                                      "Advanced Settings updated",
                                                  notificationdesc:
                                                      "isShowHeaderAgentsTab - is set to ${Utils.getboolText(!switchvalue)}"));
                                        }),
                            ),
                            title: getTranslatedForCurrentUser(
                                this.context, 'xxxxshowheaderxxx'),
                            subtitle: // russian lang has different tag for this string
                                Utils.checkIfNull(getTranslatedForCurrentUser(
                                        this.context, 'xxru16xx')) ??
                                    getTranslatedForCurrentUser(this.context,
                                            'xxxshowheaderdescxxx')
                                        .replaceAll('(####)', 'WebView'),
                            leadingicondata:
                                Icons.settings_applications_rounded),
                    userAppSettings!.agentsLandingCustomTabURL == ""
                        ? SizedBox()
                        : customTile(
                            margin: 5,
                            iconsize: 30,
                            trailingWidget: Container(
                              margin: EdgeInsets.only(right: 3, top: 5),
                              width: 50,
                              height: 19,
                              child: FlutterSwitch(
                                  activeText: '',
                                  inactiveText: '',
                                  width: 46.0,
                                  activeColor: Mycolors.green.withOpacity(0.85),
                                  inactiveColor: Mycolors.grey,
                                  height: 19.0,
                                  valueFontSize: 12.0,
                                  toggleSize: 15.0,
                                  value:
                                      userAppSettings!.isShowFooterAgentsTab ??
                                          false,
                                  borderRadius: 25.0,
                                  padding: 3.0,
                                  showOnOff: true,
                                  onToggle: AppConstants.isdemomode == true
                                      ? (val) {
                                          Utils.toast(
                                              getTranslatedForCurrentUser(
                                                  this.context,
                                                  'xxxnotalwddemoxxaccountxx'));
                                        }
                                      : (val) async {
                                          bool switchvalue = userAppSettings!
                                                  .isShowFooterAgentsTab ??
                                              false;
                                          await confirmchangeswitch(
                                              context: this.context,
                                              currentlbool: switchvalue,
                                              updatedmodel: userAppSettings!.copyWith(
                                                  isShowFooterAgentsTab:
                                                      !switchvalue,
                                                  notifcationpostedby:
                                                      widget.currentuserid,
                                                  notificationtime: DateTime
                                                          .now()
                                                      .millisecondsSinceEpoch,
                                                  notificationtitle:
                                                      "Advanced Settings updated",
                                                  notificationdesc:
                                                      "isShowFooterAgentsTab - is set to ${Utils.getboolText(!switchvalue)}"));
                                        }),
                            ),
                            title: // russian lang has different tag for this string
                                Utils.checkIfNull(getTranslatedForCurrentUser(
                                        this.context, 'xxru14xx')) ??
                                    getTranslatedForCurrentUser(
                                        this.context, 'xxxshowfooterxxx'),
                            subtitle: // russian lang has different tag for this string
                                Utils.checkIfNull(getTranslatedForCurrentUser(
                                        this.context, 'xxru17xx')) ??
                                    getTranslatedForCurrentUser(this.context,
                                            'xxxshowfooterdescxxx')
                                        .replaceAll('(####)', 'WebView'),
                            leadingicondata:
                                Icons.settings_applications_rounded),
                    SizedBox(
                      height: 120,
                    ),
                  ]));
  }
}
