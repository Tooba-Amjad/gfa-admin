// ignore_for_file: deprecated_member_use

import 'dart:io';
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';
import 'package:thinkcreative_technologies/Configs/db_keys.dart';
import 'package:thinkcreative_technologies/Configs/db_paths.dart';
import 'package:thinkcreative_technologies/Configs/number_limits.dart';
import 'package:thinkcreative_technologies/Localization/language_constants.dart';
import 'package:thinkcreative_technologies/Models/customer_model.dart';
import 'package:thinkcreative_technologies/Models/userapp_settings_model.dart';
import 'package:thinkcreative_technologies/Screens/networkSensitiveUi/NetworkSensitiveUi.dart';
import 'package:thinkcreative_technologies/Screens/tickets/all_tickets.dart';
import 'package:thinkcreative_technologies/Screens/users/user_notifications.dart';
import 'package:thinkcreative_technologies/Services/my_providers/observer.dart';
import 'package:thinkcreative_technologies/Utils/setStatusBarColor.dart';
import 'package:thinkcreative_technologies/Widgets/CameraGalleryImagePicker/camera_image_gallery_picker.dart';
import 'package:thinkcreative_technologies/Widgets/custom_buttons.dart';
import 'package:thinkcreative_technologies/Widgets/custom_text.dart';
import 'package:thinkcreative_technologies/Services/firebase_services/FirebaseApi.dart';
import 'package:thinkcreative_technologies/Services/my_providers/session_provider.dart';
import 'package:thinkcreative_technologies/Widgets/dialogs/CustomDialog.dart';
import 'package:thinkcreative_technologies/Widgets/dialogs/FormDialog.dart';
import 'package:thinkcreative_technologies/Widgets/dialogs/loadingDialog.dart';
import 'package:thinkcreative_technologies/Widgets/dialogs/uploadMediaWithProgress.dart';
import 'package:thinkcreative_technologies/Widgets/late_load.dart';
import 'package:thinkcreative_technologies/Widgets/my_inkwell.dart';
import 'package:thinkcreative_technologies/Utils/custom_time_formatter.dart';
import 'package:thinkcreative_technologies/Utils/utils.dart';
import 'package:thinkcreative_technologies/Configs/app_constants.dart';
import 'package:thinkcreative_technologies/Configs/my_colors.dart';
import 'package:thinkcreative_technologies/Widgets/Input_box.dart';
import 'package:thinkcreative_technologies/Widgets/my_scaffold.dart';
import 'package:thinkcreative_technologies/Widgets/boxdecoration.dart';
import 'package:thinkcreative_technologies/Widgets/custom_dividers.dart';
import 'package:thinkcreative_technologies/Services/my_providers/firestore_collections_data_admin.dart';
import 'package:thinkcreative_technologies/Utils/page_navigator.dart';
import 'package:thinkcreative_technologies/Utils/tiles.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:path/path.dart' as p;

class CustomerProfileDetails extends StatefulWidget {
  final CustomerModel? customer;
  final UserAppSettingsModel? userAppSettingsModel;
  final String currentuserid;
  final String? customerID;

  CustomerProfileDetails({
    this.customer,
    this.userAppSettingsModel,
    required this.currentuserid,
    this.customerID,
  });
  @override
  _CustomerProfileDetailsState createState() => _CustomerProfileDetailsState();
}

class _CustomerProfileDetailsState extends State<CustomerProfileDetails> {
  TextEditingController _controller = new TextEditingController();
  TextEditingController _name = new TextEditingController();
  TextEditingController _pcode = new TextEditingController();
  TextEditingController _pnumber = new TextEditingController();
  TextEditingController _email = new TextEditingController();
  CustomerModel? customer;
  CollectionReference colRef =
      FirebaseFirestore.instance.collection(DbPaths.collectioncustomers);
  @override
  void initState() {
    super.initState();
    if (widget.customer != null) {
      customer = widget.customer;
    } else {
      fetchCustomer();
    }

    fetchUserAppSettings();
  }

  fetchCustomer({String? customerId}) async {
    await FirebaseFirestore.instance
        .collection(DbPaths.collectioncustomers)
        .doc(customerId ?? widget.customerID!)
        .get()
        .then((value) {
      if (value.exists) {
        customer = CustomerModel.fromSnapshot(value);
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _name.dispose();
    _pcode.dispose();
    _email.dispose();
    _pnumber.dispose();
  }

  UserAppSettingsModel? userAppSettings;
  fetchUserAppSettings() {
    FirebaseFirestore.instance
        .collection(DbPaths.userapp)
        .doc(DbPaths.appsettings)
        .get()
        .then((value) {
      userAppSettings = UserAppSettingsModel.fromSnapshot(value);

      setState(() {});
    });
  }

  confirmchangeswitch(
    BuildContext context,
    String? accountSTATUS,
    String userid,
    String? fullname,
    String? photourl,
  ) async {
    final firestore = Provider.of<FirestoreDataProviderCUSTOMERS>(this.context,
        listen: false);
    final observer = Provider.of<Observer>(this.context, listen: false);
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
        rightbtnonpress:
            //  ((accountSTATUS == Dbkeys.sTATUSallowed) &&
            //             (_controller.text.trim().length > 100 ||
            //                 _controller.text.trim().length < 1)) ==
            //         true
            //     ? () {}
            //     :
            AppConstants.isdemomode == true
                ? () {
                    Utils.toast(getTranslatedForCurrentUser(
                        this.context, 'xxxnotalwddemoxxaccountxx'));
                  }
                : () async {
                    Navigator.pop(this.context);
                    colRef.doc(userid).update({
                      Dbkeys.actionmessage: accountSTATUS ==
                              Dbkeys.sTATUSallowed
                          ? _controller.text.trim().length < 1
                              ? getTranslatedForCurrentUser(
                                  this.context, 'xxxaccountblockedxxx')
                              : '${getTranslatedForCurrentUser(this.context, 'xxxaccountblockedforxxx')} ${_controller.text.trim()}.'
                          : accountSTATUS == Dbkeys.sTATUSpending
                              ? getTranslatedForCurrentUser(this.context,
                                  'xxxcongratatulationacapprovedxxx')
                              : accountSTATUS == Dbkeys.sTATUSblocked
                                  ? getTranslatedForCurrentUser(this.context,
                                      'xxxcongratatulationacapprovedxxx')
                                  : getTranslatedForCurrentUser(
                                      this.context, 'xxxacstatuschangedxxx'),
                      Dbkeys.accountstatus:
                          accountSTATUS == Dbkeys.sTATUSallowed
                              ? Dbkeys.sTATUSblocked
                              : accountSTATUS == Dbkeys.sTATUSblocked
                                  ? Dbkeys.sTATUSallowed
                                  : Dbkeys.sTATUSallowed
                    }).then((value) async {
                      // 1. Show Success
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

                      // 3. Update the UI state
                      firestore.updateparticulardocinProvider(
                          colRef: colRef,
                          userid: customer!.id,
                          onfetchDone: (userDoc) async {
                            setState(() {
                              customer = CustomerModel.fromSnapshot(userDoc);
                            });
                          });

                      // 4. Perform secondary tasks in background
                      unawaited(colRef.get().then((value) {
                        int tapproved = value.docs
                            .where((element) =>
                                element[Dbkeys.accountstatus] ==
                                Dbkeys.sTATUSallowed)
                            .length;
                        int tblocked = value.docs
                            .where((element) =>
                                element[Dbkeys.accountstatus] ==
                                Dbkeys.sTATUSblocked)
                            .length;
                        int tpending = value.docs
                            .where((element) =>
                                element[Dbkeys.accountstatus] ==
                                Dbkeys.sTATUSpending)
                            .length;
                        FirebaseFirestore.instance
                            .collection(DbPaths.userapp)
                            .doc(DbPaths.docusercount)
                            .update({
                          Dbkeys.totalapprovedcustomers: tapproved,
                          Dbkeys.totalblockedcustomers: tblocked,
                          Dbkeys.totalpendingcustomers: tpending,
                        });
                      }));

                      unawaited(FirebaseApi.runTransactionSendNotification(
                        docRef: colRef
                            .doc(customer!.id)
                            .collection(DbPaths.customernotifications)
                            .doc(DbPaths.customernotifications),
                        context: this.context,
                        parentid: "CUSTOMER--${customer!.id}",
                        onErrorFn: (e) {},
                        onSuccessFn: () async {
                          await FirebaseApi.runTransactionRecordActivity(
                              onErrorFn: (e) {},
                              onSuccessFn: () async {},
                              parentid: "CUSTOMER--${customer!.id}",
                              postedbyID: widget.currentuserid,
                              title: accountSTATUS == Dbkeys.sTATUSallowed
                                  ? '${getTranslatedForCurrentUser(this.context, 'xxaccountxx')} ${getTranslatedForCurrentUser(this.context, 'xxxblockedxxx')}'
                                  : accountSTATUS == Dbkeys.sTATUSpending
                                      ? '${getTranslatedForCurrentUser(this.context, 'xxaccountxx')} ${getTranslatedForCurrentUser(this.context, 'xxxapprovedxxx')}'
                                      : accountSTATUS == Dbkeys.sTATUSblocked
                                          ? '${getTranslatedForCurrentUser(this.context, 'xxaccountxx')} ${getTranslatedForCurrentUser(this.context, 'xxxapprovedxxx')}'
                                          : getTranslatedForCurrentUser(
                                              this.context,
                                              'xxxacstatuschangexxx'),
                              plainDesc: accountSTATUS == Dbkeys.sTATUSallowed
                                  ? '$fullname (${getTranslatedForCurrentUser(this.context, 'xxcustomerxx')})${getTranslatedForCurrentUser(this.context, 'xxxtheaccountblockedforxxx')} ${_controller.text.trim()}. ${getTranslatedForCurrentUser(this.context, 'xxxbyxxx')} ${widget.currentuserid}  '
                                  : accountSTATUS == Dbkeys.sTATUSpending
                                      ? '$fullname (${getTranslatedForCurrentUser(this.context, 'xxcustomerxx')}) ${getTranslatedForCurrentUser(this.context, 'xxaccountxx')} ${getTranslatedForCurrentUser(this.context, 'xxxapprovedxxx')}. ${getTranslatedForCurrentUser(this.context, 'xxxbyxxx')} ${widget.currentuserid}   '
                                      : accountSTATUS == Dbkeys.sTATUSblocked
                                          ? '$fullname (${getTranslatedForCurrentUser(this.context, 'xxcustomerxx')}) ${getTranslatedForCurrentUser(this.context, 'xxaccountxx')} ${getTranslatedForCurrentUser(this.context, 'xxxapprovedxxx')}. ${getTranslatedForCurrentUser(this.context, 'xxxbyxxx')} ${widget.currentuserid}  '
                                          : '$fullname (${getTranslatedForCurrentUser(this.context, 'xxcustomerxx')}) ${getTranslatedForCurrentUser(this.context, 'xxxacstatuschangexxx')}. ${getTranslatedForCurrentUser(this.context, 'xxxbyxxx')} ${widget.currentuserid}  ',
                              context: this.context,
                              isshowloader: false);
                        },
                        postedbyID: widget.currentuserid,
                        isshowloader: false,
                        title: accountSTATUS == Dbkeys.sTATUSallowed
                            ? '${getTranslatedForCurrentUser(this.context, 'xxaccountxx')} ${getTranslatedForCurrentUser(this.context, 'xxxblockedxxx')}'
                            : accountSTATUS == Dbkeys.sTATUSpending
                                ? '${getTranslatedForCurrentUser(this.context, 'xxaccountxx')} ${getTranslatedForCurrentUser(this.context, 'xxxapprovedxxx')}'
                                : accountSTATUS == Dbkeys.sTATUSblocked
                                    ? '${getTranslatedForCurrentUser(this.context, 'xxaccountxx')}  ${getTranslatedForCurrentUser(this.context, 'xxxapprovedxxx')}'
                                    : getTranslatedForCurrentUser(
                                        this.context,
                                        'xxxacstatuschangexxx'),
                        plainDesc: accountSTATUS == Dbkeys.sTATUSallowed
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
                      ));

                      _controller.clear();
                    }).catchError((e) {
                      _controller.clear();
                      ShowSnackbar().open(
                          context: this.context,
                          scaffoldKey: _scaffoldKey,
                          status: 1,
                          time: 3,
                          label: getTranslatedForCurrentUser(this.context, 'xxxfailedntryagainxxx') + e.toString());
                    });
                  });
  }

  Widget ratingbar({double? rate}) {
    return RatingBarIndicator(
      rating: rate ?? 1.15,
      itemBuilder: (context, index) => Icon(
        Icons.star,
        color: Colors.amber,
      ),
      itemCount: 5,
      itemSize: 15.0,
      direction: Axis.horizontal,
    );
  }

  setAsOffline(
    BuildContext context,
  ) async {
    final firestore = Provider.of<FirestoreDataProviderCUSTOMERS>(this.context,
        listen: false);
    Utils.toast(getTranslatedForCurrentUser(this.context, 'xxplswaitxx'));
    await colRef.doc(customer!.id).update({
      Dbkeys.lastSeen: DateTime.now().millisecondsSinceEpoch,
    });

    await firestore.updateparticulardocinProvider(
        userid: customer!.id,
        colRef: colRef,
        onfetchDone: (userDoc) {
          setState(() {
            customer = CustomerModel.fromSnapshot(userDoc);
          });
        });
  }

  updateEmail(String email) {
    ShowFormDialog().open(
        controller: _email,
        maxlength: 50,
        keyboardtype: TextInputType.text,
        iscentrealign: true,
        context: this.context,
        title: getTranslatedForCurrentUser(this.context, 'xxxupdatexxxxxx')
            .replaceAll('(####)',
                '${getTranslatedForCurrentUser(this.context, 'xxemailxx')}'),
        subtitle: getTranslatedForCurrentUser(this.context, 'xxupdateemailxx'),
        buttontext: getTranslatedForCurrentUser(this.context, 'xxupdatexx'),
        hinttext: "${getTranslatedForCurrentUser(this.context, 'xxemailxx')}",
        footerWidget: customer!.email == ""
            ? SizedBox()
            : Padding(
                padding: EdgeInsets.fromLTRB(15, 25, 15, 6),
                child: InkWell(
                  onTap: AppConstants.isdemomode == true
                      ? () {
                          Utils.toast(getTranslatedForCurrentUser(
                              this.context, 'xxxnotalwddemoxxaccountxx'));
                        }
                      : () async {
                          Navigator.of(this.context).pop();
                          ShowLoading()
                              .open(context: this.context, key: _keyLoader);

                          await FirebaseFirestore.instance
                              .collection(DbPaths.collectioncustomers)
                              .doc(customer!.id)
                              .update({
                            Dbkeys.email: "",
                          }).then((value) async {
                            await Utils.sendDirectNotification(
                                title: getTranslatedForEventsAndAlerts(
                                        this.context, 'xxxxxremovedxxx')
                                    .replaceAll('(####)',
                                        '${getTranslatedForEventsAndAlerts(this.context, 'xxemailxx')}'),
                                parentID: "CUSTOMER--${customer!.id}",
                                plaindesc: getTranslatedForEventsAndAlerts(
                                    this.context,
                                    'xxxyopuaccountemailremovedbyadmin'),
                                docRef: FirebaseFirestore.instance
                                    .collection(DbPaths.collectioncustomers)
                                    .doc(customer!.id)
                                    .collection(DbPaths.customernotifications)
                                    .doc(DbPaths.customernotifications),
                                postedbyID: 'Admin');
                            await FirebaseApi.runTransactionRecordActivity(
                              parentid: "CUSTOMER--${customer!.id}",
                              title: getTranslatedForEventsAndAlerts(
                                      this.context, 'xxxxxremovedxxx')
                                  .replaceAll('(####)',
                                      '${getTranslatedForEventsAndAlerts(this.context, 'xxemailxx')}'),
                              postedbyID: "sys",
                              onErrorFn: (e) {
                                ShowLoading()
                                    .close(key: _keyLoader, context: context);
                                Utils.toast(
                                    "${getTranslatedForCurrentUser(this.context, 'xxxfailedntryagainxxx')}  $e");
                              },
                              onSuccessFn: () async {
                                final firestore =
                                    Provider.of<FirestoreDataProviderCUSTOMERS>(
                                        this.context,
                                        listen: false);
                                firestore.fetchNextData(
                                    Dbkeys.dataTypeCUSTOMERS,
                                    colRef
                                        .orderBy(Dbkeys.joinedOn,
                                            descending: true)
                                        .limit(Numberlimits
                                            .totalDatatoLoadAtOnceFromFirestore),
                                    true);
                                await FirebaseFirestore.instance
                                    .collection(DbPaths.collectioncustomers)
                                    .doc(customer!.id)
                                    .get()
                                    .then((doc) {
                                  customer = CustomerModel.fromSnapshot(doc);
                                  setState(() {});
                                });
                                ShowLoading()
                                    .close(key: _keyLoader, context: context);
                                Utils.toast(
                                  getTranslatedForEventsAndAlerts(this.context,
                                          'xxxxxremovedsuccessxxx')
                                      .replaceAll('(####)',
                                          '${getTranslatedForEventsAndAlerts(this.context, 'xxemailxx')}'),
                                );
                              },
                              styledDesc:
                                  '${getTranslatedForCurrentUser(this.context, 'xxcustomerxx')} <bold>${customer!.nickname}</bold> ${getTranslatedForCurrentUser(this.context, 'xxemailxx')} ${getTranslatedForCurrentUser(this.context, 'xxremovedbyadminxx')}',
                              plainDesc:
                                  '${getTranslatedForCurrentUser(this.context, 'xxcustomerxx')} ${customer!.nickname} ${getTranslatedForCurrentUser(this.context, 'xxemailxx')} ${getTranslatedForCurrentUser(this.context, 'xxremovedbyadminxx')} ',
                            );
                          }).catchError((e) {
                            ShowLoading()
                                .close(key: _keyLoader, context: context);
                            Utils.toast(
                                "${getTranslatedForCurrentUser(this.context, 'xxxfailedntryagainxxx')}  $e");
                          });
                        },
                  child: MtCustomfontBoldSemi(
                    text: getTranslatedForCurrentUser(
                            this.context, 'xxxremovexxxxxx')
                        .replaceAll('(####)',
                            '${getTranslatedForCurrentUser(this.context, 'xxemailxx')}'),
                    color: Mycolors.red,
                    fontsize: 15,
                  ),
                ),
              ),
        onpressed: AppConstants.isdemomode == true
            ? () {
                Utils.toast(getTranslatedForCurrentUser(
                    this.context, 'xxxnotalwddemoxxaccountxx'));
              }
            : () async {
                if (_email.text.trim().length < 1 ||
                    (!_email.text.trim().contains("@") ||
                        !_email.text.trim().contains("."))) {
                  Utils.toast(getTranslatedForCurrentUser(
                      this.context, 'xxvalidemailxx'));
                } else {
                  if (email == "${_email.text.trim().toLowerCase()}") {
                    Utils.toast(getTranslatedForCurrentUser(
                        this.context, 'xxxalreadyexistsxxx'));
                  } else {
                    String userid = customer!.id;
                    Navigator.of(this.context).pop();
                    ShowLoading().open(context: this.context, key: _keyLoader);

                    await FirebaseFirestore.instance
                        .collection(DbPaths.collectionagents)
                        .where(Dbkeys.email,
                            isEqualTo: "${_email.text.trim().toLowerCase()}")
                        .get()
                        .then((agents) async {
                      if (agents.docs.length != 0) {
                        ShowLoading().close(key: _keyLoader, context: context);
                        Utils.toast(
                          getTranslatedForCurrentUser(
                                  this.context, 'xxusingemailxxx')
                              .replaceAll('(####)',
                                  '${getTranslatedForCurrentUser(this.context, 'xxagentxx')} ${agents.docs[0][Dbkeys.nickname]}'),
                        );
                      } else {
                        await FirebaseFirestore.instance
                            .collection(DbPaths.collectioncustomers)
                            .where(Dbkeys.email,
                                isEqualTo:
                                    "${_email.text.trim().toLowerCase()}")
                            .get()
                            .then((doc) async {
                          // customer = CustomerModel.fromSnapshot(doc);
                          // setState(() {});
                          if (doc.docs.length == 0) {
                            await FirebaseFirestore.instance
                                .collection(DbPaths.collectioncustomers)
                                .doc(userid)
                                .update({
                              Dbkeys.email: _email.text.trim().toLowerCase(),
                            }).then((value) async {
                              await Utils.sendDirectNotification(
                                  title: getTranslatedForCurrentUser(
                                          this.context, 'xxxxxxupdatedxx')
                                      .replaceAll('(####)',
                                          '${getTranslatedForCurrentUser(this.context, 'xxemailxx')}'),
                                  parentID: "CUSTOMER--$userid",
                                  plaindesc: getTranslatedForCurrentUser(
                                          this.context,
                                          'xxxaccountemailupdatedtoxxx')
                                      .replaceAll('(####)',
                                          '${getTranslatedForCurrentUser(this.context, '${_email.text.trim().toLowerCase()}')}'),
                                  docRef: FirebaseFirestore.instance
                                      .collection(DbPaths.collectioncustomers)
                                      .doc(userid)
                                      .collection(DbPaths.customernotifications)
                                      .doc(DbPaths.customernotifications),
                                  postedbyID: 'Admin');
                              await FirebaseApi.runTransactionRecordActivity(
                                parentid: "CUSTOMER--$userid",
                                title:
                                    "${getTranslatedForCurrentUser(this.context, 'xxcustomerxx')} ${getTranslatedForCurrentUser(this.context, 'xxxxxxupdatedxx').replaceAll('(####)', '${getTranslatedForCurrentUser(this.context, 'xxemailxx')}')}",
                                postedbyID: "sys",
                                onErrorFn: (e) {
                                  ShowLoading()
                                      .close(key: _keyLoader, context: context);
                                  Utils.toast(
                                      "${getTranslatedForCurrentUser(this.context, 'xxxfailedntryagainxxx')}\n $e");
                                },
                                onSuccessFn: () {},
                                styledDesc:
                                    '${getTranslatedForCurrentUser(this.context, 'xxcustomerxx')} <bold>${customer!.nickname}</bold> ${getTranslatedForCurrentUser(this.context, 'xxxaccountemailupdatedtoxxx').replaceAll('(####)', '${"<bold>${_email.text.trim().toLowerCase()}</bold>"}')}',
                                plainDesc:
                                    '${getTranslatedForCurrentUser(this.context, 'xxcustomerxx')} ${customer!.nickname} ${getTranslatedForCurrentUser(this.context, 'xxxaccountemailupdatedtoxxx').replaceAll('(####)', '${_email.text.trim().toLowerCase()}')}',
                              );
                            }).then((value) async {
                              final firestore =
                                  Provider.of<FirestoreDataProviderCUSTOMERS>(
                                      this.context,
                                      listen: false);
                              firestore.fetchNextData(
                                  Dbkeys.dataTypeCUSTOMERS,
                                  colRef
                                      .orderBy(Dbkeys.joinedOn,
                                          descending: true)
                                      .limit(Numberlimits
                                          .totalDatatoLoadAtOnceFromFirestore),
                                  true);
                              await FirebaseFirestore.instance
                                  .collection(DbPaths.collectioncustomers)
                                  .doc(userid)
                                  .get()
                                  .then((doc) {
                                customer = CustomerModel.fromSnapshot(doc);
                                setState(() {});
                              });

                              ShowLoading()
                                  .close(key: _keyLoader, context: context);

                              Utils.toast(
                                getTranslatedForCurrentUser(
                                        this.context, 'xxxxxemailsuccessxxx')
                                    .replaceAll('(####)',
                                        '${getTranslatedForCurrentUser(this.context, 'xxemailxx')}'),
                              );
                            }).catchError((e) {
                              ShowLoading()
                                  .close(key: _keyLoader, context: context);
                              Utils.toast(
                                  "${getTranslatedForCurrentUser(this.context, 'xxxfailedntryagainxxx')}\n  $e");
                            });
                          } else {
                            ShowLoading()
                                .close(key: _keyLoader, context: context);
                            Utils.toast(
                              getTranslatedForCurrentUser(
                                      this.context, 'xxusingemailxxx')
                                  .replaceAll('(####)',
                                      '${getTranslatedForCurrentUser(this.context, 'xxcustomerxx')} ${doc.docs[0][Dbkeys.nickname]}'),
                            );
                          }
                        });
                      }
                    });
                  }
                }
              });
  }

  updateMobile(String phone) {
    ShowFormDialog().open(
        controller: _pcode,
        maxlength: 14,
        keyboardtype: TextInputType.number,
        iscentrealign: true,
        inputFormatter: [
          FilteringTextInputFormatter.allow(RegExp('[0-9]')),
        ],
        controllerExtra: _pnumber,
        context: this.context,
        title: getTranslatedForCurrentUser(this.context, 'xxxupdatexxxxxx')
            .replaceAll('(####)',
                '${getTranslatedForCurrentUser(this.context, 'xxenter_mobilenumberxx')}'),
        subtitle: getTranslatedForCurrentUser(this.context, 'xxupdatephonexx'),
        buttontext: getTranslatedForCurrentUser(this.context, 'xxupdatexx'),
        hinttext: getTranslatedForCurrentUser(this.context, 'xxccxx'),
        hinttextExtra:
            getTranslatedForCurrentUser(this.context, 'xxxphonenumberxx'),
        footerWidget: customer!.phone == ""
            ? SizedBox()
            : Padding(
                padding: EdgeInsets.fromLTRB(15, 25, 15, 6),
                child: InkWell(
                  onTap: AppConstants.isdemomode == true
                      ? () {
                          Utils.toast(getTranslatedForCurrentUser(
                              this.context, 'xxxnotalwddemoxxaccountxx'));
                        }
                      : () async {
                          Navigator.of(this.context).pop();
                          ShowLoading()
                              .open(context: this.context, key: _keyLoader);

                          await FirebaseFirestore.instance
                              .collection(DbPaths.collectioncustomers)
                              .doc(customer!.id)
                              .update({
                            Dbkeys.phone: "",
                            Dbkeys.countryCode: "",
                            Dbkeys.phoneRaw: "",
                          }).then((value) async {
                            await Utils.sendDirectNotification(
                                title: getTranslatedForCurrentUser(
                                    this.context, 'xxphoneremovedxxx'),
                                parentID: "CUSTOMER--${customer!.id}",
                                plaindesc:
                                    "${getTranslatedForCurrentUser(this.context, 'xxaccountxx')} ${getTranslatedForCurrentUser(this.context, 'xxphoneremovedxxx')}",
                                docRef: FirebaseFirestore.instance
                                    .collection(DbPaths.collectioncustomers)
                                    .doc(customer!.id)
                                    .collection(DbPaths.customernotifications)
                                    .doc(DbPaths.customernotifications),
                                postedbyID: 'Admin');
                            await FirebaseApi.runTransactionRecordActivity(
                              parentid: "CUSTOMER--${customer!.id}",
                              title:
                                  "${getTranslatedForCurrentUser(this.context, 'xxcustomerxx')} ${getTranslatedForCurrentUser(this.context, 'xxphoneremovedxxx')}",
                              postedbyID: "sys",
                              onErrorFn: (e) {
                                ShowLoading()
                                    .close(key: _keyLoader, context: context);
                                Utils.toast(
                                    "${getTranslatedForCurrentUser(this.context, 'xxfailedxx')} $e");
                              },
                              onSuccessFn: () async {
                                final firestore =
                                    Provider.of<FirestoreDataProviderCUSTOMERS>(
                                        this.context,
                                        listen: false);
                                firestore.fetchNextData(
                                    Dbkeys.dataTypeCUSTOMERS,
                                    colRef
                                        .orderBy(Dbkeys.joinedOn,
                                            descending: true)
                                        .limit(Numberlimits
                                            .totalDatatoLoadAtOnceFromFirestore),
                                    true);
                                await FirebaseFirestore.instance
                                    .collection(DbPaths.collectioncustomers)
                                    .doc(customer!.id)
                                    .get()
                                    .then((doc) {
                                  customer = CustomerModel.fromSnapshot(doc);
                                  setState(() {});
                                });
                                ShowLoading()
                                    .close(key: _keyLoader, context: context);
                                Utils.toast(getTranslatedForCurrentUser(
                                        this.context, 'xxxxxremovedsuccessxxx')
                                    .replaceAll('(####)',
                                        '${getTranslatedForCurrentUser(this.context, 'xxxphonenumberxx')}'));
                              },
                              styledDesc:
                                  '${getTranslatedForCurrentUser(this.context, 'xxcustomerxx')} <bold>${customer!.nickname}</bold> ${getTranslatedForCurrentUser(this.context, 'xxphoneremovedxxx')}',
                              plainDesc:
                                  '${getTranslatedForCurrentUser(this.context, 'xxcustomerxx')} ${customer!.nickname} ${getTranslatedForCurrentUser(this.context, 'xxphoneremovedxxx')} ',
                            );
                          }).catchError((e) {
                            ShowLoading()
                                .close(key: _keyLoader, context: context);
                            Utils.toast(
                                "${getTranslatedForCurrentUser(this.context, 'xxfailedxx')} $e");
                          });
                        },
                  child: MtCustomfontBoldSemi(
                    text: getTranslatedForCurrentUser(
                            this.context, 'xxxremovexxxxxx')
                        .replaceAll('(####)',
                            '${getTranslatedForCurrentUser(this.context, 'xxxphonenumberxx')}'),
                    color: Mycolors.red,
                    fontsize: 15,
                  ),
                ),
              ),
        onpressed: AppConstants.isdemomode == true
            ? () {
                Utils.toast(getTranslatedForCurrentUser(
                    this.context, 'xxxnotalwddemoxxaccountxx'));
              }
            : () async {
                if (_pcode.text.trim().length < 1 ||
                    (_pcode.text.trim().contains("+") &&
                        _pcode.text.trim().length < 2)) {
                  Utils.toast(
                      getTranslatedForCurrentUser(this.context, 'xxvalidccxx'));
                } else if (_pnumber.text.trim().length < 5) {
                  Utils.toast(getTranslatedForCurrentUser(
                      this.context, 'xxentervalidmobxx'));
                } else {
                  if (phone ==
                      "+${_pcode.text.trim()}${_pnumber.text.trim()}") {
                    Utils.toast(getTranslatedForCurrentUser(
                        this.context, 'xxxalreadyexistsxxx'));
                  } else {
                    String userid = customer!.id;
                    Navigator.of(this.context).pop();
                    ShowLoading().open(context: this.context, key: _keyLoader);

                    await FirebaseFirestore.instance
                        .collection(DbPaths.collectionagents)
                        .where(Dbkeys.phone,
                            isEqualTo:
                                "+" + _pcode.text.trim() + _pnumber.text.trim())
                        .get()
                        .then((agents) async {
                      if (agents.docs.length != 0) {
                        ShowLoading().close(key: _keyLoader, context: context);
                        Utils.toast(
                          getTranslatedForCurrentUser(
                                  this.context, 'xxusingphonexxx')
                              .replaceAll('(####)',
                                  '${getTranslatedForCurrentUser(this.context, 'xxagentxx')} ${agents.docs[0][Dbkeys.nickname]}'),
                        );
                      } else {
                        await FirebaseFirestore.instance
                            .collection(DbPaths.collectioncustomers)
                            .where(Dbkeys.phone,
                                isEqualTo: "+" +
                                    _pcode.text.trim() +
                                    _pnumber.text.trim())
                            .get()
                            .then((doc) async {
                          // customer = CustomerModel.fromSnapshot(doc);
                          // setState(() {});
                          if (doc.docs.length == 0) {
                            await FirebaseFirestore.instance
                                .collection(DbPaths.collectioncustomers)
                                .doc(userid)
                                .update({
                              Dbkeys.phoneRaw: _pnumber.text.trim(),
                              Dbkeys.phone: "+" +
                                  _pcode.text.trim() +
                                  _pnumber.text.trim(),
                              Dbkeys.countryCode: "+" + _pcode.text.trim(),
                            }).then((value) async {
                              await Utils.sendDirectNotification(
                                  title: getTranslatedForCurrentUser(
                                      this.context, 'xxphoneupdatedxxx'),
                                  parentID: "CUSTOMER--$userid",
                                  plaindesc:
                                      "${getTranslatedForCurrentUser(this.context, 'xxxphoneupdatedbyadminxx').replaceAll('(####)', '+${_pcode.text.trim() + _pnumber.text.trim()}')}",
                                  docRef: FirebaseFirestore.instance
                                      .collection(DbPaths.collectioncustomers)
                                      .doc(userid)
                                      .collection(DbPaths.customernotifications)
                                      .doc(DbPaths.customernotifications),
                                  postedbyID: 'Admin');
                              await FirebaseApi.runTransactionRecordActivity(
                                parentid: "CUSTOMER--$userid",
                                title:
                                    "${getTranslatedForCurrentUser(this.context, 'xxcustomerxx')} ${getTranslatedForCurrentUser(this.context, 'xxphoneupdatedxxx')}",
                                postedbyID: "sys",
                                onErrorFn: (e) {
                                  ShowLoading()
                                      .close(key: _keyLoader, context: context);
                                  Utils.toast(
                                      "${getTranslatedForCurrentUser(this.context, 'xxfailedxx')} $e");
                                },
                                onSuccessFn: () {},
                                styledDesc:
                                    '${getTranslatedForCurrentUser(this.context, 'xxcustomerxx')} <bold> ${customer!.nickname}</bold> ${getTranslatedForCurrentUser(this.context, 'xxxphoneupdatedbyadminxx').replaceAll('(####)', "<bold>+${_pcode.text.trim() + _pnumber.text.trim()}</bold>")}',
                                plainDesc:
                                    '${getTranslatedForCurrentUser(this.context, 'xxcustomerxx')} ${customer!.nickname} ${getTranslatedForCurrentUser(this.context, 'xxxphoneupdatedbyadminxx').replaceAll('(####)', '+${_pcode.text.trim() + _pnumber.text.trim()}')}',
                              );
                            }).then((value) async {
                              final firestore =
                                  Provider.of<FirestoreDataProviderCUSTOMERS>(
                                      this.context,
                                      listen: false);
                              firestore.fetchNextData(
                                  Dbkeys.dataTypeCUSTOMERS,
                                  colRef
                                      .orderBy(Dbkeys.joinedOn,
                                          descending: true)
                                      .limit(Numberlimits
                                          .totalDatatoLoadAtOnceFromFirestore),
                                  true);
                              await FirebaseFirestore.instance
                                  .collection(DbPaths.collectioncustomers)
                                  .doc(userid)
                                  .get()
                                  .then((doc) {
                                customer = CustomerModel.fromSnapshot(doc);
                                setState(() {});
                              });

                              ShowLoading()
                                  .close(key: _keyLoader, context: context);

                              Utils.toast(getTranslatedForCurrentUser(
                                  this.context, 'xxphoneupdatedxxx'));
                            }).catchError((e) {
                              ShowLoading()
                                  .close(key: _keyLoader, context: context);
                              Utils.toast(
                                  "${getTranslatedForCurrentUser(this.context, 'xxfailedxx')} $e");
                            });
                          } else {
                            ShowLoading()
                                .close(key: _keyLoader, context: context);
                            Utils.toast(
                              getTranslatedForCurrentUser(
                                      this.context, 'xxusingphonexxx')
                                  .replaceAll('(####)',
                                      '${getTranslatedForCurrentUser(this.context, 'xxcustomerxx')} ${doc.docs[0][Dbkeys.nickname]}'),
                            );
                          }
                        });
                      }
                    });
                  }
                }
              });
  }

  updateName(String name) {
    ShowFormDialog().open(
        controller: _name,
        hinttext:
            "${getTranslatedForCurrentUser(this.context, 'xxcustomerxx')} ${getTranslatedForCurrentUser(this.context, 'xxfullnamexx')}",
        context: this.context,
        title: getTranslatedForCurrentUser(this.context, 'xxupdatenamexxx'),
        subtitle: getTranslatedForCurrentUser(this.context, 'xxupdatenamexx'),
        buttontext: getTranslatedForCurrentUser(this.context, 'xxupdatexx'),
        onpressed: AppConstants.isdemomode == true
            ? () {
                Utils.toast(getTranslatedForCurrentUser(
                    this.context, 'xxxnotalwddemoxxaccountxx'));
              }
            : () async {
                if (_name.text.trim().length < 2) {
                  Utils.toast(getTranslatedForCurrentUser(
                      this.context, 'xxenterfullnamexx'));
                } else if (name == _name.text.trim()) {
                  Utils.toast(getTranslatedForCurrentUser(
                      this.context, 'xxxalreadyexistsxxx'));
                } else {
                  Navigator.of(this.context).pop();
                  ShowLoading().open(context: this.context, key: _keyLoader);
                  await colRef.doc(customer!.id).update({
                    Dbkeys.nickname: _name.text.trim(),
                    Dbkeys.searchKey:
                        _name.text.trim().substring(0, 1).toUpperCase(),
                  }).then((value) async {
                    var names = _name.text.trim().trim().split(' ');

                    String shortname = _name.text.trim().trim();
                    String lastName = "";
                    if (names.length > 1) {
                      shortname = names[0];
                      lastName = names[1];
                      if (shortname.length < 3) {
                        shortname = lastName;
                        if (lastName.length < 3) {
                          shortname = _name.text.trim();
                        }
                      }
                    }
                    await FirebaseApi.runUPDATEmapobjectinListField(
                        docrefdata: FirebaseFirestore.instance
                            .collection(DbPaths.userapp)
                            .doc(DbPaths.registry),
                        compareKey: Dbkeys.rgstUSERID,
                        compareVal: customer!.id,
                        onErrorFn: (err) {
                          ShowLoading()
                              .close(context: this.context, key: _keyLoader);

                          Utils.toast(getTranslatedForCurrentUser(
                                  this.context, 'xxfailedxx') +
                              err.toString());
                        },
                        replaceableMapObjectWithOnlyFieldsRequired: {
                          Dbkeys.rgstUSERID: customer!.id,
                          Dbkeys.rgstFULLNAME: _name.text.trim(),
                          Dbkeys.rgstSHORTNAME: shortname,
                        },
                        onSuccessFn: () async {
                          await Utils.sendDirectNotification(
                              title: getTranslatedForCurrentUser(
                                  this.context, 'xxnameupdatedxxx'),
                              parentID: "CUSTOMER--${customer!.id}",
                              plaindesc: getTranslatedForCurrentUser(
                                      this.context, 'xxxacnameupdatedbyadminxx')
                                  .replaceAll(
                                      '(####)', '${_name.text.toString()}'),
                              docRef: FirebaseFirestore.instance
                                  .collection(DbPaths.collectioncustomers)
                                  .doc(customer!.id)
                                  .collection(DbPaths.customernotifications)
                                  .doc(DbPaths.customernotifications),
                              postedbyID: 'Admin');
                          await FirebaseApi.runTransactionRecordActivity(
                            parentid: "CUSTOMER--${customer!.id}",
                            title:
                                "${getTranslatedForCurrentUser(this.context, 'xxcustomerxx')}${getTranslatedForCurrentUser(this.context, 'xxnameupdatedxxx')}",
                            postedbyID: "sys",
                            onErrorFn: (e) {
                              ShowLoading()
                                  .close(key: _keyLoader, context: context);
                              Utils.toast(
                                  "${getTranslatedForCurrentUser(this.context, 'xxfailedxx')}" +
                                      "$e");
                            },
                            onSuccessFn: () {},
                            styledDesc:
                                '${getTranslatedForCurrentUser(this.context, 'xxcustomerxx')} <bold> ${getTranslatedForCurrentUser(this.context, 'xxidxx')} ${customer!.id} </bold>${getTranslatedForCurrentUser(this.context, 'xxxacnameupdatedbyadminxx').replaceAll('(####)', '${_name.text.toString()}')}.',
                            plainDesc:
                                '${getTranslatedForCurrentUser(this.context, 'xxcustomerxx')} ${getTranslatedForCurrentUser(this.context, 'xxidxx')} ${customer!.id} ${getTranslatedForCurrentUser(this.context, 'xxxacnameupdatedbyadminxx').replaceAll('(####)', '${_name.text.toString()}')}.',
                          );

                          final firestore =
                              Provider.of<FirestoreDataProviderCUSTOMERS>(
                                  this.context,
                                  listen: false);
                          firestore.fetchNextData(
                              Dbkeys.dataTypeCUSTOMERS,
                              colRef
                                  .orderBy(Dbkeys.joinedOn, descending: true)
                                  .limit(Numberlimits
                                      .totalDatatoLoadAtOnceFromFirestore),
                              true);

                          await FirebaseFirestore.instance
                              .collection(DbPaths.collectioncustomers)
                              .doc(customer!.id)
                              .get()
                              .then((doc) {
                            customer = CustomerModel.fromSnapshot(doc);
                            setState(() {});
                          });
                          ShowLoading()
                              .close(key: _keyLoader, context: context);
                          Utils.toast(
                              "${getTranslatedForCurrentUser(this.context, 'xxcustomerxx')} ${getTranslatedForCurrentUser(this.context, 'xxxnameupdatedsuccesxxx')}");
                        }).catchError((e) {
                      ShowLoading()
                          .close(context: this.context, key: _keyLoader);

                      Utils.toast(
                          "${getTranslatedForCurrentUser(this.context, 'xxfailedxx')}" +
                              e.toString());
                    });
                  }).catchError((e) {
                    ShowLoading().close(context: this.context, key: _keyLoader);

                    Utils.toast(
                        "${getTranslatedForCurrentUser(this.context, 'xxfailedxx')}" +
                            e.toString());
                  });
                }
              });
  }

  Future uploadSelectedLocalFileWithProgressIndicator(
      File selectedFile, bool isVideo, bool isthumbnail, int timeEpoch,
      {String? filenameoptional}) async {
    String ext = p.extension(selectedFile.path);
    String fileName = customer!.id + ext;
    // isthumbnail == false
    //     ? isVideo == true
    //         ? 'Video-$timeEpoch.mp4'
    //         : '$timeEpoch'
    //     : '${timeEpoch}Thumbnail.png'
    // );
    Reference reference =
        FirebaseStorage.instance.ref("CustomerProfilePics/").child(fileName);

    UploadTask uploading = reference.putFile(selectedFile);

    showDialog<void>(
        context: this.context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return new WillPopScope(
              onWillPop: () async => false,
              child: SimpleDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(7),
                  ),
                  // side: BorderSide(width: 5, color: Colors.green)),
                  key: _keyLoader,
                  backgroundColor: Colors.white,
                  children: <Widget>[
                    Center(
                      child: StreamBuilder(
                          stream: uploading.snapshotEvents,
                          builder: (BuildContext context, snapshot) {
                            if (snapshot.hasData) {
                              final TaskSnapshot snap = uploading.snapshot;

                              return openUploadDialog(
                                context: this.context,
                                percent: bytesTransferred(snap) / 100,
                                title: isthumbnail == true
                                    ? getTranslatedForCurrentUser(
                                        this.context, 'xxgeneratingthumbnailxx')
                                    : getTranslatedForCurrentUser(
                                        this.context, 'xxsendingxx'),
                                subtitle:
                                    "${((((snap.bytesTransferred / 1024) / 1000) * 100).roundToDouble()) / 100}/${((((snap.totalBytes / 1024) / 1000) * 100).roundToDouble()) / 100} MB",
                              );
                            } else {
                              return openUploadDialog(
                                context: this.context,
                                percent: 0.0,
                                title: isthumbnail == true
                                    ? getTranslatedForCurrentUser(
                                        this.context, 'xxgeneratingthumbnailxx')
                                    : getTranslatedForCurrentUser(
                                        this.context, 'xxsendingxx'),
                                subtitle: "",
                              );
                            }
                          }),
                    ),
                  ]));
        });

    TaskSnapshot downloadTask = await uploading;
    String downloadedurl = await downloadTask.ref.getDownloadURL();

    Navigator.of(_keyLoader.currentContext!, rootNavigator: true).pop(); //
    return downloadedurl;
  }

  Widget buildheader() {
    final observer = Provider.of<Observer>(this.context, listen: false);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Column(
          children: <Widget>[
            Stack(
              alignment: Alignment.bottomCenter,
              children: [
                Container(
                  margin: EdgeInsets.fromLTRB(12, 12, 12.0, 7.0),
                  padding: EdgeInsets.only(bottom: 10),
                  width: 85,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Mycolors.greylightcolor,
                    border: Border.all(
                      color: Colors.white,
                      width: 1,
                    ),
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: customer!.accountstatus == Dbkeys.sTATUSblocked
                          ? NetworkImage(
                              AppConstants.defaultprofilepicfromnetworklink)
                          : NetworkImage(customer!.photoUrl == ''
                              ? AppConstants.defaultprofilepicfromnetworklink
                              : customer!.photoUrl),
                    ),
                  ),
                ),
                customer!.lastSeen == true
                    ? Positioned(
                        bottom: 10,
                        child: Container(
                            padding: EdgeInsets.fromLTRB(6, 3, 6, 3),
                            decoration:
                                boxDecoration(radius: 10, showShadow: false),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.circle,
                                  size: 10,
                                  color: Colors.green,
                                ),
                                SizedBox(width: 3),
                                MtCustomfontMedium(
                                  text: getTranslatedForCurrentUser(
                                      this.context, 'xxonlinexx'),
                                  fontsize: 12,
                                )
                              ],
                            )))
                    : SizedBox(),
                customer!.isAccountDeletedbyAdmin == true
                    ? SizedBox()
                    : Positioned(
                        top: 10,
                        right: 15,
                        child: CircleAvatar(
                            backgroundColor: Mycolors.secondary,
                            radius: 17,
                            child: IconButton(
                                onPressed: AppConstants.isdemomode == true
                                    ? () {
                                        Utils.toast(getTranslatedForCurrentUser(
                                            this.context,
                                            'xxxnotalwddemoxxaccountxx'));
                                      }
                                    : () async {
                                        final firestore = Provider.of<
                                                FirestoreDataProviderCUSTOMERS>(
                                            this.context,
                                            listen: false);
                                        await Navigator.push(
                                            this.context,
                                            new MaterialPageRoute(
                                                builder: (context) =>
                                                    new CameraImageGalleryPicker(
                                                      onTakeFile: (file) async {
                                                        setStatusBarColor();

                                                        int timeStamp = DateTime
                                                                .now()
                                                            .millisecondsSinceEpoch;

                                                        String? url =
                                                            await uploadSelectedLocalFileWithProgressIndicator(
                                                                file,
                                                                false,
                                                                false,
                                                                timeStamp);
                                                        if (url != null) {
                                                          ShowLoading().open(
                                                              context:
                                                                  this.context,
                                                              key: _keyLoader2);
                                                          await colRef
                                                              .doc(customer!.id)
                                                              .update({
                                                            Dbkeys.photoUrl:
                                                                url,
                                                          }).then((value) async {
                                                            await FirebaseApi
                                                                .runUPDATEmapobjectinListField(
                                                                    docrefdata: FirebaseFirestore
                                                                        .instance
                                                                        .collection(DbPaths
                                                                            .userapp)
                                                                        .doc(DbPaths
                                                                            .registry),
                                                                    compareKey:
                                                                        Dbkeys
                                                                            .rgstUSERID,
                                                                    compareVal:
                                                                        customer!
                                                                            .id,
                                                                    onErrorFn:
                                                                        (err) {
                                                                      ShowLoading().close(
                                                                          context:
                                                                              this.context,
                                                                          key: _keyLoader2);

                                                                      Utils.toast(
                                                                          "${getTranslatedForCurrentUser(this.context, 'xxfailedxx')} " +
                                                                              err.toString());
                                                                    },
                                                                    replaceableMapObjectWithOnlyFieldsRequired: {
                                                                      Dbkeys.rgstUSERID:
                                                                          customer!
                                                                              .id,
                                                                      Dbkeys.rgstPHOTOURL:
                                                                          url,
                                                                    },
                                                                    onSuccessFn:
                                                                        () async {
                                                                      await Utils.sendDirectNotification(
                                                                          title: getTranslatedForCurrentUser(
                                                                              this
                                                                                  .context,
                                                                              'xxxphotoupdatedxxx'),
                                                                          parentID:
                                                                              "CUSTOMER--${customer!.id}",
                                                                          plaindesc: getTranslatedForCurrentUser(
                                                                              this
                                                                                  .context,
                                                                              'xxxyouracphotoxxx'),
                                                                          docRef: FirebaseFirestore
                                                                              .instance
                                                                              .collection(DbPaths.collectioncustomers)
                                                                              .doc(customer!.id)
                                                                              .collection(DbPaths.customernotifications)
                                                                              .doc(DbPaths.customernotifications),
                                                                          postedbyID: 'Admin');
                                                                      await FirebaseApi.runTransactionRecordActivity(
                                                                          parentid: "CUSTOMER--${customer!.id}",
                                                                          title: "${getTranslatedForCurrentUser(this.context, 'xxcustomerxx')} ${getTranslatedForCurrentUser(this.context, 'xxxphotoupdatedxxx')}",
                                                                          postedbyID: "sys",
                                                                          onErrorFn: (e) {
                                                                            ShowLoading().close(
                                                                                key: _keyLoader2,
                                                                                context: this.context);
                                                                            Utils.toast("${getTranslatedForCurrentUser(this.context, 'xxfailedxx')} $e");
                                                                          },
                                                                          onSuccessFn: () {},
                                                                          styledDesc: '${getTranslatedForCurrentUser(this.context, 'xxcustomerxx')} ${getTranslatedForCurrentUser(this.context, 'xxidxx')} <bold>${customer!.id}</bold> ${getTranslatedForCurrentUser(this.context, 'xxxphotoupdatedxxx')} ${getTranslatedForCurrentUser(this.context, 'xxxbyxxx')} ${getTranslatedForCurrentUser(this.context, 'xxadminxx')}',
                                                                          plainDesc: '${getTranslatedForCurrentUser(this.context, 'xxcustomerxx')} ${getTranslatedForCurrentUser(this.context, 'xxidxx')} ${customer!.id} ${getTranslatedForCurrentUser(this.context, 'xxxphotoupdatedxxx')} ${getTranslatedForCurrentUser(this.context, 'xxxbyxxx')} ${getTranslatedForCurrentUser(this.context, 'xxadminxx')}');

                                                                      firestore.fetchNextData(
                                                                          Dbkeys
                                                                              .dataTypeCUSTOMERS,
                                                                          colRef
                                                                              .orderBy(Dbkeys.joinedOn, descending: true)
                                                                              .limit(Numberlimits.totalDatatoLoadAtOnceFromFirestore),
                                                                          true);

                                                                      await FirebaseFirestore
                                                                          .instance
                                                                          .collection(DbPaths
                                                                              .collectioncustomers)
                                                                          .doc(customer!
                                                                              .id)
                                                                          .get()
                                                                          .then(
                                                                              (doc) {
                                                                        customer =
                                                                            CustomerModel.fromSnapshot(doc);
                                                                        setState(
                                                                            () {});
                                                                      });
                                                                      ShowLoading().close(
                                                                          key:
                                                                              _keyLoader2,
                                                                          context:
                                                                              this.context);
                                                                      Utils.toast(
                                                                          "${getTranslatedForCurrentUser(this.context, 'xxcustomerxx')} ${getTranslatedForCurrentUser(this.context, 'xxxphotoupdatedxxx')}");
                                                                    }).catchError(
                                                                (e) {
                                                              ShowLoading().close(
                                                                  context: this
                                                                      .context,
                                                                  key:
                                                                      _keyLoader2);

                                                              Utils.toast(
                                                                  "${getTranslatedForCurrentUser(this.context, 'xxfailedxx')} " +
                                                                      e.toString());
                                                            });
                                                          });
                                                          await file.delete();
                                                        }
                                                      },
                                                    )));
                                      },
                                icon: Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
                                  size: 15,
                                ))))
              ],
            ),
          ],
        ),
        Container(
          width: MediaQuery.of(this.context).size.width / 1.6,
          padding: EdgeInsets.fromLTRB(10.0, 25.0, 0.0, 0.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: [
                  MtCustomfontBold(
                    color: Mycolors.white,
                    text: customer!.nickname,
                    fontsize:
                        customer!.isAccountDeletedbyAdmin == true ? 15 : 19.5,
                  ),
                  SizedBox(width: 10),
                  customer!.isAccountDeletedbyAdmin == true
                      ? SizedBox()
                      : CircleAvatar(
                          backgroundColor: Mycolors.secondary,
                          radius: 12,
                          child: IconButton(
                              onPressed: AppConstants.isdemomode == true
                                  ? () {
                                      Utils.toast(getTranslatedForCurrentUser(
                                          this.context,
                                          'xxxnotalwddemoxxaccountxx'));
                                    }
                                  : () async {
                                      await updateName(customer!.nickname);
                                    },
                              icon: Icon(
                                Icons.edit,
                                color: Colors.white,
                                size: 10,
                              )))
                ],
              ),

              Divider(
                color: Colors.white10,
              ),

              SizedBox(
                height: 5.0,
              ),

              // Row(
              //   crossAxisAlignment: CrossAxisAlignment.end,
              //   mainAxisAlignment: MainAxisAlignment.start,
              //   children: [
              //     Icon(Icons.timer, color: Colors.white, size: 15),
              //     SizedBox(width: 10),
              //     MtCustomfontRegular(
              //       text: 'Lastseen 12 years ago ',
              //       color: Mycolors.whitelight,
              //       fontsize: 13,
              //     ),
              //   ],
              // ),
              SizedBox(
                height: 8.0,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Icon(Icons.account_box, color: Colors.white, size: 15),
                  SizedBox(width: 10),
                  MtCustomfontRegular(
                    text:
                        '${getTranslatedForCurrentUser(this.context, 'xxidxx')} ${customer!.id}',
                    color: Mycolors.whitelight,
                    fontsize: 13,
                  ),
                ],
              ),
              SizedBox(
                height: 11.0,
              ),
              customer!.isAccountDeletedbyAdmin == true
                  ? SizedBox()
                  : observer.basicSettingUserApp!.loginTypeUserApp ==
                          "Email/Password"
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Icon(Icons.email, color: Colors.white, size: 15),
                            SizedBox(width: 10),
                            MtCustomfontRegular(
                              text: customer!.email == ""
                                  ? ""
                                  : AppConstants.isdemomode == true
                                      ? '*${customer!.email.substring(1, 4)}********'
                                      : '${customer!.email}',
                              color: Mycolors.whitelight,
                              fontsize: 13,
                            ),
                            SizedBox(width: 20),
                            CircleAvatar(
                                backgroundColor: Mycolors.secondary,
                                radius: 12,
                                child: IconButton(
                                    onPressed: AppConstants.isdemomode == true
                                        ? () {
                                            Utils.toast(
                                                getTranslatedForCurrentUser(
                                                    this.context,
                                                    'xxxnotalwddemoxxaccountxx'));
                                          }
                                        : () async {
                                            await updateEmail(customer!.phone);
                                          },
                                    icon: Icon(
                                      Icons.edit,
                                      color: Colors.white,
                                      size: 10,
                                    )))
                          ],
                        )
                      : Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Icon(Icons.phone, color: Colors.white, size: 15),
                            SizedBox(width: 10),
                            MtCustomfontRegular(
                              text: customer!.phone == ""
                                  ? ""
                                  : AppConstants.isdemomode == true
                                      ? '${customer!.phone.substring(0, 6)}********'
                                      : '${customer!.phone}',
                              color: Mycolors.whitelight,
                              fontsize: 13,
                            ),
                            SizedBox(width: 20),
                            CircleAvatar(
                                backgroundColor: Mycolors.secondary,
                                radius: 12,
                                child: IconButton(
                                    onPressed: AppConstants.isdemomode == true
                                        ? () {
                                            Utils.toast(
                                                getTranslatedForCurrentUser(
                                                    this.context,
                                                    'xxxnotalwddemoxxaccountxx'));
                                          }
                                        : () async {
                                            await updateMobile(customer!.phone);
                                          },
                                    icon: Icon(
                                      Icons.edit,
                                      color: Colors.white,
                                      size: 10,
                                    )))
                          ],
                        ),
              SizedBox(
                height: 11.0,
              ),

              SizedBox(
                height: 0,
              ),
            ],
          ),
        ),
      ],
    );
  }

  final GlobalKey<State> _keyLoader = new GlobalKey<State>(debugLabel: '0000');
  final GlobalKey<State> _keyLoader2 =
      new GlobalKey<State>(debugLabel: '00002');

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(this.context).size.width;
    return NetworkSensitive(
      child: Utils.getNTPWrappedWidget(Consumer<Observer>(
          builder: (context, observer, _child) => Consumer<CommonSession>(
              builder: (context, user, _child) => customer == null
                  ? Scaffold(
                      backgroundColor: Mycolors.backgroundcolor,
                      body: circularProgress(),
                    )
                  : MyScaffold(
                      iconTextColor: Mycolors.white,
                      appbarColor: Mycolors.primary,
                      elevation: 0,
                      icondata1: customer!.isAccountDeletedbyAdmin == true
                          ? null
                          : Icons.notifications,
                      icon1press: () {
                        pageNavigator(
                            this.context,
                            UsersNotifiaction(
                                docRef: colRef
                                    .doc(customer!.id)
                                    .collection(DbPaths.customernotifications)
                                    .doc(DbPaths.customernotifications)));
                      },
                      // icondata1: customer!.email == '' ? null : Icons.email_outlined,
                      icondata2:
                          observer.basicSettingUserApp!.loginTypeUserApp ==
                                  "Email/Password"
                              ? customer!.email == ''
                                  ? null
                                  : Icons.email
                              : customer!.phone == ''
                                  ? null
                                  : Icons.phone,
                      icon2press: AppConstants.isdemomode == true
                          ? () {
                              Utils.toast(getTranslatedForCurrentUser(
                                  this.context, 'xxxnotalwddemoxxaccountxx'));
                            }
                          : () {
                              if (observer
                                      .basicSettingUserApp!.loginTypeUserApp ==
                                  "Email/Password") {
                                final Uri params = Uri(
                                  scheme: 'mailto',
                                  path: customer!.email,
                                );

                                launchUrl(params,
                                    mode: LaunchMode.platformDefault);
                              } else {
                                final Uri params = Uri(
                                  scheme: 'tel',
                                  path: customer!.phone,
                                );
                                launchUrl(params,
                                    mode: LaunchMode.platformDefault);
                              }
                            },
                      scaffoldkey: _scaffoldKey,
                      title:
                          '${getTranslatedForCurrentUser(this.context, 'xxprofilexxx')} - ${getTranslatedForCurrentUser(this.context, 'xxcustomerxx')}',
                      // appBar: AppBar(
                      //   elevation: 0,
                      //   titleSpacing: 0,
                      //   title: MtCustomfontBold(
                      //     color: Mycolors.white,
                      //     text: 'Profile',
                      //   ),
                      //   backgroundColor: Mycolors.primary,
                      // ),
                      body: ListView(
                        children: [
                          Stack(
                            alignment: Alignment.bottomCenter,
                            children: [
                              Column(children: [
                                Container(
                                  height: 200,
                                  color: Mycolors.primary,
                                  child: Row(children: [buildheader()]),
                                ),
                                Container(
                                  height: 60,
                                  color: Colors.transparent,
                                ),
                              ]),
                              Positioned(
                                bottom: 0,
                                child: Container(
                                  alignment: Alignment.center,
                                  margin: EdgeInsets.all(5),
                                  padding: EdgeInsets.all(2),
                                  child: customer!.isAccountDeletedbyAdmin ==
                                          true
                                      ? MtCustomfontRegular(
                                          text: customer!.actionmessage,
                                          fontsize: 12,
                                        )
                                      : GridView(
                                          physics:
                                              NeverScrollableScrollPhysics(),
                                          shrinkWrap: true,
                                          children: [
                                            myinkwell(
                                              onTap: userAppSettings == null
                                                  ? () {}
                                                  : () {
                                                      pageNavigator(
                                                          this.context,
                                                          AllTickets(
                                                            subtitle:
                                                                "${getTranslatedForCurrentUser(this.context, 'xxcustomerxx')} : ${customer!.nickname}  (${getTranslatedForCurrentUser(this.context, 'xxidxx')} ${customer!.id})",
                                                            userAppSettingsModel:
                                                                userAppSettings!,
                                                            query: FirebaseFirestore
                                                                .instance
                                                                .collection(DbPaths
                                                                    .collectiontickets)
                                                                .where(
                                                                    Dbkeys
                                                                        .ticketcreatedBy,
                                                                    isEqualTo: widget
                                                                        .customer!
                                                                        .id),
                                                          ));
                                                    },
                                              child: eachGridTile(
                                                  label:
                                                      getTranslatedForCurrentUser(
                                                          this.context,
                                                          'xxtktssxx'),
                                                  width: w / 1.0,
                                                  icon: futureLoadCollections(
                                                      future: FirebaseFirestore
                                                          .instance
                                                          .collection(DbPaths
                                                              .collectiontickets)
                                                          .where(
                                                              Dbkeys
                                                                  .ticketcreatedBy,
                                                              isEqualTo:
                                                                  customer!.id)
                                                          .get(),
                                                      placeholder:
                                                          MtPoppinsBold(
                                                        lineheight: 0.8,
                                                        text: '0',
                                                        color: Mycolors.grey,
                                                        fontsize: 22,
                                                      ),
                                                      noDataWidget:
                                                          MtPoppinsBold(
                                                        lineheight: 0.8,
                                                        text: '0',
                                                        color: Mycolors.grey,
                                                        fontsize: 22,
                                                      ),
                                                      onfetchdone: (docs) {
                                                        return MtPoppinsBold(
                                                          lineheight: 0.8,
                                                          text:
                                                              '${docs.length}',
                                                          color: Mycolors.grey,
                                                          fontsize: 22,
                                                        );
                                                      })),
                                            ),
                                            // eachGridTile(
                                            //     label: 'Audio Call Recieved',
                                            //     width: w / 1.0,
                                            //     icon: MtPoppinsBold(
                                            //       lineheight: 0.8,
                                            //       text: '99',
                                            //       color: Mycolors.grey,
                                            //       fontsize: 22,
                                            //     )),
                                            // eachGridTile(
                                            //     label: 'Video Call Made',
                                            //     width: w / 1.0,
                                            //     icon: MtPoppinsBold(
                                            //       lineheight: 0.8,
                                            //       text: '99',
                                            //       color: Mycolors.grey,
                                            //       fontsize: 22,
                                            //     )),
                                            // eachGridTile(
                                            //     label: 'Video Call Recieved',
                                            //     width: w / 1.0,
                                            //     icon: MtPoppinsBold(
                                            //       lineheight: 0.8,
                                            //       text: '99',
                                            //       color: Mycolors.grey,
                                            //       fontsize: 22,
                                            //     )),
                                            eachGridTile(
                                                label:
                                                    getTranslatedForCurrentUser(
                                                        this.context,
                                                        'xxxandroidxxx'),
                                                width: w / 1.0,
                                                icon: MtPoppinsBold(
                                                  lineheight: 0.8,
                                                  text:
                                                      '${customer!.totalvisitsANDROID}',
                                                  color: Mycolors.grey,
                                                  fontsize: 22,
                                                )),
                                            eachGridTile(
                                                label:
                                                    getTranslatedForCurrentUser(
                                                        this.context,
                                                        'xxxiosvisistsxxx'),
                                                width: w / 1.0,
                                                icon: MtPoppinsBold(
                                                  lineheight: 0.8,
                                                  text:
                                                      '${customer!.totalvisitsIOS}',
                                                  color: Mycolors.grey,
                                                  fontsize: 22,
                                                )),
                                          ],
                                          gridDelegate:
                                              SliverGridDelegateWithFixedCrossAxisCount(
                                                  crossAxisCount: 3,
                                                  childAspectRatio: 1.35,
                                                  mainAxisSpacing: 4,
                                                  crossAxisSpacing: 4),
                                          padding: EdgeInsets.all(2),
                                        ),
                                  decoration: boxDecoration(showShadow: true),
                                  height: 110,
                                  width: w / 1.1,
                                ),
                                //  Container(
                                //   child: Column(
                                //     mainAxisAlignment:
                                //         MainAxisAlignment.spaceEvenly,
                                //     children: [
                                //       Row(
                                //           mainAxisAlignment:
                                //               MainAxisAlignment.spaceAround,
                                //           children: [
                                //             eachcount(
                                //                 text: 'Audio Call Made',
                                //                 count:
                                //                     '${userDoc[Dbkeys.audiocallsmade]}'),
                                //             myverticaldivider(
                                //                 height: 50,
                                //                 color: Mycolors.greylightcolor),
                                //             eachcount(text: 'Video Calls'),
                                //             myverticaldivider(
                                //                 height: 50,
                                //                 color: Mycolors.greylightcolor),
                                //             eachcount(text: 'Media Sent'),
                                //           ]),
                                //       myvhorizontaldivider(width: w / 1.2),
                                //       Row(
                                //           mainAxisAlignment:
                                //               MainAxisAlignment.spaceAround,
                                //           children: [
                                //             eachcount(
                                //                 text: 'Audio Calls',
                                //                 count:
                                //                     '${userDoc[Dbkeys.audiocallsmade]}'),
                                //             myverticaldivider(
                                //                 height: 50,
                                //                 color: Mycolors.greylightcolor),
                                //             eachcount(text: 'Video Calls'),
                                //             myverticaldivider(
                                //                 height: 50,
                                //                 color: Mycolors.greylightcolor),
                                //             eachcount(text: 'Media Sent'),
                                //           ]),
                                //     ],
                                //   ),

                                // )
                              ),
                            ],
                          ),

                          customer!.isAccountDeletedbyAdmin == true
                              ? SizedBox()
                              : Padding(
                                  padding: EdgeInsets.all(20),
                                  child: observer.basicSettingUserApp == null
                                      ? SizedBox()
                                      : observer.basicSettingUserApp!
                                                      .loginTypeUserApp ==
                                                  "Email/Password" &&
                                              customer!.email == ""
                                          ? Column(
                                              children: [
                                                MtCustomfontBold(
                                                  lineheight: 1.2,
                                                  textalign: TextAlign.center,
                                                  text:
                                                      getTranslatedForCurrentUser(
                                                          this.context,
                                                          'xxxnoemaillinkedxxx'),
                                                  color: Mycolors.red,
                                                  fontsize: 13,
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets.all(
                                                      13.0),
                                                  child: MySimpleButtonWithIcon(
                                                    iconData: Icons.add,
                                                    buttoncolor:
                                                        Mycolors.orange,
                                                    buttontext:
                                                        getTranslatedForCurrentUser(
                                                            this.context,
                                                            'xxxaddemailxxx'),
                                                    onpressed: AppConstants
                                                                .isdemomode ==
                                                            true
                                                        ? () {
                                                            Utils.toast(
                                                                getTranslatedForCurrentUser(
                                                                    this.context,
                                                                    'xxxnotalwddemoxxaccountxx'));
                                                          }
                                                        : () async {
                                                            await updateEmail(
                                                                customer!
                                                                    .email);
                                                          },
                                                  ),
                                                )
                                              ],
                                            )
                                          : observer.basicSettingUserApp!
                                                          .loginTypeUserApp ==
                                                      "Phone" &&
                                                  customer!.phone == ""
                                              ? Column(
                                                  children: [
                                                    MtCustomfontBold(
                                                      lineheight: 1.2,
                                                      textalign:
                                                          TextAlign.center,
                                                      text: getTranslatedForCurrentUser(
                                                          this.context,
                                                          'xxxphonelinkedxxx'),
                                                      color: Mycolors.red,
                                                      fontsize: 13,
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              13.0),
                                                      child:
                                                          MySimpleButtonWithIcon(
                                                        iconData: Icons.add,
                                                        buttoncolor:
                                                            Mycolors.orange,
                                                        buttontext:
                                                            getTranslatedForCurrentUser(
                                                                this.context,
                                                                'xxxaddphonexxx'),
                                                        onpressed: AppConstants
                                                                    .isdemomode ==
                                                                true
                                                            ? () {
                                                                Utils.toast(getTranslatedForCurrentUser(
                                                                    this.context,
                                                                    'xxxnotalwddemoxxaccountxx'));
                                                              }
                                                            : () async {
                                                                await updateMobile(
                                                                    customer!
                                                                        .phone);
                                                              },
                                                      ),
                                                    )
                                                  ],
                                                )
                                              : SizedBox()),
                          customer!.isAccountDeletedbyAdmin == true
                              ? SizedBox()
                              : InputSwitch(
                                  onString: customer!.accountstatus ==
                                          Dbkeys.sTATUSallowed
                                      ? ' ${getTranslatedForCurrentUser(this.context, 'xxstatusxx')}:  ${getTranslatedForCurrentUser(this.context, 'xxxapprovedxxx')}'
                                      : customer!.accountstatus ==
                                              Dbkeys.sTATUSblocked
                                          ? ' ${getTranslatedForCurrentUser(this.context, 'xxstatusxx')}:  ${getTranslatedForCurrentUser(this.context, 'xxxblockedxxx')}'
                                          : customer!.accountstatus ==
                                                  Dbkeys.sTATUSallowed
                                              ? ' ${getTranslatedForCurrentUser(this.context, 'xxstatusxx')}:  ${getTranslatedForCurrentUser(this.context, 'xxxpendingapprovalxxx')}'
                                              : '',
                                  offString: customer!.accountstatus ==
                                          Dbkeys.sTATUSallowed
                                      ? ' ${getTranslatedForCurrentUser(this.context, 'xxstatusxx')}:  ${getTranslatedForCurrentUser(this.context, 'xxxapprovedxxx')}'
                                      : customer!.accountstatus ==
                                              Dbkeys.sTATUSblocked
                                          ? ' ${getTranslatedForCurrentUser(this.context, 'xxstatusxx')}:  ${getTranslatedForCurrentUser(this.context, 'xxxblockedxxx')}'
                                          : customer!.accountstatus ==
                                                  Dbkeys.sTATUSallowed
                                              ? ' ${getTranslatedForCurrentUser(this.context, 'xxstatusxx')}:  ${getTranslatedForCurrentUser(this.context, 'xxxpendingapprovalxxx')}'
                                              : '${getTranslatedForCurrentUser(this.context, 'xxstatusxx')}',
                                  initialbool: customer!.accountstatus ==
                                          Dbkeys.sTATUSallowed
                                      ? true
                                      : customer!.accountstatus ==
                                              Dbkeys.sTATUSblocked
                                          ? false
                                          : customer!.accountstatus ==
                                                  Dbkeys.sTATUSpending
                                              ? false
                                              : false,
                                  onChanged: AppConstants.isdemomode == true
                                      ? (val) {
                                          Utils.toast(
                                              getTranslatedForCurrentUser(
                                                  this.context,
                                                  'xxxnotalwddemoxxaccountxx'));
                                        }
                                      : (val) async {
                                          await confirmchangeswitch(
                                            this.context,
                                            customer!.accountstatus,
                                            customer!.id,
                                            customer!.nickname,
                                            customer!.photoUrl,
                                          );
                                        },
                                ),

                          customer!.isAccountDeletedbyAdmin == true
                              ? SizedBox()
                              : customer!.accountstatus ==
                                          Dbkeys.sTATUSblocked ||
                                      customer!.accountstatus ==
                                          Dbkeys.sTATUSpending
                                  ? Container(
                                      decoration: boxDecoration(
                                          radius: 7,
                                          color: Mycolors.orange,
                                          bgColor:
                                              Mycolors.orange.withOpacity(0.2)),
                                      width: w,
                                      margin: EdgeInsets.all(12),
                                      padding:
                                          EdgeInsets.fromLTRB(12, 15, 12, 15),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: [
                                          MtCustomfontBoldSemi(
                                            textalign: TextAlign.left,
                                            text:
                                                '${getTranslatedForCurrentUser(this.context, 'xxxuseralertmessagexxx')} - ',
                                            fontsize: 14,
                                            color: Colors.orange[800],
                                          ),
                                          Divider(),
                                          MtCustomfontBoldSemi(
                                              textalign: TextAlign.left,
                                              text: customer!.actionmessage,
                                              fontsize: 14,
                                              color: Mycolors.black,
                                              lineheight: 1.3)
                                        ],
                                      ),
                                    )
                                  : SizedBox(),

                          // Container(
                          //   color: Colors.white,
                          //   child: ListTile(
                          //     title: MtCustomfontMedium(
                          //       fontsize: 16,
                          //       color: Mycolors.black,
                          //       text: 'Send Notification',
                          //     ),

                          //     subtitle: MtCustomfontRegular(
                          //       text: 'Send Notification to this User Only',
                          //       fontsize: 13,
                          //     ),
                          //     trailing: Icon(Icons.keyboard_arrow_right),
                          //     leading: Icon(
                          //       EvaIcons.paperPlane,
                          //       color: Mycolors.primary,
                          //     ),
                          //     // isThreeLine: true,
                          //     onTap: () async {
                          //       await createNotificationID(
                          //           this.context, RandomDigits.getString(8));
                          //     },
                          //   ),
                          // ),
                          SizedBox(
                            height: 10,
                          ),
                          // Container(
                          //   color: Colors.white,
                          //   child: ListTile(
                          //     title: MtCustomfontMedium(
                          //       fontsize: 16,
                          //       color: Mycolors.black,
                          //       text: 'Call History',
                          //     ),

                          //     subtitle: MtCustomfontRegular(
                          //       text: 'See User Call Log',
                          //       fontsize: 13,
                          //     ),
                          //     trailing: Icon(Icons.keyboard_arrow_right),
                          //     leading: Icon(
                          //       EvaIcons.phoneCallOutline,
                          //       color: Mycolors.primary,
                          //     ),
                          //     // isThreeLine: true,
                          //     onTap: () async {
                          //       // pageNavigator(
                          //       //     this.context,
                          //       //     CallHistory(
                          //       //       userphone: userDoc[Dbkeys.uSERphone],
                          //       //       fullname: userDoc[Dbkeys.uSERfullname],
                          //       //     ));
                          //     },
                          //   ),
                          // ),
                          SizedBox(
                            height: 9,
                          ),

                          customer!.isAccountDeletedbyAdmin == true
                              ? SizedBox()
                              : Container(
                                  color: Colors.white,
                                  child: ListTile(
                                    title: Padding(
                                      padding: const EdgeInsets.only(top: 8),
                                      child: MtCustomfontBoldSemi(
                                        color: Mycolors.black,
                                        text: getTranslatedForCurrentUser(
                                            this.context, 'xxlastseenxx'),
                                        fontsize: 15.6,
                                      ),
                                    ),
                                    subtitle: Padding(
                                      padding: const EdgeInsets.only(top: 8),
                                      child: MtCustomfontRegular(
                                        color: Mycolors.grey,
                                        text: customer!.lastSeen == true
                                            ? getTranslatedForCurrentUser(
                                                this.context, 'xxonlinexx')
                                            : customer!.lastSeen != true
                                                ? formatTimeDateCOMLPETEString(
                                                    context: this.context,
                                                    timestamp:
                                                        customer!.lastSeen)
                                                : '--',
                                        fontsize: 12.8,
                                      ),
                                    ),
                                    leading: Icon(
                                      Icons.access_time_rounded,
                                      color: Mycolors.primary,
                                    ),
                                    trailing: customer!.lastSeen == true
                                        ? myinkwell(
                                            onTap: AppConstants.isdemomode ==
                                                    true
                                                ? () {
                                                    Utils.toast(
                                                        getTranslatedForCurrentUser(
                                                            this.context,
                                                            'xxxnotalwddemoxxaccountxx'));
                                                  }
                                                : () {
                                                    setAsOffline(this.context);
                                                  },
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: MtCustomfontBold(
                                                text:
                                                    getTranslatedForCurrentUser(
                                                        this.context,
                                                        'xxxsetasofflinexx'),
                                                fontsize: 12.6,
                                                color: Mycolors.primary,
                                              ),
                                            ),
                                          )
                                        : SizedBox(),
                                    isThreeLine: false,
                                    onTap: () {},
                                  )),
                          SizedBox(
                            height: 10,
                          ),
                          customer!.isAccountDeletedbyAdmin == true
                              ? SizedBox()
                              : Container(
                                  color: Colors.white,
                                  child: ListTile(
                                    title: Padding(
                                      padding: const EdgeInsets.only(top: 8),
                                      child: MtCustomfontBoldSemi(
                                        color: Mycolors.black,
                                        text: getTranslatedForCurrentUser(
                                            this.context, 'xxxjoinedonxxx'),
                                        fontsize: 15.6,
                                      ),
                                    ),
                                    subtitle: Padding(
                                      padding: const EdgeInsets.only(top: 8),
                                      child: MtCustomfontRegular(
                                        color: Mycolors.grey,
                                        text: formatTimeDateCOMLPETEString(
                                          context: this.context,
                                          timestamp: customer!.joinedOn,
                                        ),
                                        fontsize: 12.8,
                                      ),
                                    ),
                                    leading: Icon(
                                      Icons.access_time_rounded,
                                      color: Mycolors.primary,
                                    ),
                                    isThreeLine: false,
                                    onTap: () {},
                                  )),
                          SizedBox(
                            height: 10,
                          ),
                          customer!.isAccountDeletedbyAdmin == true
                              ? SizedBox()
                              : Container(
                                  color: Colors.white,
                                  child: ListTile(
                                    title: Padding(
                                      padding: const EdgeInsets.only(top: 8),
                                      child: MtCustomfontBoldSemi(
                                        color: Mycolors.black,
                                        text: getTranslatedForCurrentUser(
                                            this.context,
                                            'xxxaccountcreatedbyxxx'),
                                        fontsize: 15.6,
                                      ),
                                    ),
                                    subtitle: Padding(
                                      padding: const EdgeInsets.only(top: 8),
                                      child: MtCustomfontRegular(
                                        color: Mycolors.grey,
                                        text: customer!.accountcreatedby == ""
                                            ? getTranslatedForCurrentUser(
                                                this.context, 'xxcustomerxx')
                                            : customer!.accountcreatedby,
                                        fontsize: 12.8,
                                      ),
                                    ),
                                    leading: Icon(
                                      Icons.person,
                                      color: Mycolors.primary,
                                    ),
                                    isThreeLine: false,
                                    onTap: () {},
                                  )),
                          SizedBox(
                            height: 18,
                          ),

                          customer!.isAccountDeletedbyAdmin == true
                              ? SizedBox()
                              : customer!.deviceDetails.isEmpty
                                  ? SizedBox()
                                  : Container(
                                      margin: EdgeInsets.all(10),
                                      padding:
                                          EdgeInsets.fromLTRB(12, 20, 12, 20),
                                      decoration:
                                          boxDecoration(showShadow: true),
                                      child: Column(children: [
                                        MtCustomfontMedium(
                                          text: getTranslatedForCurrentUser(
                                              this.context,
                                              'xxxuserdeviceindoxxx'),
                                          color: Mycolors.primary,
                                          fontsize: 15,
                                        ),
                                        myvhorizontaldivider(
                                            width: w, marginheight: 14),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Container(
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    Icons.phone_iphone,
                                                    color: Mycolors.secondary,
                                                    size: 22,
                                                  ),
                                                  SizedBox(
                                                    width: 10,
                                                  ),
                                                  MtCustomfontRegular(
                                                    text: customer!
                                                                .deviceDetails[
                                                            Dbkeys
                                                                .deviceInfoMANUFACTURER] +
                                                        ' ' +
                                                        customer!.deviceDetails[
                                                            Dbkeys
                                                                .deviceInfoMODEL],
                                                    color: Mycolors.grey,
                                                    fontsize: 14,
                                                  ),
                                                ],
                                              ),
                                            ),
                                            // customer!.deviceDetails[
                                            //             Dbkeys.deviceInfoOS] ==
                                            //         'android'
                                            //     ? Icon(
                                            //         Icons.android,
                                            //         color: Color(0xFFA0C034),
                                            //       )
                                            //     : Image.asset(
                                            //         'assets/COMMON_ASSETS/apple.png',
                                            //         height: 20,
                                            //       ),
                                          ],
                                        ),
                                        SizedBox(
                                          height: 12,
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Container(
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    Icons
                                                        .check_circle_outline_rounded,
                                                    color: Mycolors.secondary,
                                                    size: 22,
                                                  ),
                                                  SizedBox(
                                                    width: 10,
                                                  ),
                                                  MtCustomfontRegular(
                                                    text: getTranslatedForCurrentUser(
                                                        this.context,
                                                        'xxxphysicalrealdevicexxx'),
                                                    color: Mycolors.grey,
                                                    fontsize: 14,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                          height: 12,
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Container(
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    Icons.access_time,
                                                    color: Mycolors.secondary,
                                                    size: 21,
                                                  ),
                                                  SizedBox(
                                                    width: 10,
                                                  ),
                                                  MtCustomfontRegular(
                                                    text: '${getTranslatedForCurrentUser(this.context, 'xxxlastloginxxx')} - ' +
                                                        formatTimeDateCOMLPETEString(
                                                            context:
                                                                this.context,
                                                            timestamp: customer!
                                                                    .deviceDetails[
                                                                Dbkeys
                                                                    .deviceInfoLOGINTIMESTAMP]),
                                                    color: Mycolors.grey,
                                                    fontsize: 14,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ]),
                                    ),
                          SizedBox(
                            height: 10,
                          ),
                          customer!.isAccountDeletedbyAdmin == true
                              ? SizedBox()
                              : Container(
                                  color: Colors.white,
                                  child: ListTile(
                                    title: MtCustomfontMedium(
                                      fontsize: 16,
                                      color: Mycolors.black,
                                      text: 'Firebase UID',
                                    ),

                                    subtitle: MtCustomfontRegular(
                                      text: AppConstants.isdemomode == true
                                          ? '****************'
                                          : customer!.firebaseuid,
                                      fontsize: 13,
                                    ),
                                    trailing: Icon(Icons.copy_outlined),
                                    leading: Icon(
                                      EvaIcons.personDoneOutline,
                                      color: Mycolors.primary,
                                    ),
                                    // isThreeLine: true,
                                    onTap: AppConstants.isdemomode == true
                                        ? () {
                                            Utils.toast(
                                                getTranslatedForCurrentUser(
                                                    this.context,
                                                    'xxxnotalwddemoxxaccountxx'));
                                          }
                                        : () async {
                                            Clipboard.setData(new ClipboardData(
                                              text: customer!.firebaseuid,
                                            ));
                                            Utils.toast('Copied to Clipboard');
                                          },
                                  ),
                                ),
                          SizedBox(
                            height: 10,
                          ),

                          customer!.isAccountDeletedbyAdmin == true
                              ? SizedBox()
                              : Container(
                                  color: Colors.white,
                                  child: ListTile(
                                    title: Padding(
                                      padding: const EdgeInsets.only(top: 8),
                                      child: MtCustomfontBoldSemi(
                                        color: Mycolors.black,
                                        text: getTranslatedForCurrentUser(
                                            this.context,
                                            'xxcurrentloginstxxx'),
                                        fontsize: 15.6,
                                      ),
                                    ),
                                    subtitle: Padding(
                                      padding: const EdgeInsets.only(top: 8),
                                      child: MtCustomfontBoldSemi(
                                        color: customer!.currentDeviceID == ""
                                            ? Mycolors.red
                                            : Mycolors.onlinetag,
                                        text: customer!.currentDeviceID == ""
                                            ? getTranslatedForCurrentUser(
                                                this.context, 'xxxloggedoutxxx')
                                            : getTranslatedForCurrentUser(
                                                this.context, 'xxxloggedinxxx'),
                                        fontsize: 12.8,
                                      ),
                                    ),
                                    trailing: customer!.currentDeviceID == ""
                                        ? SizedBox()
                                        : myinkwell(
                                            onTap:
                                                AppConstants.isdemomode == true
                                                    ? () {
                                                        Utils.toast(
                                                            getTranslatedForCurrentUser(
                                                                this.context,
                                                                'xxxnotalwddemoxxaccountxx'));
                                                      }
                                                    : () {
                                                        String currentdeviceName = customer!
                                                                .deviceDetails
                                                                .isEmpty
                                                            ? "UnKnown Device"
                                                            : customer!.deviceDetails[
                                                                    Dbkeys
                                                                        .deviceInfoMANUFACTURER] +
                                                                ' ' +
                                                                customer!
                                                                        .deviceDetails[
                                                                    Dbkeys
                                                                        .deviceInfoMODEL];

                                                        ShowConfirmWithInputTextDialog()
                                                            .open(
                                                                context: this
                                                                    .context,
                                                                title: getTranslatedForCurrentUser(
                                                                    this
                                                                        .context,
                                                                    'xxxforcelogoutxxx'),
                                                                controller:
                                                                    _name,
                                                                subtitle: getTranslatedForCurrentUser(
                                                                    this
                                                                        .context,
                                                                    'xxxforcelogoutdescxxx'),
                                                                rightbtntext: getTranslatedForCurrentUser(
                                                                        this
                                                                            .context,
                                                                        'xxlogoutxx')
                                                                    .toUpperCase(),
                                                                rightbtnonpress:
                                                                    AppConstants.isdemomode ==
                                                                            true
                                                                        ? () {
                                                                            Utils.toast(getTranslatedForCurrentUser(this.context,
                                                                                'xxxnotalwddemoxxaccountxx'));
                                                                          }
                                                                        : () async {
                                                                            Navigator.of(context).pop();
                                                                            ShowLoading().open(
                                                                                context: this.context,
                                                                                key: _keyLoader);
                                                                            await Utils.sendDirectNotification(
                                                                                title: getTranslatedForCurrentUser(this.context, 'xxxaccountloggedoutxxx'),
                                                                                parentID: "CUSTOMER--${customer!.id}",
                                                                                plaindesc: _name.text.trim().length < 1 ? getTranslatedForCurrentUser(this.context, 'xxxaccountforcedloggedoutxxx').replaceAll('(####)', '$currentdeviceName') : getTranslatedForCurrentUser(this.context, 'xxxaccountforcedloggedoutxxx').replaceAll('(####)', '$currentdeviceName') + "${getTranslatedForCurrentUser(this.context, 'xxreasonxxx')} ${_name.text.trim()}",
                                                                                docRef: FirebaseFirestore.instance.collection(DbPaths.collectioncustomers).doc(customer!.id).collection(DbPaths.customernotifications).doc(DbPaths.customernotifications),
                                                                                postedbyID: 'Admin');
                                                                            await colRef.doc(customer!.id).update({
                                                                              Dbkeys.currentDeviceID: "",
                                                                              Dbkeys.notificationTokens: []
                                                                            });
                                                                            await FirebaseApi.runTransactionRecordActivity(
                                                                              parentid: "CUSTOMER--${customer!.id}",
                                                                              title: getTranslatedForCurrentUser(this.context, 'xxxaccountloggedoutxxx'),
                                                                              postedbyID: "sys",
                                                                              onErrorFn: (e) {
                                                                                ShowLoading().close(key: _keyLoader, context: context);
                                                                                Utils.toast("${getTranslatedForCurrentUser(this.context, 'xxxfailedntryagainxxx')} ERROR: $e");
                                                                              },
                                                                              onSuccessFn: () async {
                                                                                ShowLoading().close(key: _keyLoader, context: context);
                                                                                await fetchCustomer(customerId: customer!.id);

                                                                                Utils.toast(getTranslatedForCurrentUser(this.context, 'xxxuserloggedoutxxx'));
                                                                              },
                                                                              styledDesc: '<bold>${getTranslatedForCurrentUser(this.context, 'xxcustomerxx')} ${getTranslatedForCurrentUser(this.context, 'xxidxx')} ${customer!.id}</bold> ${getTranslatedForCurrentUser(this.context, 'xxxaccountforcedloggedoutxxx').replaceAll('(####)', '<bold>$currentdeviceName</bold>')}',
                                                                              plainDesc: '${getTranslatedForCurrentUser(this.context, 'xxcustomerxx')} ${getTranslatedForCurrentUser(this.context, 'xxidxx')} ${customer!.id} ${getTranslatedForCurrentUser(this.context, 'xxxaccountforcedloggedoutxxx').replaceAll('(####)', '$currentdeviceName')}',
                                                                            );
                                                                          });
                                                      },
                                            child: MtCustomfontBold(
                                              text: getTranslatedForCurrentUser(
                                                  this.context,
                                                  'xxxforcelogoutxxx'),
                                              color: Mycolors.red,
                                              fontsize: 13,
                                            ),
                                          ),
                                    leading: Icon(
                                      Icons.key,
                                      color: Mycolors.primary,
                                    ),
                                    isThreeLine: false,
                                    onTap: () {},
                                  )),
                          SizedBox(
                            height: 10,
                          ),

                          customer!.isAccountDeletedbyAdmin == true
                              ? SizedBox()
                              : customer!.currentDeviceID == ""
                                  ? SizedBox()
                                  : Container(
                                      color: Colors.white,
                                      child: ListTile(
                                        title: Padding(
                                          padding:
                                              const EdgeInsets.only(top: 8),
                                          child: MtCustomfontBoldSemi(
                                            color: Mycolors.black,
                                            text: getTranslatedForCurrentUser(
                                                this.context,
                                                'xxnotificationstatusxxx'),
                                            fontsize: 15.6,
                                          ),
                                        ),
                                        subtitle: Padding(
                                          padding:
                                              const EdgeInsets.only(top: 8),
                                          child: MtCustomfontBoldSemi(
                                            color:
                                                customer!.notificationTokens ==
                                                        []
                                                    ? Mycolors.pink
                                                    : Mycolors.onlinetag,
                                            text: customer!
                                                        .notificationTokens ==
                                                    []
                                                ? getTranslatedForCurrentUser(
                                                        this.context,
                                                        'xxxmutedxxx')
                                                    .toUpperCase()
                                                : getTranslatedForCurrentUser(
                                                        this.context,
                                                        'xxactivexx')
                                                    .toUpperCase(),
                                            fontsize: 12.8,
                                          ),
                                        ),
                                        leading: Icon(
                                          Icons.notifications,
                                          color: Mycolors.primary,
                                        ),
                                        isThreeLine: false,
                                        onTap: () {},
                                      )),

                          SizedBox(
                            height: 30,
                          ),
                          customer!.isAccountDeletedbyAdmin == true
                              ? SizedBox()
                              : Padding(
                                  padding: const EdgeInsets.all(18.0),
                                  child: MySimpleButton(
                                    onpressed: AppConstants.isdemomode == true
                                        ? () {
                                            Utils.toast(
                                                getTranslatedForCurrentUser(
                                                    this.context,
                                                    'xxxnotalwddemoxxaccountxx'));
                                          }
                                        : () async {
                                            ShowConfirmWithInputTextDialog()
                                                .open(
                                                    controller: _controller,
                                                    rightbtntext:
                                                        getTranslatedForCurrentUser(
                                                            this.context,
                                                            'xxdeletexx'),
                                                    leftbtntext:
                                                        getTranslatedForCurrentUser(
                                                            this.context,
                                                            'xxcancelxx'),
                                                    context: this.context,
                                                    title:
                                                        getTranslatedForCurrentUser(
                                                            this.context,
                                                            'xxdeleteaccountxx'),
                                                    subtitle:
                                                        getTranslatedForCurrentUser(
                                                            this.context,
                                                            'xxdeleteaccountdescxx'),
                                                    rightbtnonpress: () async {
                                                      Navigator.of(this.context)
                                                          .pop();
                                                      ShowLoading().open(
                                                          context: this.context,
                                                          key: _keyLoader);
                                                      try {
                                                        var id = customer!.id;
                                                        var reason = _controller
                                                            .text
                                                            .trim();

                                                        String photourl =
                                                            customer!.photoUrl;

                                                        ///--------
                                                        if (photourl != "") {
                                                          try {
                                                            await FirebaseStorage
                                                                .instance
                                                                .refFromURL(
                                                                    photourl)
                                                                .delete();
                                                          } catch (e) {}
                                                        }
//------delete support tkts
                                                        await FirebaseFirestore
                                                            .instance
                                                            .collection(DbPaths
                                                                .collectiontickets)
                                                            .where(
                                                                Dbkeys
                                                                    .ticketcustomerID,
                                                                isEqualTo: id)
                                                            .get()
                                                            .then(
                                                                (value) async {
                                                          for (var d
                                                              in value.docs) {
                                                            await d.reference
                                                                .delete();
                                                          }
                                                        });

//-----------
                                                        await FirebaseFirestore
                                                            .instance
                                                            .collection(DbPaths
                                                                .collectioncustomers)
                                                            .doc(id)
                                                            .update({
                                                          Dbkeys.isAccountDeletedbyAdmin:
                                                              true,
                                                          Dbkeys.actionmessage:
                                                              reason == ""
                                                                  ? "Account Deleted By Admin"
                                                                  : reason,
                                                          Dbkeys.searchKey: "C",
                                                          Dbkeys.email: "",
                                                          Dbkeys.phone: "",
                                                          Dbkeys.phoneRaw: "",
                                                          Dbkeys.countryCode:
                                                              "",
                                                          Dbkeys.phonenumbervariants:
                                                              [],
                                                          Dbkeys.searchKey: "C",
                                                          Dbkeys.currentDeviceID:
                                                              "",
                                                          Dbkeys.notificationTokens:
                                                              [],
                                                          Dbkeys.nickname:
                                                              "Customer ID: $id (Deleted)",
                                                          Dbkeys.photoUrl: "",
                                                        });

                                                        String shortname =
                                                            "Customer ID: $id (Deleted)";

                                                        await FirebaseApi
                                                            .runUPDATEmapobjectinListField(
                                                                docrefdata: FirebaseFirestore
                                                                    .instance
                                                                    .collection(
                                                                        DbPaths
                                                                            .userapp)
                                                                    .doc(DbPaths
                                                                        .registry),
                                                                compareKey: Dbkeys
                                                                    .rgstUSERID,
                                                                compareVal:
                                                                    customer!
                                                                        .id,
                                                                onErrorFn:
                                                                    (err) {
                                                                  ShowLoading().close(
                                                                      context: this
                                                                          .context,
                                                                      key:
                                                                          _keyLoader);

                                                                  Utils.toast(getTranslatedForCurrentUser(
                                                                          this.context,
                                                                          'xxfailedxx') +
                                                                      err.toString());
                                                                },
                                                                replaceableMapObjectWithOnlyFieldsRequired: {
                                                                  Dbkeys.rgstUSERID:
                                                                      customer!
                                                                          .id,
                                                                  Dbkeys.rgstFULLNAME:
                                                                      shortname,
                                                                  Dbkeys.rgstSHORTNAME:
                                                                      shortname,
                                                                },
                                                                onSuccessFn:
                                                                    () async {
                                                                  await FirebaseApi
                                                                      .runTransactionRecordActivity(
                                                                    parentid:
                                                                        "CUSTOMER--${customer!.id}",
                                                                    title:
                                                                        "${getTranslatedForCurrentUser(this.context, 'xxcustomerxx')}${getTranslatedForCurrentUser(this.context, 'xxaccountdeletedxx')}",
                                                                    postedbyID:
                                                                        "sys",
                                                                    onErrorFn:
                                                                        (e) {
                                                                      ShowLoading().close(
                                                                          key:
                                                                              _keyLoader,
                                                                          context:
                                                                              this.context);
                                                                      Utils.toast(
                                                                          "${getTranslatedForCurrentUser(this.context, 'xxfailedxx')}" +
                                                                              "$e");
                                                                    },
                                                                    onSuccessFn:
                                                                        () {},
                                                                    styledDesc:
                                                                        '${getTranslatedForCurrentUser(this.context, 'xxcustomerxx')} ${getTranslatedForCurrentUser(this.context, 'xxidxx')} ${customer!.id} ${getTranslatedForCurrentUser(this.context, 'xxaccountdeletedxx')}.',
                                                                    plainDesc:
                                                                        '${getTranslatedForCurrentUser(this.context, 'xxcustomerxx')} ${getTranslatedForCurrentUser(this.context, 'xxidxx')} ${customer!.id} ${getTranslatedForCurrentUser(this.context, 'xxaccountdeletedxx')}.',
                                                                  );

                                                                  final firestore = Provider.of<
                                                                          FirestoreDataProviderCUSTOMERS>(
                                                                      this
                                                                          .context,
                                                                      listen:
                                                                          false);
                                                                  firestore.fetchNextData(
                                                                      Dbkeys
                                                                          .dataTypeCUSTOMERS,
                                                                      colRef
                                                                          .orderBy(
                                                                              Dbkeys.joinedOn,
                                                                              descending: true)
                                                                          .limit(Numberlimits.totalDatatoLoadAtOnceFromFirestore),
                                                                      true);

                                                                  await FirebaseFirestore
                                                                      .instance
                                                                      .collection(
                                                                          DbPaths
                                                                              .collectioncustomers)
                                                                      .doc(customer!
                                                                          .id)
                                                                      .get()
                                                                      .then(
                                                                          (doc) {
                                                                    customer = CustomerModel
                                                                        .fromSnapshot(
                                                                            doc);
                                                                    setState(
                                                                        () {});
                                                                  });
                                                                  ShowLoading().close(
                                                                      key:
                                                                          _keyLoader,
                                                                      context: this
                                                                          .context);
                                                                  Utils.toast(
                                                                      " ${getTranslatedForCurrentUser(this.context, 'xxaccountdeletedxx')}");
                                                                }).catchError(
                                                            (e) {
                                                          ShowLoading().close(
                                                              context:
                                                                  this.context,
                                                              key: _keyLoader);

                                                          Utils.toast(
                                                              "${getTranslatedForCurrentUser(this.context, 'xxfailedxx')}" +
                                                                  e.toString());
                                                        });
                                                      } catch (e) {
                                                        ShowLoading().close(
                                                            context:
                                                                this.context,
                                                            key: _keyLoader);
                                                        ShowSnackbar().open(
                                                            scaffoldKey:
                                                                _scaffoldKey,
                                                            context:
                                                                this.context,
                                                            label: "Failed $e");
                                                      }
                                                    });
                                          },
                                    buttoncolor: Mycolors.red,
                                    buttontext: getTranslatedForCurrentUser(
                                        this.context, 'xxdeleteaccountxx'),
                                  ),
                                ),
                          SizedBox(
                            height: 30,
                          ),
                        ],
                      ))))),
    );
  }
}
