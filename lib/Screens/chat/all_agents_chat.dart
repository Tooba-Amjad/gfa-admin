import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:thinkcreative_technologies/Configs/db_keys.dart';
import 'package:thinkcreative_technologies/Configs/db_paths.dart';
import 'package:thinkcreative_technologies/Configs/my_colors.dart';
import 'package:thinkcreative_technologies/Configs/optional_constants.dart';
import 'package:thinkcreative_technologies/Localization/language_constants.dart';
import 'package:thinkcreative_technologies/Models/agent_model.dart';
import 'package:thinkcreative_technologies/Screens/agents/agent_profile_details.dart';
import 'package:thinkcreative_technologies/Screens/chat/agent_agent_chatroom.dart';
import 'package:thinkcreative_technologies/Services/my_providers/firestore_collections_data_admin.dart';
import 'package:thinkcreative_technologies/Utils/custom_time_formatter.dart';
import 'package:thinkcreative_technologies/Utils/page_navigator.dart';
import 'package:thinkcreative_technologies/Widgets/avatars/customCircleAvatars.dart';
import 'package:thinkcreative_technologies/Widgets/custom_text.dart';
import 'package:thinkcreative_technologies/Widgets/dialogs/loadingDialog.dart';
import 'package:thinkcreative_technologies/Widgets/late_load.dart';
import 'package:thinkcreative_technologies/Widgets/my_inkwell.dart';
import 'package:thinkcreative_technologies/Widgets/my_scaffold.dart';
import 'package:thinkcreative_technologies/Widgets/nodata_widget.dart';

class AllAgentsChat extends StatefulWidget {
  final Query? query;
  final String? subtitle;
  const AllAgentsChat({Key? key, this.query, this.subtitle}) : super(key: key);

  @override
  _AllAgentsChatState createState() => _AllAgentsChatState();
}

class _AllAgentsChatState extends State<AllAgentsChat> {
  late Stream<QuerySnapshot> _chatStream;

  @override
  void initState() {
    super.initState();
    _chatStream = widget.query != null
        ? widget.query!.snapshots()
        : FirebaseFirestore.instance
            .collection(DbPaths.collectionAgentIndividiualmessages)
            .orderBy(Dbkeys.lastMessageTime, descending: true)
            .snapshots();
    print('🔴 AllAgentsChat - Stream initialized in initState');
  }

  @override
  void didUpdateWidget(AllAgentsChat oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.query != widget.query) {
      _chatStream = widget.query != null
          ? widget.query!.snapshots()
          : FirebaseFirestore.instance
              .collection(DbPaths.collectionAgentIndividiualmessages)
              .orderBy(Dbkeys.lastMessageTime, descending: true)
              .snapshots();
      print('🔴 AllAgentsChat - Stream reinitialized in didUpdateWidget');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MyScaffold(
      title: getTranslatedForCurrentUser(this.context, 'xxagentchatsxx'),
      subtitle: widget.subtitle,
      icondata1: Icons.refresh,
      icon1press: () {
        setState(() {});
      },
      body: StreamBuilder<QuerySnapshot>(
          stream: _chatStream,
          builder: (context, snapshot) {
            
            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Text(
                    snapshot.error.toString(),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return circularProgress();
            }

            List<DocumentSnapshot> chats = snapshot.data!.docs;

            if (chats.length == 0) {
              return noDataWidget(
                  context: this.context,
                  title: getTranslatedForCurrentUser(
                      this.context, 'xxxnochatsxxx'),
                  subtitle: getTranslatedForCurrentUser(
                          this.context, 'xxxnoxxchatxxx')
                      .replaceAll('(####)',
                          '${getTranslatedForCurrentUser(this.context, 'xxagentsxx')}'),
                  iconData: LineAwesomeIcons.alternate_ticket);
            }

            return ListView.builder(
                itemCount: chats.length,
                itemBuilder: (BuildContext context, int i) {
                  String user1 = chats[i]["chatmembers"][0];
                  String user2 = chats[i]["chatmembers"][1];
                  return streamLoad(
                      stream: FirebaseFirestore.instance
                          .collection(DbPaths.collectionagents)
                          .doc(user1)
                          .snapshots(),
                      placeholder: SizedBox(),
                      onfetchdone: (user1Map) {
                        if (user1Map != null) {
                          return streamLoad(
                              stream: FirebaseFirestore.instance
                                  .collection(DbPaths.collectionagents)
                                  .doc(user2)
                                  .snapshots(),
                              placeholder: SizedBox(),
                              onfetchdone: (user2Map) {
                                if (user2Map != null) {
                                  return myinkwell(
                                    onTap: () {
                                      pageNavigator(
                                          context,
                                          AgentToAgentChatRoom(
                                            onDelete: () {
                                              setState(() {});
                                            },
                                            chatroomID:
                                                chats[i].reference.id,
                                            lhsUserID: user1,
                                            lhsUserName:
                                                user1Map[Dbkeys.nickname],
                                            lhsUserPhoto:
                                                user1Map[Dbkeys.photoUrl],
                                            rhsUserID: user2,
                                            rhsUserName:
                                                user2Map[Dbkeys.nickname],
                                            rhsUserPhoto:
                                                user2Map[Dbkeys.photoUrl],
                                            chatRoomDoc: chats[i],
                                          ));
                                    },
                                    child: Container(
                                      padding: EdgeInsets.all(6),
                                      child: Card(
                                        child: Padding(
                                          padding: const EdgeInsets.all(13.0),
                                          child: Column(
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  MtCustomfontBoldSemi(
                                                    text:
                                                        "${getTranslatedForCurrentUser(this.context, 'xxxchatidxxx')} ${chats[i].reference.id}",
                                                    fontsize: 11,
                                                    color: Mycolors.grey,
                                                  ),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.end,
                                                    children: [
                                                      Icon(
                                                        Icons.message,
                                                        color: Mycolors.grey
                                                            .withOpacity(0.3),
                                                        size: 14,
                                                      ),
                                                      SizedBox(
                                                        width: 7,
                                                      ),
                                                      MtCustomfontBold(
                                                        text: formatTimeDateCOMLPETEString(
                                                            context:
                                                                this.context,
                                                            timestamp: chats[i][
                                                                Dbkeys
                                                                    .lastMessageTime]),
                                                        fontsize: 11,
                                                        color: Mycolors.primary,
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                              Divider(),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  SizedBox(
                                                      width: MediaQuery.of(
                                                                  context)
                                                              .size
                                                              .width /
                                                          2.9,
                                                      child: myinkwell(
                                                        onTap: () {
                                                          pageNavigator(
                                                              this.context,
                                                              AgentProfileDetails(
                                                                agentID: AgentModel
                                                                        .fromJson(
                                                                            user1Map)
                                                                    .id,
                                                                agent:
                                                                    AgentModel
                                                                        .fromJson(
                                                                            user1Map),
                                                                currentuserid:
                                                                    Optionalconstants
                                                                        .currentAdminID,
                                                              ));
                                                        },
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Stack(
                                                              children: [
                                                                customCircleAvatar(
                                                                  radius: 17,
                                                                  url: user1Map[
                                                                      Dbkeys
                                                                          .photoUrl],
                                                                ),
                                                                user1Map[Dbkeys
                                                                            .lastSeen] ==
                                                                        true
                                                                    ? Positioned(
                                                                        top: 0,
                                                                        left: 0,
                                                                        child:
                                                                            CircleAvatar(
                                                                          radius:
                                                                              6,
                                                                          backgroundColor:
                                                                              Mycolors
                                                                                  .white,
                                                                          child:
                                                                              CircleAvatar(
                                                                            backgroundColor:
                                                                                Mycolors.onlinetag,
                                                                            radius:
                                                                                4,
                                                                          ),
                                                                        ))
                                                                    : SizedBox(),
                                                              ],
                                                            ),
                                                            SizedBox(
                                                              height: 15,
                                                            ),
                                                            MtCustomfontMedium(
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              maxlines: 1,
                                                              fontsize: 14,
                                                              text: user1Map[
                                                                  Dbkeys
                                                                      .nickname],
                                                            ),
                                                          ],
                                                        ),
                                                      )),
                                                  Icon(
                                                    Icons
                                                        .connect_without_contact_outlined,
                                                    size: 44,
                                                    color: Mycolors.orange,
                                                  ),
                                                  SizedBox(
                                                      width: MediaQuery.of(
                                                                  context)
                                                              .size
                                                              .width /
                                                          2.9,
                                                      child: myinkwell(
                                                        onTap: () {
                                                          pageNavigator(
                                                              this.context,
                                                              AgentProfileDetails(
                                                                agentID: AgentModel
                                                                        .fromJson(
                                                                            user2Map)
                                                                    .id,
                                                                agent:
                                                                    AgentModel
                                                                        .fromJson(
                                                                            user2Map),
                                                                currentuserid:
                                                                    Optionalconstants
                                                                        .currentAdminID,
                                                              ));
                                                        },
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .end,
                                                          children: [
                                                            Stack(
                                                              children: [
                                                                customCircleAvatar(
                                                                  radius: 17,
                                                                  url: user2Map[
                                                                      Dbkeys
                                                                          .photoUrl],
                                                                ),
                                                                user2Map[Dbkeys
                                                                            .lastSeen] ==
                                                                        true
                                                                    ? Positioned(
                                                                        top: 0,
                                                                        right:
                                                                            0,
                                                                        child:
                                                                            CircleAvatar(
                                                                          radius:
                                                                              6,
                                                                          backgroundColor:
                                                                              Mycolors
                                                                                  .white,
                                                                          child:
                                                                              CircleAvatar(
                                                                            backgroundColor:
                                                                                Mycolors.onlinetag,
                                                                            radius:
                                                                                4,
                                                                          ),
                                                                        ))
                                                                    : SizedBox(),
                                                              ],
                                                            ),
                                                            SizedBox(
                                                              height: 15,
                                                            ),
                                                            MtCustomfontMedium(
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              maxlines: 1,
                                                              textalign:
                                                                  TextAlign.end,
                                                              fontsize: 14,
                                                              text: user2Map[
                                                                  Dbkeys
                                                                      .nickname],
                                                            ),
                                                          ],
                                                        ),
                                                      ))
                                                ],
                                              ),
                                              Divider(
                                                height: 27,
                                              ),
                                              MtCustomfontBold(
                                                text: getTranslatedForCurrentUser(
                                                    this.context,
                                                    'xxxviewchatroomxxx'),
                                                letterspacing: 1.2,
                                                color: Mycolors.orange,
                                                fontsize: 13,
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                } else {
                                  return SizedBox();
                                }
                              });
                        } else {
                          return SizedBox();
                        }
                      });
                },
              );
            },
          ),
    );
  }
}
