import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:provider/provider.dart';
import 'package:thinkcreative_technologies/Configs/app_constants.dart';
import 'package:thinkcreative_technologies/Localization/language_constants.dart';
import 'package:thinkcreative_technologies/Models/userapp_settings_model.dart';
import 'package:thinkcreative_technologies/Services/my_providers/session_provider.dart';
import 'package:thinkcreative_technologies/Utils/utils.dart';
import 'package:thinkcreative_technologies/Configs/my_colors.dart';
import 'package:thinkcreative_technologies/Utils/delayed_function.dart';
import 'package:thinkcreative_technologies/Widgets/dialogs/CustomDialog.dart';
import 'package:thinkcreative_technologies/Widgets/dialogs/FormDialog.dart';
import 'package:thinkcreative_technologies/Widgets/dialogs/loadingDialog.dart';
import 'package:thinkcreative_technologies/Widgets/headers/sectionheaders.dart';
import 'package:thinkcreative_technologies/Widgets/my_scaffold.dart';
import 'package:thinkcreative_technologies/Utils/custom_tiles.dart';

class AdvancedSettings extends StatefulWidget {
  final String currentuserid;
  final DocumentReference docRef;
  AdvancedSettings({required this.docRef, required this.currentuserid});
  @override
  _AdvancedSettingsState createState() => _AdvancedSettingsState();
}

class _AdvancedSettingsState extends State<AdvancedSettings> {
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
            "${getTranslatedForCurrentUser(this.context, 'xxuserappsetupincompletexx')}. ${onError.toString()}";

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
        title: getTranslatedForCurrentUser(this.context, 'xxadvancesettingsxx'),
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
                    //* -------------------------------

                    sectionHeader(
                        '${getTranslatedForCurrentUser(this.context, 'xxagentxx').toUpperCase()} ${getTranslatedForCurrentUser(this.context, 'xxprofilexxx').toUpperCase()}'),
                    customTile(
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
                                      .agentUnderReviewAfterEditProfile ??
                                  false,
                              borderRadius: 25.0,
                              padding: 3.0,
                              showOnOff: true,
                              onToggle: AppConstants.isdemomode == true
                                  ? (val) {
                                      Utils.toast(getTranslatedForCurrentUser(
                                          this.context,
                                          'xxxnotalwddemoxxaccountxx'));
                                    }
                                  : (val) async {
                                      bool switchvalue = userAppSettings!
                                              .agentUnderReviewAfterEditProfile ??
                                          false;
                                      await confirmchangeswitch(
                                          context: this.context,
                                          currentlbool: switchvalue,
                                          updatedmodel: userAppSettings!.copyWith(
                                              agentUnderReviewAfterEditProfile:
                                                  !switchvalue,
                                              notifcationpostedby:
                                                  widget.currentuserid,
                                              notificationtime: DateTime.now()
                                                  .millisecondsSinceEpoch,
                                              notificationtitle:
                                                  "Advanced Settings updated",
                                              notificationdesc:
                                                  "agentUnderReviewAfterEditProfile - is set to ${Utils.getboolText(!switchvalue)}"));
                                    }),
                        ),
                        title: getTranslatedForCurrentUser(
                            this.context, 'xxxrequirereviewxx'),
                        subtitle: getTranslatedForCurrentUser(
                            this.context, 'xxxeverytimexx'),
                        leadingicondata: Icons.settings_applications_rounded),
                    //* -------------------------------
                    //* -------------------------------

                    sectionHeader(
                        '${getTranslatedForCurrentUser(this.context, 'xxcustomerxx').toUpperCase()} ${getTranslatedForCurrentUser(this.context, 'xxprofilexxx').toUpperCase()}'),

                    customTile(
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
                                      .customerUnderReviewAfterEditProfile ??
                                  false,
                              borderRadius: 25.0,
                              padding: 3.0,
                              showOnOff: true,
                              onToggle: AppConstants.isdemomode == true
                                  ? (val) {
                                      Utils.toast(getTranslatedForCurrentUser(
                                          this.context,
                                          'xxxnotalwddemoxxaccountxx'));
                                    }
                                  : (val) async {
                                      bool switchvalue = userAppSettings!
                                              .customerUnderReviewAfterEditProfile ??
                                          false;
                                      await confirmchangeswitch(
                                          context: this.context,
                                          currentlbool: switchvalue,
                                          updatedmodel: userAppSettings!.copyWith(
                                              customerUnderReviewAfterEditProfile:
                                                  !switchvalue,
                                              notifcationpostedby:
                                                  widget.currentuserid,
                                              notificationtime: DateTime.now()
                                                  .millisecondsSinceEpoch,
                                              notificationtitle:
                                                  "Advanced Settings updated",
                                              notificationdesc:
                                                  "customerUnderReviewAfterEditprofile - is set to ${Utils.getboolText(!switchvalue)}"));
                                    }),
                        ),
                        title: getTranslatedForCurrentUser(
                            this.context, 'xxxrequirereviewxx'),
                        subtitle: getTranslatedForCurrentUser(
                            this.context, 'xxxeverytimexx'),
                        leadingicondata: Icons.settings_applications_rounded),
                    //* -------------------------------

                    sectionHeader(getTranslatedForCurrentUser(
                        this.context, 'xxxgeneralxxx')),
                    customTile(
                        ishighlightdesc: userAppSettings!.feedbackEmail != "",
                        margin: 5,
                        iconsize: 30,
                        trailingicondata: Icons.edit_outlined,
                        title:
                            '${getTranslatedForCurrentUser(this.context, 'xxfeedbackxx')} ${getTranslatedForCurrentUser(this.context, 'xxemailxx')}',
                        subtitle: userAppSettings!.feedbackEmail == ""
                            ? getTranslatedForCurrentUser(
                                this.context, 'xxxenteremailwherexxx')
                            : userAppSettings!.feedbackEmail,
                        leadingicondata: Icons.settings_applications_rounded,
                        ontap: () {
                          _controller.text = userAppSettings!.feedbackEmail!;
                          ShowFormDialog().open(
                              inputFormatter: [
                                FilteringTextInputFormatter.allow(
                                    RegExp("[0-9a-zA-Z,.-_]")),
                              ],
                              iscapital: false,
                              controller: _controller,
                              maxlength: 500,
                              maxlines: 4,
                              minlines: 2,
                              iscentrealign: true,
                              context: this.context,
                              title:
                                  '${getTranslatedForCurrentUser(this.context, 'xxfeedbackxx')} ${getTranslatedForCurrentUser(this.context, 'xxemailxx')}',
                              onpressed: AppConstants.isdemomode == true
                                  ? () {
                                      Utils.toast(getTranslatedForCurrentUser(
                                          this.context,
                                          'xxxnotalwddemoxxaccountxx'));
                                    }
                                  : () async {
                                      if (_controller.text.trim().length < 2 ||
                                          !_controller.text
                                              .trim()
                                              .contains("@")) {
                                        ShowSnackbar().open(
                                            context: this.context,
                                            scaffoldKey: _scaffoldKey,
                                            time: 3,
                                            label: getTranslatedForCurrentUser(
                                                this.context,
                                                'xxvalidemailxx'));
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
                                                feedbackEmail:
                                                    _controller.text.trim(),
                                                notifcationpostedby:
                                                    widget.currentuserid,
                                                notificationtime: DateTime.now()
                                                    .millisecondsSinceEpoch,
                                                notificationtitle:
                                                    "Feedback email updated",
                                                notificationdesc:
                                                    "feedbackEmail - is set to ${_controller.text.trim()}"));
                                      }
                                    },
                              buttontext: getTranslatedForCurrentUser(
                                  this.context, 'xxupdatexx'),
                              hinttext: getTranslatedForCurrentUser(
                                  this.context, 'xxenteremailxx'));
                        }),
                    customTile(
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
                                  userAppSettings!.is24hrsTimeformat ?? false,
                              borderRadius: 25.0,
                              padding: 3.0,
                              showOnOff: true,
                              onToggle: AppConstants.isdemomode == true
                                  ? (val) {
                                      Utils.toast(getTranslatedForCurrentUser(
                                          this.context,
                                          'xxxnotalwddemoxxaccountxx'));
                                    }
                                  : (val) async {
                                      bool switchvalue =
                                          userAppSettings!.is24hrsTimeformat ??
                                              false;
                                      await confirmchangeswitch(
                                          context: this.context,
                                          currentlbool: switchvalue,
                                          updatedmodel: userAppSettings!.copyWith(
                                              is24hrsTimeformat: !switchvalue,
                                              notifcationpostedby:
                                                  widget.currentuserid,
                                              notificationtime: DateTime.now()
                                                  .millisecondsSinceEpoch,
                                              notificationtitle:
                                                  "Advanced Settings updated",
                                              notificationdesc:
                                                  "is24hrsTimeFormat - is set to ${Utils.getboolText(!switchvalue)}"));
                                    }),
                        ),
                        title: getTranslatedForCurrentUser(
                            this.context, 'xxxis24hrtimeformatxx'),
                        subtitle: getTranslatedForCurrentUser(
                            this.context, 'xxxshowtimeampmxx'),
                        leadingicondata: Icons.settings_applications_rounded),
                    customTile(
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
                                      .isPercentProgressShowWhileUploading ??
                                  false,
                              borderRadius: 25.0,
                              padding: 3.0,
                              showOnOff: true,
                              onToggle: AppConstants.isdemomode == true
                                  ? (val) {
                                      Utils.toast(getTranslatedForCurrentUser(
                                          this.context,
                                          'xxxnotalwddemoxxaccountxx'));
                                    }
                                  : (val) async {
                                      bool switchvalue = userAppSettings!
                                              .isPercentProgressShowWhileUploading ??
                                          false;
                                      await confirmchangeswitch(
                                          context: this.context,
                                          currentlbool: switchvalue,
                                          updatedmodel: userAppSettings!.copyWith(
                                              isPercentProgressShowWhileUploading:
                                                  !switchvalue,
                                              notifcationpostedby:
                                                  widget.currentuserid,
                                              notificationtime: DateTime.now()
                                                  .millisecondsSinceEpoch,
                                              notificationtitle:
                                                  "Advanced Settings updated",
                                              notificationdesc:
                                                  "isPercentProgressShowWhileUploading - is set to ${Utils.getboolText(!switchvalue)}"));
                                    }),
                        ),
                        title: getTranslatedForCurrentUser(
                            this.context, 'xxxshowprogresspercentagexx'),
                        subtitle: getTranslatedForCurrentUser(
                            this.context, 'xxxshowprogressxxx'),
                        leadingicondata: Icons.settings_applications_rounded),
                    customTile(
                        ishighlightdesc: true,
                        margin: 5,
                        iconsize: 30,
                        trailingicondata: Icons.edit_outlined,
                        title: getTranslatedForCurrentUser(
                            this.context, 'xxxmaxuploadfilesizexx'),
                        subtitle: userAppSettings!.maxFileSizeAllowedInMB
                                .toString() +
                            "MB  ${getTranslatedForCurrentUser(this.context, 'xxxuserscantabovethisxxx')}",
                        leadingicondata: Icons.settings_applications_rounded,
                        ontap: AppConstants.isdemomode == true
                            ? () {
                                Utils.toast(getTranslatedForCurrentUser(
                                    this.context, 'xxxnotalwddemoxxaccountxx'));
                              }
                            : () {
                                _controller.text = userAppSettings!
                                    .maxFileSizeAllowedInMB
                                    .toString();
                                ShowFormDialog().open(
                                    inputFormatter: [
                                      FilteringTextInputFormatter.allow(RegExp(
                                              "[0-9]") //-- Only Number & Aplhabets
                                          )
                                    ],
                                    iscapital: false,
                                    controller: _controller,
                                    keyboardtype: TextInputType.number,
                                    maxlength: 8,
                                    // maxlines: 4,
                                    // minlines: 2,
                                    iscentrealign: true,
                                    context: this.context,
                                    title: 'MB',
                                    subtitle: "",
                                    onpressed: AppConstants.isdemomode == true
                                        ? () {
                                            Utils.toast(
                                                getTranslatedForCurrentUser(
                                                    this.context,
                                                    'xxxnotalwddemoxxaccountxx'));
                                          }
                                        : () async {
                                            if (_controller.text.trim().length <
                                                    1 ||
                                                _controller.text.trim() ==
                                                    "0") {
                                              // ShowSnackbar().open(
                                              //     context: this.context,
                                              //     scaffoldKey: _scaffoldKey,
                                              //     time: 3,
                                              //     label:
                                              //         'Please enter a valid number');
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
                                                    maxFileSizeAllowedInMB:
                                                        int.tryParse(_controller
                                                            .text
                                                            .trim()),
                                                    notifcationpostedby:
                                                        widget.currentuserid,
                                                    notificationtime: DateTime
                                                            .now()
                                                        .millisecondsSinceEpoch,
                                                    notificationtitle:
                                                        "Advanced Settings updated",
                                                    notificationdesc:
                                                        "maxFileSizeAllowedInMB - is set to ${Utils.getCallValueText(int.tryParse(_controller.text.trim())!)}MB"),
                                              );
                                            }
                                          },
                                    buttontext: getTranslatedForCurrentUser(
                                        this.context, 'xxupdatexx'),
                                    hinttext: 'MB');
                              }),
                    //* -------------------------------
                    sectionHeader(getTranslatedForCurrentUser(
                        this.context, 'xxxappinvitesettingsxx')),
                    customTile(
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
                              value: userAppSettings!.isCustomAppShareLink ??
                                  false,
                              borderRadius: 25.0,
                              padding: 3.0,
                              showOnOff: true,
                              onToggle: AppConstants.isdemomode == true
                                  ? (val) {
                                      Utils.toast(getTranslatedForCurrentUser(
                                          this.context,
                                          'xxxnotalwddemoxxaccountxx'));
                                    }
                                  : (val) async {
                                      bool switchvalue = userAppSettings!
                                              .isCustomAppShareLink ??
                                          false;
                                      await confirmchangeswitch(
                                          context: this.context,
                                          currentlbool: switchvalue,
                                          updatedmodel: userAppSettings!.copyWith(
                                              isCustomAppShareLink:
                                                  !switchvalue,
                                              notifcationpostedby:
                                                  widget.currentuserid,
                                              notificationtime: DateTime.now()
                                                  .millisecondsSinceEpoch,
                                              notificationtitle:
                                                  "Advanced Settings updated",
                                              notificationdesc:
                                                  "isCustomAppShareMessage - is set to ${Utils.getboolText(!switchvalue)}"));
                                    }),
                        ),
                        title: // russian lang has different tag for this string
                            Utils.checkIfNull(getTranslatedForCurrentUser(
                                    this.context, 'xxru12xx')) ??
                                getTranslatedForCurrentUser(
                                    this.context, 'xxxcustomappsharexxx'),
                        subtitle: getTranslatedForCurrentUser(
                            this.context, 'xxxxsharemsgsystemgenxxx'),
                        leadingicondata: Icons.settings_applications_rounded),
                    customTile(
                        ishighlightdesc:
                            userAppSettings!.appShareMessageStringAndroid != "",
                        margin: 5,
                        iconsize: 30,
                        trailingicondata: Icons.edit_outlined,
                        title: getTranslatedForCurrentUser(
                            this.context, 'xxxandroidsharemssgxx'),
                        subtitle:
                            userAppSettings!.appShareMessageStringAndroid == ""
                                ? ""
                                : userAppSettings!
                                    .appShareMessageStringAndroid!,
                        leadingicondata: Icons.settings_applications_rounded,
                        ontap: () {
                          _controller.text = _controller.text = userAppSettings!
                                      .appShareMessageStringAndroid ==
                                  ""
                              ? ""
                              : userAppSettings!.appShareMessageStringAndroid!;
                          ShowFormDialog().open(
                              inputFormatter: [],
                              iscapital: false,
                              controller: _controller,
                              maxlength: 500,
                              maxlines: 4,
                              minlines: 2,
                              iscentrealign: true,
                              context: this.context,
                              title: getTranslatedForCurrentUser(
                                  this.context, 'xxmssgxx'),
                              onpressed: AppConstants.isdemomode == true
                                  ? () {
                                      Utils.toast(getTranslatedForCurrentUser(
                                          this.context,
                                          'xxxnotalwddemoxxaccountxx'));
                                    }
                                  : () async {
                                      if (_controller.text.trim().length < 2) {
                                        ShowSnackbar().open(
                                          context: this.context,
                                          scaffoldKey: _scaffoldKey,
                                          time: 3,
                                          label: getTranslatedForCurrentUser(
                                                  this.context, 'xxvalidxxxx')
                                              .replaceAll('(####)',
                                                  '${getTranslatedForCurrentUser(this.context, 'xxmssgxx')}'),
                                        );
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
                                              appShareMessageStringAndroid:
                                                  _controller.text.trim(),
                                              notifcationpostedby:
                                                  widget.currentuserid,
                                              notificationtime: DateTime.now()
                                                  .millisecondsSinceEpoch,
                                              notificationtitle:
                                                  "Advanced Settings updated",
                                              notificationdesc:
                                                  "appShareMessageStringAndroid - is set to ${_controller.text.trim()}"),
                                        );
                                      }
                                    },
                              buttontext: getTranslatedForCurrentUser(
                                  this.context, 'xxupdatexx'),
                              hinttext: getTranslatedForCurrentUser(
                                  this.context, 'xxmssgxx'));
                        }),
                    customTile(
                        ishighlightdesc:
                            userAppSettings!.appShareMessageStringiOS != "",
                        margin: 5,
                        iconsize: 30,
                        trailingicondata: Icons.edit_outlined,
                        title: getTranslatedForCurrentUser(
                            this.context, 'xxxiossharemssgxx'),
                        subtitle:
                            userAppSettings!.appShareMessageStringiOS == ""
                                ? ""
                                : userAppSettings!.appShareMessageStringiOS,
                        leadingicondata: Icons.settings_applications_rounded,
                        ontap: () {
                          _controller.text =
                              userAppSettings!.appShareMessageStringiOS == ""
                                  ? ""
                                  : userAppSettings!.appShareMessageStringiOS!;
                          ShowFormDialog().open(
                              inputFormatter: [],
                              iscapital: false,
                              controller: _controller,
                              maxlength: 500,
                              maxlines: 4,
                              minlines: 2,
                              iscentrealign: true,
                              context: this.context,
                              title: getTranslatedForCurrentUser(
                                  this.context, 'xxmssgxx'),
                              onpressed: AppConstants.isdemomode == true
                                  ? () {
                                      Utils.toast(getTranslatedForCurrentUser(
                                          this.context,
                                          'xxxnotalwddemoxxaccountxx'));
                                    }
                                  : () async {
                                      if (_controller.text.trim().length < 2) {
                                        ShowSnackbar().open(
                                          context: this.context,
                                          scaffoldKey: _scaffoldKey,
                                          time: 3,
                                          label: getTranslatedForCurrentUser(
                                                  this.context, 'xxvalidxxxx')
                                              .replaceAll('(####)',
                                                  '${getTranslatedForCurrentUser(this.context, 'xxmssgxx')}'),
                                        );
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
                                                appShareMessageStringiOS:
                                                    _controller.text.trim(),
                                                notifcationpostedby:
                                                    widget.currentuserid,
                                                notificationtime: DateTime.now()
                                                    .millisecondsSinceEpoch,
                                                notificationtitle:
                                                    "Advanced Settings updated",
                                                notificationdesc:
                                                    "appShareStringIOS - is set to ${_controller.text.trim()}"));
                                      }
                                    },
                              buttontext: getTranslatedForCurrentUser(
                                  this.context, 'xxupdatexx'),
                              hinttext: getTranslatedForCurrentUser(
                                  this.context, 'xxmssgxx'));
                        }),
                    SizedBox(
                      height: 20,
                    ),
                  ]));
  }
}
