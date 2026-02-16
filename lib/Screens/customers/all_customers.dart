import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:thinkcreative_technologies/Configs/db_paths.dart';
import 'package:thinkcreative_technologies/Configs/enum.dart';
import 'package:thinkcreative_technologies/Configs/my_colors.dart';
import 'package:thinkcreative_technologies/Configs/number_limits.dart';
import 'package:thinkcreative_technologies/Localization/language_constants.dart';
import 'package:thinkcreative_technologies/Models/customer_model.dart';
import 'package:thinkcreative_technologies/Screens/customers/create_customer.dart';
import 'package:thinkcreative_technologies/Screens/networkSensitiveUi/NetworkSensitiveUi.dart';
import 'package:thinkcreative_technologies/Screens/users/SearchByName.dart';
import 'package:thinkcreative_technologies/Screens/users/SearchUser.dart';
import 'package:thinkcreative_technologies/Services/my_providers/observer.dart';
import 'package:thinkcreative_technologies/Services/my_providers/liveListener.dart';
import 'package:thinkcreative_technologies/Widgets/InfiniteList/InfiniteCOLLECTIONListViewWidgetAdmin.dart';
import 'package:thinkcreative_technologies/Widgets/WarningWidgets/warning_tile.dart';
import 'package:thinkcreative_technologies/Widgets/custom_text.dart';
import 'package:thinkcreative_technologies/Services/firebase_services/FirebaseApi.dart';
import 'package:thinkcreative_technologies/Services/my_providers/session_provider.dart';
import 'package:thinkcreative_technologies/Widgets/dialogs/CustomDialog.dart';
import 'package:thinkcreative_technologies/Widgets/my_inkwell.dart';
import 'package:thinkcreative_technologies/Widgets/boxdecoration.dart';
import 'package:thinkcreative_technologies/Utils/utils.dart';
import 'package:thinkcreative_technologies/Configs/app_constants.dart';
import 'package:thinkcreative_technologies/Configs/db_keys.dart';

import 'package:thinkcreative_technologies/Widgets/customcards/custom_card.dart';
import 'package:thinkcreative_technologies/Widgets/my_scaffold.dart';
import 'package:thinkcreative_technologies/Services/my_providers/firestore_collections_data_admin.dart';
import 'package:thinkcreative_technologies/Utils/page_navigator.dart';

class AllCustomers extends StatefulWidget {
  final String currentuserid;

  AllCustomers({
    required this.currentuserid,
  });
  @override
  _AllCustomersState createState() => _AllCustomersState();
}

class _AllCustomersState extends State<AllCustomers> {
  TextEditingController _controller = new TextEditingController();
  CollectionReference colRef =
      FirebaseFirestore.instance.collection(DbPaths.collectioncustomers);

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  confirmchangeswitch(
    BuildContext context,
    String accountSTATUS,
    String? userid,
    String? fullname,
    String? photourl,
  ) async {
    final firestore = Provider.of<FirestoreDataProviderCUSTOMERS>(this.context,
        listen: false);

    ShowSnackbar().close(context: this.context, scaffoldKey: _scaffoldKey);
    await ShowConfirmWithInputTextDialog().open(
        controller: _controller,
        isshowform: accountSTATUS == Dbkeys.sTATUSpending
            ? false
            : accountSTATUS == Dbkeys.sTATUSblocked
                ? false
                : accountSTATUS == Dbkeys.sTATUSallowed
                    ? true
                    : false,
        context: this.context,
        subtitle: accountSTATUS == Dbkeys.sTATUSallowed
            ? getTranslatedForCurrentUser(this.context, 'xxxareyousureblockxxx')
            : accountSTATUS == Dbkeys.sTATUSblocked
                ? getTranslatedForCurrentUser(
                    this.context, 'xxxareyousureremoveblockkxxx')
                : getTranslatedForCurrentUser(
                    this.context, 'xxxareyousureapprovekkxxx'),
        title: accountSTATUS == Dbkeys.sTATUSallowed
            ? getTranslatedForCurrentUser(this.context, 'xxblockuserqxx')
            : accountSTATUS == Dbkeys.sTATUSblocked
                ? getTranslatedForCurrentUser(this.context, 'xxallowuserqxx')
                : getTranslatedForCurrentUser(this.context, 'xxapproveuserqxx'),
        rightbtnonpress: AppConstants.isdemomode == true
            ? () {
                Utils.toast(getTranslatedForCurrentUser(
                    this.context, 'xxxnotalwddemoxxaccountxx'));
              }
            : () async {
                int tapproved = 0;
                int tblocked = 0;
                int tpending = 0;
                Navigator.pop(this.context);
                ShowLoading().open(context: this.context, key: _keyLoader);
                await colRef.doc(userid).update({
                  Dbkeys.actionmessage: accountSTATUS == Dbkeys.sTATUSallowed
                      ? _controller.text.trim().length < 1
                          ? getTranslatedForCurrentUser(
                              this.context, 'xxxaccountblockedxxx')
                          : '${getTranslatedForCurrentUser(this.context, 'xxxaccountblockedforxxx')} ${_controller.text.trim()}.'
                      : accountSTATUS == Dbkeys.sTATUSpending
                          ? getTranslatedForCurrentUser(
                              this.context, 'xxxcongratatulationacapprovedxxx')
                          : accountSTATUS == Dbkeys.sTATUSblocked
                              ? getTranslatedForCurrentUser(this.context,
                                  'xxxcongratatulationacapprovedxxx')
                              : getTranslatedForCurrentUser(
                                  this.context, 'xxxacstatuschangedxxx'),
                  Dbkeys.accountstatus: accountSTATUS == Dbkeys.sTATUSallowed
                      ? Dbkeys.sTATUSblocked
                      : accountSTATUS == Dbkeys.sTATUSblocked
                          ? Dbkeys.sTATUSallowed
                          : Dbkeys.sTATUSallowed
                  // Dbkeys.cpnfilter: '$currency${!usrisvisble}',
                }).then((val) {
                  // ShowLoading().close(context: this.context, key: _keyLoader);
                }).then((val) async {
                  await FirebaseFirestore.instance
                      .collection(DbPaths.collectioncustomers)
                      .get()
                      .then((value) {
                    tapproved = value.docs
                        .where((element) =>
                            element[Dbkeys.accountstatus] ==
                            Dbkeys.sTATUSallowed)
                        .length;
                    tblocked = value.docs
                        .where((element) =>
                            element[Dbkeys.accountstatus] ==
                            Dbkeys.sTATUSblocked)
                        .length;
                    tpending = value.docs
                        .where((element) =>
                            element[Dbkeys.accountstatus] ==
                            Dbkeys.sTATUSpending)
                        .length;
                  }).then((value) async {
                    FirebaseFirestore.instance
                        .collection(DbPaths.userapp)
                        .doc(DbPaths.docusercount)
                        .update({
                      Dbkeys.totalapprovedcustomers: tapproved,
                      Dbkeys.totalblockedcustomers: tblocked,
                      Dbkeys.totalpendingcustomers: tpending,
                    });
                    //-- CREATED HISTORY
                    if (AppConstants.isrecordhistory == true) {
                      await FirebaseApi.runTransactionRecordActivity(
                        parentid: "CUSTOMER--$userid",
                        onErrorFn: (e) {
                          ShowLoading()
                              .close(context: this.context, key: _keyLoader);
                          _controller.clear();
                          // print('Erssssror:${observer.isshowerrorlog} $error');
                          ShowSnackbar().open(
                              context: this.context,
                              scaffoldKey: _scaffoldKey,
                              status: 1,
                              time: 3,
                              label:
                                  '${getTranslatedForCurrentUser(this.context, 'xxxfailedntryagainxxx')} $e');
                        },
                        onSuccessFn: () async {
                          await Utils.sendDirectNotification(
                            postedbyID: widget.currentuserid,
                            docRef: this
                                .colRef
                                .doc(userid)
                                .collection(DbPaths.customernotifications)
                                .doc(DbPaths.customernotifications),
                            parentID: "CUSTOMER--$userid",
                            title: accountSTATUS == Dbkeys.sTATUSallowed
                                ? '${getTranslatedForCurrentUser(this.context, 'xxaccountxx')} ${getTranslatedForCurrentUser(this.context, 'xxxblockedxxx')}'
                                : accountSTATUS == Dbkeys.sTATUSpending
                                    ? '${getTranslatedForCurrentUser(this.context, 'xxaccountxx')} ${getTranslatedForCurrentUser(this.context, 'xxxapprovedxxx')}'
                                    : accountSTATUS == Dbkeys.sTATUSblocked
                                        ? '${getTranslatedForCurrentUser(this.context, 'xxaccountxx')} ${getTranslatedForCurrentUser(this.context, 'xxxapprovedxxx')}'
                                        : getTranslatedForEventsAndAlerts(
                                            this.context,
                                            'xxxacstatuschangexxx'),
                            plaindesc: accountSTATUS == Dbkeys.sTATUSallowed
                                ? _controller.text.trim().length < 1
                                    ? getTranslatedForCurrentUser(
                                        this.context, 'xxxaccountblockedxxx')
                                    : '${getTranslatedForCurrentUser(this.context, 'xxxaccountblockedforxxx')} ${_controller.text.trim()}.'
                                : accountSTATUS == Dbkeys.sTATUSpending
                                    ? getTranslatedForCurrentUser(this.context,
                                        'xxxcongratatulationacapprovedxxx')
                                    : accountSTATUS == Dbkeys.sTATUSblocked
                                        ? getTranslatedForCurrentUser(
                                            this.context,
                                            'xxxcongratatulationacapprovedxxx')
                                        : getTranslatedForCurrentUser(
                                            this.context,
                                            'xxxacstatuschangedxxx'),
                          );
                          await firestore.updateparticulardocinProvider(
                              colRef: colRef,
                              userid: userid!,
                              onfetchDone: (userDoc) async {});

                          ShowLoading()
                              .close(context: this.context, key: _keyLoader);
                          _controller.clear();
                          ShowSnackbar().open(
                              context: this.context,
                              scaffoldKey: _scaffoldKey,
                              status: 2,
                              time: 3,
                              label: accountSTATUS == Dbkeys.sTATUSallowed
                                  ? '${getTranslatedForCurrentUser(this.context, 'xxxsuccessxxx')}  ${fullname!.toUpperCase()} - ${getTranslatedForCurrentUser(this.context, 'xxxblockedxxx')}. ${getTranslatedForCurrentUser(this.context, 'xxxusernotifiedxxx')} '
                                  : accountSTATUS == Dbkeys.sTATUSblocked
                                      ? '${getTranslatedForCurrentUser(this.context, 'xxxsuccessxxx')}  ${fullname!.toUpperCase()} - ${getTranslatedForCurrentUser(this.context, 'xxxapprovedxxx')}. ${getTranslatedForCurrentUser(this.context, 'xxxusernotifiedxxx')} '
                                      : '${getTranslatedForCurrentUser(this.context, 'xxxsuccessxxx')} . ${getTranslatedForCurrentUser(this.context, 'xxxusernotifiedxxx')} ');
                        },
                        postedbyID: widget.currentuserid,
                        context: this.context,
                        title: accountSTATUS == Dbkeys.sTATUSallowed
                            ? '${getTranslatedForCurrentUser(this.context, 'xxaccountxx')} ${getTranslatedForCurrentUser(this.context, 'xxxblockedxxx')}'
                            : accountSTATUS == Dbkeys.sTATUSpending
                                ? '${getTranslatedForCurrentUser(this.context, 'xxaccountxx')} ${getTranslatedForCurrentUser(this.context, 'xxxapprovedxxx')}'
                                : accountSTATUS == Dbkeys.sTATUSblocked
                                    ? '${getTranslatedForCurrentUser(this.context, 'xxaccountxx')} ${getTranslatedForCurrentUser(this.context, 'xxxapprovedxxx')}'
                                    : getTranslatedForCurrentUser(
                                        this.context, 'xxxacstatuschangexxx'),
                        plainDesc: accountSTATUS == Dbkeys.sTATUSallowed
                            ? '$fullname (${getTranslatedForCurrentUser(this.context, 'xxcustomerxx')})${getTranslatedForCurrentUser(this.context, 'xxxtheaccountblockedforxxx')} ${_controller.text.trim()}. ${getTranslatedForCurrentUser(this.context, 'xxxbyxxx')} ${widget.currentuserid}  '
                            : accountSTATUS == Dbkeys.sTATUSpending
                                ? '$fullname (${getTranslatedForCurrentUser(this.context, 'xxcustomerxx')}) ${getTranslatedForCurrentUser(this.context, 'xxaccountxx')} ${getTranslatedForCurrentUser(this.context, 'xxxapprovedxxx')}. ${getTranslatedForCurrentUser(this.context, 'xxxbyxxx')} ${widget.currentuserid}   '
                                : accountSTATUS == Dbkeys.sTATUSblocked
                                    ? '$fullname (${getTranslatedForCurrentUser(this.context, 'xxcustomerxx')}) ${getTranslatedForCurrentUser(this.context, 'xxaccountxx')} ${getTranslatedForCurrentUser(this.context, 'xxxapprovedxxx')}. ${getTranslatedForCurrentUser(this.context, 'xxxbyxxx')} ${widget.currentuserid}  '
                                    : '$fullname (${getTranslatedForCurrentUser(this.context, 'xxcustomerxx')}) ${getTranslatedForCurrentUser(this.context, 'xxxacstatuschangexxx')}. ${getTranslatedForCurrentUser(this.context, 'xxxbyxxx')} ${widget.currentuserid}  ',
                      );
                    }
                  });
                });
              });
  }

  final GlobalKey<State> _keyLoader = new GlobalKey<State>(debugLabel: '0000');

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  searchWidget(BuildContext context) {
    var w = MediaQuery.of(this.context).size.width;
    showModalBottomSheet(
        context: this.context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
        ),
        builder: (BuildContext context) {
          // return your layout
          return Container(
            padding: EdgeInsets.all(3),
            height: 270,
            child: Column(children: [
              SizedBox(
                height: 18,
              ),
              MtCustomfontBold(
                color: Mycolors.black,
                fontsize: 18,
                text:
                    '${getTranslatedForCurrentUser(this.context, 'xxxsearchxxx')}  ${getTranslatedForCurrentUser(this.context, 'xxcustomerxx')}',
              ),
              SizedBox(
                height: 35,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  myinkwell(
                    onTap: () {
                      Navigator.of(this.context).pop();
                      pageNavigator(
                          this.context,
                          SearchUserByName(
                            serchusertype: Usertype.customer.index,
                            colRef: colRef,
                          ));
                    },
                    child: Container(
                      padding: EdgeInsets.all(8),
                      width: w / 3.35,
                      decoration: boxDecoration(
                        showShadow: true,
                        radius: 7,
                        bgColor: Mycolors.pink,
                      ),
                      height: 90,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.sort_by_alpha_outlined,
                              size: 28, color: Mycolors.yellow),
                          SizedBox(
                            height: 7,
                          ),
                          MtCustomfontMedium(
                            text: getTranslatedForCurrentUser(
                                    this.context, 'xxxbyxxxxnamexxx')
                                .replaceAll('(####)', ''),
                            color: Colors.white,
                            textalign: TextAlign.center,
                            lineheight: 1.3,
                          )
                        ],
                      ),
                    ),
                  ),
                  //  myinkwell(
                  //   onTap: () {
                  //     Navigator.of(this.context).pop();
                  //     pageNavigator(
                  //         this.context,
                  //         SearchUser(
                  //             pageuserKeyword: widget.usertypenamekeyword,
                  //             colRef: colRef,
                  //             currentuserid: widget.currentuserid,
                  //             searchtype: 'byphone'));
                  //   },
                  //   child: Container(
                  //     padding: EdgeInsets.all(8),
                  //     width: w / 3.35,
                  //     decoration: boxDecoration(
                  //       showShadow: true,
                  //       radius: 7,
                  //       bgColor: Mycolors.purple,
                  //     ),
                  //     height: 90,
                  //     child: Column(
                  //       crossAxisAlignment: CrossAxisAlignment.center,
                  //       mainAxisAlignment: MainAxisAlignment.center,
                  //       children: [
                  //         Icon(Icons.phone_enabled,
                  //             size: 28, color: Mycolors.yellow),
                  //         SizedBox(
                  //           height: 7,
                  //         ),
                  //         MtCustomfontMedium(
                  //           text: 'Search by Phone ',
                  //           color: Colors.white,
                  //           textalign: TextAlign.center,
                  //           lineheight: 1.3,
                  //         )
                  //       ],
                  //     ),
                  //   ),
                  // ),
                  myinkwell(
                    onTap: () {
                      Navigator.of(this.context).pop();
                      pageNavigator(
                          this.context,
                          SearchUser(
                              serchusertype: Usertype.customer.index,
                              colRef: colRef,
                              searchtype: 'byid'));
                    },
                    child: Container(
                      padding: EdgeInsets.all(8),
                      width: w / 3.35,
                      decoration: boxDecoration(
                        showShadow: true,
                        radius: 7,
                        bgColor: Mycolors.purple,
                      ),
                      height: 90,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Icon(Icons.account_box,
                              size: 28, color: Mycolors.yellow),
                          SizedBox(
                            height: 7,
                          ),
                          MtCustomfontMedium(
                            text: getTranslatedForCurrentUser(
                                    this.context, 'xxxbyxxxxidxxx')
                                .replaceAll(
                                    '(####)',
                                    getTranslatedForCurrentUser(
                                        this.context, 'xxcustomerxx')),
                            color: Colors.white,
                            textalign: TextAlign.center,
                            lineheight: 1.3,
                          )
                        ],
                      ),
                    ),
                  ),
                  myinkwell(
                      onTap: () {
                        Navigator.of(this.context).pop();
                        pageNavigator(
                            this.context,
                            SearchUser(
                                colRef: colRef,
                                serchusertype: Usertype.customer.index,
                                searchtype: 'byuid'));
                      },
                      child: Container(
                        padding: EdgeInsets.all(8),
                        width: w / 3.35,
                        decoration: boxDecoration(
                          showShadow: true,
                          radius: 7,
                          bgColor: Mycolors.orange,
                        ),
                        height: 90,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.perm_identity_outlined,
                                size: 28,
                                color: Colors.yellowAccent.withOpacity(0.8)),
                            SizedBox(
                              height: 9,
                            ),
                            MtCustomfontMedium(
                              text: 'Firebase\nUID',
                              color: Colors.white,
                              textalign: TextAlign.center,
                              lineheight: 1.3,
                            )
                          ],
                        ),
                      ))
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  myinkwell(
                    onTap: () {
                      Navigator.of(this.context).pop();
                      pageNavigator(
                          this.context,
                          SearchUser(
                              colRef: colRef,
                              serchusertype: Usertype.customer.index,
                              searchtype: 'byphone'));
                    },
                    child: Container(
                      padding: EdgeInsets.all(8),
                      width: w / 3.35,
                      decoration: boxDecoration(
                        showShadow: true,
                        radius: 7,
                        bgColor: Mycolors.cyan,
                      ),
                      height: 90,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.phone, size: 28, color: Mycolors.yellow),
                          SizedBox(
                            height: 7,
                          ),
                          MtCustomfontMedium(
                            text: getTranslatedForCurrentUser(
                                    this.context, 'xxxbyxxxxphonexxx')
                                .replaceAll('(####)', ''),
                            color: Colors.white,
                            textalign: TextAlign.center,
                            lineheight: 1.3,
                          )
                        ],
                      ),
                    ),
                  ),
                  myinkwell(
                    onTap: () {
                      Navigator.of(this.context).pop();
                      pageNavigator(
                          this.context,
                          SearchUser(
                              colRef: colRef,
                              serchusertype: Usertype.customer.index,
                              searchtype: 'byemailid'));
                    },
                    child: Container(
                      padding: EdgeInsets.all(8),
                      width: w / 3.35,
                      decoration: boxDecoration(
                        showShadow: true,
                        radius: 7,
                        bgColor: Mycolors.green,
                      ),
                      height: 90,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Icon(Icons.email_outlined,
                              size: 28, color: Mycolors.yellow),
                          SizedBox(
                            height: 7,
                          ),
                          MtCustomfontMedium(
                            text: getTranslatedForCurrentUser(
                                    this.context, 'xxxbyxxxxemailxxx')
                                .replaceAll('(####)', ''),
                            color: Colors.white,
                            textalign: TextAlign.center,
                            lineheight: 1.3,
                          )
                        ],
                      ),
                    ),
                  ),
                  myinkwell(
                      onTap: () {},
                      child: Container(
                        padding: EdgeInsets.all(8),
                        width: w / 3.35,
                        color: Colors.transparent,
                      ))
                ],
              ),
            ]),
          );
        });
  }

  late Query query = colRef
      .orderBy(Dbkeys.joinedOn, descending: true)
      .limit(Numberlimits.totalDatatoLoadAtOnceFromFirestore);
  sort(BuildContext context, String sortby) {
    final firestore = Provider.of<FirestoreDataProviderCUSTOMERS>(this.context,
        listen: false);
    switch (sortby) {
      case Dbkeys.sortbyBLOCKED:
        {
          query = colRef
              .where(Dbkeys.accountstatus, isEqualTo: Dbkeys.sTATUSblocked)
              .limit(Numberlimits.totalDatatoLoadAtOnceFromFirestore);
        }
        break;
      case Dbkeys.sortbyAPPROVED:
        {
          query = colRef
              .where(Dbkeys.accountstatus, isEqualTo: Dbkeys.sTATUSallowed)
              .limit(Numberlimits.totalDatatoLoadAtOnceFromFirestore);
        }
        break;
      case Dbkeys.sortbyPENDING:
        {
          query = colRef
              .where(Dbkeys.accountstatus, isEqualTo: Dbkeys.sTATUSpending)
              .limit(Numberlimits.totalDatatoLoadAtOnceFromFirestore);
        }
        break;
      case Dbkeys.sortbyALLUSERS:
        {
          query = colRef
              .orderBy(Dbkeys.joinedOn, descending: true)
              .limit(Numberlimits.totalDatatoLoadAtOnceFromFirestore);
        }
        break;

      case Dbkeys.sortbyUSERSONLINE:
        {
          query = colRef
              .where(Dbkeys.lastSeen, isEqualTo: true)
              .limit(Numberlimits.totalDatatoLoadAtOnceFromFirestore);
        }
        break;
      default:
        {
          query = colRef
              .orderBy(Dbkeys.joinedOn, descending: true)
              .limit(Numberlimits.totalDatatoLoadAtOnceFromFirestore);
        }
    }
    setState(() {});
    firestore.reset();
    firestore.fetchNextData(Dbkeys.dataTypeCUSTOMERS, query, true);
  }

  @override
  Widget build(BuildContext context) {
    SpecialLiveConfigData? livedata =
        Provider.of<SpecialLiveConfigData?>(this.context, listen: true);
    bool isready = livedata == null
        ? false
        : !livedata.docmap.containsKey(Dbkeys.secondadminID) ||
                livedata.docmap[Dbkeys.secondadminID] == '' ||
                livedata.docmap[Dbkeys.secondadminID] == null
            ? false
            : true;
    return NetworkSensitive(
      child: Utils.getNTPWrappedWidget(Consumer<Observer>(
          builder: (context, observer, _child) => Consumer<CommonSession>(
                builder: (context, session, _child) =>
                    Consumer<FirestoreDataProviderCUSTOMERS>(
                  builder: (context, firestoreDataProvider, _) => MyScaffold(
                      isforcehideback: true,
                      scaffoldkey: _scaffoldKey,
                      title:
                          ' ${getTranslatedForCurrentUser(this.context, 'xxcustomersxx')}',
                      actions: [
                        IconButton(
                          icon: Icon(
                            Icons.add,
                            color: Mycolors.black,
                          ),
                          onPressed: () {
                            pageNavigator(this.context, CreateCustomer());
                          },
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.search,
                            color: Mycolors.black,
                          ),
                          onPressed: () {
                            searchWidget(this.context);
                          },
                        ),
                        PopupMenuButton<String>(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(8, 6, 10, 9),
                            child: Icon(EvaIcons.listOutline),
                          ),
                          onSelected: (choice) {
                            sort(this.context, choice);
                          },
                          itemBuilder: (BuildContext context) {
                            return {
                              Dbkeys.sortbyALLUSERS,
                              Dbkeys.sortbyAPPROVED,
                              Dbkeys.sortbyBLOCKED,
                              Dbkeys.sortbyPENDING,
                              Dbkeys.sortbyUSERSONLINE,
                            }.map((String choice) {
                              String keyname = choice == 'All Blocked'
                                  ? getTranslatedForCurrentUser(
                                      context, 'xxallblockedxx')
                                  : choice == 'All Pending'
                                      ? getTranslatedForCurrentUser(
                                          context, 'xxallpendingxx')
                                      : choice == 'All Approved'
                                          ? getTranslatedForCurrentUser(
                                              context, 'xxallaprovedxx')
                                          : choice == 'All Users'
                                              ? getTranslatedForCurrentUser(
                                                  context, 'xxallusersxx')
                                              : choice == 'Online Users'
                                                  ? getTranslatedForCurrentUser(
                                                      context,
                                                      'xxonlineusersxx')
                                                  : "";
                              return PopupMenuItem<String>(
                                value: choice,
                                child: Text(
                                  keyname,
                                  style: TextStyle(fontSize: 14),
                                ),
                              );
                            }).toList();
                          },
                        ),
                      ],
                      body: InfiniteCOLLECTIONListViewWidgetAdmin(
                        firestoreDataProviderCUSTOMERS: firestoreDataProvider,
                        datatype: Dbkeys.dataTypeCUSTOMERS,
                        refdata: query,
                        list: Column(
                          children: [
                            isready == false
                                ? warningTile(
                                    isstyledtext: true,
                                    title: getTranslatedForCurrentUser(
                                            this.context,
                                            'xxxassignsecondadminxxx')
                                        .replaceAll('(####)',
                                            '<bold>${getTranslatedForCurrentUser(this.context, 'xxsecondadminxx')}</bold>')
                                        .replaceAll('(###)',
                                            '<bold>${getTranslatedForCurrentUser(this.context, 'xxcustomersxx')}</bold>'),
                                    warningTypeIndex: WarningType.alert.index)
                                : SizedBox(),
                            ListView.builder(
                                padding: EdgeInsets.all(0),
                                physics: ScrollPhysics(),
                                shrinkWrap: true,
                                itemCount:
                                    firestoreDataProvider.recievedDocs.length,
                                itemBuilder: (BuildContext context, int i) {
                                  CustomerModel customer =
                                      CustomerModel.fromJson(
                                          firestoreDataProvider
                                              .recievedDocs[i]);

                                  return CustomerCard(
                                    isProfileFetchedFromProvider: true,
                                    onswitchchanged:
                                        AppConstants.isdemomode == true
                                            ? (val) {
                                                Utils.toast(
                                                    getTranslatedForCurrentUser(
                                                        this.context,
                                                        'xxxnotalwddemoxxaccountxx'));
                                              }
                                            : (val) async {
                                                await confirmchangeswitch(
                                                  this.context,
                                                  customer.accountstatus,
                                                  customer.id,
                                                  customer.nickname,
                                                  customer.photoUrl,
                                                );
                                              },
                                    usermodel: customer,
                                  );
                                }),
                          ],
                        ),
                      )),
                ),
              ))),
    );
  }
}
