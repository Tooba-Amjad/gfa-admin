import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:provider/provider.dart';
import 'package:thinkcreative_technologies/Configs/app_constants.dart';
import 'package:thinkcreative_technologies/Localization/language_constants.dart';
import 'package:thinkcreative_technologies/Models/basic_settings_model_userapp.dart';
import 'package:thinkcreative_technologies/Services/my_providers/session_provider.dart';
import 'package:thinkcreative_technologies/Utils/delayed_function.dart';
import 'package:thinkcreative_technologies/Utils/utils.dart';
import 'package:thinkcreative_technologies/Configs/my_colors.dart';
import 'package:thinkcreative_technologies/Widgets/Input_box.dart';
import 'package:thinkcreative_technologies/Widgets/dialogs/CustomDialog.dart';
import 'package:thinkcreative_technologies/Widgets/dialogs/FormDialog.dart';
import 'package:thinkcreative_technologies/Widgets/dialogs/loadingDialog.dart';
import 'package:thinkcreative_technologies/Widgets/headers/sectionheaders.dart';
import 'package:thinkcreative_technologies/Widgets/my_scaffold.dart';
import 'package:thinkcreative_technologies/Utils/custom_tiles.dart';

class UserLoginSettings extends StatefulWidget {
  final String currentuserid;
  final DocumentReference docRef;
  UserLoginSettings({required this.docRef, required this.currentuserid});
  @override
  _UserLoginSettingsState createState() => _UserLoginSettingsState();
}

class _UserLoginSettingsState extends State<UserLoginSettings> {
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
  BasicSettingModelUserApp? basicrAppSettings;
  fetchdata() async {
    await widget.docRef.get().then((dc) async {
      if (dc.exists) {
        //           Codec<String, String> stringToBase64 = utf8.fuse(base64);
        // String v = stringToBase64.decode(dc["f9846v"]).toString();

        String decoded = utf8.decode(base64.decode(dc["f9846v"]));
        // try parse the http json response
        var jsonobject = json.decode(decoded) as Map<String, dynamic>;

        basicrAppSettings = BasicSettingModelUserApp.fromJson(jsonobject);
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

  Future setEncoded(BasicSettingModelUserApp settingsmodel) async {
    String str = json.encode(settingsmodel.toMap());
    String encoded = base64.encode(utf8.encode("$str"));
    await widget.docRef.set({"f9846v": encoded}, SetOptions(merge: true));
    basicrAppSettings = settingsmodel;
  }

  confirmchangeswitch({
    required BuildContext context,
    bool? currentlbool,
    String? toONmessage,
    String? toOFFmessage,
    required BasicSettingModelUserApp updatedmodel,
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
                await setEncoded(updatedmodel).then((value) async {
                  ShowLoading().close(context: this.context, key: _keyLoader);
                  setState(() {
                    basicrAppSettings = updatedmodel;
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
      required BasicSettingModelUserApp updatedmodel,
      p}) async {
    final session = Provider.of<CommonSession>(this.context, listen: false);
    Navigator.pop(this.context);
    ShowLoading().open(context: this.context, key: _keyLoader);
    await setEncoded(updatedmodel).then((value) async {
      ShowLoading().close(context: this.context, key: _keyLoader);
      setState(() {
        basicrAppSettings = updatedmodel;
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
        title: getTranslatedForCurrentUser(this.context, 'xxxloginrulesxxx'),
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
                        this.context, 'xxxauthxxx')),

                    Card(
                      elevation: 0.1,
                      margin: EdgeInsets.all(4),
                      child: InputGroup2large(
                        title: getTranslatedForCurrentUser(
                            this.context, 'xxxauthtypexxx'),
                        subtitle: // russian lang has different tag for this string
                            Utils.checkIfNull(getTranslatedForCurrentUser(
                                    this.context, 'xxru9xx')) ??
                                getTranslatedForCurrentUser(
                                        this.context, 'xxxsigninproviderforxxx')
                                    .replaceAll('(####)',
                                        '${getTranslatedForCurrentUser(this.context, 'xxcustomersxx')}')
                                    .replaceAll('(###)',
                                        '${getTranslatedForCurrentUser(this.context, 'xxagentsxxx')}'),
                        val1: 'Phone',
                        val2: 'Email/Password',
                        selectedvalue: basicrAppSettings!.loginTypeUserApp
                                        .toString() ==
                                    "" ||
                                basicrAppSettings!.loginTypeUserApp
                                        .toString() ==
                                    "Phone"
                            ? 'Phone'
                            : basicrAppSettings!.loginTypeUserApp.toString(),
                        onChanged: AppConstants.isdemomode == true
                            ? (val) {
                                Utils.toast(getTranslatedForCurrentUser(
                                    this.context, 'xxxnotalwddemoxxaccountxx'));
                              }
                            : (val) async {
                                basicrAppSettings = basicrAppSettings!.copyWith(
                                  loginTypeUserApp: val,
                                );
                                final session = Provider.of<CommonSession>(
                                    this.context,
                                    listen: false);

                                ShowLoading().open(
                                    context: this.context, key: _keyLoader);
                                await setEncoded(basicrAppSettings!)
                                    .then((value) async {
                                  ShowLoading().close(
                                      context: this.context, key: _keyLoader);
                                  setState(() {
                                    basicrAppSettings = basicrAppSettings;
                                  });

                                  ShowSnackbar().open(
                                      context: this.context,
                                      scaffoldKey: _scaffoldKey,
                                      status: 2,
                                      time: 2,
                                      label: getTranslatedForCurrentUser(
                                          this.context,
                                          'xxsuccessvalueupdatedxx'));
                                  session.setUserAppSettingFromFirestore();
                                }).catchError((error) {
                                  ShowLoading().close(
                                      context: this.context, key: _keyLoader);
                                  print('Error: $error');
                                  ShowSnackbar().open(
                                      context: this.context,
                                      scaffoldKey: _scaffoldKey,
                                      status: 1,
                                      time: 3,
                                      label:
                                          '${getTranslatedForCurrentUser(this.context, 'xxxfailedntryagainxxx')}\n $error');
                                });
                              },
                      ),
                    ),

                    //* -------------------------------

                    sectionHeader(
                        // russian lang has different tag for this string
                        Utils.checkIfNull(getTranslatedForCurrentUser(
                                this.context, 'xxru10xx')) ??
                            '${getTranslatedForCurrentUser(this.context, 'xxagentxx').toUpperCase()} ${getTranslatedForCurrentUser(this.context, 'xxloginxx').toUpperCase()}'),
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
                              value: basicrAppSettings!.agentLoginEnabled!,
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
                                      bool switchvalue = basicrAppSettings!
                                              .agentLoginEnabled ??
                                          false;
                                      await confirmchangeswitch(
                                          context: this.context,
                                          currentlbool: switchvalue,
                                          updatedmodel: basicrAppSettings!
                                              .copyWith(
                                                  agentLoginEnabled:
                                                      !switchvalue));
                                    }),
                        ),
                        title: getTranslatedForCurrentUser(
                                this.context, 'xxxxloginenabledxxxx')
                            .replaceAll('(####)',
                                '${Utils.checkIfNull(getTranslatedForCurrentUser(this.context, 'xxru145xx')) ?? getTranslatedForCurrentUser(this.context, 'xxagentxx')}'),
                        subtitle: getTranslatedForCurrentUser(
                                this.context, 'xxxxexistingwhohavecanloginxx')
                            .replaceAll('(####)',
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
                                  basicrAppSettings!.agentRegistartionEnabled!,
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
                                      bool switchvalue = basicrAppSettings!
                                              .agentRegistartionEnabled ??
                                          false;
                                      await confirmchangeswitch(
                                          context: this.context,
                                          currentlbool: switchvalue,
                                          updatedmodel: basicrAppSettings!
                                              .copyWith(
                                                  agentRegistartionEnabled:
                                                      !switchvalue));
                                    }),
                        ),
                        title: getTranslatedForCurrentUser(
                                this.context, 'xxxxregenabledxxxx')
                            .replaceAll('(####)',
                                '${Utils.checkIfNull(getTranslatedForCurrentUser(this.context, 'xxru145xx')) ?? getTranslatedForCurrentUser(this.context, 'xxagentxx')}'),
                        subtitle: getTranslatedForCurrentUser(
                                this.context, 'xxxnewcancreateaccountxxx')
                            .replaceAll('(####)',
                                '${getTranslatedForCurrentUser(this.context, 'xxagentsxx')}'),
                        leadingicondata: Icons.settings_applications_rounded),

                    basicrAppSettings!.agentRegistartionEnabled == false ||
                            basicrAppSettings!.loginTypeUserApp.toString() ==
                                "Phone"
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
                                      basicrAppSettings!.isCustomDomainsOnly!,
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
                                          bool switchvalue = basicrAppSettings!
                                                  .isCustomDomainsOnly ??
                                              false;
                                          await confirmchangeswitch(
                                              context: this.context,
                                              currentlbool: switchvalue,
                                              updatedmodel: basicrAppSettings!
                                                  .copyWith(
                                                      isCustomDomainsOnly:
                                                          !switchvalue));
                                        }),
                            ),
                            title: getTranslatedForCurrentUser(
                                this.context, 'xxxcustomdomainisallowxxx'),
                            subtitle: getTranslatedForCurrentUser(
                                    this.context, 'xxxcustomdomainxxx')
                                .replaceAll('(####)',
                                    '${getTranslatedForCurrentUser(this.context, 'xxagentsxx')}'),
                            leadingicondata:
                                Icons.settings_applications_rounded),
                    basicrAppSettings!.agentRegistartionEnabled == false ||
                            basicrAppSettings!.loginTypeUserApp.toString() ==
                                "Phone"
                        ? SizedBox()
                        : basicrAppSettings!.isCustomDomainsOnly == false
                            ? SizedBox()
                            : customTile(
                                ishighlightdesc: true,
                                margin: 5,
                                iconsize: 30,
                                trailingicondata: Icons.edit_outlined,
                                title: getTranslatedForCurrentUser(
                                    this.context, 'xxxcustomdomainsxxx'),
                                subtitle:
                                    basicrAppSettings!.customDomainslist == ""
                                        ? getTranslatedForCurrentUser(
                                            this.context, 'xxxpredeflistxxx')
                                        : basicrAppSettings!.customDomainslist!,
                                leadingicondata:
                                    Icons.settings_applications_rounded,
                                ontap: () {
                                  _controller.text =
                                      basicrAppSettings!.customDomainslist!;
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
                                          this.context, 'xxxcustomdomainsxxx'),
                                      onpressed: AppConstants.isdemomode == true
                                          ? () {
                                              Utils.toast(
                                                  getTranslatedForCurrentUser(
                                                      this.context,
                                                      'xxxnotalwddemoxxaccountxx'));
                                            }
                                          : () async {
                                              await fieldupdate(
                                                  context: this.context,
                                                  updatedmodel:
                                                      basicrAppSettings!
                                                          .copyWith(
                                                              customDomainslist:
                                                                  _controller
                                                                      .text
                                                                      .trim()));
                                            },
                                      buttontext: getTranslatedForCurrentUser(
                                          this.context, 'xxupdatexx'),
                                      hinttext: getTranslatedForCurrentUser(
                                          this.context, 'xxxpredeflistxxx'));
                                }),
                    basicrAppSettings!.agentRegistartionEnabled == false
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
                                  value: basicrAppSettings!
                                      .agentVerificationNeeded!,
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
                                          bool switchvalue = basicrAppSettings!
                                                  .agentVerificationNeeded ??
                                              false;
                                          await confirmchangeswitch(
                                              context: this.context,
                                              currentlbool: switchvalue,
                                              updatedmodel: basicrAppSettings!
                                                  .copyWith(
                                                      agentVerificationNeeded:
                                                          !switchvalue));
                                        }),
                            ),
                            title: getTranslatedForCurrentUser(
                                    this.context, 'xxxxverfrequiredxxx')
                                .replaceAll('(####)',
                                    '${Utils.checkIfNull(getTranslatedForCurrentUser(this.context, 'xxru145xx')) ?? getTranslatedForCurrentUser(this.context, 'xxagentxx')}'),
                            subtitle:
// russian lang has different tag for this string
                                Utils.checkIfNull(getTranslatedForCurrentUser(
                                        this.context, 'xxru11xx')) ??
                                    getTranslatedForCurrentUser(this.context,
                                            'xxxxeverynewagentapprovalxxx')
                                        .replaceAll('(####)',
                                            '${getTranslatedForCurrentUser(this.context, 'xxagentxx')}'),
                            leadingicondata:
                                Icons.settings_applications_rounded),
                    basicrAppSettings!.agentRegistartionEnabled == false
                        ? SizedBox()
                        : customTile(
                            ishighlightdesc: true,
                            margin: 5,
                            iconsize: 30,
                            trailingicondata: Icons.edit_outlined,
                            title: getTranslatedForCurrentUser(
                                this.context, 'xxxaccountapprovalmessagexx'),
                            subtitle: basicrAppSettings!.accountapprovalmessage,
                            leadingicondata:
                                Icons.settings_applications_rounded,
                            ontap: () {
                              _controller.text =
                                  basicrAppSettings!.accountapprovalmessage!;
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
                                          Utils.toast(
                                              getTranslatedForCurrentUser(
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
                                                updatedmodel: basicrAppSettings!
                                                    .copyWith(
                                                        accountapprovalmessage:
                                                            _controller.text
                                                                .trim()));
                                          }
                                        },
                                  buttontext: getTranslatedForCurrentUser(
                                      this.context, 'xxupdatexx'),
                                  hinttext: getTranslatedForCurrentUser(
                                      this.context, 'xxmssgxx'));
                            }),
                    //* -------------------------------

                    sectionHeader(
                        '${getTranslatedForCurrentUser(this.context, 'xxcustomerxx').toUpperCase()} ${getTranslatedForCurrentUser(this.context, 'xxloginxx').toUpperCase()}'),
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
                              value: basicrAppSettings!.customerLoginEnabled!,
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
                                      bool switchvalue = basicrAppSettings!
                                              .customerLoginEnabled ??
                                          false;
                                      await confirmchangeswitch(
                                          context: this.context,
                                          currentlbool: switchvalue,
                                          updatedmodel: basicrAppSettings!
                                              .copyWith(
                                                  customerLoginEnabled:
                                                      !switchvalue));
                                    }),
                        ),
                        title: getTranslatedForCurrentUser(
                                this.context, 'xxxxloginenabledxxxx')
                            .replaceAll('(####)',
                                '${getTranslatedForCurrentUser(this.context, 'xxcustomerxx')}'),
                        subtitle: getTranslatedForCurrentUser(
                                this.context, 'xxxxexistingwhohavecanloginxx')
                            .replaceAll('(####)',
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
                              value: basicrAppSettings!
                                  .customerRegistationEnabled!,
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
                                      bool switchvalue = basicrAppSettings!
                                              .customerRegistationEnabled ??
                                          false;
                                      await confirmchangeswitch(
                                          context: this.context,
                                          currentlbool: switchvalue,
                                          updatedmodel: basicrAppSettings!
                                              .copyWith(
                                                  customerRegistationEnabled:
                                                      !switchvalue));
                                    }),
                        ),
                        title: getTranslatedForCurrentUser(
                                this.context, 'xxxxregenabledxxxx')
                            .replaceAll('(####)',
                                '${getTranslatedForCurrentUser(this.context, 'xxcustomerxx')}'),
                        subtitle: getTranslatedForCurrentUser(
                                this.context, 'xxxnewcancreateaccountxxx')
                            .replaceAll('(####)',
                                '${getTranslatedForCurrentUser(this.context, 'xxcustomersxx')}'),
                        leadingicondata: Icons.settings_applications_rounded),

                    basicrAppSettings!.agentRegistartionEnabled == false
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
                                  value: basicrAppSettings!
                                      .customerVerificationNeeded!,
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
                                          bool switchvalue = basicrAppSettings!
                                                  .customerVerificationNeeded ??
                                              false;
                                          await confirmchangeswitch(
                                              context: this.context,
                                              currentlbool: switchvalue,
                                              updatedmodel: basicrAppSettings!
                                                  .copyWith(
                                                      customerVerificationNeeded:
                                                          !switchvalue));
                                        }),
                            ),
                            title: getTranslatedForCurrentUser(
                                    this.context, 'xxxxverfrequiredxxx')
                                .replaceAll('(####)',
                                    '${getTranslatedForCurrentUser(this.context, 'xxcustomerxx')}'),
                            subtitle: getTranslatedForCurrentUser(this.context,
                                    'xxxxeverynewagentapprovalxxx')
                                .replaceAll('(####)',
                                    '${getTranslatedForCurrentUser(this.context, 'xxcustomerxx')}'),
                            leadingicondata:
                                Icons.settings_applications_rounded),

                    SizedBox(
                      height: 20,
                    ),
                  ]));
  }
}
