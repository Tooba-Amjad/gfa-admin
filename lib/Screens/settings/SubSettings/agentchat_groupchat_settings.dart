import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:provider/provider.dart';
import 'package:thinkcreative_technologies/Configs/app_constants.dart';
import 'package:thinkcreative_technologies/Configs/enum.dart';
import 'package:thinkcreative_technologies/Localization/language_constants.dart';
import 'package:thinkcreative_technologies/Models/userapp_settings_model.dart';
import 'package:thinkcreative_technologies/Services/my_providers/session_provider.dart';
import 'package:thinkcreative_technologies/Utils/utils.dart';
import 'package:thinkcreative_technologies/Widgets/Input_box.dart';
import 'package:thinkcreative_technologies/Configs/my_colors.dart';
import 'package:thinkcreative_technologies/Utils/delayed_function.dart';
import 'package:thinkcreative_technologies/Widgets/WarningWidgets/warning_tile.dart';
import 'package:thinkcreative_technologies/Widgets/dialogs/CustomDialog.dart';
import 'package:thinkcreative_technologies/Widgets/dialogs/FormDialog.dart';
import 'package:thinkcreative_technologies/Widgets/dialogs/loadingDialog.dart';
import 'package:thinkcreative_technologies/Widgets/headers/sectionheaders.dart';
import 'package:thinkcreative_technologies/Widgets/my_scaffold.dart';
import 'package:thinkcreative_technologies/Utils/custom_tiles.dart';

class AgentChatGroupChatSettings extends StatefulWidget {
  final String currentuserid;
  final DocumentReference docRef;
  AgentChatGroupChatSettings(
      {required this.docRef, required this.currentuserid});
  @override
  _AgentChatGroupChatSettingsState createState() =>
      _AgentChatGroupChatSettingsState();
}

class _AgentChatGroupChatSettingsState
    extends State<AgentChatGroupChatSettings> {
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
    bool isdepartmentbased =
        isloading == true ? false : userAppSettings!.departmentBasedContent!;
    return MyScaffold(
        scaffoldkey: _scaffoldKey,
        titlespacing: 0,
        title: getTranslatedForCurrentUser(this.context, 'xxxchatsettingsxxx'),
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
                    isdepartmentbased
                        ? warningTile(
                            isstyledtext: true,
                            title: // russian lang has different tag for this string
                                Utils.checkIfNull(getTranslatedForCurrentUser(
                                        this.context, 'xxru39xx')) ??
                                    getTranslatedForCurrentUser(this.context,
                                            'xxxdepartmentbasedonxxx')
                                        .replaceAll('(######)',
                                            '<bold>${getTranslatedForCurrentUser(this.context, 'xxdepartmentxx')}</bold>')
                                        .replaceAll('(#####)',
                                            '<bold>${getTranslatedForCurrentUser(this.context, 'xxdepartmentsxx')}</bold>')
                                        .replaceAll('(####)',
                                            '<bold>${getTranslatedForCurrentUser(this.context, 'xxagentsxx')}</bold>'),
                            warningTypeIndex: WarningType.alert.index,
                          )
                        : warningTile(
                            isstyledtext: true,
                            title: getTranslatedForCurrentUser(
                                    this.context, 'xxxdepartmentbasedoffxxx')
                                .replaceAll('(######)',
                                    '<bold>${getTranslatedForCurrentUser(this.context, 'xxdepartmentxx')}</bold>')
                                .replaceAll('(#####)',
                                    '<bold>${getTranslatedForCurrentUser(this.context, 'xxagentsxx')}</bold>'),
                            warningTypeIndex: WarningType.success.index,
                          ),
                    //* -------------------------------
                    sectionHeader(getTranslatedForCurrentUser(
                            this.context, 'xxagentchatsxx')
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
                              value: userAppSettings!
                                      .agentCancreateandViewNewIndividualChat ??
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
                                              .agentCancreateandViewNewIndividualChat ??
                                          false;
                                      await confirmchangeswitch(
                                          context: this.context,
                                          currentlbool: switchvalue,
                                          updatedmodel: userAppSettings!.copyWith(
                                              agentCancreateandViewNewIndividualChat:
                                                  !switchvalue,
                                              notifcationpostedby:
                                                  widget.currentuserid,
                                              notificationtime: DateTime.now()
                                                  .millisecondsSinceEpoch,
                                              notificationtitle:
                                                  "Chat Settings updated",
                                              notificationdesc:
                                                  "agentCancreateandViewNewIndividualChat - is set to ${Utils.getboolText(!switchvalue)}"));
                                    }),
                        ),
                        title: getTranslatedForCurrentUser(
                            this.context, 'xxagentchatsxx'),
                        subtitle: isdepartmentbased
                            ? // russian lang has different tag for this string
                            Utils.checkIfNull(getTranslatedForCurrentUser(
                                    this.context, 'xxru40xx')) ??
                                getTranslatedForCurrentUser(this.context,
                                        'xxxindividualchatdeptxxx')
                                    .replaceAll('(####)',
                                        '${getTranslatedForCurrentUser(this.context, 'xxagentsxx')}')
                                    .replaceAll('(###)',
                                        '${getTranslatedForCurrentUser(this.context, 'xxdepartmentxx')}')
                                    .replaceAll('(##)',
                                        '${getTranslatedForCurrentUser(this.context, 'xxadminxx')}')
                            : getTranslatedForCurrentUser(this.context,
                                    'xxxindividualchatgloballytxxx')
                                .replaceAll('(####)',
                                    '${getTranslatedForCurrentUser(this.context, 'xxagentsxx')}')
                                .replaceAll('(###)',
                                    '${getTranslatedForCurrentUser(this.context, 'xxadminxx')}'),
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
                                  userAppSettings!.agentCanCallAgents ?? false,
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
                                          userAppSettings!.agentCanCallAgents ??
                                              false;
                                      await confirmchangeswitch(
                                          context: this.context,
                                          currentlbool: switchvalue,
                                          updatedmodel: userAppSettings!.copyWith(
                                              agentCanCallAgents: !switchvalue,
                                              notifcationpostedby:
                                                  widget.currentuserid,
                                              notificationtime: DateTime.now()
                                                  .millisecondsSinceEpoch,
                                              notificationtitle:
                                                  "Chat Settings updated",
                                              notificationdesc:
                                                  "agentCanCallAgents - is set to ${Utils.getboolText(!switchvalue)}"));
                                    }),
                        ),
                        title: // russian lang has different tag for this string
                            Utils.checkIfNull(getTranslatedForCurrentUser(this.context, 'xxru41xx')) ??
                                getTranslatedForCurrentUser(this.context, 'xxxcancallxxx')
                                    .replaceAll('(####)',
                                        '${getTranslatedForCurrentUser(this.context, 'xxagentsxx')}')
                                    .replaceAll('(###)',
                                        '${getTranslatedForCurrentUser(this.context, 'xxagentsxx')}'),
                        subtitle: isdepartmentbased
                            ? // russian lang has different tag for this string
                            Utils.checkIfNull(getTranslatedForCurrentUser(this.context, 'xxru42xx')) ??
                                getTranslatedForCurrentUser(
                                        context, 'xxxindividualcalldeptxxx')
                                    .replaceAll('(####)',
                                        '${getTranslatedForCurrentUser(this.context, 'xxagentsxx')}')
                                    .replaceAll('(###)',
                                        '${getTranslatedForCurrentUser(this.context, 'xxdepartmentxx')}')
                                    .replaceAll(
                                        '(##)', '${getTranslatedForCurrentUser(this.context, 'xxadminxx')}')
                            : getTranslatedForCurrentUser(
                                    this.context, 'xxxindividualcallgloballytxxx')
                                .replaceAll('(####)', '${getTranslatedForCurrentUser(this.context, 'xxagentsxx')}')
                                .replaceAll('(###)', '${getTranslatedForCurrentUser(this.context, 'xxadminxx')}'),
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
                                      .secondadminCancreateandViewNewIndividualChat ??
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
                                              .secondadminCancreateandViewNewIndividualChat ??
                                          false;
                                      await confirmchangeswitch(
                                          context: this.context,
                                          currentlbool: switchvalue,
                                          updatedmodel: userAppSettings!.copyWith(
                                              secondadminCancreateandViewNewIndividualChat:
                                                  !switchvalue,
                                              notifcationpostedby:
                                                  widget.currentuserid,
                                              notificationtime: DateTime.now()
                                                  .millisecondsSinceEpoch,
                                              notificationtitle:
                                                  "Chat Settings updated",
                                              notificationdesc:
                                                  "SecondAdminCanChatWithAgents - is set to ${Utils.getboolText(!switchvalue)}"));
                                    }),
                        ),
                        title: // russian lang has different tag for this string
                            Utils.checkIfNull(getTranslatedForCurrentUser(
                                    this.context, 'xxru43xx')) ??
                                getTranslatedForCurrentUser(
                                        this.context, 'xxxcanchatwithxxx')
                                    .replaceAll('(####)',
                                        '${getTranslatedForCurrentUser(this.context, 'xxsecondadminxx')}')
                                    .replaceAll('(###)',
                                        '${getTranslatedForCurrentUser(this.context, 'xxagentsxx')}'),
                        subtitle: // russian lang has different tag for this string
                            Utils.checkIfNull(getTranslatedForCurrentUser(
                                    this.context, 'xxru44xx')) ??
                                getTranslatedForCurrentUser(
                                        this.context, 'xxxcanchatwithdescxxx')
                                    .replaceAll('(####)',
                                        '${getTranslatedForCurrentUser(this.context, 'xxsecondadminxx')}')
                                    .replaceAll('(###)',
                                        '${getTranslatedForCurrentUser(this.context, 'xxagentsxx')}'),
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
                                  userAppSettings!.secondadminCanCallAgents ??
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
                                              .secondadminCanCallAgents ??
                                          false;
                                      await confirmchangeswitch(
                                          context: this.context,
                                          currentlbool: switchvalue,
                                          updatedmodel: userAppSettings!.copyWith(
                                              secondadminCanCallAgents:
                                                  !switchvalue,
                                              notifcationpostedby:
                                                  widget.currentuserid,
                                              notificationtime: DateTime.now()
                                                  .millisecondsSinceEpoch,
                                              notificationtitle:
                                                  "Chat Settings updated",
                                              notificationdesc:
                                                  "SecondAdminCanCallAgents - is set to ${Utils.getboolText(!switchvalue)}"));
                                    }),
                        ),
                        title: // russian lang has different tag for this string
                            Utils.checkIfNull(getTranslatedForCurrentUser(
                                    this.context, 'xxru45xx')) ??
                                getTranslatedForCurrentUser(
                                        this.context, 'xxxcancallxxx')
                                    .replaceAll('(####)',
                                        '${getTranslatedForCurrentUser(this.context, 'xxsecondadminxx')}')
                                    .replaceAll('(###)',
                                        '${getTranslatedForCurrentUser(this.context, 'xxagentsxx')}'),
                        subtitle: // russian lang has different tag for this string
                            Utils.checkIfNull(getTranslatedForCurrentUser(
                                    this.context, 'xxru46xx')) ??
                                getTranslatedForCurrentUser(this.context,
                                        'xxxindividualcallgloballytxxx')
                                    .replaceAll('(####)',
                                        '${getTranslatedForCurrentUser(this.context, 'xxsecondadminxx')}, ${getTranslatedForCurrentUser(this.context, 'xxagentsxx')}')
                                    .replaceAll('(###)',
                                        '${getTranslatedForCurrentUser(this.context, 'xxadminxx')}'),
                        leadingicondata: Icons.settings_applications_rounded),
                    userAppSettings!.secondadminCanCallAgents == true ||
                            userAppSettings!.agentCanCallAgents == true
                        ? Card(
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
                              val3String: getTranslatedForCurrentUser(
                                      this.context, 'xxaudioxx') +
                                  ", " +
                                  getTranslatedForCurrentUser(
                                      this.context, 'xxvideoxx'),
                              selectedvalue: userAppSettings!
                                  .personalcalltypeagents
                                  .toString(),
                              onChanged: AppConstants.isdemomode == true
                                  ? (val) {
                                      Utils.toast(getTranslatedForCurrentUser(
                                          this.context,
                                          'xxxnotalwddemoxxaccountxx'));
                                    }
                                  : (val) async {
                                      userAppSettings = userAppSettings!.copyWith(
                                          personalcalltypeagents:
                                              int.tryParse(val!),
                                          notifcationpostedby:
                                              widget.currentuserid,
                                          notificationtime: DateTime.now()
                                              .millisecondsSinceEpoch,
                                          notificationtitle:
                                              "Chat Settings updated",
                                          notificationdesc:
                                              "personalcalltypeagents - is set to ${Utils.getCallValueText(int.tryParse(val)!)}");
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
                          )
                        : SizedBox(),
                    customTile(
                        ishighlightdesc: true,
                        margin: 5,
                        iconsize: 30,
                        trailingicondata: Icons.edit_outlined,
                        title: getTranslatedForCurrentUser(
                            this.context, 'xxxdefaultmssgdltingtimexxx'),
                        subtitle: userAppSettings!
                                .defaultMessageDeletingTimeForOneToOneChat
                                .toString() +
                            " ${getTranslatedForCurrentUser(this.context, 'xxxdaysxxx')}    ${getTranslatedForCurrentUser(this.context, 'xxxsetzeroxxx')}",
                        leadingicondata: Icons.settings_applications_rounded,
                        ontap: () {
                          _controller.text = userAppSettings!
                              .defaultMessageDeletingTimeForOneToOneChat
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
                                  this.context, 'xxxdeleteafterxxx'),
                              subtitle: getTranslatedForCurrentUser(
                                  this.context, 'xxxdeleteafterdescxxx'),
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
                                            label: getTranslatedForCurrentUser(
                                                this.context,
                                                'xxxplsentervalidnumberxx'));
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
                                              defaultMessageDeletingTimeForOneToOneChat:
                                                  int.tryParse(
                                                      _controller.text.trim()),
                                              notifcationpostedby:
                                                  widget.currentuserid,
                                              notificationtime: DateTime.now()
                                                  .millisecondsSinceEpoch,
                                              notificationtitle:
                                                  "Chat Deleting Time updated",
                                              notificationdesc:
                                                  "defaultMessageDeletingTimeForOneToOneChat - is set to ${_controller.text.trim()}"),
                                        );
                                      }
                                    },
                              buttontext: getTranslatedForCurrentUser(
                                  this.context, 'xxupdatexx'),
                              hinttext: getTranslatedForCurrentUser(
                                  this.context, 'xxxdaysxxx'));
                        }),
                    //* -------------------------------
                    SizedBox(
                      height: 26,
                    ),
                    sectionHeader(
                      (getTranslatedForCurrentUser(
                                  this.context, 'xxgroupchatxx')
                              .replaceAll('(####)',
                                  '${getTranslatedForCurrentUser(this.context, 'xxagents')}'))
                          .toUpperCase(),
                    ),

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
                                  userAppSettings!.agentsCanCreateAgentsGroup ??
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
                                              .agentsCanCreateAgentsGroup ??
                                          false;
                                      await confirmchangeswitch(
                                          context: this.context,
                                          currentlbool: switchvalue,
                                          updatedmodel: userAppSettings!.copyWith(
                                              agentsCanCreateAgentsGroup:
                                                  !switchvalue,
                                              notifcationpostedby:
                                                  widget.currentuserid,
                                              notificationtime: DateTime.now()
                                                  .millisecondsSinceEpoch,
                                              notificationtitle:
                                                  "Chat Settings updated",
                                              notificationdesc:
                                                  "agentsCanCreateGroupChat - is set to ${Utils.getboolText(!switchvalue)}"));
                                    }),
                        ),
                        title:
// russian lang has different tag for this string
                            Utils.checkIfNull(getTranslatedForCurrentUser(this.context, 'xxru47xx')) ??
                                getTranslatedForCurrentUser(this.context, 'xxxcancreatexxx')
                                    .replaceAll(
                                        '(####)', '${getTranslatedForCurrentUser(this.context, 'xxagentsxx')}')
                                    .replaceAll(
                                        '(###)', '${getTranslatedForCurrentUser(this.context, 'xxgroupchatonlyxx')}'),
                        subtitle: isdepartmentbased
                            ? // russian lang has different tag for this string
                            Utils.checkIfNull(getTranslatedForCurrentUser(this.context, 'xxru48xx')) ??
                                getTranslatedForCurrentUser(this.context, 'xxxcreategroupwithdeptxxx')
                                    .replaceAll('(######)',
                                        '${getTranslatedForCurrentUser(this.context, 'xxagentsxx')}')
                                    .replaceAll('(#####)',
                                        '${getTranslatedForCurrentUser(this.context, 'xxgroupchatonlyxx')}')
                                    .replaceAll('(####)',
                                        '${getTranslatedForCurrentUser(this.context, 'xxdepartmentxx')}')
                                    .replaceAll(
                                        '(###)', '${getTranslatedForCurrentUser(this.context, 'xxadminxx')}')
                                    .replaceAll(
                                        '(##)', '${getTranslatedForCurrentUser(this.context, 'xxgroupchatonlyxx')}')
                            : getTranslatedForCurrentUser(
                                    this.context, 'xxxcreategroupgloballyxxx')
                                .replaceAll('(######)', '${getTranslatedForCurrentUser(this.context, 'xxagentsxx')}')
                                .replaceAll('(#####)', '${getTranslatedForCurrentUser(this.context, 'xxgroupchatonlyxx')}')
                                .replaceAll('(####)', '${getTranslatedForCurrentUser(this.context, 'xxagentsxx')}')
                                .replaceAll('(###)', '${getTranslatedForCurrentUser(this.context, 'xxadminxx')}')
                                .replaceAll('(##)', '${getTranslatedForCurrentUser(this.context, 'xxgroupchatonlyxx')}'),
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
                                      .secondadminCanCreateAgentsGroup ??
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
                                              .secondadminCanCreateAgentsGroup ??
                                          false;
                                      await confirmchangeswitch(
                                          context: this.context,
                                          currentlbool: switchvalue,
                                          updatedmodel: userAppSettings!.copyWith(
                                              secondadminCanCreateAgentsGroup:
                                                  !switchvalue,
                                              notifcationpostedby:
                                                  widget.currentuserid,
                                              notificationtime: DateTime.now()
                                                  .millisecondsSinceEpoch,
                                              notificationtitle:
                                                  "Chat Settings updated",
                                              notificationdesc:
                                                  "SecondAdminCancreateGroupChat - is set to ${Utils.getboolText(!switchvalue)}"));
                                    }),
                        ),
                        title:
                            // russian lang has different tag for this string
                            Utils.checkIfNull(getTranslatedForCurrentUser(this.context, 'xxru49xx')) ??
                                getTranslatedForCurrentUser(
                                        this.context, 'xxxcancreatexxx')
                                    .replaceAll('(####)',
                                        '${getTranslatedForCurrentUser(this.context, 'xxsecondadminxx')}')
                                    .replaceAll('(###)',
                                        '${getTranslatedForCurrentUser(this.context, 'xxgroupchatonlyxx')}'),
                        subtitle: // russian lang has different tag for this string
                            Utils.checkIfNull(getTranslatedForCurrentUser(this.context, 'xxru50xx')) ??
                                getTranslatedForCurrentUser(this.context,
                                        'xxxcreategroupgloballyxxx')
                                    .replaceAll(
                                        '(######)', '${getTranslatedForCurrentUser(this.context, 'xxsecondadminxx')}')
                                    .replaceAll('(#####)',
                                        '${getTranslatedForCurrentUser(this.context, 'xxgroupchatonlyxx')}')
                                    .replaceAll('(####)',
                                        '${getTranslatedForCurrentUser(this.context, 'xxagentsxx')}')
                                    .replaceAll('(###)',
                                        '${getTranslatedForCurrentUser(this.context, 'xxadminxx')}')
                                    .replaceAll('(##)',
                                        '${getTranslatedForCurrentUser(this.context, 'xxgroupchatonlyxx')}'),
                        leadingicondata: Icons.settings_applications_rounded),
                    customTile(
                        ishighlightdesc: true,
                        margin: 5,
                        iconsize: 30,
                        trailingicondata: Icons.edit_outlined,
                        title: getTranslatedForCurrentUser(
                            this.context, 'xxgroupmembersxx'),
                        subtitle: // russian lang has different tag for this string
                            Utils.checkIfNull(getTranslatedForCurrentUser(
                                        this.context, 'xxru51xx')) !=
                                    null
                                ? userAppSettings!.groupMemberslimit
                                        .toString() +
                                    " ${getTranslatedForCurrentUser(this.context, 'xxru51xx')}"
                                : userAppSettings!.groupMemberslimit
                                        .toString() +
                                    " ${getTranslatedForCurrentUser(this.context, 'xxagentsxx')}",
                        leadingicondata: Icons.settings_applications_rounded,
                        ontap: () {
                          _controller.text =
                              userAppSettings!.groupMemberslimit.toString();
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
                                  this.context, 'xxgroupmembersxx'),
                              subtitle: getTranslatedForCurrentUser(
                                  this.context, 'xxxtotlagroupmemberxxx'),
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
                                            label: getTranslatedForCurrentUser(
                                                this.context,
                                                'xxxplsentervalidnumberxx'));
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
                                              groupMemberslimit: int.tryParse(
                                                  _controller.text.trim()),
                                              notifcationpostedby:
                                                  widget.currentuserid,
                                              notificationtime: DateTime.now()
                                                  .millisecondsSinceEpoch,
                                              notificationtitle:
                                                  "Chat Settings updated",
                                              notificationdesc:
                                                  "groupmemberLimit - is set to ${int.tryParse(_controller.text.trim())} Members"),
                                        );
                                      }
                                    },
                              buttontext: getTranslatedForCurrentUser(
                                  this.context, 'xxupdatexx'),
                              hinttext: '');
                        }),

                    customTile(
                        ishighlightdesc: true,
                        margin: 5,
                        iconsize: 30,
                        trailingicondata: Icons.edit_outlined,
                        title: getTranslatedForCurrentUser(
                            this.context, 'xxxdefaultmssgdltingtimexxx'),
                        subtitle: userAppSettings!
                                .defaultMessageDeletingTimeForGroup
                                .toString() +
                            " ${getTranslatedForCurrentUser(this.context, 'xxxdaysxxx')}    ${getTranslatedForCurrentUser(this.context, 'xxxsetzeroxxx')}",
                        leadingicondata: Icons.settings_applications_rounded,
                        ontap: () {
                          _controller.text = userAppSettings!
                              .defaultMessageDeletingTimeForGroup
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
                                  this.context, 'xxxdeleteafterxxx'),
                              subtitle: getTranslatedForCurrentUser(
                                  this.context, 'xxxdeleteafterdescxxx'),
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
                                            label: getTranslatedForCurrentUser(
                                                this.context,
                                                'xxxplsentervalidnumberxx'));
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
                                              defaultMessageDeletingTimeForGroup:
                                                  int.tryParse(
                                                      _controller.text.trim()),
                                              notifcationpostedby:
                                                  widget.currentuserid,
                                              notificationtime: DateTime.now()
                                                  .millisecondsSinceEpoch,
                                              notificationtitle:
                                                  "Chat Settings updated",
                                              notificationdesc:
                                                  "defaultMessageDeletingTimeForGroup - is set to ${int.tryParse(_controller.text.trim())} Days"),
                                        );
                                      }
                                    },
                              buttontext: getTranslatedForCurrentUser(
                                  this.context, 'xxupdatexx'),
                              hinttext: getTranslatedForCurrentUser(
                                  this.context, 'xxxdaysxxx'));
                        }),
                    //* -------------------------------

                    //* -------------------------------
                    SizedBox(
                      height: 26,
                    ),
                    sectionHeader(getTranslatedForCurrentUser(
                        this.context, 'xxxpersonalinfoviewxx')),
                    warningTile(
                        isstyledtext: true,
                        title: // russian lang has different tag for this string
                            Utils.checkIfNull(getTranslatedForCurrentUser(
                                    this.context, 'xxru52xx')) ??
                                getTranslatedForCurrentUser(
                                        this.context, 'xxxifbelowtuirnedoffxx')
                                    .replaceAll('(####)',
                                        '${getTranslatedForCurrentUser(this.context, 'xxagentsxx')}'),
                        warningTypeIndex: WarningType.alert.index),
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
                                      .agentCanSeeAgentStatisticsProfile ??
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
                                              .agentCanSeeAgentStatisticsProfile ??
                                          false;
                                      await confirmchangeswitch(
                                          context: this.context,
                                          currentlbool: switchvalue,
                                          updatedmodel: userAppSettings!.copyWith(
                                              agentCanSeeAgentStatisticsProfile:
                                                  !switchvalue,
                                              notifcationpostedby:
                                                  widget.currentuserid,
                                              notificationtime: DateTime.now()
                                                  .millisecondsSinceEpoch,
                                              notificationtitle:
                                                  "Chat Settings updated",
                                              notificationdesc:
                                                  "agentCanSeeAgentStatisticsProfile - is set to ${Utils.getboolText(!switchvalue)}"));
                                    }),
                        ),
                        title: // russian lang has different tag for this string
                            Utils.checkIfNull(getTranslatedForCurrentUser(this.context, 'xxru53xx')) ??
                                getTranslatedForCurrentUser(context, 'xxxcanseexxprofilexxx')
                                    .replaceAll('(####)',
                                        '${getTranslatedForCurrentUser(this.context, 'xxagentsxx')}')
                                    .replaceAll(
                                        '(###)', '${getTranslatedForCurrentUser(this.context, 'xxagentxx')}'),
                        subtitle: isdepartmentbased
                            ? // russian lang has different tag for this string
                            Utils.checkIfNull(getTranslatedForCurrentUser(this.context, 'xxru54xx')) ??
                                getTranslatedForCurrentUser(context, 'xxxcanseedeptxx')
                                    .replaceAll('(####)',
                                        '${getTranslatedForCurrentUser(this.context, 'xxagentxx')}')
                                    .replaceAll('(###)',
                                        '${getTranslatedForCurrentUser(this.context, 'xxagentsxx')}')
                                    .replaceAll(
                                        '(##)', '${getTranslatedForCurrentUser(this.context, 'xxdepartmentxx')}')
                            : getTranslatedForCurrentUser(this.context, 'xxxcanseeallxx')
                                .replaceAll('(####)',
                                    '${getTranslatedForCurrentUser(this.context, 'xxagentxx')}')
                                .replaceAll('(###)',
                                    '${getTranslatedForCurrentUser(this.context, 'xxagentsxx')}'),
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
                                      .agentsCanSeeCustomerStatisticsProfile ??
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
                                              .agentsCanSeeCustomerStatisticsProfile ??
                                          false;
                                      await confirmchangeswitch(
                                          context: this.context,
                                          currentlbool: switchvalue,
                                          updatedmodel: userAppSettings!.copyWith(
                                              agentsCanSeeCustomerStatisticsProfile:
                                                  !switchvalue,
                                              notifcationpostedby:
                                                  widget.currentuserid,
                                              notificationtime: DateTime.now()
                                                  .millisecondsSinceEpoch,
                                              notificationtitle:
                                                  "Chat Settings updated",
                                              notificationdesc:
                                                  "agentsCanSeeCustomerStatisticsProfile - is set to ${Utils.getboolText(!switchvalue)}"));
                                    }),
                        ),
                        title: // russian lang has different tag for this string
                            Utils.checkIfNull(getTranslatedForCurrentUser(this.context, 'xxru55xx')) ??
                                getTranslatedForCurrentUser(context, 'xxxcanseexxprofilexxx')
                                    .replaceAll('(####)',
                                        '${getTranslatedForCurrentUser(this.context, 'xxagentsxx')}')
                                    .replaceAll(
                                        '(###)', '${getTranslatedForCurrentUser(this.context, 'xxcustomerxx')}'),
                        subtitle: isdepartmentbased
                            ? // russian lang has different tag for this string
                            Utils.checkIfNull(getTranslatedForCurrentUser(this.context, 'xxru56xx')) ??
                                getTranslatedForCurrentUser(context, 'xxxcanseedeptxx')
                                    .replaceAll('(####)',
                                        '${getTranslatedForCurrentUser(this.context, 'xxagentxx')}')
                                    .replaceAll('(###)',
                                        '${getTranslatedForCurrentUser(this.context, 'xxcustomersxx')}')
                                    .replaceAll(
                                        '(##)', '${getTranslatedForCurrentUser(this.context, 'xxdepartmentxx')}')
                            : getTranslatedForCurrentUser(this.context, 'xxxcanseeallxx')
                                .replaceAll('(####)',
                                    '${getTranslatedForCurrentUser(this.context, 'xxagentxx')}')
                                .replaceAll('(###)',
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
                                      .secondadminCanSeeAgentStatisticsProfile ??
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
                                              .secondadminCanSeeAgentStatisticsProfile ??
                                          false;
                                      await confirmchangeswitch(
                                          context: this.context,
                                          currentlbool: switchvalue,
                                          updatedmodel: userAppSettings!.copyWith(
                                              secondadminCanSeeAgentStatisticsProfile:
                                                  !switchvalue,
                                              notifcationpostedby:
                                                  widget.currentuserid,
                                              notificationtime: DateTime.now()
                                                  .millisecondsSinceEpoch,
                                              notificationtitle:
                                                  "Chat Settings updated",
                                              notificationdesc:
                                                  "SecondAdminCanSeeManagerProfile - is set to ${Utils.getboolText(!switchvalue)}"));
                                    }),
                        ),
                        title: // russian lang has different tag for this string
                            Utils.checkIfNull(getTranslatedForCurrentUser(
                                    this.context, 'xxru57xx')) ??
                                getTranslatedForCurrentUser(
                                        this.context, 'xxxcanseexxprofilexxx')
                                    .replaceAll('(####)',
                                        '${getTranslatedForCurrentUser(this.context, 'xxsecondadminxx')}')
                                    .replaceAll('(###)',
                                        '${getTranslatedForCurrentUser(this.context, 'xxagentxx')}'),
                        subtitle: // russian lang has different tag for this string
                            Utils.checkIfNull(getTranslatedForCurrentUser(
                                    this.context, 'xxru58xx')) ??
                                getTranslatedForCurrentUser(
                                        this.context, 'xxxcanseeallxx')
                                    .replaceAll('(####)',
                                        '${getTranslatedForCurrentUser(this.context, 'xxsecondadminxx')}')
                                    .replaceAll('(###)',
                                        '${getTranslatedForCurrentUser(this.context, 'xxagentsxx')}'),
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
                                      .secondadminCanSeeCustomerStatisticsProfile ??
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
                                              .secondadminCanSeeCustomerStatisticsProfile ??
                                          false;
                                      await confirmchangeswitch(
                                          context: this.context,
                                          currentlbool: switchvalue,
                                          updatedmodel: userAppSettings!.copyWith(
                                              secondadminCanSeeCustomerStatisticsProfile:
                                                  !switchvalue,
                                              notifcationpostedby:
                                                  widget.currentuserid,
                                              notificationtime: DateTime.now()
                                                  .millisecondsSinceEpoch,
                                              notificationtitle:
                                                  "Chat Settings updated",
                                              notificationdesc:
                                                  "SecondAdminCanSeeCustomerProfile - is set to ${Utils.getboolText(!switchvalue)}"));
                                    }),
                        ),
                        title:// russian lang has different tag for this string
                            Utils.checkIfNull(getTranslatedForCurrentUser(
                                    this.context, 'xxru59xx')) ?? getTranslatedForCurrentUser(
                                this.context, 'xxxcanseexxprofilexxx')
                            .replaceAll('(####)',
                                '${getTranslatedForCurrentUser(this.context, 'xxsecondadminxx')}')
                            .replaceAll('(###)',
                                '${getTranslatedForCurrentUser(this.context, 'xxcustomerxx')}'),
                        subtitle:// russian lang has different tag for this string
                            Utils.checkIfNull(getTranslatedForCurrentUser(
                                    this.context, 'xxru60xx')) ?? getTranslatedForCurrentUser(
                                this.context, 'xxxcanseeallxx')
                            .replaceAll('(####)',
                                '${getTranslatedForCurrentUser(this.context, 'xxsecondadminxx')}')
                            .replaceAll('(###)',
                                '${getTranslatedForCurrentUser(this.context, 'xxcustomersxx')}'),
                        leadingicondata: Icons.settings_applications_rounded),

                    SizedBox(
                      height: 30,
                    ),
                  ]));
  }
}
