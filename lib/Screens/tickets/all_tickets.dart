import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:thinkcreative_technologies/Configs/db_keys.dart';
import 'package:thinkcreative_technologies/Configs/db_paths.dart';
import 'package:thinkcreative_technologies/Configs/enum.dart';
import 'package:thinkcreative_technologies/Configs/optional_constants.dart';
import 'package:thinkcreative_technologies/Localization/language_constants.dart';
import 'package:thinkcreative_technologies/Models/ticket_model.dart';
import 'package:thinkcreative_technologies/Models/userapp_settings_model.dart';
import 'package:thinkcreative_technologies/Screens/tickets/chatroom/ticket_chat_room.dart';
import 'package:thinkcreative_technologies/Screens/tickets/ticketWidget.dart';
import 'package:thinkcreative_technologies/Utils/page_navigator.dart';
import 'package:thinkcreative_technologies/Utils/utils.dart';
import 'package:thinkcreative_technologies/Widgets/dialogs/CustomDialog.dart';
import 'package:thinkcreative_technologies/Widgets/dialogs/FormDialog.dart';
import 'package:thinkcreative_technologies/Widgets/dialogs/loadingDialog.dart';
import 'package:thinkcreative_technologies/Widgets/my_scaffold.dart';
import 'package:thinkcreative_technologies/Widgets/nodata_widget.dart';

class AllTickets extends StatefulWidget {
  final UserAppSettingsModel userAppSettingsModel;
  final Query? query;
  final String? subtitle;
  const AllTickets(
      {Key? key, required this.userAppSettingsModel, this.query, this.subtitle})
      : super(key: key);

  @override
  _AllTicketsState createState() => _AllTicketsState();
}

class _AllTicketsState extends State<AllTickets> {
  List<TicketModel> tickets = [];
  String error = "";
  bool isloading = true;
  @override
  void initState() {
    super.initState();
    fetchData(widget.query ??
        FirebaseFirestore.instance
            .collection(DbPaths.collectiontickets)
            .orderBy(Dbkeys.ticketlatestTimestampForAgents, descending: true));
  }

  fetchData(Query query) async {
    await query.get().then((docs) {
      tickets =
          docs.docs.toList().map((e) => TicketModel.fromSnapshot(e)).toList();
      isloading = false;
      setState(() {});
    }).catchError((onError) {
      error = onError.toString();
      isloading = false;
      setState(() {});
    });
  }

  final TextEditingController _controller12 = TextEditingController();
  @override
  void dispose() {
    super.dispose();
    _controller12.dispose();
  }

  final GlobalKey<State> _keyLoader =
      new GlobalKey<State>(debugLabel: '272husd1');
  @override
  Widget build(BuildContext context) {
    return MyScaffold(
      icondata2: Icons.search,
      icon2press: () {
        ShowFormDialog().open(
            context: this.context,
            controller: _controller12,
            title:
                "${getTranslatedForCurrentUser(this.context, 'xxxsearchxxx')} ${getTranslatedForCurrentUser(this.context, 'xxtktsxx')}",
            iscentrealign: true,
            hinttext: getTranslatedForCurrentUser(this.context, 'xxticketidxx'),
            rightbtntext:
                getTranslatedForCurrentUser(this.context, 'xxxsearchxxx')
                    .toUpperCase(),
            buttontext:
                getTranslatedForCurrentUser(this.context, 'xxxsearchxxx')
                    .toUpperCase(),
            onpressed: () async {
              if (_controller12.text.trim().length < 1) {
                // Navigator.of(this.context).pop();
                // Utils.toast("Please enter a Ticket ID !");
              } else {
                Navigator.of(this.context).pop();
                ShowLoadingPlsWait()
                    .open(context: this.context, key: _keyLoader);
                await FirebaseFirestore.instance
                    .collection(DbPaths.collectiontickets)
                    .doc(_controller12.text.trim())
                    .get()
                    .then((value) {
                  if (value.exists) {
                    ShowLoadingPlsWait()
                        .close(context: this.context, key: _keyLoader);
                    TicketModel ticket = TicketModel.fromSnapshot(value);

                    pageNavigator(
                        this.context,
                        TicketChatRoom(
                            isClosed: ticket.ticketStatusShort ==
                                    TicketStatusShort.close.index ||
                                ticket.ticketStatusShort ==
                                    TicketStatusShort.expired.index,
                            ticketTitle: ticket.ticketTitle,
                            ticketID: ticket.ticketID,
                            customerUID: ticket.ticketcustomerID,
                            cuurentUserCanSeeAgentNamePhoto: true,
                            cuurentUserCanSeeCustomerNamePhoto: true,
                            currentuserfullname: 'Admin',
                            isSharingIntentForwarded: false,
                            agentsListinParticularDepartment:
                                ticket.tktMEMBERSactiveList));
                    // _controller12.clear();
                  } else {
                    ShowLoadingPlsWait()
                        .close(context: this.context, key: _keyLoader);
                    Utils.toast(
                        "${getTranslatedForCurrentUser(this.context, 'xxticketidxx')}${_controller12.text.trim()} ${getTranslatedForCurrentUser(this.context, 'xxxnotfoundxxx')}");
                    // _controller12.clear();
                  }
                }).catchError((onError) {
                  ShowLoadingPlsWait()
                      .close(context: this.context, key: _keyLoader);
                  Utils.toast(
                      "${getTranslatedForCurrentUser(this.context, 'xxxfailedntryagainxxx')}\n $error");
                  // _controller12.clear();
                });
              }
            });
      },
      title: getTranslatedForCurrentUser(this.context, 'xxallxxxx').replaceAll(
          '(####)',
          '${getTranslatedForCurrentUser(this.context, 'xxtktssxx')}'),
      subtitle: widget.subtitle,
      icondata1: Icons.refresh,
      icon1press: () async {
        setState(() {
          isloading = true;
        });
        await fetchData(widget.query ??
            FirebaseFirestore.instance
                .collection(DbPaths.collectiontickets)
                .orderBy(Dbkeys.ticketlatestTimestampForAgents,
                    descending: true));
      },
      body: error != ""
          ? Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  error,
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : isloading
              ? circularProgress()
              : tickets.length == 0
                  ? noDataWidget(
                      context: this.context,
                      title: getTranslatedForCurrentUser(
                              this.context, 'xxnoxxavailabletoaddxx')
                          .replaceAll('(####)',
                              '${getTranslatedForCurrentUser(this.context, 'xxtktssxx')}'),
                      iconData: LineAwesomeIcons.alternate_ticket)
                  : ListView.builder(
                      itemCount: tickets.length,
                      itemBuilder: (BuildContext context, int i) {
                        TicketModel ticket = tickets[i];
                        return ticketWidgetForAgents(
                            isMini: false,
                            context: this.context,
                            ontap: (g, j) {
                              pageNavigator(
                                  this.context,
                                  TicketChatRoom(
                                    isClosed: ticket.ticketStatusShort ==
                                            TicketStatusShort.close.index ||
                                        ticket.ticketStatusShort ==
                                            TicketStatusShort.expired.index,
                                    agentsListinParticularDepartment: [],
                                    currentuserfullname:
                                        Optionalconstants.currentAdminID,
                                    customerUID: ticket.ticketcustomerID,
                                    cuurentUserCanSeeAgentNamePhoto: true,
                                    cuurentUserCanSeeCustomerNamePhoto: true,
                                    isSharingIntentForwarded: false,
                                    ticketID: ticket.ticketID,
                                    ticketTitle: ticket.ticketTitle,
                                  ));
                            },
                            ticket: tickets[i],
                            userAppSettingsDoc: widget.userAppSettingsModel);
                      }),
    );
  }
}
