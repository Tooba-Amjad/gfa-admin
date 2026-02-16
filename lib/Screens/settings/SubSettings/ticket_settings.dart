import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:provider/provider.dart';
import 'package:thinkcreative_technologies/Configs/app_constants.dart';
import 'package:thinkcreative_technologies/Configs/enum.dart';
import 'package:thinkcreative_technologies/Configs/optional_constants.dart';
import 'package:thinkcreative_technologies/Localization/language_constants.dart';
import 'package:thinkcreative_technologies/Models/userapp_settings_model.dart';
import 'package:thinkcreative_technologies/Screens/settings/department/all_departments_list.dart';
import 'package:thinkcreative_technologies/Services/my_providers/observer.dart';
import 'package:thinkcreative_technologies/Services/my_providers/session_provider.dart';
import 'package:thinkcreative_technologies/Utils/page_navigator.dart';
import 'package:thinkcreative_technologies/Utils/utils.dart';
import 'package:thinkcreative_technologies/Widgets/Input_box.dart';
import 'package:thinkcreative_technologies/Configs/my_colors.dart';
import 'package:thinkcreative_technologies/Utils/delayed_function.dart';
import 'package:thinkcreative_technologies/Widgets/dialogs/CustomDialog.dart';
import 'package:thinkcreative_technologies/Widgets/dialogs/FormDialog.dart';
import 'package:thinkcreative_technologies/Widgets/dialogs/loadingDialog.dart';
import 'package:thinkcreative_technologies/Widgets/headers/sectionheaders.dart';
import 'package:thinkcreative_technologies/Widgets/my_scaffold.dart';
import 'package:thinkcreative_technologies/Utils/custom_tiles.dart';

class TicketSettings extends StatefulWidget {
  final String currentuserid;
  final DocumentReference docRef;
  TicketSettings({required this.docRef, required this.currentuserid});
  @override
  _TicketSettingsState createState() => _TicketSettingsState();
}

class _TicketSettingsState extends State<TicketSettings> {
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
            "${getTranslatedForCurrentUser(this.context, 'xxuserappsetupincompletexx')}. ${onError.toString()} ";

        isloading = false;
      });
    });

    final observer = Provider.of<Observer>(this.context, listen: false);
    observer.fetchUserAppSettings(this.context);
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
        title:
            // russian lang has different tag for this string
            Utils.checkIfNull(
                    getTranslatedForCurrentUser(this.context, 'xxru18xx')) ??
                "${getTranslatedForCurrentUser(this.context, 'xxsupporttktxx')} ${getTranslatedForCurrentUser(this.context, 'xxxsettingsxxx')}",
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

                    sectionHeader(getTranslatedForCurrentUser(
                            this.context, 'xxsupporttktxx')
                        .toUpperCase()),
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
                              value: userAppSettings!.autocreatesupportticket ??
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
                                              .autocreatesupportticket ??
                                          false;
                                      await confirmchangeswitch(
                                          context: this.context,
                                          currentlbool: switchvalue,
                                          updatedmodel: userAppSettings!.copyWith(
                                              autocreatesupportticket:
                                                  !switchvalue,
                                              notifcationpostedby:
                                                  widget.currentuserid,
                                              notificationtime: DateTime.now()
                                                  .millisecondsSinceEpoch,
                                              notificationtitle:
                                                  "Support Ticket Settings updated",
                                              notificationdesc:
                                                  "autoCreateSupportTicket - is set to ${Utils.getboolText(!switchvalue)}"));
                                    }),
                        ),
                        title: getTranslatedForCurrentUser(
                                this.context, 'xxxxautocreateticketxxx')
                            .replaceAll('(####)',
                                '${getTranslatedForCurrentUser(this.context, 'xxtktsxx')}'),
                        subtitle: // russian lang has different tag for this string
                            Utils.checkIfNull(getTranslatedForCurrentUser(
                                    this.context, 'xxru19xx')) ??
                                getTranslatedForCurrentUser(
                                        this.context, 'xxxautocreatenewtktxx')
                                    .replaceAll('(####)',
                                        '${getTranslatedForCurrentUser(this.context, 'xxsupporttktxx')}')
                                    .replaceAll('(###)',
                                        '${getTranslatedForCurrentUser(this.context, 'xxcustomerxx')}'),
                        leadingicondata: Icons.settings_applications_rounded),
                    userAppSettings!.autocreatesupportticket == false
                        ? SizedBox()
                        : customTile(
                            ishighlightdesc: true,
                            margin: 5,
                            iconsize: 30,
                            trailingicondata: Icons.edit_outlined,
                            title: getTranslatedForCurrentUser(
                                    this.context, 'xxxxdefaulttitlexxx')
                                .replaceAll('(####)',
                                    '${getTranslatedForCurrentUser(this.context, 'xxsupporttktxx')}'),
                            subtitle:
                                userAppSettings!.defaultTopicsOnLoginName!,
                            leadingicondata:
                                Icons.settings_applications_rounded,
                            ontap: () {
                              _controller.text =
                                  userAppSettings!.defaultTopicsOnLoginName!;
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
                                        this.context, 'xxxxdefaulttitlexxx')
                                    .replaceAll('(####)',
                                        '${getTranslatedForCurrentUser(this.context, 'xxsupporttktxx')}'),
                                onpressed: AppConstants.isdemomode == true
                                    ? () {
                                        Utils.toast(getTranslatedForCurrentUser(
                                            this.context,
                                            'xxxnotalwddemoxxaccountxx'));
                                      }
                                    : () async {
                                        if (_controller.text.trim().length <
                                            2) {
                                          ShowSnackbar().open(
                                            context: this.context,
                                            scaffoldKey: _scaffoldKey,
                                            time: 3,
                                            label: getTranslatedForCurrentUser(
                                                    this.context, 'xxvalidxxxx')
                                                .replaceAll('(####)',
                                                    '${getTranslatedForCurrentUser(this.context, 'xxtitlexx')}'),
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
                                                  defaultTopicsOnLoginName:
                                                      _controller.text.trim(),
                                                  notifcationpostedby:
                                                      widget.currentuserid,
                                                  notificationtime: DateTime
                                                          .now()
                                                      .millisecondsSinceEpoch,
                                                  notificationtitle:
                                                      "Ticket Settings updated",
                                                  notificationdesc:
                                                      "defaultTopicsOnLoginName - is set to ${_controller.text.trim()}"));
                                        }
                                      },
                                buttontext: getTranslatedForCurrentUser(
                                    this.context, 'xxupdatexx'),
                              );
                            }),
                    //* -------------------------------

                    userAppSettings!.departmentBasedContent == false
                        ? SizedBox()
                        : sectionHeader(
                            '${getTranslatedForCurrentUser(this.context, 'xxdepartmentsxx').toUpperCase()}'),

                    userAppSettings!.departmentBasedContent == false
                        ? SizedBox()
                        : customTile(
                            margin: 5,
                            iconsize: 30,
                            trailingicondata:
                                Icons.keyboard_arrow_right_outlined,
                            title:
                                // russian lang has different tag for this string
                                Utils.checkIfNull(getTranslatedForCurrentUser(this.context, 'xxru20xx')) ??
                                    '${getTranslatedForCurrentUser(this.context, 'xxtktssxx')} ${getTranslatedForCurrentUser(this.context, 'xxdepartmentsxx')}',
                            subtitle: Optionalconstants.isEditDefaultDepartment ==
                                    false
                                ? // russian lang has different tag for this string
                                Utils.checkIfNull(getTranslatedForCurrentUser(
                                            this.context, 'xxru21xx')) !=
                                        null
                                    ? "${getTranslatedForCurrentUser(this.context, 'xxru21xx')} ${userAppSettings!.departmentList!.length - 1}"
                                    : userAppSettings!.departmentList!.length <
                                            2
                                        ? "0 ${getTranslatedForCurrentUser(this.context, 'xxdepartmentxx')}"
                                        : (userAppSettings!.departmentList!.length - 1).toString() +
                                            " ${getTranslatedForCurrentUser(this.context, 'xxdepartmentsxx')}"
                                :
                                // russian lang has different tag for this string
                                Utils.checkIfNull(getTranslatedForCurrentUser(
                                            this.context, 'xxru21xx')) !=
                                        null
                                    ? "${getTranslatedForCurrentUser(this.context, 'xxru21xx')} ${userAppSettings!.departmentList!.length}"
                                    : userAppSettings!.departmentList!.length <
                                            1
                                        ? "0 ${getTranslatedForCurrentUser(this.context, 'xxdepartmentxx')}"
                                        : userAppSettings!.departmentList!.length
                                                .toString() +
                                            " ${getTranslatedForCurrentUser(this.context, 'xxdepartmentsxx')}",
                            leadingicondata: Icons.settings_applications_rounded,
                            ontap: () {
                              pageNavigator(
                                  this.context,
                                  AllDepartmentList(
                                    isShowForSignleAgent: false,
                                    filteragentid: "",
                                    onbackpressed: () {
                                      fetchdata();
                                    },
                                    currentuserid: widget.currentuserid,
                                  ));
                            }),

                    //* -------------------------------

                    sectionHeader(getTranslatedForCurrentUser(
                            this.context, 'xxsecondadminxx')
                        .toUpperCase()),

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
                                  userAppSettings!.secondadminCanCreateTicket ??
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
                                              .secondadminCanCreateTicket ??
                                          false;
                                      await confirmchangeswitch(
                                          context: this.context,
                                          currentlbool: switchvalue,
                                          updatedmodel: userAppSettings!.copyWith(
                                              secondadminCanCreateTicket:
                                                  !switchvalue,
                                              notificationtime: DateTime.now()
                                                  .millisecondsSinceEpoch,
                                              notificationtitle:
                                                  "Support Ticket Settings updated",
                                              notificationdesc:
                                                  "SecondAdminCanCreateTicket - is set to ${Utils.getboolText(!switchvalue)}"));
                                    }),
                        ),
                        title: // russian lang has different tag for this string
                            Utils.checkIfNull(getTranslatedForCurrentUser(this.context, 'xxru22xx')) ??
                                getTranslatedForCurrentUser(
                                        this.context, 'xxxcancreatexxx')
                                    .replaceAll('(####)',
                                        '${getTranslatedForCurrentUser(this.context, 'xxsecondadminxx')}')
                                    .replaceAll('(###)',
                                        '${getTranslatedForCurrentUser(this.context, 'xxtktsxx')}'),
                        subtitle: // russian lang has different tag for this string
                            Utils.checkIfNull(getTranslatedForCurrentUser(
                                    this.context, 'xxru23xx')) ??
                                getTranslatedForCurrentUser(
                                        this.context, 'xxxcancreateforxxx')
                                    .replaceAll('(####)',
                                        '${getTranslatedForCurrentUser(this.context, 'xxsecondadminxx')}')
                                    .replaceAll('(###)',
                                        '${getTranslatedForCurrentUser(this.context, 'xxsupporttktsxx')}')
                                    .replaceAll('(##)',
                                        '${getTranslatedForCurrentUser(this.context, 'xxcustomersxx')}'),
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
                                      .secondadminCanChangeTicketStatus ??
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
                                              .secondadminCanChangeTicketStatus ??
                                          false;
                                      await confirmchangeswitch(
                                          context: this.context,
                                          currentlbool: switchvalue,
                                          updatedmodel: userAppSettings!.copyWith(
                                              secondadminCanChangeTicketStatus:
                                                  !switchvalue,
                                              notificationtime: DateTime.now()
                                                  .millisecondsSinceEpoch,
                                              notificationtitle:
                                                  "Support Ticket Settings updated",
                                              notificationdesc:
                                                  "secondAdminCanChangeTicketStatus - is set to ${Utils.getboolText(!switchvalue)}"));
                                    }),
                        ),
                        title: // russian lang has different tag for this string
                            Utils.checkIfNull(getTranslatedForCurrentUser(
                                    this.context, 'xxru24xx')) ??
                                getTranslatedForCurrentUser(
                                        this.context, 'xxxcanchangexxstatusxxx')
                                    .replaceAll('(####)',
                                        '${getTranslatedForCurrentUser(this.context, 'xxsecondadminxx')}')
                                    .replaceAll('(###)',
                                        '${getTranslatedForCurrentUser(this.context, 'xxtktsxx')}'),
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
                              value: userAppSettings!.isCallAssigningAllowed ??
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
                                              .isCallAssigningAllowed ??
                                          false;
                                      await confirmchangeswitch(
                                          context: this.context,
                                          currentlbool: switchvalue,
                                          updatedmodel: userAppSettings!.copyWith(
                                              isCallAssigningAllowed:
                                                  !switchvalue,
                                              notificationtime: DateTime.now()
                                                  .millisecondsSinceEpoch,
                                              notificationtitle:
                                                  "Support Ticket Settings updated",
                                              notificationdesc:
                                                  "isCallAssigningAllowed - is set to ${Utils.getboolText(!switchvalue)}"));
                                    }),
                        ),
                        title: getTranslatedForCurrentUser(
                            this.context, 'xxxcallassigningallowedxxx'),
                        subtitle: // russian lang has different tag for this string
                            Utils.checkIfNull(getTranslatedForCurrentUser(
                                    this.context, 'xxru25xx')) ??
                                getTranslatedForCurrentUser(
                                        this.context, 'xxxcanassigncallxx')
                                    .replaceAll('(####)',
                                        '${getTranslatedForCurrentUser(this.context, 'xxcustomerxx')}')
                                    .replaceAll('(###)',
                                        '${getTranslatedForCurrentUser(this.context, 'xxagentsxx')}'),
                        leadingicondata: Icons.settings_applications_rounded),

                    userAppSettings!.isCallAssigningAllowed == false
                        ? SizedBox()
                        : Card(
                            elevation: 0.1,
                            margin: EdgeInsets.all(4),
                            child: InputGroup3small(
                              title: getTranslatedForCurrentUser(
                                  this.context, 'xxxallowedcalltypexxx'),
                              val1: CallType.audio.index.toString(),
                              val1String: getTranslatedForCurrentUser(
                                  this.context, 'xxaudioxx'),
                              val2: CallType.video.index.toString(),
                              val2String: getTranslatedForCurrentUser(
                                  this.context, 'xxvideoxx'),
                              val3: CallType.both.index.toString(),
                              val3String:
                                  "${getTranslatedForCurrentUser(this.context, 'xxaudioxx')}, ${getTranslatedForCurrentUser(this.context, 'xxvideoxx')}",
                              selectedvalue: userAppSettings!
                                  .callTypeForTicketChatRoom
                                  .toString(),
                              onChanged: AppConstants.isdemomode == true
                                  ? (val) {
                                      Utils.toast(getTranslatedForCurrentUser(
                                          this.context,
                                          'xxxnotalwddemoxxaccountxx'));
                                    }
                                  : (val) async {
                                      userAppSettings = userAppSettings!.copyWith(
                                          callTypeForTicketChatRoom:
                                              int.tryParse(val!),
                                          notifcationpostedby:
                                              widget.currentuserid,
                                          notificationtime: DateTime.now()
                                              .millisecondsSinceEpoch,
                                          notificationtitle:
                                              "Ticket Settings updated",
                                          notificationdesc:
                                              "callTypeForTicketChatRoom - is set to ${Utils.getCallValueText(int.tryParse(val)!)}");
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
                    //* -------------------------------

                    sectionHeader(
                        getTranslatedForCurrentUser(this.context, 'xxagentsxx')
                            .toUpperCase()),
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
                              value: userAppSettings!.agentCanCreateTicket ??
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
                                              .agentCanCreateTicket ??
                                          false;
                                      await confirmchangeswitch(
                                          context: this.context,
                                          currentlbool: switchvalue,
                                          updatedmodel: userAppSettings!.copyWith(
                                              agentCanCreateTicket:
                                                  !switchvalue,
                                              notificationtime: DateTime.now()
                                                  .millisecondsSinceEpoch,
                                              notificationtitle:
                                                  "Support Ticket Settings updated",
                                              notificationdesc:
                                                  "agentCancreateTicket - is set to ${Utils.getboolText(!switchvalue)}"));
                                    }),
                        ),
                        title: getTranslatedForCurrentUser(
                                this.context, 'xxxcancreatexxx')
                            .replaceAll('(####)',
                                '${getTranslatedForCurrentUser(this.context, 'xxagentsxx')}')
                            .replaceAll('(###)',
                                '${getTranslatedForCurrentUser(this.context, 'xxtktssxx')}'),
                        subtitle: // russian lang has different tag for this string
                            Utils.checkIfNull(getTranslatedForCurrentUser(
                                    this.context, 'xxru26xx')) ??
                                getTranslatedForCurrentUser(
                                        this.context, 'xxxcancreateforxxx')
                                    .replaceAll('(####)',
                                        '${getTranslatedForCurrentUser(this.context, 'xxagentsxx')}')
                                    .replaceAll('(###)',
                                        '${getTranslatedForCurrentUser(this.context, 'xxsupporttktsxx')}')
                                    .replaceAll('(##)',
                                        '${getTranslatedForCurrentUser(this.context, 'xxcustomersxx')}'),
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
                              value:
                                  userAppSettings!.agentCanChangeTicketStatus ??
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
                                              .agentCanChangeTicketStatus ??
                                          false;
                                      await confirmchangeswitch(
                                        context: this.context,
                                        currentlbool: switchvalue,
                                        updatedmodel: userAppSettings!.copyWith(
                                            agentCanChangeTicketStatus:
                                                !switchvalue,
                                            notificationtime: DateTime.now()
                                                .millisecondsSinceEpoch,
                                            notificationtitle:
                                                "Support Ticket Settings updated",
                                            notificationdesc:
                                                "agentCanChangeTicketStatus - is set to ${Utils.getboolText(!switchvalue)}"),
                                      );
                                    }),
                        ),
                        title: // russian lang has different tag for this string
                            Utils.checkIfNull(getTranslatedForCurrentUser(
                                    this.context, 'xxru27xx')) ??
                                getTranslatedForCurrentUser(
                                        this.context, 'xxxcanchangexxstatusxxx')
                                    .replaceAll('(####)',
                                        '${getTranslatedForCurrentUser(this.context, 'xxagentsxx')}')
                                    .replaceAll('(###)',
                                        '${getTranslatedForCurrentUser(this.context, 'xxtktsxx')}'),
                        leadingicondata: Icons.settings_applications_rounded),
                    //* -------------------------------

                    sectionHeader(getTranslatedForCurrentUser(
                            this.context, 'xxcustomerxx')
                        .toUpperCase()),
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
                              value: userAppSettings!.customerCanCreateTicket ??
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
                                              .customerCanCreateTicket ??
                                          false;
                                      await confirmchangeswitch(
                                          context: this.context,
                                          currentlbool: switchvalue,
                                          updatedmodel: userAppSettings!.copyWith(
                                              customerCanCreateTicket:
                                                  !switchvalue,
                                              notificationtime: DateTime.now()
                                                  .millisecondsSinceEpoch,
                                              notificationtitle:
                                                  "Support Ticket Settings updated",
                                              notificationdesc:
                                                  "customerCanCreateTicket - is set to ${Utils.getboolText(!switchvalue)}"));
                                    }),
                        ),
                        title: getTranslatedForCurrentUser(
                                this.context, 'xxxcancreatexxx')
                            .replaceAll('(####)',
                                '${getTranslatedForCurrentUser(this.context, 'xxcustomersxx')}')
                            .replaceAll('(###)',
                                '${getTranslatedForCurrentUser(this.context, 'xxtktssxx')}'),
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
                                      .customerCanChangeTicketStatus ??
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
                                              .customerCanChangeTicketStatus ??
                                          false;
                                      await confirmchangeswitch(
                                          context: this.context,
                                          currentlbool: switchvalue,
                                          updatedmodel: userAppSettings!.copyWith(
                                              customerCanChangeTicketStatus:
                                                  !switchvalue,
                                              notificationtime: DateTime.now()
                                                  .millisecondsSinceEpoch,
                                              notificationtitle:
                                                  "Support Ticket Settings updated",
                                              notificationdesc:
                                                  "customerCanChangeTicketStatus - is set to ${Utils.getboolText(!switchvalue)}"));
                                    }),
                        ),
                        title: // russian lang has different tag for this string
                            Utils.checkIfNull(getTranslatedForCurrentUser(
                                    this.context, 'xxru28xx')) ??
                                getTranslatedForCurrentUser(
                                        this.context, 'xxxcanchangexxstatusxxx')
                                    .replaceAll('(####)',
                                        '${getTranslatedForCurrentUser(this.context, 'xxcustomersxx')}')
                                    .replaceAll('(###)',
                                        '${getTranslatedForCurrentUser(this.context, 'xxtktsxx')}'),
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
                                      .customerCanSeeAgentNameInTicketCallScreen ??
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
                                              .customerCanSeeAgentNameInTicketCallScreen ??
                                          false;
                                      await confirmchangeswitch(
                                          context: this.context,
                                          currentlbool: switchvalue,
                                          updatedmodel: userAppSettings!.copyWith(
                                              customerCanSeeAgentNameInTicketCallScreen:
                                                  !switchvalue,
                                              notificationtime: DateTime.now()
                                                  .millisecondsSinceEpoch,
                                              notificationtitle:
                                                  "Support Ticket Settings updated",
                                              notificationdesc:
                                                  "customerCanSeeAgents - is set to ${Utils.getboolText(!switchvalue)}"));
                                    }),
                        ),
                        title: // russian lang has different tag for this string
                            Utils.checkIfNull(getTranslatedForCurrentUser(this.context, 'xxru29xx')) ??
                                getTranslatedForCurrentUser(
                                        this.context, 'xxxcanseexxxxx')
                                    .replaceAll('(####)',
                                        '${getTranslatedForCurrentUser(this.context, 'xxcustomersxx')}')
                                    .replaceAll('(###)',
                                        '${getTranslatedForCurrentUser(this.context, 'xxagentsxx')}'),
                        subtitle: // russian lang has different tag for this string
                            Utils.checkIfNull(getTranslatedForCurrentUser(
                                    this.context, 'xxru30xx')) ??
                                getTranslatedForCurrentUser(
                                        this.context, 'xxxcanseexinxxxx')
                                    .replaceAll('(####)',
                                        '${getTranslatedForCurrentUser(this.context, 'xxcustomersxx')}')
                                    .replaceAll('(###)',
                                        '${getTranslatedForCurrentUser(this.context, 'xxagentsxx')}')
                                    .replaceAll('(##)',
                                        '${getTranslatedForCurrentUser(this.context, 'xxsupporttktsxx')}'),
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
                              value: userAppSettings!.customerCanRateTicket ??
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
                                              .customerCanRateTicket ??
                                          false;
                                      await confirmchangeswitch(
                                          context: this.context,
                                          currentlbool: switchvalue,
                                          updatedmodel: userAppSettings!.copyWith(
                                              customerCanRateTicket:
                                                  !switchvalue,
                                              notificationtime: DateTime.now()
                                                  .millisecondsSinceEpoch,
                                              notificationtitle:
                                                  "Support Ticket Settings updated",
                                              notificationdesc:
                                                  "customerCanRateTicket - is set to ${Utils.getboolText(!switchvalue)}"));
                                    }),
                        ),
                        title: // russian lang has different tag for this string
                            Utils.checkIfNull(getTranslatedForCurrentUser(
                                    this.context, 'xxru31xx')) ??
                                getTranslatedForCurrentUser(this.context,
                                        'xxxcustomercanratetktxxx')
                                    .replaceAll('(####)',
                                        '${getTranslatedForCurrentUser(this.context, 'xxcustomersxx')}')
                                    .replaceAll('###)',
                                        '${getTranslatedForCurrentUser(this.context, 'xxtktsxx')}'),
                        subtitle: // russian lang has different tag for this string
                            Utils.checkIfNull(getTranslatedForCurrentUser(
                                    this.context, 'xxru32xx')) ??
                                getTranslatedForCurrentUser(
                                        this.context, 'xxxprovidefeedbackxxx')
                                    .replaceAll('####)',
                                        '${getTranslatedForCurrentUser(this.context, 'xxtktsxx')}'),
                        leadingicondata: Icons.settings_applications_rounded),

                    //* -------------------------------

                    sectionHeader(getTranslatedForCurrentUser(
                        this.context, 'xxxgeneralxxx')),

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
                                      .showIsTypingInTicketChatRoom ??
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
                                              .showIsTypingInTicketChatRoom ??
                                          false;
                                      await confirmchangeswitch(
                                          context: this.context,
                                          currentlbool: switchvalue,
                                          updatedmodel: userAppSettings!.copyWith(
                                              showIsTypingInTicketChatRoom:
                                                  !switchvalue,
                                              notificationtime: DateTime.now()
                                                  .millisecondsSinceEpoch,
                                              notificationtitle:
                                                  "Support Ticket Settings updated",
                                              notificationdesc:
                                                  "showWhiIstypingInticketChatroom - is set to ${Utils.getboolText(!switchvalue)}"));
                                    }),
                        ),
                        title: getTranslatedForCurrentUser(
                            this.context, 'xxxxshowistypingxxx'),
                        subtitle: // russian lang has different tag for this string
                            Utils.checkIfNull(getTranslatedForCurrentUser(
                                    this.context, 'xxru33xx')) ??
                                getTranslatedForCurrentUser(
                                        this.context, 'xxxxshowoistypingdescxx')
                                    .replaceAll('(####)',
                                        '${getTranslatedForCurrentUser(this.context, 'xxtktsxx')}'),
                        leadingicondata: Icons.settings_applications_rounded),

                    customTile(
                        ishighlightdesc: true,
                        margin: 5,
                        iconsize: 30,
                        trailingicondata: Icons.edit_outlined,
                        title:
                            // russian lang has different tag for this string
                            Utils.checkIfNull(getTranslatedForCurrentUser(
                                    this.context, 'xxru34xx')) ??
                                '${getTranslatedForCurrentUser(this.context, 'xxtktsxx')} ${getTranslatedForCurrentUser(this.context, 'xxxxreopenxxx')} ${getTranslatedForCurrentUser(this.context, 'xxxdaysxxx')}',
                        subtitle: Utils.checkIfNull(getTranslatedForCurrentUser(
                                    this.context, 'xxru35xx')) !=
                                null
                            ? getTranslatedForCurrentUser(
                                    this.context, 'xxru35xx')
                                .replaceAll(
                                    '(####)',
                                    userAppSettings!.reopenTicketTillDays
                                        .toString())
                            : userAppSettings!.reopenTicketTillDays.toString() +
                                " ${getTranslatedForCurrentUser(this.context, 'xxxdaysxxx')}" +
                                "  (${getTranslatedForCurrentUser(this.context, 'xxxxcanbereopenedafterxxx').replaceAll('(####)', '${getTranslatedForCurrentUser(this.context, 'xxtktsxx')}').replaceAll('(###)', '${getTranslatedForCurrentUser(this.context, 'xxxdaysxxx')}')}).  ${getTranslatedForCurrentUser(this.context, 'xxxsetzeroxxx')}",
                        leadingicondata: Icons.settings_applications_rounded,
                        ontap: () {
                          _controller.text =
                              userAppSettings!.reopenTicketTillDays.toString();
                          ShowFormDialog().open(
                              inputFormatter: [
                                FilteringTextInputFormatter.allow(
                                    RegExp("[0-9]") //-- Only Number & Aplhabets
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
                              title:
                                  '${getTranslatedForCurrentUser(this.context, 'xxtktsxx')} ${getTranslatedForCurrentUser(this.context, 'xxxxreopenxxx')} ${getTranslatedForCurrentUser(this.context, 'xxxdaysxxx')}',
                              subtitle:
                                  "${getTranslatedForCurrentUser(this.context, 'xxxxcanbereopenedafterxxx').replaceAll('(####)', '${getTranslatedForCurrentUser(this.context, 'xxtktsxx')}').replaceAll('(###)', '${getTranslatedForCurrentUser(this.context, 'xxxdaysxxx')}')}",
                              onpressed: AppConstants.isdemomode == true
                                  ? () {
                                      Utils.toast(getTranslatedForCurrentUser(
                                          this.context,
                                          'xxxnotalwddemoxxaccountxx'));
                                    }
                                  : () async {
                                      if (_controller.text.trim().length < 1) {
                                        ShowSnackbar().open(
                                            context: this.context,
                                            scaffoldKey: _scaffoldKey,
                                            time: 3,
                                            label:
                                                "${getTranslatedForCurrentUser(this.context, 'xxxplsentervalidnumberxx')} ${getTranslatedForCurrentUser(this.context, 'xxxsetzeroxxx')}");
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
                                              reopenTicketTillDays:
                                                  int.tryParse(
                                                      _controller.text.trim()),
                                              notifcationpostedby:
                                                  widget.currentuserid,
                                              notificationtime: DateTime.now()
                                                  .millisecondsSinceEpoch,
                                              notificationtitle:
                                                  "Ticket Settings updated",
                                              notificationdesc:
                                                  "reopenTicketTillDays - is set to ${int.tryParse(_controller.text.trim())} Days"),
                                        );
                                      }
                                    },
                              buttontext: getTranslatedForCurrentUser(
                                  this.context, 'xxupdatexx'),
                              hinttext: getTranslatedForCurrentUser(
                                  this.context, 'xxxdaysxxx'));
                        }),
                    customTile(
                        ishighlightdesc: true,
                        margin: 5,
                        iconsize: 30,
                        trailingicondata: Icons.edit_outlined,
                        title: getTranslatedForCurrentUser(
                            this.context, 'xxxdefaultmssgdltingtimexxx'),
                        subtitle: userAppSettings!
                                .defaultTicketMssgsDeletingTimeAfterClosing
                                .toString() +
                            " ${getTranslatedForCurrentUser(this.context, 'xxxdaysxxx')} ${getTranslatedForCurrentUser(this.context, 'xxxsetzeroxxx')}",
                        leadingicondata: Icons.settings_applications_rounded,
                        ontap: () {
                          _controller.text = userAppSettings!
                              .defaultTicketMssgsDeletingTimeAfterClosing
                              .toString();
                          ShowFormDialog().open(
                              inputFormatter: [
                                FilteringTextInputFormatter.allow(
                                    RegExp("[0-9]") //-- Only Number & Aplhabets
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
                              title: getTranslatedForCurrentUser(
                                  this.context, 'xxxdaysxxx'),
                              subtitle: getTranslatedForCurrentUser(
                                      this.context, 'xxxxforclosedtktxxxx')
                                  .replaceAll('(####)',
                                      '${getTranslatedForCurrentUser(this.context, 'xxtktsxx')}'),
                              onpressed: AppConstants.isdemomode == true
                                  ? () {
                                      Utils.toast(getTranslatedForCurrentUser(
                                          this.context,
                                          'xxxnotalwddemoxxaccountxx'));
                                    }
                                  : () async {
                                      if (_controller.text.trim().length < 1) {
                                        ShowSnackbar().open(
                                            context: this.context,
                                            scaffoldKey: _scaffoldKey,
                                            time: 3,
                                            label:
                                                "${getTranslatedForCurrentUser(this.context, 'xxxplsentervalidnumberxx')} ${getTranslatedForCurrentUser(this.context, 'xxxsetzeroxxx')}");
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
                                              defaultTicketMssgsDeletingTimeAfterClosing:
                                                  int.tryParse(
                                                      _controller.text.trim()),
                                              notifcationpostedby:
                                                  widget.currentuserid,
                                              notificationtime: DateTime.now()
                                                  .millisecondsSinceEpoch,
                                              notificationtitle:
                                                  "Ticket Settings updated",
                                              notificationdesc:
                                                  "defaultTicketMssgsDeletingTimeAfterClosing - is set to ${int.tryParse(_controller.text.trim())} Days"),
                                        );
                                      }
                                    },
                              buttontext: getTranslatedForCurrentUser(
                                  this.context, 'xxupdatexx'),
                              hinttext: getTranslatedForCurrentUser(
                                  this.context, 'xxxdaysxxx'));
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
                              value: userAppSettings!
                                      .isMediaSendingAllowedInTicketChatRoom ??
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
                                              .isMediaSendingAllowedInTicketChatRoom ??
                                          false;
                                      await confirmchangeswitch(
                                          context: this.context,
                                          currentlbool: switchvalue,
                                          updatedmodel: userAppSettings!.copyWith(
                                              isMediaSendingAllowedInTicketChatRoom:
                                                  !switchvalue,
                                              notificationtime: DateTime.now()
                                                  .millisecondsSinceEpoch,
                                              notificationtitle:
                                                  "Support Ticket Settings updated",
                                              notificationdesc:
                                                  "MediaSendingInTicketChatRoomAllowed - is set to ${Utils.getboolText(!switchvalue)}"));
                                    }),
                        ),
                        title: getTranslatedForCurrentUser(
                            this.context, 'xxxmediasendingxxx'),
                        subtitle: // russian lang has different tag for this string
                            Utils.checkIfNull(getTranslatedForCurrentUser(
                                    this.context, 'xxru36xx')) ??
                                getTranslatedForCurrentUser(
                                        this.context, 'xxxcanuploadmediaxxx')
                                    .replaceAll('(####)',
                                        '${getTranslatedForCurrentUser(this.context, 'xxcustomersxx')}')
                                    .replaceAll('(###)',
                                        '${getTranslatedForCurrentUser(this.context, 'xxagentsxx')}')
                                    .replaceAll('(##)',
                                        '${getTranslatedForCurrentUser(this.context, 'xxtktsxx')}'),
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
                              value: userAppSettings!.showIsCustomerOnline ??
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
                                              .showIsCustomerOnline ??
                                          false;
                                      await confirmchangeswitch(
                                          context: this.context,
                                          currentlbool: switchvalue,
                                          updatedmodel: userAppSettings!.copyWith(
                                              showIsCustomerOnline:
                                                  !switchvalue,
                                              notificationtime: DateTime.now()
                                                  .millisecondsSinceEpoch,
                                              notificationtitle:
                                                  "Support Ticket Settings updated",
                                              notificationdesc:
                                                  "showCustomerIsOnlineInTicketChatRomm - is set to ${Utils.getboolText(!switchvalue)}"));
                                    }),
                        ),
                        title: getTranslatedForCurrentUser(
                                this.context, 'xxxonlinestatusxxx')
                            .replaceAll('(####)',
                                '${getTranslatedForCurrentUser(this.context, 'xxcustomerxx')}'),
                        subtitle: // russian lang has different tag for this string
                            Utils.checkIfNull(getTranslatedForCurrentUser(
                                    this.context, 'xxru37xx')) ??
                                getTranslatedForCurrentUser(
                                        this.context, 'xxxchnagexxxstatusxxx')
                                    .replaceAll('(####)',
                                        '${getTranslatedForCurrentUser(this.context, 'xxagentsxxx')}')
                                    .replaceAll('(###)',
                                        '${getTranslatedForCurrentUser(this.context, 'xxcustomerxx')}')
                                    .replaceAll('(##)',
                                        '${getTranslatedForCurrentUser(this.context, 'xxsupporttktsxx')}'),
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
                              value:
                                  userAppSettings!.showIsAgentOnline ?? false,
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
                                          userAppSettings!.showIsAgentOnline ??
                                              false;
                                      await confirmchangeswitch(
                                          context: this.context,
                                          currentlbool: switchvalue,
                                          updatedmodel: userAppSettings!.copyWith(
                                              showIsAgentOnline: !switchvalue,
                                              notificationtime: DateTime.now()
                                                  .millisecondsSinceEpoch,
                                              notificationtitle:
                                                  "Support Ticket Settings updated",
                                              notificationdesc:
                                                  "CustomerCanSeeAgentIsOnlineinTicketChatroom - is set to ${Utils.getboolText(!switchvalue)}"));
                                    }),
                        ),
                        title: getTranslatedForCurrentUser(
                                this.context, 'xxxonlinestatusxxx')
                            .replaceAll('(####)',
                                '${Utils.checkIfNull(getTranslatedForCurrentUser(this.context, 'xxru147xx')) ?? getTranslatedForCurrentUser(this.context, 'xxagentxx')}'),
                        subtitle: // russian lang has different tag for this string
                            Utils.checkIfNull(getTranslatedForCurrentUser(
                                    this.context, 'xxru38xx')) ??
                                getTranslatedForCurrentUser(
                                        this.context, 'xxxchnagexxxstatusxxx')
                                    .replaceAll('(####)',
                                        '${getTranslatedForCurrentUser(this.context, 'xxcustomerxx')}')
                                    .replaceAll('(###)',
                                        '${getTranslatedForCurrentUser(this.context, 'xxagentsxxx')}')
                                    .replaceAll('(##)',
                                        '${getTranslatedForCurrentUser(this.context, 'xxsupporttktsxx')}'),
                        leadingicondata: Icons.settings_applications_rounded),
                  ]));
  }
}
