import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:thinkcreative_technologies/Configs/app_constants.dart';
import 'package:thinkcreative_technologies/Configs/db_keys.dart';
import 'package:thinkcreative_technologies/Configs/db_paths.dart';
import 'package:thinkcreative_technologies/Configs/enum.dart';
import 'package:thinkcreative_technologies/Localization/language_constants.dart';
import 'package:thinkcreative_technologies/Models/basic_settings_model_adminapp.dart';
import 'package:thinkcreative_technologies/Models/basic_settings_model_userapp.dart';
import 'package:thinkcreative_technologies/Models/userapp_settings_model.dart';
import 'package:thinkcreative_technologies/Screens/initialization/initialization_constant.dart';
import 'package:thinkcreative_technologies/Utils/utils.dart';

class Observer with ChangeNotifier {
  bool? isgeolocationprefered = false;
  bool? islocationeditallowed = false;
  bool? isgeolocationmandatory = false;
  bool? isshowerrorlog = false;
  String? privacypolicy;
  String? tnc;
  BasicSettingModelAdminApp? basicSettingDoc;
  BasicSettingModelUserApp? basicSettingUserApp;
  UserAppSettingsModel? userAppSettingsDoc;

  setbasicsettings({
    BasicSettingModelAdminApp? basicModel,
  }) {
    this.basicSettingDoc = basicModel ?? this.basicSettingDoc;
    notifyListeners();
  }

  fetchUserAppSettings(BuildContext context) async {
    // Utils.toast("FETCHING SETTINGS !");
    await InitializationConstant.k12.get().then((doc) {
      if (doc.exists) {
        userAppSettingsDoc = UserAppSettingsModel.fromSnapshot(doc);
        notifyListeners();
      } else {
        Utils.toast(
            "INSTALLATION PENDING ! ${getTranslatedForCurrentUser(context, 'xxuserappsetupincompletexx')}");
      }
    });

    await FirebaseFirestore.instance
        .collection(InitializationConstant.k9)
        .doc(InitializationConstant.k14)
        .get()
        .then((dc) async {
      if (dc.exists) {
        String decoded = utf8.decode(base64.decode(dc["f9846v"]));
        // try parse the http json response
        var jsonobject = json.decode(decoded) as Map<String, dynamic>;
        basicSettingUserApp = BasicSettingModelUserApp.fromJson(jsonobject);
        notifyListeners();
      } else {
        Utils.toast(
            "INSTALLATION PENDING ! Unable to fetch Basic Settings userapp in Observer");
      }
    }).catchError((onError) {
      Utils.toast(
          "INSTALLATION PENDING ! Unable to fetch Basic Settings userapp in Observer, ERROR: $onError");
    });
  }

  setObserver({
    bool? isgeolocationpreferedforuser,
    bool? islocationeditforuser,
    bool? isgeolocationmandatoryforuser,
    bool? isshowerrorloguser,
    String? ncoversionrate,
    String? nprivacypolicy,
    String? ntnc,
  }) {
    this.islocationeditallowed = islocationeditforuser;
    this.isgeolocationprefered = isgeolocationpreferedforuser;
    this.isgeolocationmandatory = isgeolocationmandatoryforuser;
    this.isshowerrorlog = isshowerrorloguser;
    this.privacypolicy = nprivacypolicy;
    this.tnc = ntnc;
    notifyListeners();
  }

  deleteAllOldAgentMessages(var chatid) async {
    if (AppConstants.isdemomode == false) {
      String timestampKey = Dbkeys.timestamp;
      String mssgTypeKey = Dbkeys.messageType;
      if (userAppSettingsDoc!.defaultMessageDeletingTimeForOneToOneChat != 0) {
        await FirebaseFirestore.instance
            .collection(DbPaths.collectionAgentIndividiualmessages)
            .doc(chatid)
            .collection(chatid)
            .where(timestampKey,
                isLessThan: DateTime.now()
                    .subtract(Duration(
                        days: userAppSettingsDoc!
                            .defaultMessageDeletingTimeForOneToOneChat!))
                    .millisecondsSinceEpoch)
            .get()
            .then((mssgs) async {
          for (var mssg in mssgs.docs) {
            if (mssg[mssgTypeKey] == MessageType.audio.index) {
              var ref = FirebaseStorage.instance
                  .refFromURL(mssg[Dbkeys.content].split('-BREAK-')[0]);
              await ref.delete();
              await mssg.reference.delete();
              print("DELETED OLD MSSG -  " + mssg[timestampKey].toString());
            } else if (mssg[mssgTypeKey] == MessageType.video.index) {
              var ref0 = FirebaseStorage.instance
                  .refFromURL(mssg[Dbkeys.content].split('-BREAK-')[0]);
              var ref1 = FirebaseStorage.instance
                  .refFromURL(mssg[Dbkeys.content].split('-BREAK-')[1]);
              await ref0.delete();
              await ref1.delete();
              await mssg.reference.delete();
              print("DELETED OLD MSSG -  " + mssg[timestampKey].toString());
            } else if (mssg[mssgTypeKey] == MessageType.image.index) {
              if (mssg[Dbkeys.content].contains('giphy')) {
                await mssg.reference.delete();
                print("DELETED OLD MSSG -  " + mssg[timestampKey].toString());
              } else {
                var ref =
                    FirebaseStorage.instance.refFromURL(mssg[Dbkeys.content]);
                await ref.delete();
                await mssg.reference.delete();
                print("DELETED OLD MSSG -  " + mssg[timestampKey].toString());
              }
            } else if (mssg[mssgTypeKey] == MessageType.doc.index) {
              var ref = FirebaseStorage.instance
                  .refFromURL(mssg[Dbkeys.content].split('-BREAK-')[0]);
              await ref.delete();
              await mssg.reference.delete();
              print("DELETED OLD MSSG -  " + mssg[timestampKey].toString());
            } else if (mssg[mssgTypeKey] == MessageType.location.index) {
              await mssg.reference.delete();
              print("DELETED OLD MSSG -  " + mssg[timestampKey].toString());
            } else if (mssg[mssgTypeKey] == MessageType.text.index) {
              await mssg.reference.delete();
              print("DELETED OLD MSSG -  " + mssg[timestampKey].toString());
            } else {
              await mssg.reference.delete();
              print("DELETED OLD MSSG -  " + mssg[timestampKey].toString());
            }
          }
        });
      }
    }
  }

  deleteAllOldAgentGroupMessages(var chatid) async {
    if (AppConstants.isdemomode == false) {
      String timestampKey = Dbkeys.groupmsgTIME;
      String mssgTypeKey = Dbkeys.groupmsgTYPE;
      if (userAppSettingsDoc!.defaultMessageDeletingTimeForGroup != 0) {
        await FirebaseFirestore.instance
            .collection(DbPaths.collectionAgentGroups)
            .doc(chatid)
            .collection(DbPaths.collectiongroupChats)
            .where(timestampKey,
                isLessThan: DateTime.now()
                    .subtract(Duration(
                        days: userAppSettingsDoc!
                            .defaultMessageDeletingTimeForGroup!))
                    .millisecondsSinceEpoch)
            .get()
            .then((mssgs) async {
          for (var mssg in mssgs.docs) {
            if (mssg[mssgTypeKey] == MessageType.audio.index) {
              var ref = FirebaseStorage.instance
                  .refFromURL(mssg[Dbkeys.groupmsgCONTENT].split('-BREAK-')[0]);
              await ref.delete();
              await mssg.reference.delete();
              print("DELETED OLD MSSG -  " + mssg[timestampKey].toString());
            } else if (mssg[mssgTypeKey] == MessageType.video.index) {
              var ref0 = FirebaseStorage.instance
                  .refFromURL(mssg[Dbkeys.groupmsgCONTENT].split('-BREAK-')[0]);
              var ref1 = FirebaseStorage.instance
                  .refFromURL(mssg[Dbkeys.groupmsgCONTENT].split('-BREAK-')[1]);
              await ref0.delete();
              await ref1.delete();
              await mssg.reference.delete();
              print("DELETED OLD MSSG -  " + mssg[timestampKey].toString());
            } else if (mssg[mssgTypeKey] == MessageType.image.index) {
              if (mssg[Dbkeys.groupmsgCONTENT].contains('giphy')) {
                await mssg.reference.delete();
              } else {
                var ref = FirebaseStorage.instance
                    .refFromURL(mssg[Dbkeys.groupmsgCONTENT]);
                await ref.delete();
                await mssg.reference.delete();
                print("DELETED OLD MSSG -  " + mssg[timestampKey].toString());
              }
            } else if (mssg[mssgTypeKey] == MessageType.doc.index) {
              var ref = FirebaseStorage.instance
                  .refFromURL(mssg[Dbkeys.groupmsgCONTENT].split('-BREAK-')[0]);
              await ref.delete();
              await mssg.reference.delete();
              print("DELETED OLD MSSG -  " + mssg[timestampKey].toString());
            } else if (mssg[mssgTypeKey] == MessageType.location.index) {
              await mssg.reference.delete();
              print("DELETED OLD MSSG -  " + mssg[timestampKey].toString());
            } else if (mssg[mssgTypeKey] == MessageType.text.index) {
              await mssg.reference.delete();
              print("DELETED OLD MSSG -  " + mssg[timestampKey].toString());
            } else {
              await mssg.reference.delete();
              print("DELETED OLD MSSG -  " + mssg[timestampKey].toString());
            }
          }
        });
      }
    }
  }

  deleteAllOldTicketChatroom(var chatid, var isClosed) async {
    if (AppConstants.isdemomode == false) {
      String timestampKey = Dbkeys.tktMssgTIME;
      String mssgTypeKey = Dbkeys.tktMssgTYPE;
      if (userAppSettingsDoc!.defaultTicketMssgsDeletingTimeAfterClosing != 0 &&
          isClosed == true) {
        await FirebaseFirestore.instance
            .collection(DbPaths.collectiontickets)
            .doc(chatid)
            .collection(DbPaths.collectionticketChats)
            .where(timestampKey,
                isLessThan: DateTime.now()
                    .subtract(Duration(
                        days: userAppSettingsDoc!
                            .defaultTicketMssgsDeletingTimeAfterClosing!))
                    .millisecondsSinceEpoch)
            .get()
            .then((mssgs) async {
          for (var mssg in mssgs.docs) {
            if (mssg[mssgTypeKey] == MessageType.audio.index) {
              var ref = FirebaseStorage.instance
                  .refFromURL(mssg[Dbkeys.tktMssgCONTENT].split('-BREAK-')[0]);
              await ref.delete();
              await mssg.reference.delete();
              print("DELETED OLD MSSG -  " + mssg[timestampKey].toString());
            } else if (mssg[mssgTypeKey] == MessageType.video.index) {
              var ref0 = FirebaseStorage.instance
                  .refFromURL(mssg[Dbkeys.tktMssgCONTENT].split('-BREAK-')[0]);
              var ref1 = FirebaseStorage.instance
                  .refFromURL(mssg[Dbkeys.tktMssgCONTENT].split('-BREAK-')[1]);
              await ref0.delete();
              await ref1.delete();
              await mssg.reference.delete();
              print("DELETED OLD MSSG -  " + mssg[timestampKey].toString());
            } else if (mssg[mssgTypeKey] == MessageType.image.index) {
              if (mssg[Dbkeys.tktMssgCONTENT].contains('giphy')) {
                await mssg.reference.delete();
                print("DELETED OLD MSSG -  " + mssg[timestampKey].toString());
              } else {
                var ref = FirebaseStorage.instance
                    .refFromURL(mssg[Dbkeys.tktMssgCONTENT]);
                await ref.delete();
                await mssg.reference.delete();
                print("DELETED OLD MSSG -  " + mssg[timestampKey].toString());
              }
            } else if (mssg[mssgTypeKey] == MessageType.doc.index) {
              var ref = FirebaseStorage.instance
                  .refFromURL(mssg[Dbkeys.tktMssgCONTENT].split('-BREAK-')[0]);
              await ref.delete();
              await mssg.reference.delete();
              print("DELETED OLD MSSG -  " + mssg[timestampKey].toString());
            } else if (mssg[mssgTypeKey] == MessageType.location.index) {
              await mssg.reference.delete();
              print("DELETED OLD MSSG -  " + mssg[timestampKey].toString());
            } else if (mssg[mssgTypeKey] == MessageType.text.index) {
              await mssg.reference.delete();
              print("DELETED OLD MSSG -  " + mssg[timestampKey].toString());
            } else {
              await mssg.reference.delete();
              print("DELETED OLD MSSG -  " + mssg[timestampKey].toString());
            }
          }
        });
      }
    }
  }
}
