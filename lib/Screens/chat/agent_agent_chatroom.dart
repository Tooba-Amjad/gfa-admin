import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:thinkcreative_technologies/Configs/app_constants.dart';
import 'package:thinkcreative_technologies/Configs/db_keys.dart';
import 'package:thinkcreative_technologies/Configs/db_paths.dart';
import 'package:thinkcreative_technologies/Configs/enum.dart';
import 'package:thinkcreative_technologies/Configs/my_colors.dart';
import 'package:thinkcreative_technologies/Localization/language_constants.dart';
import 'package:thinkcreative_technologies/Screens/chat/chat_bubble.dart';
import 'package:thinkcreative_technologies/Services/firebase_services/FirebaseApi.dart';
import 'package:thinkcreative_technologies/Services/my_providers/firestore_collections_data_admin.dart';
import 'package:thinkcreative_technologies/Services/my_providers/observer.dart';
import 'package:thinkcreative_technologies/Utils/utils.dart';
import 'package:thinkcreative_technologies/Widgets/InfiniteList/InfiniteCOLLECTIONListViewWidgetAdmin.dart';
import 'package:thinkcreative_technologies/Widgets/WarningWidgets/warning_tile.dart';
import 'package:thinkcreative_technologies/Widgets/dialogs/CustomDialog.dart';
import 'package:thinkcreative_technologies/Widgets/my_scaffold.dart';

class AgentToAgentChatRoom extends StatefulWidget {
  final Function onDelete;
  final String chatroomID;
  final String lhsUserName;
  final String lhsUserPhoto;
  final String lhsUserID;
  final String rhsUserName;
  final String rhsUserPhoto;
  final String rhsUserID;
  final chatRoomDoc;
  const AgentToAgentChatRoom(
      {Key? key,
      required this.chatroomID,
      required this.onDelete,
      required this.lhsUserPhoto,
      required this.lhsUserName,
      required this.lhsUserID,
      required this.rhsUserName,
      required this.rhsUserPhoto,
      required this.chatRoomDoc,
      required this.rhsUserID})
      : super(key: key);

  @override
  State<AgentToAgentChatRoom> createState() => _AgentToAgentChatRoomState();
}

class _AgentToAgentChatRoomState extends State<AgentToAgentChatRoom> {
  final GlobalKey<State> _keyLoader3q2 =
      new GlobalKey<State>(debugLabel: '000fsdfd0');
  final _reason = TextEditingController();

  var chatroomDoc;
  @override
  void initState() {
    super.initState();
    chatroomDoc = widget.chatRoomDoc;
    deleteAllOldMssgs();
  }

  deleteAllOldMssgs() async {
    var observer = Provider.of<Observer>(this.context, listen: false);
    await observer.deleteAllOldAgentMessages(
      widget.chatroomID,
    );
  }

  @override
  void dispose() {
    super.dispose();
    _reason.dispose();
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    final observer = Provider.of<Observer>(this.context, listen: true);
    return MyScaffold(
      iconWidget: Row(
        children: [
          IconButton(
              onPressed: () {
                final provider = Provider.of<FirestoreDataProviderCHATMESSAGES>(
                    this.context,
                    listen: false);

                FirebaseFirestore.instance
                    .collection(DbPaths.collectionAgentIndividiualmessages)
                    .doc(widget.chatroomID)
                    .get()
                    .then((value) {
                  if (value.exists) {
                    chatroomDoc = value;
                  }
                });
                provider.reset();
                provider.fetchNextData(
                    Dbkeys.dataTypeMESSAGES,
                    FirebaseFirestore.instance
                        .collection(DbPaths.collectionAgentIndividiualmessages)
                        .doc(widget.chatroomID)
                        .collection(widget.chatroomID),
                    false);
              },
              icon: Icon(
                Icons.replay_outlined,
                color: Mycolors.secondary,
              )),
          IconButton(
              onPressed: AppConstants.isdemomode == true
                  ? () {
                      Utils.toast(getTranslatedForCurrentUser(
                          this.context, 'xxxnotalwddemoxxaccountxx'));
                    }
                  : () {
                      ShowConfirmWithInputTextDialog().open(
                        controller: _reason,
                        rightbtntext: getTranslatedForCurrentUser(
                                this.context, 'xxdeletexx')
                            .toUpperCase(),
                        rightbtnonpress: () async {
                          String agent1 = widget.lhsUserID;
                          String agent2 = widget.rhsUserID;
                          Navigator.of(this.context).pop();
                          ShowLoading()
                              .open(context: this.context, key: _keyLoader3q2);
                          await FirebaseFirestore.instance
                              .collection(
                                  DbPaths.collectionAgentIndividiualmessages)
                              .doc(widget.chatroomID)
                              .delete()
                              .then((value) async {
                            await Utils.sendDirectNotification(
                                title: getTranslatedForCurrentUser(this.context, 'xxxdeletedyourxxx')
                                    .replaceAll(
                                        '(####)', '${getTranslatedForCurrentUser(this.context, 'xxadminxx')}')
                                    .replaceAll(
                                        '(###)', '${getTranslatedForCurrentUser(this.context, 'xxagentchatsxx')}'),
                                parentID: "AGENTCHATROOM--${widget.chatroomID}",
                                plaindesc: _reason.text.trim().length < 1
                                    ? getTranslatedForCurrentUser(this.context, 'xxxdeletedyourwithxxx')
                                        .replaceAll('(####)',
                                            '${getTranslatedForCurrentUser(this.context, 'xxadminxx')}')
                                        .replaceAll(
                                            '(###)', '${getTranslatedForCurrentUser(this.context, 'xxagentchatsxx')} ${getTranslatedForCurrentUser(this.context, 'xxidxx')} ${widget.chatroomID}')
                                        .replaceAll(
                                            '(##)', '${getTranslatedForCurrentUser(this.context, 'xxagentxx')} ${getTranslatedForCurrentUser(this.context, 'xxidxx')}$agent2')
                                    : getTranslatedForCurrentUser(
                                            this.context, 'xxxdeletedyourwithxxx')
                                        .replaceAll('(####)', '${getTranslatedForCurrentUser(this.context, 'xxadminxx')}')
                                        .replaceAll('(###)', '${getTranslatedForCurrentUser(this.context, 'xxagentchatsxx')} ${getTranslatedForCurrentUser(this.context, 'xxidxx')} ${widget.chatroomID}')
                                        .replaceAll('(##)', '${getTranslatedForCurrentUser(this.context, 'xxagentxx')} ${getTranslatedForCurrentUser(this.context, 'xxidxx')}$agent2.   ${getTranslatedForCurrentUser(this.context, 'xxreasonxxx')} ${_reason.text.trim()}'),
                                docRef: FirebaseFirestore.instance.collection(DbPaths.collectionagents).doc(agent1).collection(DbPaths.agentnotifications).doc(DbPaths.agentnotifications),
                                postedbyID: 'Admin');

                            await Utils.sendDirectNotification(
                                title: getTranslatedForCurrentUser(this.context, 'xxxdeletedyourxxx')
                                    .replaceAll(
                                        '(####)', '${getTranslatedForCurrentUser(this.context, 'xxadminxx')}')
                                    .replaceAll(
                                        '(###)', '${getTranslatedForCurrentUser(this.context, 'xxagentchatsxx')}'),
                                parentID: "AGENTCHATROOM--${widget.chatroomID}",
                                plaindesc: _reason.text.trim().length < 1
                                    ? getTranslatedForCurrentUser(this.context, 'xxxdeletedyourwithxxx')
                                        .replaceAll('(####)',
                                            '${getTranslatedForCurrentUser(this.context, 'xxadminxx')}')
                                        .replaceAll(
                                            '(###)', '${getTranslatedForCurrentUser(this.context, 'xxagentchatsxx')} ${getTranslatedForCurrentUser(this.context, 'xxidxx')} ${widget.chatroomID}')
                                        .replaceAll(
                                            '(##)', '${getTranslatedForCurrentUser(this.context, 'xxagentxx')} ${getTranslatedForCurrentUser(this.context, 'xxidxx')}$agent1')
                                    : getTranslatedForCurrentUser(
                                            this.context, 'xxxdeletedyourwithxxx')
                                        .replaceAll('(####)', '${getTranslatedForCurrentUser(this.context, 'xxadminxx')}')
                                        .replaceAll('(###)', '${getTranslatedForCurrentUser(this.context, 'xxagentchatsxx')} ${getTranslatedForCurrentUser(this.context, 'xxidxx')} ${widget.chatroomID}')
                                        .replaceAll('(##)', '${getTranslatedForCurrentUser(this.context, 'xxagentxx')} ${getTranslatedForCurrentUser(this.context, 'xxidxx')}$agent1.   ${getTranslatedForCurrentUser(this.context, 'xxreasonxxx')} ${_reason.text.trim()}'),
                                docRef: FirebaseFirestore.instance.collection(DbPaths.collectionagents).doc(agent2).collection(DbPaths.agentnotifications).doc(DbPaths.agentnotifications),
                                postedbyID: 'Admin');
                            await FirebaseApi.runTransactionRecordActivity(
                              parentid: "AGENTCHATROOM--${widget.chatroomID}",
                              title: getTranslatedForCurrentUser(
                                      this.context, 'xxxchatroomdeletedxxx')
                                  .replaceAll('(####)',
                                      '${getTranslatedForCurrentUser(this.context, 'xxagentxx')}')
                                  .replaceAll('(###)',
                                      '${getTranslatedForCurrentUser(this.context, 'xxadminxx')}'),
                              postedbyID: "sys",
                              onErrorFn: (e) {
                                ShowLoading().close(
                                    key: _keyLoader3q2, context: context);
                                Utils.toast(
                                    "${getTranslatedForCurrentUser(this.context, 'xxfailedxx')} $e");
                              },
                              onSuccessFn: () {
                                ShowLoading().close(
                                    key: _keyLoader3q2, context: context);
                                Utils.toast(
                                    "${getTranslatedForCurrentUser(this.context, 'xxxchatroomidxxx')} ${widget.chatroomID} ${getTranslatedForCurrentUser(this.context, 'xxxdeletedxxx')}");
                                FirebaseFirestore.instance
                                    .collection(DbPaths.collectionagents)
                                    .doc(agent1)
                                    .collection(Dbkeys.chatsWith)
                                    .doc(Dbkeys.chatsWith)
                                    .set({'$agent2': FieldValue.delete()},
                                        SetOptions(merge: true));
                                FirebaseFirestore.instance
                                    .collection(DbPaths.collectionagents)
                                    .doc(agent2)
                                    .collection(Dbkeys.chatsWith)
                                    .doc(Dbkeys.chatsWith)
                                    .set({'$agent1': FieldValue.delete()},
                                        SetOptions(merge: true));
                                widget.onDelete();
                                Navigator.of(this.context).pop();
                              },
                              plainDesc: _reason.text.trim().length < 1
                                  ? getTranslatedForCurrentUser(
                                          this.context, 'xxxdeletedbyxxxxx')
                                      .replaceAll('(####)',
                                          '${getTranslatedForCurrentUser(this.context, 'xxadminxx')}')
                                      .replaceAll('(###)',
                                          '${getTranslatedForCurrentUser(this.context, 'xxagentsxx')} ${getTranslatedForCurrentUser(this.context, 'xxxchatroomidxxx')} ${widget.chatroomID}')
                                      .replaceAll(
                                          '(##)', '${getTranslatedForCurrentUser(this.context, 'xxagentsxx')} ${getTranslatedForCurrentUser(this.context, 'xxidxx')}($agent1 - $agent2)')
                                  : getTranslatedForCurrentUser(
                                              this.context, 'xxxdeletedbyxxxxx')
                                          .replaceAll('(####)',
                                              '${getTranslatedForCurrentUser(this.context, 'xxadminxx')}')
                                          .replaceAll('(###)',
                                              '${getTranslatedForCurrentUser(this.context, 'xxagentsxx')} ${getTranslatedForCurrentUser(this.context, 'xxxchatroomidxxx')} ${widget.chatroomID}')
                                          .replaceAll('(##)',
                                              '${getTranslatedForCurrentUser(this.context, 'xxagentsxx')} ${getTranslatedForCurrentUser(this.context, 'xxidxx')}($agent1 - $agent2)') +
                                      ".  ${getTranslatedForCurrentUser(this.context, 'xxchatdeletedxx')}.  ${getTranslatedForCurrentUser(this.context, 'xxreasonxxx')} ${_reason.text.trim()}",
                            );
                          });
                        },
                        context: this.context,
                        title:
                            "${getTranslatedForCurrentUser(this.context, 'xxdeletethischatxx')}",
                        subtitle: getTranslatedForCurrentUser(
                                this.context, 'xxdouwantdeletechatxx')
                            .replaceAll('(####)',
                                '${getTranslatedForCurrentUser(this.context, 'xxagentsxx')}'),
                      );
                    },
              icon: Icon(
                Icons.delete,
                color: Mycolors.red,
              )),
        ],
      ),
      title: "${widget.lhsUserName} - ${widget.rhsUserName} ",
      subtitle:
          '${getTranslatedForCurrentUser(this.context, 'xxxchatroomidxxx')} ${widget.chatroomID}',
      body: Stack(
        children: [
          new Container(
            decoration: new BoxDecoration(
              color: Mycolors.backgroundcolor,
              image: new DecorationImage(
                  image: AssetImage("assets/COMMON_ASSETS/background.png"),
                  fit: BoxFit.cover),
            ),
          ),
          Consumer<FirestoreDataProviderCHATMESSAGES>(
              builder: (context, firetsoreProvider, _child) =>
                  InfiniteCOLLECTIONListViewWidgetAdmin(
                    isreverse: true,
                    firestoreDataProviderMESSAGES: firetsoreProvider,
                    datatype: Dbkeys.dataTypeMESSAGES,
                    refdata: FirebaseFirestore.instance
                        .collection(DbPaths.collectionAgentIndividiualmessages)
                        .doc(widget.chatroomID)
                        .collection(widget.chatroomID),
                    list: Column(
                      children: [
                        firetsoreProvider.recievedDocs.length == 0 ||
                                firetsoreProvider.isFetchingData == true
                            ? SizedBox()
                            : firetsoreProvider.hasNext == false
                                ? warningTile(
                                    title: observer.userAppSettingsDoc!
                                                .defaultMessageDeletingTimeForOneToOneChat ==
                                            0
                                        ? getTranslatedForCurrentUser(
                                            this.context,
                                            'xxmssgautodeletenotxxx')
                                        : getTranslatedForCurrentUser(
                                                this.context,
                                                'xxxmssgautodeletexxx')
                                            .replaceAll('(####)',
                                                '<bold>${observer.userAppSettingsDoc!.defaultMessageDeletingTimeForOneToOneChat}</bold>'),
                                    warningTypeIndex: WarningType.alert.index,
                                    isstyledtext: true)
                                : SizedBox(),
                        ListView.builder(
                            // reverse: true,
                            // padding: EdgeInsets.only(bottom: 150),
                            physics: ScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: firetsoreProvider.recievedDocs.length,
                            itemBuilder: (BuildContext context, int i) {
                              var mssg = firetsoreProvider.recievedDocs[i];
                              bool isLHS =
                                  mssg[Dbkeys.from] == widget.lhsUserID;
                              return InkWell(
                                onLongPress: () {
                                  HapticFeedback.mediumImpact();
                                  ShowConfirmWithInputTextDialog().open(
                                      context: this.context,
                                      controller: _reason,
                                      title: getTranslatedForCurrentUser(
                                          this.context, 'xxxdltmssgxxx'),
                                      subtitle: getTranslatedForCurrentUser(
                                              this.context, 'xxxdltmssglongxxx')
                                          .replaceAll('(####)',
                                              ' ${mssg[Dbkeys.timestamp]}'),
                                      rightbtntext: getTranslatedForCurrentUser(
                                              this.context, 'xxdeletexx')
                                          .toUpperCase(),
                                      rightbtnonpress: () async {
                                        Navigator.of(this.context).pop();
                                        ShowLoading().open(
                                            context: this.context,
                                            key: _keyLoader3q2);
                                        await FirebaseFirestore.instance
                                            .collection(DbPaths
                                                .collectionAgentIndividiualmessages)
                                            .doc(widget.chatroomID)
                                            .collection(widget.chatroomID)
                                            .doc(mssg[Dbkeys.timestamp]
                                                .toString())
                                            .update({
                                          Dbkeys.hasSenderDeleted: true,
                                          Dbkeys.deletedType: DeletedType
                                              .adminDeleted.index
                                              .toString(),
                                          Dbkeys.deletedReason:
                                              _reason.text.trim().length < 1
                                                  ? ""
                                                  : _reason.text.trim(),
                                        }).then((value) {
                                          ShowLoading().close(
                                              context: this.context,
                                              key: _keyLoader3q2);
                                          Utils.toast(
                                              getTranslatedForCurrentUser(
                                                  this.context,
                                                  'xxmsgdeletedxx'));
                                          final provider = Provider.of<
                                                  FirestoreDataProviderCHATMESSAGES>(
                                              this.context,
                                              listen: false);

                                          FirebaseFirestore.instance
                                              .collection(DbPaths
                                                  .collectionAgentIndividiualmessages)
                                              .doc(widget.chatroomID)
                                              .get()
                                              .then((value) {
                                            if (value.exists) {
                                              chatroomDoc = value;
                                            }
                                          });
                                          provider.reset();
                                          provider.fetchNextData(
                                              Dbkeys.dataTypeMESSAGES,
                                              FirebaseFirestore.instance
                                                  .collection(DbPaths
                                                      .collectionAgentIndividiualmessages)
                                                  .doc(widget.chatroomID)
                                                  .collection(
                                                      widget.chatroomID),
                                              false);
                                        }).catchError((e) {
                                          ShowLoading().close(
                                              context: this.context,
                                              key: _keyLoader3q2);
                                          Utils.toast(
                                              "${getTranslatedForCurrentUser(this.context, 'xxfailedxx')} $e");
                                        });
                                      });
                                },
                                child: chatBubble(
                                    context: this.context,
                                    lhsUserID: widget.lhsUserID,
                                    rhsUserID: widget.rhsUserID,
                                    lhsUserPhoto: widget.lhsUserPhoto,
                                    rhsUserPhoto: widget.rhsUserPhoto,
                                    lhsUsername: widget.lhsUserName,
                                    rhsUsername: widget.rhsUserName,
                                    isLHS: isLHS,
                                    chatMssgDoc: mssg,
                                    chatRoomDoc: chatroomDoc),
                              );
                            }),
                      ],
                    ),
                  )),
        ],
      ),
    );
  }
}
