import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thinkcreative_technologies/Configs/db_keys.dart';
import 'package:thinkcreative_technologies/Configs/app_constants.dart';
import 'package:thinkcreative_technologies/Configs/db_paths.dart';
import 'package:thinkcreative_technologies/Configs/my_colors.dart';
import 'package:thinkcreative_technologies/Localization/language.dart';
import 'package:thinkcreative_technologies/Localization/language_constants.dart';
import 'package:thinkcreative_technologies/Models/basic_settings_model_adminapp.dart';
import 'package:thinkcreative_technologies/Screens/dashboard/BottomNavBarAdminApp.dart';
import 'package:thinkcreative_technologies/Screens/authentication/PasscodeScreen.dart';
import 'package:thinkcreative_technologies/Screens/splashScreen/SplashScreen.dart';
import 'package:thinkcreative_technologies/Services/my_providers/session_provider.dart';
import 'package:thinkcreative_technologies/Utils/utils.dart';
import 'package:thinkcreative_technologies/Widgets/custom_buttons.dart';
import 'package:thinkcreative_technologies/Widgets/Input_box.dart';
import 'package:thinkcreative_technologies/Widgets/custom_text.dart';
import 'package:thinkcreative_technologies/Utils/hide_keyboard.dart';
import 'package:thinkcreative_technologies/Utils/page_navigator.dart';
import 'package:thinkcreative_technologies/Widgets/dialogs/CustomDialog.dart';
import 'package:thinkcreative_technologies/Widgets/dynamic_modal_bottomsheet.dart';
import 'package:thinkcreative_technologies/Widgets/my_inkwell.dart';
import 'package:thinkcreative_technologies/main.dart';

class AdminAauth extends StatefulWidget {
  AdminAauth({
    Key? key,
    required this.prefs,
    required this.basicsettings,
    required this.currentdeviceID,
    required this.deviceInfoMap,
  }) : super(key: key);

  final SharedPreferences prefs;
  final BasicSettingModelAdminApp basicsettings;
  final String currentdeviceID;
  final deviceInfoMap;

  @override
  _AdminAauthState createState() => new _AdminAauthState();
}

class _AdminAauthState extends State<AdminAauth> {
  bool isloggedin = false;

  String? errormsg = '';
  int attempt = 0;
  TextEditingController _enteredemailcontroller = new TextEditingController();
  TextEditingController _enteredpasswordcontroller = new TextEditingController();
  final _scaffoldKey = GlobalKey<ScaffoldState>(debugLabel: '_hhddbh');
  GlobalKey<State> _keyLoader = new GlobalKey<State>(debugLabel: '7338dshh83833');
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      checkLoginStatus(false);
      if (AppConstants.isdemomode == true) {
        _enteredemailcontroller.text = AppConstants.demoadminemail;
        _enteredpasswordcontroller.text = AppConstants.demoadminpassword;
      }
    });
  }

  // firsttimeWriteDatabase() async {
  //   final session = Provider.of<CommonSession>(this.context, listen: false);
  //   //-------Below Firestore Document creation for Admin app Settings ---------
  //   await FirebaseFirestore.instance.collection(DbPaths.adminapp).doc(DbPaths.admincred).set(adminappsettingsmap, SetOptions(merge: true)).then((value) async {
  //     await batchwrite().then((value) async {
  //       if (value == false) {
  //         setState(() {
  //           errormsg = 'Error occured while setting up admin app.\n\nPlease inform the below captured error to developer: BATCH_WRITE FAILED AT ADMIN LOGIN PAGE';
  //         });
  //
  //         await session.createalert(
  //             alertmsgforuser: '',
  //             context: this.context,
  //             alerttime: DateTime.now().millisecondsSinceEpoch,
  //             alerttitle: 'Database setup failed',
  //             alertdesc: 'First time database write failed by admin (${AppConstants.apptype}). \n[CAPTURED ERROR: Batched Write failed at admin login page]');
  //       } else if (value == true) {
  //         checkLoginStatus();
  //       }
  //     });
  //   }).catchError((err) async {
  //     if (mounted)
  //       setState(() {
  //         errormsg = 'Error occured while setting up admin app.\n\nPlease inform the below captured error to developer: $err';
  //       });
  //
  //     await session.createalert(
  //         alertmsgforuser: '',
  //         context: this.context,
  //         alerttime: DateTime.now().millisecondsSinceEpoch,
  //         alerttitle: 'Database setup failed',
  //         alertdesc: 'First time database write failed by admin (${AppConstants.apptype}). \n[CAPTURED ERROR:$err]');
  //   });
  // }

  void _changeLanguage(Language language) async {
    Locale _locale = await setLocaleForUsers(language.languageCode);
    AppWrapper.setLocale(this.context, _locale);

    await widget.prefs.setBool('islanguageselected', true);
  }

  checkLoginStatus(bool isfreshlogin) async {
    final session = Provider.of<CommonSession>(this.context, listen: false);
    session.setData(newbasicadminappsettings: widget.basicsettings);
    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      print('User is currently signed out!');

      setState(() {
        isLoading = false;
        isloggedin = false;
        errormsg = null;
      });
    } else {
      print('User is signed in!');
      await FirebaseFirestore.instance.collection(DbPaths.adminapp).doc(DbPaths.admincred).get().then((doc) async {
        if (doc.exists) {
          if (doc.data()!.containsKey(Dbkeys.admindeviceid)) {
            if (doc[Dbkeys.admindeviceid] == widget.currentdeviceID || (doc[Dbkeys.admindeviceid] == "")) {
              if (doc[Dbkeys.admindeviceid] == "" && isfreshlogin == true) {
                if (doc[Dbkeys.setupNotdoneyet] == true) {
                  Navigator.pushAndRemoveUntil(
                    this.context,
                    MaterialPageRoute(
                      builder: (BuildContext context) => MyBottomNavBarAdminApp(
                        prefs: widget.prefs,
                        isFirstTimeSetup: true,
                        currentdeviceid: widget.currentdeviceID,
                      ),
                    ),
                    (route) => false,
                  );
                } else {
                  pageNavigator(
                      this.context,
                      PasscodeScreen(
                        prefs: widget.prefs,
                        currentdeviceID: widget.currentdeviceID,
                        deviceInfoMap: widget.deviceInfoMap,
                        docmap: doc.data(),
                        basicsettings: widget.basicsettings,
                        isfirsttime: false,
                      ));
                }
              } else if ((doc[Dbkeys.admindeviceid] == "" || doc[Dbkeys.admindeviceid] == "no-device") && isfreshlogin == false) {
                var b = widget.prefs.getBool('isLoggedIn');

                if (b == true) {
                  pageNavigator(
                      this.context,
                      PasscodeScreen(
                        prefs: widget.prefs,
                        currentdeviceID: widget.currentdeviceID,
                        deviceInfoMap: widget.deviceInfoMap,
                        docmap: doc.data(),
                        basicsettings: widget.basicsettings,
                        isfirsttime: false,
                      ));
                } else {
                  setState(() {
                    isLoading = false;
                    isloggedin = false;
                    errormsg = null;
                  });
                  FirebaseAuth.instance.signOut();
                }
              } else {
                pageNavigator(
                    this.context,
                    PasscodeScreen(
                      prefs: widget.prefs,
                      currentdeviceID: widget.currentdeviceID,
                      deviceInfoMap: widget.deviceInfoMap,
                      docmap: doc.data(),
                      basicsettings: widget.basicsettings,
                      isfirsttime: false,
                    ));
              }
            } else {
              if (AppConstants.isdemomode == true || AppConstants.isMultiDeviceLoginEnabled == true) {
                pageNavigator(
                    this.context,
                    PasscodeScreen(
                      prefs: widget.prefs,
                      currentdeviceID: widget.currentdeviceID,
                      deviceInfoMap: widget.deviceInfoMap,
                      docmap: doc.data(),
                      basicsettings: widget.basicsettings,
                      isfirsttime: false,
                    ));
              } else {
                if (isfreshlogin == true && _enteredemailcontroller.text.trim().length > 1) {
                  pageNavigator(
                      this.context,
                      PasscodeScreen(
                        prefs: widget.prefs,
                        currentdeviceID: widget.currentdeviceID,
                        deviceInfoMap: widget.deviceInfoMap,
                        docmap: doc.data(),
                        basicsettings: widget.basicsettings,
                        isfirsttime: false,
                      ));
                } else {
                  await FirebaseAuth.instance.signOut();
                  isLoading = false;
                  errormsg = null;
                  isloggedin = false;
                  setState(() {});
                }

                print("fnsdvfbsvfbnsd nbfsvdnfbsdfbnfnb fbns f nds fsd");
                // Restart.restartApp();

                // Navigator.of(this.context).popUntil((route) => route.isFirst);
                // Restart.restartApp();
              }
            }
          } else {
            isLoading = false;
            setState(() {});
            errormsg = null;
            FirebaseAuth.instance.signOut();
            Utils.toast("${getTranslatedForCurrentUser(this.context, 'xxxsessionexpiredxxx')}.\n\n Not ready yet");
          }
        } else {
          setState(() {
            isLoading = false;
            errormsg = 'Error occured while setting up admin app. ERR_487';
          });
          FirebaseAuth.instance.signOut();
          Utils.toast(errormsg!);
        }
      }).catchError((e) {
        setState(() {
          isLoading = false;
          errormsg = "ERR_423:  Error loadin admin data. Please try again . If it continues Please report it to developer.";
        });
        Utils.toast(errormsg!);
      });
    }
  }

  bool istask1done = false;
  bool isLoading = true;
  loginWdget(BuildContext context) {
    var h = MediaQuery.of(this.context).size.height;
    return ListView(
      children: [
        Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(28, 45, 28, 17),
                    child: Image.asset(
                      AppConstants.logopath,
                      height: 90,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(28, h / 47, 28, 10),
                    child: MtCustomfontBoldSemi(
                      text: getTranslatedForCurrentUser(this.context, 'xxwelcomexx').replaceAll('(####)', ''),
                      color: Colors.white54,
                      fontsize: 23,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(28, 5, 13, 17),
                    child: MtCustomfontBoldExtra(
                      text: AppConstants.title,
                      color: Colors.white,
                      fontsize: 30,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 30,
              ),
              SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 3.0,
                      color: Colors.white.withOpacity(0.3),
                      spreadRadius: 1.0,
                    ),
                  ],
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.white,
                ),
                margin: EdgeInsets.fromLTRB(15, h / 30.3, 16, 0),
                child: Column(
                  children: <Widget>[
                    SizedBox(
                      height: 13,
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(28, 10, 28, 10),
                      child: MtCustomfontBold(
                        text: AppConstants.isdemomode == true
                            ? getTranslatedForCurrentUser(this.context, 'xxxlogintoadmindemoxxx')
                            : getTranslatedForCurrentUser(this.context, 'xxxlogintoadminxxx'),
                        color: Mycolors.secondary,
                        fontsize: 18,
                      ),
                    ),
                    SizedBox(
                      height: 3,
                    ),

                    Padding(
                      padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                      child: InpuTextBox(
                        boxbordercolor: Colors.white,
                        boxbcgcolor: Mycolors.greylightcolor,
                        hinttext: getTranslatedForCurrentUser(this.context, 'xxemailxx'),
                        boxcornerradius: 6,
                        boxheight: 50,
                        controller: _enteredemailcontroller,
                        forcedmargin: EdgeInsets.only(bottom: 0),
                        autovalidate: false,
                        contentpadding: EdgeInsets.only(top: 15, bottom: 15, left: 20, right: 20),
                        keyboardtype: TextInputType.emailAddress,
                        inputFormatter: [],
                        onSaved: (val) {},
                        isboldinput: true,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8, 2, 8, 8),
                      child: InpuTextBox(
                        boxbordercolor: Colors.white,
                        boxbcgcolor: Mycolors.greylightcolor,
                        hinttext: getTranslatedForCurrentUser(this.context, 'xxpasswordxx'),
                        boxcornerradius: 6,
                        boxheight: 50,
                        autovalidate: false,
                        contentpadding: EdgeInsets.only(top: 15, bottom: 15, left: 20, right: 20),
                        keyboardtype: TextInputType.text,
                        inputFormatter: [],
                        obscuretext: true,
                        controller: _enteredpasswordcontroller,
                        isboldinput: true,
                      ),
                    ),
                    // Padding(
                    //   padding: EdgeInsets.all(17),
                    //   child: Text(
                    //     'Send a SMS Code to Verify your number.',
                    //     // 'Send a SMS Code to verify your number',
                    //     textAlign: TextAlign.center,
                    //     // style: TextStyle(color: Mycolors.black),
                    //   ),
                    // ),

//                     InkWell(
//                       onTap: () {
//                         for (var i = 0; i < 50; i++) {
//                           print(
//                               "       exlistDV$i: exlistDV$i ?? this.exlistDV$i,");

//                           // print(
//                           //     'String exstring$i = ""; int exint$i = 0; double exdouble$i = 0.0;  bool exbooltrue$i = true; bool exboolfalse$i = true; Map extraMap$i = {}; List<dynamic> exlist$i = [];');

//                           // print(
//                           //     'required this.exstring$i, required this.exint$i, required this.exdouble$i, required this.exbooltrue$i,  required this.exboolfalse$i, required this.extraMap$i,  required this.exlist$i,');

//                           // print(
//                           //     ' final String? exstring$i,  final int? exint$i,  final double? exdouble$i,     final bool? exbooltrue$i, final bool? exboolfalse$i,   final Map? extraMap$i,     final List<dynamic>? exlist$i,');

//                           // print(
//                           //     ' exstring$i: exstring$i ?? this.exstring$i, exint$i: exint$i ?? this.exint$i, exdouble$i: exdouble$i ?? this.exdouble$i, exbooltrue$i: exbooltrue$i ?? this.exbooltrue$i, exboolfalse$i: exboolfalse$i ?? this.exboolfalse$i, extraMap$i: extraMap$i ?? this.extraMap$i, exlist$i: exlist$i ?? this.exlist$i,');

//                           // print(
//                           //     'exstring$i: doc[Dbkeys.exstring$i], exint$i: doc[Dbkeys.exint$i], exdouble$i: doc[Dbkeys.exdouble$i], exbooltrue$i: doc[Dbkeys.exbooltrue$i], exboolfalse$i: doc[Dbkeys.exboolfalse$i], extraMap$i: doc[Dbkeys.extraMap$i], exlist$i: doc[Dbkeys.exlist$i],');

//                           // print(
//                           //     'Dbkeys.$i: this.exstring$i, Dbkeys.exint$i: this.exint$i, Dbkeys.exdouble$i: this.exdouble$i, Dbkeys.exbooltrue$i: this.exbooltrue$i, Dbkeys.exboolfalse$i: this.exboolfalse$i, Dbkeys.extraMap$i: this.extraMap$i, Dbkeys.exlist$i: this.exlist$i,');

// //------final for db keys -----

//                           // print(
//                           //     '  static final String exlist$i = \'L$i\';');
//                           // print(
//                           //     '  static final String exbooltrue$i = \'bT$i\';');
//                           // print(
//                           //     '  static final String exboolfalse$i = \'bF$i\';');
//                           // print(
//                           //     '  static final String extraMap$i = \'m$i\';');
//                           // print(
//                           //     '  static final String exdouble$i = \'d$i\';');
//                           // print(
//                           //     '  static final String exstring$i = \'s$i\';');
//                           // print(
//                           //     '  static final String exint$i = \'i$i\';');
//                           //-----for empty data----

//                           // print(
//                           //     'this.exstring$i="", this.exint$i=0, this.exdouble$i=0.0, this.exbooltrue$i=true, this.exboolfalse$i=false, this.extraMap$i=const{}, this.exlist$i=const[],');

//                         }
//                       },
//                       child: Padding(
//                         padding: const EdgeInsets.all(18.0),
//                         child: Text("datdfdsfdsfsdfsfsda"),
//                       ),
//                     ),

                    Padding(
                      padding: EdgeInsets.fromLTRB(15, 12, 15, 0),
                      child: isLoading == true
                          ? Center(
                              child: CircularProgressIndicator(),
                            )
                          : MySimpleButton(
                              buttoncolor: Mycolors.black,
                              buttontext: getTranslatedForCurrentUser(this.context, 'xxloginxx').toUpperCase(),
                              onpressed: AppConstants.isdemomode == true
                                  ? () async {
                                      ShowLoading().open(
                                        context: this.context,
                                        key: _keyLoader,
                                      );
                                      try {
                                        // UserCredential userCredential =
                                        await FirebaseAuth.instance
                                            .signInWithEmailAndPassword(
                                                email: AppConstants.isdemomode == true ? AppConstants.demoadminemail : _enteredemailcontroller.text.trim(),
                                                password: AppConstants.isdemomode == true ? AppConstants.demoadminpassword : _enteredpasswordcontroller.text.trim())
                                            .then((value) {
                                          ShowLoading().close(
                                            context: this.context,
                                            key: _keyLoader,
                                          );
                                          pageNavigator(
                                              this.context,
                                              PasscodeScreen(
                                                prefs: widget.prefs,
                                                currentdeviceID: widget.currentdeviceID,
                                                deviceInfoMap: widget.deviceInfoMap,
                                                basicsettings: widget.basicsettings,
                                                docmap: "",
                                                isfirsttime: false,
                                              ));
                                        });
                                      } catch (e) {
                                        ShowLoading().close(
                                          context: this.context,
                                          key: _keyLoader,
                                        );
                                        Utils.toast(e.toString());
                                      }
                                    }
                                  : widget.basicsettings.isEmailLoginEnabled == true
                                      ? () async {
                                          ShowSnackbar().open(
                                              label: getTranslatedForCurrentUser(this.context, 'xxxlogintempdisbaledxxx'),
                                              context: this.context,
                                              scaffoldKey: _scaffoldKey,
                                              time: 2,
                                              status: 0);
                                        }
                                      : () async {
                                          if (_enteredemailcontroller.text.trim().length < 2 || _enteredpasswordcontroller.text.trim().length < 2) {
                                            ShowSnackbar().open(
                                                label: getTranslatedForCurrentUser(this.context, 'xxxplsenterlogincredxxx'),
                                                context: this.context,
                                                scaffoldKey: _scaffoldKey,
                                                time: 2,
                                                status: 0);
                                          } else {
                                            hidekeyboard(this.context);
                                            await loginCredentialsCheck(context);
                                          }
                                        }),
                    ),

                    SizedBox(
                      height: 11,
                    ),
                    AppConstants.isdemomode == true
                        ? MtCustomfontRegular(
                            text: getTranslatedForCurrentUser(this.context, 'xxxtaploginxxx'),
                            fontsize: 12,
                            color: Mycolors.green,
                          )
                        : SizedBox(),
                    SizedBox(
                      height: 11,
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
        Center(
          child: Language.languageList().length < 2
              ? SizedBox()
              : Padding(
                  padding: const EdgeInsets.fromLTRB(10, 27, 7, 10),
                  child: myinkwell(
                      onTap: Language.languageList().length < 2
                          ? () {}
                          : () {
                              showDynamicModalBottomSheet(
                                title: "",
                                context: this.context,
                                widgetList: Language.languageList()
                                    .map(
                                      (e) => myinkwell(
                                        onTap: () {
                                          Navigator.of(this.context).pop();
                                          _changeLanguage(e);
                                        },
                                        child: Container(
                                          margin: EdgeInsets.all(14),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: <Widget>[
                                              Text(
                                                e.flag + ' ' + '    ' + e.languageNameInEnglish,
                                                style: TextStyle(color: Mycolors.black, fontWeight: FontWeight.w500, fontSize: 16),
                                              ),
                                              Language.languageList().length < 2
                                                  ? SizedBox()
                                                  : Icon(
                                                      Icons.done,
                                                      color: e.languageCode == widget.prefs.getString(LAGUAGE_CODE) ? Mycolors.green : Colors.transparent,
                                                    )
                                            ],
                                          ),
                                        ),
                                      ),
                                    )
                                    .toList(),
                              );
                            },
                      child: Container(
                        alignment: Alignment.center,
                        width: 130,
                        child: Row(
                          children: [
                            Container(
                              // radius: 40,
                              child: Row(
                                children: [
                                  MtCustomfontBoldSemi(
                                    color: Mycolors.black,
                                    textalign: TextAlign.center,
                                    text: widget.prefs.getString(LAGUAGE_CODE) == null
                                        ? Language.languageList()[
                                                Language.languageList().indexWhere((element) => element.languageCode == DefaulLANGUAGEfileCodeForCURRENTuser)]
                                            .flag
                                            .toString()
                                        : Language.languageList()[
                                                Language.languageList().indexWhere((element) => element.languageCode == widget.prefs.getString(LAGUAGE_CODE))]
                                            .flag
                                            .toString(),
                                    fontsize: 16,
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  MtCustomfontBoldSemi(
                                    color: Mycolors.white,
                                    textalign: TextAlign.center,
                                    text: widget.prefs.getString(LAGUAGE_CODE) == null
                                        ? Language.languageList()[
                                                Language.languageList().indexWhere((element) => element.languageCode == DefaulLANGUAGEfileCodeForCURRENTuser)]
                                            .languageNameInEnglish
                                            .toString()
                                        : Language.languageList()[
                                                Language.languageList().indexWhere((element) => element.languageCode == widget.prefs.getString(LAGUAGE_CODE))]
                                            .languageNameInEnglish
                                            .toString(),
                                    fontsize: 16,
                                  ),
                                  SizedBox(
                                    width: 8,
                                  ),
                                  Icon(
                                    Icons.keyboard_arrow_down_rounded,
                                    size: 27,
                                    color: Mycolors.secondary,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )),
                ),
        )
      ],
    );
  }

  loginCredentialsCheck(BuildContext context) async {
    final session = Provider.of<CommonSession>(this.context, listen: false);
    hidekeyboard(this.context);

    ShowLoading().open(
      context: this.context,
      key: _keyLoader,
    );

    try {
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: AppConstants.isdemomode == true ? AppConstants.demoadminemail : _enteredemailcontroller.text.trim(),
          password: AppConstants.isdemomode == true ? AppConstants.demoadminpassword : _enteredpasswordcontroller.text.trim());
      if (userCredential.user != null) {
        await FirebaseMessaging.instance.subscribeToTopic('Admin').then((value) async {
          await FirebaseMessaging.instance.subscribeToTopic('Activities').then((value) async {
            ShowLoading().close(
              context: this.context,
              key: _keyLoader,
            );
            await checkLoginStatus(true);
          }).catchError((err) {
            ShowLoading().close(
              context: this.context,
              key: _keyLoader,
            );

            Utils.toast('ERROR SUBSCRIBING NOTIFICATION ACTIVITIES' + err.toString());
            print('ERROR SUBSCRIBING NOTIFICATION ACTIVITIES' + err.toString());
          });
        }).catchError((err) {
          ShowLoading().close(
            context: this.context,
            key: _keyLoader,
          );
          Utils.toast('ERROR SUBSCRIBING NOTIFICATION ADMIN' + err.toString());
          print('ERROR SUBSCRIBING NOTIFICATION ADMIN' + err.toString());
        });
      } else {
        setState(() {
          attempt = attempt + 1;
        });
        ShowLoading().close(
          context: this.context,
          key: _keyLoader,
        );
        ShowSnackbar()
            .open(label: getTranslatedForCurrentUser(this.context, 'xxxfailedntryagainxxx'), context: this.context, scaffoldKey: _scaffoldKey, time: 3, status: 1);
        if (attempt > 2) {
          await session.createalert(
              alertmsgforuser: null,
              context: this.context,
              alertcollection: DbPaths.collectionALLNORMALalerts,
              alerttime: DateTime.now().millisecondsSinceEpoch,
              alerttitle: 'Admin Credentials match failed',
              alertdesc: 'Error occured while matching admin entered login credentials in admin app ERR_456 ');
        }
      }
    } on FirebaseAuthException catch (e) {
      print(e.toString());
      setState(() {
        attempt = attempt + 1;
      });
      ShowLoading().close(
        context: this.context,
        key: _keyLoader,
      );
      ShowSnackbar().open(label: getTranslatedForCurrentUser(this.context, 'xxauthfailedxx'), context: this.context, scaffoldKey: _scaffoldKey, time: 3, status: 1);
      if (attempt > 2) {
        await session.createalert(
            alertmsgforuser: null,
            context: this.context,
            alertcollection: DbPaths.collectionALLNORMALalerts,
            alerttime: DateTime.now().millisecondsSinceEpoch,
            alerttitle: 'Admin Credentials match failed',
            alertdesc: 'Error occured while matching admin entered login credentials in admin app \n[CAPTURED ERROR: $e ] ERR_457');
      }
    } catch (e) {
      setState(() {
        attempt = attempt + 1;
      });
      ShowLoading().close(
        context: this.context,
        key: _keyLoader,
      );
      ShowSnackbar()
          .open(label: getTranslatedForCurrentUser(this.context, 'xxxfailedntryagainxxx'), context: this.context, scaffoldKey: _scaffoldKey, time: 3, status: 1);
      if (attempt > 2) {
        await session.createalert(
            alertmsgforuser: null,
            context: this.context,
            alertcollection: DbPaths.collectionALLNORMALalerts,
            alerttime: DateTime.now().millisecondsSinceEpoch,
            alerttitle: 'Admin Credentials match failed',
            alertdesc: 'Error occured while matching admin entered login credentials in admin app \n[CAPTURED ERROR: $e ] ERR_457');
      }
    }
    // await FirebaseFirestore.instance
    //     .collection(Dbkeys.admincredentials)
    //     .doc(Dbkeys.admincredentials)
    //     .get()
    //     .then((doc) async {
    //   if (doc.exists) {
    //     if (doc[Dbkeys.adminusername] == _enteredemailcontroller.text &&
    //         doc[Dbkeys.adminpassword] == _enteredpasswordcontroller.text) {
    //       //--- entered credentials are correct
    //       ShowLoading().close(
    //         context: this.context,
    //         key: _keyLoader,
    //       );
    //       pageNavigator(this.context, PasscodeScreen());
    //     } else {
    //       //--- entered credentials are incorrect
    //       ShowLoading().close(
    //         context: this.context,
    //         key: _keyLoader,
    //       );
    //       ShowSnackbar().open(
    //           label: 'Invalid Credentials. Please try again !',
    //           context: this.context,
    //           scaffoldKey: _scaffoldKey,
    //           time: 3,
    //           status: 1);
    //       await session.createalert(
    //           alertmsgforuser: null,
    //           context: this.context,
    //           alertcollection: DbPaths.collectionALLNORMALalerts,
    //           alerttime: DateTime.now().millisecondsSinceEpoch,
    //           alerttitle: 'Admin Credentials incorrect',
    //           alertdesc:
    //               'Error occured while matching admin entered login credentials in admin app \n[CAPTURED ERROR: Firestore document does not exists. This message is showing ]');
    //     }
    //   } else {
    //
    //     ShowLoading().close(
    //       context: this.context,
    //       key: _keyLoader,
    //     );
    //     ShowSnackbar().open(
    //         label: 'Login Failed ! Please enter correct credentials',
    //         context: this.context,
    //         scaffoldKey: _scaffoldKey,
    //         time: 3,
    //         status: 1);
    //     if (attempt > 3) {
    //       await session.createalert(
    //           alertmsgforuser: null,
    //           context: this.context,
    //           alertcollection: DbPaths.collectionTXNHIGHalerts,
    //           alerttime: DateTime.now().millisecondsSinceEpoch,
    //           alerttitle: 'Admin Credentials Incorrect',
    //           alertdesc:
    //               'More than 3 attempts to login admin app has been made \n[CAPTURED ERROR: Incorrect admin credentials]');
    //     }
    //   }
    // }).catchError((err) async {
    //
  }

  @override
  Widget build(BuildContext context) {
    return isLoading == true
        ? Splashscreen()
        : Scaffold(
            key: _scaffoldKey,
            backgroundColor: Mycolors.primary,
            body: Platform.isAndroid && widget.basicsettings.isappunderconstructionandroid! || Platform.isIOS && widget.basicsettings.isappunderconstructionios!
                ? Center(
                    child: Padding(
                    padding: EdgeInsets.all(68.0),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.settings_applications, size: 88, color: Colors.cyanAccent[400]),
                          SizedBox(
                            height: 40,
                          ),
                          Text(
                            getTranslatedForCurrentUser(this.context, 'xxappundercxx'),
                            textAlign: TextAlign.center,
                            style: TextStyle(height: 1.4, fontSize: 20, color: Colors.white, fontWeight: FontWeight.w700),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Text(
                            errormsg!,
                            textAlign: TextAlign.center,
                            style: TextStyle(height: 1.4, fontSize: 17, color: Colors.white70, fontWeight: FontWeight.w400),
                          ),
                        ],
                      ),
                    ),
                  ))
                : errormsg != null
                    ? Center(
                        child: Padding(
                        padding: EdgeInsets.all(68.0),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.error_outline, size: 88, color: Colors.pinkAccent[400]),
                              SizedBox(
                                height: 40,
                              ),
                              Text(
                                getTranslatedForCurrentUser(this.context, 'xxxsessionlongxxx'),
                                textAlign: TextAlign.center,
                                style: TextStyle(height: 1.4, fontSize: 18, color: Colors.white, fontWeight: FontWeight.w600),
                              ),
                              SizedBox(
                                height: 7,
                              ),
                              Text(
                                getTranslatedForCurrentUser(this.context, 'xxxifitsnotuxxx'),
                                textAlign: TextAlign.center,
                                style: TextStyle(height: 1.4, fontSize: 14, color: Colors.white, fontWeight: FontWeight.w400),
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              Text(
                                errormsg!,
                                textAlign: TextAlign.center,
                                style: TextStyle(height: 1.4, fontSize: 17, color: Colors.white70, fontWeight: FontWeight.w400),
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              MySimpleButton(
                                buttoncolor: Mycolors.black,
                                buttontext: getTranslatedForCurrentUser(this.context, 'xxloginxx').toUpperCase(),
                                onpressed: () {
                                  Navigator.pushReplacement(this.context, new MaterialPageRoute(builder: (context) => new AppWrapper()));
                                },
                              )
                            ],
                          ),
                        ),
                      ))
                    : loginWdget(this.context));
  }
}
