import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:thinkcreative_technologies/Configs/app_constants.dart';
import 'package:thinkcreative_technologies/Configs/my_colors.dart';
import 'package:thinkcreative_technologies/Localization/language_constants.dart';
import 'package:thinkcreative_technologies/Screens/initialization/initialization_constant.dart';
import 'package:thinkcreative_technologies/Screens/settings/SubSettings/agentchat_groupchat_settings.dart';
import 'package:thinkcreative_technologies/Screens/settings/SubSettings/custom_tabs_settings.dart';
import 'package:thinkcreative_technologies/Screens/settings/SubSettings/demo_userids.dart';
import 'package:thinkcreative_technologies/Screens/settings/SubSettings/terms_privacy_settings.dart';
import 'package:thinkcreative_technologies/Screens/settings/SubSettings/ticket_settings.dart';
import 'package:thinkcreative_technologies/Screens/settings/SubSettings/userapp_basic_settings.dart';
import 'package:thinkcreative_technologies/Screens/settings/SubSettings/userapp_login_settings.dart';
import 'package:thinkcreative_technologies/Screens/settings/SubSettings/advanced_settings.dart';
import 'package:thinkcreative_technologies/Widgets/my_scaffold.dart';
import 'package:thinkcreative_technologies/Widgets/boxdecoration.dart';
import 'package:thinkcreative_technologies/Utils/custom_tiles.dart';
import 'package:thinkcreative_technologies/Utils/page_navigator.dart';

class SubUserAppControls extends StatefulWidget {
  final bool isforcehideleading;
  final String currentuserid;
  final Color iconcolor;
  final DocumentReference docref;
  SubUserAppControls(
      {required this.isforcehideleading,
      required this.currentuserid,
      required this.iconcolor,
      required this.docref});
  @override
  _SubUserAppControlsState createState() => _SubUserAppControlsState();
}

class _SubUserAppControlsState extends State<SubUserAppControls> {
  @override
  Widget build(BuildContext context) {
    return MyScaffold(
      titlespacing: 15,
      title: getTranslatedForEventsAndAlerts(
          this.context, 'xxxuserappcontrolsxxx'),
      body: ListView(padding: EdgeInsets.only(top: 4), children: [
        customTile(
            isheading: true,
            margin: 8,
            iconsize: 35,
            leadingWidget: Container(
              decoration: boxDecoration(
                radius: 9,
                color: Mycolors.purple,
                showShadow: false,
                bgColor: Mycolors.purple,
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
            title:
                getTranslatedForCurrentUser(this.context, 'xxxbasicsetupxxx'),
            subtitle:
                getTranslatedForCurrentUser(this.context, 'xxxandroidiosxxx'),
            leadingicondata: Icons.settings_applications_rounded,
            leadingiconcolor: widget.iconcolor,
            ontap: () {
              pageNavigator(
                  this.context,
                  UserBasicSettings(
                    currentuserid: widget.currentuserid,
                    docRef: FirebaseFirestore.instance
                        .collection(InitializationConstant.k9)
                        .doc(InitializationConstant.k14),
                  ));
            }),
        customTile(
            isheading: true,
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
                  Icons.key,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ),
            title:
                getTranslatedForCurrentUser(this.context, 'xxxauthsettingsxx'),
            subtitle: getTranslatedForCurrentUser(
                this.context, 'xxxauthsettingsdescxx'),
            leadingicondata: Icons.settings_applications_rounded,
            leadingiconcolor: widget.iconcolor,
            ontap: () {
              pageNavigator(
                  this.context,
                  UserLoginSettings(
                    currentuserid: widget.currentuserid,
                    docRef: FirebaseFirestore.instance
                        .collection(InitializationConstant.k9)
                        .doc(InitializationConstant.k14),
                  ));
            }),
        customTile(
            isheading: true,
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
                  Icons.app_settings_alt,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ),
            title: getTranslatedForCurrentUser(
                this.context, 'xxadvancesettingsxx'),
            subtitle: getTranslatedForCurrentUser(
                this.context, 'xxxbettermanagementxxx'),
            leadingicondata: Icons.settings_applications_rounded,
            leadingiconcolor: widget.iconcolor,
            ontap: () {
              pageNavigator(
                  this.context,
                  AdvancedSettings(
                    currentuserid: widget.currentuserid,
                    docRef: widget.docref,
                  ));
            }),
        customTile(
            isheading: true,
            margin: 8,
            iconsize: 35,
            leadingWidget: Container(
              decoration: boxDecoration(
                radius: 9,
                color: Mycolors.purple,
                showShadow: false,
                bgColor: Mycolors.purple,
              ),
              height: 40,
              width: 40,
              child: Center(
                child: Icon(
                  LineAwesomeIcons.table,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ),
            title:
                getTranslatedForCurrentUser(this.context, 'xxxcustomtabsxxx'),
            subtitle:
                getTranslatedForCurrentUser(this.context, 'xxxaddcustomtabxxx'),
            leadingicondata: Icons.settings_applications_rounded,
            leadingiconcolor: widget.iconcolor,
            ontap: () {
              pageNavigator(
                  this.context,
                  CustomTabSettings(
                    currentuserid: widget.currentuserid,
                    docRef: widget.docref,
                  ));
            }),
        customTile(
            isheading: true,
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
                  LineAwesomeIcons.alternate_ticket,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ),
            title:
                '${getTranslatedForCurrentUser(this.context, 'xxcustomerxx')} ${getTranslatedForCurrentUser(this.context, 'xxsupporttktsxx')}',
            subtitle: getTranslatedForCurrentUser(
                    this.context, 'xxxwherexxcancommunicatexxx')
                .replaceAll('(####)',
                    '${getTranslatedForCurrentUser(this.context, 'xxsupporttktxx')} ${getTranslatedForCurrentUser(this.context, 'xxchatxx')}')
                .replaceAll('(###)',
                    '${getTranslatedForCurrentUser(this.context, 'xxagentsxx')}')
                .replaceAll('(##)',
                    '${getTranslatedForCurrentUser(this.context, 'xxcustomerxx')}'),
            leadingicondata: Icons.settings_applications_rounded,
            leadingiconcolor: widget.iconcolor,
            ontap: () {
              pageNavigator(
                  this.context,
                  TicketSettings(
                    currentuserid: widget.currentuserid,
                    docRef: widget.docref,
                  ));
            }),
        customTile(
            isheading: true,
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
                  Icons.people_alt_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ),
            title: getTranslatedForCurrentUser(this.context, 'xxagentchatsxx'),
            subtitle:
                '${getTranslatedForCurrentUser(this.context, 'xxagentchatsxx')}, ${getTranslatedForCurrentUser(this.context, 'xxgroupchatxx').replaceAll('(####)', '${getTranslatedForCurrentUser(this.context, 'xxagentsxx')}')}',
            leadingicondata: Icons.settings_applications_rounded,
            leadingiconcolor: widget.iconcolor,
            ontap: () {
              pageNavigator(
                  this.context,
                  AgentChatGroupChatSettings(
                    currentuserid: widget.currentuserid,
                    docRef: widget.docref,
                  ));
            }),
        customTile(
            isheading: true,
            margin: 8,
            iconsize: 35,
            leadingWidget: Container(
              decoration: boxDecoration(
                radius: 9,
                color: Colors.purple[400],
                showShadow: false,
                bgColor: Colors.purple[400]!,
              ),
              height: 40,
              width: 40,
              child: Center(
                child: Icon(
                  Icons.lock,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ),
            title:
                getTranslatedForCurrentUser(this.context, 'xxxtermsandpolicy'),
            subtitle: getTranslatedForCurrentUser(
                this.context, 'xxxuploadpdforaddweblinks'),
            leadingicondata: Icons.settings_applications_rounded,
            leadingiconcolor: widget.iconcolor,
            ontap: () {
              pageNavigator(
                  this.context,
                  TermsPrivacySettings(
                    currentuserid: widget.currentuserid,
                    docRef: FirebaseFirestore.instance
                        .collection(InitializationConstant.k9)
                        .doc(InitializationConstant.k14),
                  ));
            }),
        AppConstants.isdemomode == true
            ? SizedBox()
            : SizedBox(
                height: 20,
              ),
        AppConstants.appname == "Mobijet Admin" &&
                AppConstants.isdemomode == false
            ? customTile(
                isheading: true,
                margin: 8,
                iconsize: 35,
                leadingWidget: Container(
                  decoration: boxDecoration(
                    radius: 9,
                    color: Colors.brown[400],
                    showShadow: false,
                    bgColor: Colors.brown[400]!,
                  ),
                  height: 40,
                  width: 40,
                  child: Center(
                    child: Icon(
                      Icons.supervised_user_circle,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ),
                title: 'Demo User IDs',
                subtitle: 'Demo Agents & Customer IDs',
                leadingicondata: Icons.settings_applications_rounded,
                leadingiconcolor: widget.iconcolor,
                ontap: () {
                  pageNavigator(
                      this.context,
                      DemoUserIDs(
                        currentuserid: widget.currentuserid,
                        docRef: widget.docref,
                      ));
                })
            : SizedBox(),
      ]),
    );
  }
}
