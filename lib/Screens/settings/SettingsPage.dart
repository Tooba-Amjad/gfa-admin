import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thinkcreative_technologies/Configs/app_constants.dart';
import 'package:thinkcreative_technologies/Configs/db_keys.dart';
import 'package:thinkcreative_technologies/Configs/db_paths.dart';
import 'package:thinkcreative_technologies/Configs/enum.dart';
import 'package:thinkcreative_technologies/Configs/my_colors.dart';
import 'package:thinkcreative_technologies/Screens/initialization/initialization_constant.dart';
import 'package:thinkcreative_technologies/Screens/role_manager/role_manager.dart';
import 'package:thinkcreative_technologies/Screens/settings/EditAdminAppSettings.dart';
import 'package:thinkcreative_technologies/Screens/settings/SubSettings/sub-userapp-controls.dart';
import 'package:thinkcreative_technologies/Screens/settings/department/department_settings.dart';
import 'package:thinkcreative_technologies/Screens/users/select_second_admin.dart';
import 'package:thinkcreative_technologies/Services/firebase_services/FirebaseApi.dart';
import 'package:thinkcreative_technologies/Services/my_providers/liveListener.dart';
import 'package:thinkcreative_technologies/Services/my_providers/user_registry_provider.dart';
import 'package:thinkcreative_technologies/Utils/utils.dart';
import 'package:thinkcreative_technologies/Widgets/WarningWidgets/warning_tile.dart';
import 'package:thinkcreative_technologies/Widgets/avatars/Avatar.dart';
import 'package:thinkcreative_technologies/Widgets/dialogs/CustomDialog.dart';
import 'package:thinkcreative_technologies/Widgets/my_scaffold.dart';
import 'package:thinkcreative_technologies/Widgets/boxdecoration.dart';
import 'package:thinkcreative_technologies/Utils/custom_tiles.dart';
import 'package:thinkcreative_technologies/Utils/page_navigator.dart';
import 'package:thinkcreative_technologies/Localization/language_constants.dart';

class SettingsPage extends StatefulWidget {
  final SharedPreferences prefs;
  final String currentuserid;
  final bool isforcehideleading;
  SettingsPage(
      {required this.isforcehideleading,
      required this.currentuserid,
      required this.prefs});
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final GlobalKey<State> _keyLoader =
      new GlobalKey<State>(debugLabel: '272hu1');

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    SpecialLiveConfigData? livedata =
        Provider.of<SpecialLiveConfigData?>(this.context, listen: true);

    var registry = Provider.of<UserRegistry>(this.context, listen: true);
    bool isready = livedata == null
        ? false
        : !livedata.docmap.containsKey(Dbkeys.secondadminID) ||
                livedata.docmap[Dbkeys.secondadminID] == '' ||
                livedata.docmap[Dbkeys.secondadminID] == null
            ? false
            : true;
    return MyScaffold(
      scaffoldkey: _scaffoldKey,
      isforcehideback: widget.isforcehideleading,
      titlespacing: 15,
      title: getTranslatedForCurrentUser(this.context, 'xxxsettingsxxx'),
      body: ListView(padding: EdgeInsets.only(top: 4), children: [
        customTile(
          margin: 8,
          iconsize: 35,
          leadingWidget: avatar(
            imageUrl: isready == true
                ? registry
                    .getUserData(
                        this.context, livedata!.docmap[Dbkeys.secondadminID])
                    .photourl
                : null,
          ),
          title: getTranslatedForCurrentUser(this.context, 'xxsecondadminxx'),
          trailingWidget: IconButton(
              onPressed: () {
                pageNavigator(
                    this.context,
                    SelectSecondAdmin(
                        alreadyselecteduserid:
                            livedata!.docmap[Dbkeys.secondadminID],
                        agents: registry.agents,
                        selecteduser: (agent) {
                          ShowConfirmDialog().open(
                              context: this.context,
                              subtitle: getTranslatedForCurrentUser(
                                      this.context, 'xxxassignxxrolesofxxx')
                                  .replaceAll('(####)',
                                      '${agent.fullname} (${getTranslatedForCurrentUser(this.context, 'xxidxx')} ${agent.id})')
                                  .replaceAll('(###)',
                                      '${getTranslatedForCurrentUser(this.context, 'xxsecondadminxx').toUpperCase()}'),
                              title: getTranslatedForCurrentUser(
                                      this.context, 'xxsetasxx')
                                  .replaceAll('(####)',
                                      '${getTranslatedForCurrentUser(this.context, 'xxsecondadminxx')}'),
                              rightbtnonpress: AppConstants.isdemomode == true
                                  ? () {
                                      Utils.toast(getTranslatedForCurrentUser(
                                          this.context,
                                          'xxxnotalwddemoxxaccountxx'));
                                    }
                                  : () async {
                                      Navigator.pop(this.context);
                                      ShowLoading().open(
                                          context: this.context,
                                          key: _keyLoader);
                                      await FirebaseFirestore.instance
                                          .collection(DbPaths.userapp)
                                          .doc(DbPaths.collectionconfigs)
                                          .update({
                                        Dbkeys.secondadminID:
                                            agent.id.toString()
                                      }).then((value) async {
                                        await FirebaseApi
                                            .runTransactionSendNotification(
                                                isOnlyAlertNotSave: false,
                                                parentid: "sys",
                                                docRef: FirebaseFirestore
                                                    .instance
                                                    .collection(DbPaths
                                                        .collectionagents)
                                                    .doc(agent.id.toString())
                                                    .collection(DbPaths
                                                        .agentnotifications)
                                                    .doc(DbPaths
                                                        .agentnotifications),
                                                title: getTranslatedForCurrentUser(
                                                        this.context,
                                                        'xxxurassignedasxxx')
                                                    .replaceAll('(####)',
                                                        '${getTranslatedForCurrentUser(this.context, 'xxsecondadminxx').toUpperCase()}'),
                                                plainDesc: getTranslatedForCurrentUser(
                                                        this.context,
                                                        'xxxcongratssecondadminxxx')
                                                    .replaceAll('(####)', '${getTranslatedForCurrentUser(this.context, 'xxsecondadminxx').toUpperCase()}')
                                                    .replaceAll('(###)', '${getTranslatedForCurrentUser(this.context, 'xxadminxx')}')
                                                    .replaceAll('(##)', '${getTranslatedForCurrentUser(this.context, 'xxagentsxx')}, ${getTranslatedForCurrentUser(this.context, 'xxcustomersxx')}, ${getTranslatedForCurrentUser(this.context, 'xxsupporttktsxx')} '),
                                                onErrorFn: (e) {
                                                  ShowLoading().close(
                                                      context: this.context,
                                                      key: _keyLoader);
                                                  ShowSnackbar().open(
                                                      context: this.context,
                                                      scaffoldKey: _scaffoldKey,
                                                      status: 0,
                                                      time: 2,
                                                      label:
                                                          'Error Occured ! Error: $e');
                                                  FirebaseFirestore.instance
                                                      .collection(
                                                          DbPaths.userapp)
                                                      .doc(DbPaths
                                                          .collectionconfigs)
                                                      .update({
                                                    Dbkeys.secondadminID: ""
                                                  });
                                                },
                                                postedbyID: widget.currentuserid,
                                                onSuccessFn: () async {
                                                  await FirebaseApi
                                                      .runTransactionRecordActivity(
                                                          isOnlyAlertNotSave:
                                                              false,
                                                          parentid:
                                                              "SECONDADMIN--${agent.id}",
                                                          title: getTranslatedForCurrentUser(context, 'xxnewxxassignedxx')
                                                              .replaceAll(
                                                                  '(####)',
                                                                  '${getTranslatedForCurrentUser(this.context, 'xxsecondadminxx')}'),
                                                          plainDesc: (livedata.docmap[Dbkeys.secondadminID] != "" && livedata.docmap[Dbkeys.secondadminID] != null) == true
                                                              ? getTranslatedForCurrentUser(this.context, 'xxxsecondadminassignedxx')
                                                                      .replaceAll(
                                                                          '(####)', '${getTranslatedForCurrentUser(this.context, 'xxadminxx')}')
                                                                      .replaceAll(
                                                                          '(###)', '${agent.fullname}, ${getTranslatedForCurrentUser(this.context, 'xxidxx')} ${agent.id}')
                                                                      .replaceAll(
                                                                          '(##)', '${getTranslatedForCurrentUser(this.context, 'xxsecondadminxx')}') +
                                                                  " (${getTranslatedForCurrentUser(this.context, 'xxxxcondadminremovedxxx').replaceAll('(####)', '${getTranslatedForCurrentUser(this.context, 'xxadminxx')}').replaceAll('(###)', '${getTranslatedForCurrentUser(this.context, 'xxagentidxx')} ${livedata.docmap[Dbkeys.secondadminID]}').replaceAll('(##)', '${getTranslatedForCurrentUser(this.context, 'xxsecondadminxx')}')}) "
                                                              : getTranslatedForCurrentUser(this.context, 'xxxsecondadminassignedxx')
                                                                  .replaceAll(
                                                                      '(####)',
                                                                      '${getTranslatedForCurrentUser(this.context, 'xxadminxx')}')
                                                                  .replaceAll(
                                                                      '(###)', '${agent.fullname}, ${getTranslatedForCurrentUser(this.context, 'xxidxx')} ${agent.id}')
                                                                  .replaceAll('(##)', '${getTranslatedForCurrentUser(this.context, 'xxsecondadminxx')}'),
                                                          onErrorFn: (e) {
                                                            ShowLoading().close(
                                                                context: this
                                                                    .context,
                                                                key:
                                                                    _keyLoader);
                                                            ShowSnackbar().open(
                                                                context: this
                                                                    .context,
                                                                scaffoldKey:
                                                                    _scaffoldKey,
                                                                status: 0,
                                                                time: 2,
                                                                label:
                                                                    '${getTranslatedForCurrentUser(this.context, 'xxfailedxx')} Error: $e');
                                                            FirebaseFirestore
                                                                .instance
                                                                .collection(
                                                                    DbPaths
                                                                        .userapp)
                                                                .doc(DbPaths
                                                                    .collectionconfigs)
                                                                .update({
                                                              Dbkeys.secondadminID:
                                                                  ""
                                                            });
                                                          },
                                                          postedbyID: widget.currentuserid,
                                                          onSuccessFn: () async {
                                                            if (livedata.docmap[
                                                                        Dbkeys
                                                                            .secondadminID] !=
                                                                    "" &&
                                                                livedata.docmap[
                                                                        Dbkeys
                                                                            .secondadminID] !=
                                                                    null) {
                                                              await Utils.sendDirectNotification(
                                                                  docRef: FirebaseFirestore
                                                                      .instance
                                                                      .collection(DbPaths
                                                                          .collectionagents)
                                                                      .doc(livedata.docmap[Dbkeys.secondadminID]
                                                                          .toString())
                                                                      .collection(DbPaths
                                                                          .agentnotifications)
                                                                      .doc(DbPaths
                                                                          .agentnotifications),
                                                                  title: getTranslatedForCurrentUser(this.context, 'xxxuareremovedfromxxx')
                                                                      .replaceAll(
                                                                          '(####)',
                                                                          '${getTranslatedForCurrentUser(this.context, 'xxsecondadminxx').toUpperCase()}'),
                                                                  plaindesc: getTranslatedForCurrentUser(this.context, 'xxxremovedfromxxx')
                                                                      .replaceAll(
                                                                          '(####)', '${getTranslatedForCurrentUser(this.context, 'xxadminxx')}')
                                                                      .replaceAll('(###)', '${getTranslatedForCurrentUser(this.context, 'xxsecondadminxx').toUpperCase()}'),
                                                                  postedbyID: widget.currentuserid,
                                                                  parentID: "SECONDADMIN--${livedata.docmap[Dbkeys.secondadminID]}");
                                                            }

                                                            ShowLoading().close(
                                                                context: this
                                                                    .context,
                                                                key:
                                                                    _keyLoader);

                                                            ShowSnackbar().open(
                                                              context:
                                                                  this.context,
                                                              scaffoldKey:
                                                                  _scaffoldKey,
                                                              status: 2,
                                                              time: 2,
                                                              label: getTranslatedForCurrentUser(
                                                                      this
                                                                          .context,
                                                                      'xxxsuccessassignxxx')
                                                                  .replaceAll(
                                                                      '(####)',
                                                                      '${agent.fullname}')
                                                                  .replaceAll(
                                                                      '(###)',
                                                                      '${getTranslatedForCurrentUser(this.context, 'xxsecondadminxx')}'),
                                                            );
                                                          });
                                                });
                                      }).catchError((error) {
                                        ShowLoading().close(
                                            context: this.context,
                                            key: _keyLoader);
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
                        }));
              },
              icon: Icon(isready == true ? Icons.edit : Icons.add)),
          subtitle: isready == false
              ? getTranslatedForCurrentUser(this.context, 'xxxassignxxasxxxxx')
                  .replaceAll('(####)',
                      '${getTranslatedForCurrentUser(this.context, 'xxagentxx')}')
                  .replaceAll('(###)',
                      '${getTranslatedForCurrentUser(this.context, 'xxsecondadminxx').toUpperCase()}')
              : registry
                      .getUserData(
                          this.context, livedata!.docmap[Dbkeys.secondadminID])
                      .fullname +
                  " (${getTranslatedForCurrentUser(this.context, 'xxidxx')}${livedata.docmap[Dbkeys.secondadminID]})",
          leadingicondata: Icons.settings_applications_rounded,
          leadingiconcolor: Mycolors.red,
        ),
        isready == false
            ? warningTile(
                isstyledtext: true,
                title: getTranslatedForCurrentUser(
                        this.context, 'xxxnosecondadminxxx')
                    .replaceAll('(####)',
                        '<bold>${getTranslatedForCurrentUser(this.context, 'xxsecondadminxx')}</bold>')
                    .replaceAll('(###)',
                        '<bold>${getTranslatedForCurrentUser(this.context, 'xxcustomerxx')}</bold>'),
                warningTypeIndex: WarningType.alert.index)
            : warningTile(
                isbold: true,
                isstyledtext: true,
                title: getTranslatedForCurrentUser(this.context, 'xxxcanusexxx')
                    .replaceAll('(####)',
                        '<bold>${getTranslatedForCurrentUser(this.context, 'xxsecondadminxx')}</bold>'),
                warningTypeIndex: WarningType.success.index),
        customTile(
            margin: 8,
            iconsize: 35,
            leadingWidget: Container(
              decoration: boxDecoration(
                radius: 9,
                color: Mycolors.orange,
                showShadow: false,
                bgColor: Mycolors.orange,
              ),
              height: 40,
              width: 40,
              child: Center(
                child: Icon(
                  Icons.list,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ),
            title: getTranslatedForCurrentUser(this.context, 'xxdepartmentsxx'),
            subtitle: getTranslatedForCurrentUser(
                    this.context, 'xxxuserappwillworkdeptxxx')
                .replaceAll('(####)',
                    '${getTranslatedForCurrentUser(this.context, 'xxdepartmentsxx')}'),
            leadingicondata: Icons.settings_applications_rounded,
            leadingiconcolor: Mycolors.red,
            ontap: () {
              pageNavigator(
                  this.context,
                  DepartmentSettings(
                    docRef: FirebaseFirestore.instance
                        .collection(DbPaths.userapp)
                        .doc(DbPaths.appsettings),
                    currentuserid: widget.currentuserid,
                  ));
            }),
        customTile(
            margin: 8,
            iconsize: 35,
            leadingWidget: Container(
              decoration: boxDecoration(
                radius: 9,
                color: Mycolors.red,
                showShadow: false,
                bgColor: Mycolors.red,
              ),
              height: 40,
              width: 40,
              child: Center(
                child: Icon(
                  Icons.settings,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ),
            title: getTranslatedForCurrentUser(
                this.context, 'xxxuserappcontrolsxxx'),
            subtitle: getTranslatedForCurrentUser(
                    this.context, 'xxxuserappsettingsdescxxx')
                .replaceAll('(####)',
                    '${getTranslatedForCurrentUser(this.context, 'xxagentsxx')}')
                .replaceAll('(###)',
                    '${getTranslatedForCurrentUser(this.context, 'xxcustomersxx')}'),
            ontap: () {
              pageNavigator(
                  this.context,
                  SubUserAppControls(
                    currentuserid: widget.currentuserid,
                    isforcehideleading: false,
                    docref: FirebaseFirestore.instance
                        .collection(DbPaths.userapp)
                        .doc(DbPaths.appsettings),
                    iconcolor: Mycolors.red,
                  ));
            },
            leadingicondata: Icons.settings_applications_rounded),
        customTile(
            color: Color(0xffe0f5ff),
            margin: 8,
            iconsize: 35,
            leadingWidget: Container(
              decoration: boxDecoration(
                radius: 9,
                color: Mycolors.cyan,
                showShadow: false,
                bgColor: Mycolors.cyan,
              ),
              height: 40,
              width: 40,
              child: Center(
                child: Icon(
                  Icons.person_pin_circle_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ),
            title: getTranslatedForCurrentUser(this.context, 'xxrolemanagerxx'),
            subtitle:
                '${getTranslatedForCurrentUser(this.context, 'xxxquicksettingsxxx')}. ${getTranslatedForCurrentUser(this.context, 'xxxassignrolesxxx').replaceAll('(####)', '${getTranslatedForCurrentUser(this.context, 'xxagentsxx')}').replaceAll('(###)', '${getTranslatedForCurrentUser(this.context, 'xxcustomersxx')}').replaceAll('(##)', '${getTranslatedForCurrentUser(this.context, 'xxsecondadminxx')}')}',
            ontap: () {
              pageNavigator(
                  this.context,
                  RoleManager(
                    currentuserid: widget.currentuserid,
                    docRef: FirebaseFirestore.instance
                        .collection(DbPaths.userapp)
                        .doc(DbPaths.appsettings),
                  ));
            },
            leadingicondata: Icons.settings_applications_rounded),
        SizedBox(
          height: 30,
        ),
        customTile(
            margin: 8,
            iconsize: 35,
            leadingWidget: Container(
              decoration: boxDecoration(
                radius: 9,
                color: Mycolors.green,
                showShadow: false,
                bgColor: Mycolors.green,
              ),
              height: 40,
              width: 40,
              child: Center(
                child: Icon(
                  Icons.app_settings_alt,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ),
            title: getTranslatedForCurrentUser(
                this.context, 'xxxadminappsettingsxxx'),
            subtitle: getTranslatedForCurrentUser(
                this.context, 'xxxsettingsforadminxxx'),
            leadingicondata: Icons.settings_applications_rounded,
            leadingiconcolor: Mycolors.red,
            ontap: () {
              pageNavigator(
                  this.context,
                  AdminAppSettings(
                    docRef: FirebaseFirestore.instance
                        .collection(InitializationConstant.k9)
                        .doc(InitializationConstant.k11),
                  ));
            }),
        // customTile(
        //     margin: 8,
        //     iconsize: 35,
        //     leadingWidget: Container(
        //       decoration: boxDecoration(
        //         radius: 9,
        //         color: Mycolors.purple,
        //         showShadow: false,
        //         bgColor: Mycolors.purple,
        //       ),
        //       height: 40,
        //       width: 40,
        //       child: Center(
        //         child: Icon(
        //           Icons.add,
        //           color: Colors.white,
        //           size: 22,
        //         ),
        //       ),
        //     ),
        //     title: getTranslatedForCurrentUser(this.context, 'xxmodulesxx'),
        //     subtitle:
        //         getTranslatedForCurrentUser(this.context, 'xxmodulesmanagexx'),
        //     leadingicondata: Icons.add,
        //     leadingiconcolor: Mycolors.purple,
        //     ontap: () {
        //       pageNavigator(
        //           this.context,
        //           AllModules(
        //             prefs: widget.prefs,
        //           ));
        //     }),
      ]),
    );
  }
}
