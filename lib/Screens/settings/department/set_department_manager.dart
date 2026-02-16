import 'package:flutter/material.dart';
import 'package:thinkcreative_technologies/Configs/app_constants.dart';
import 'package:thinkcreative_technologies/Configs/enum.dart';
import 'package:thinkcreative_technologies/Configs/my_colors.dart';
import 'package:thinkcreative_technologies/Localization/language_constants.dart';
import 'package:thinkcreative_technologies/Models/user_registry_model.dart';
import 'package:thinkcreative_technologies/Utils/color_light_dark.dart';
import 'package:thinkcreative_technologies/Utils/utils.dart';
import 'package:thinkcreative_technologies/Widgets/avatars/Avatar.dart';
import 'package:thinkcreative_technologies/Widgets/my_scaffold.dart';
import 'package:thinkcreative_technologies/Widgets/nodata_widget.dart';
import 'package:thinkcreative_technologies/Widgets/others/userrole_based_sticker.dart';

class SetDepartmentManager extends StatefulWidget {
  final List<UserRegistryModel> agents;
  final String alreadyselecteduserid;
  final Function(UserRegistryModel user) selecteduser;
  const SetDepartmentManager(
      {Key? key,
      required this.agents,
      required this.selecteduser,
      required this.alreadyselecteduserid})
      : super(key: key);

  @override
  _SetDepartmentManagerState createState() => _SetDepartmentManagerState();
}

class _SetDepartmentManagerState extends State<SetDepartmentManager> {
  List<UserRegistryModel> list = [];
  @override
  void initState() {
    list = widget.agents;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MyScaffold(
      isforcehideback: true,
      icon1press: () {
        Navigator.of(this.context).pop();
      },
      icondata1: Icons.close,
      subtitle: getTranslatedForCurrentUser(this.context, 'xxselectxxtoaddxx')
          .replaceAll('(####)',
              '${getTranslatedForCurrentUser(this.context, 'xxagentxx')}'),
      title: getTranslatedForCurrentUser(this.context, 'xxsetxxxx').replaceAll(
          '(####)',
          '${getTranslatedForCurrentUser(this.context, 'xxdepartmentmanagerxx')}'),
      body: list.length == 0
          ? noDataWidget(
              context: this.context,
              title: getTranslatedForCurrentUser(
                      this.context, 'xxnoxxavailabletoaddxx')
                  .replaceAll('(####)',
                      '${getTranslatedForCurrentUser(this.context, 'xxagentsxx')}'),
              iconData: Icons.people)
          : ListView.builder(
              itemCount: list.length,
              itemBuilder: (BuildContext context, int i) {
                return Card(
                  color: widget.alreadyselecteduserid == list[i].id
                      ? lighten(Mycolors.green, .52)
                      : Color.fromRGBO(255, 255, 255, 1),
                  margin: EdgeInsets.fromLTRB(6, 8, 6, 2),
                  elevation: 0.4,
                  child: ListTile(
                    trailing: widget.alreadyselecteduserid == list[i].id
                        ? SizedBox(
                            height: 28,
                            width: 100,
                            child: roleBasedSticker(
                                this.context, Usertype.departmentmanager.index))
                        : Chip(
                            label: Text(
                                getTranslatedForCurrentUser(
                                        this.context, 'xxsetasxx')
                                    .replaceAll('(####)',
                                        '${getTranslatedForCurrentUser(this.context, 'xxmanagerxx')}'),
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.blue[700],
                                )),
                            backgroundColor: Colors.blue[50],
                          ),
                    leading: avatar(
                      imageUrl:
                          list[i].photourl == "" ? null : list[i].photourl,
                    ),
                    onTap: AppConstants.isdemomode == true
                        ? () {
                            Utils.toast(getTranslatedForCurrentUser(
                                this.context, 'xxxnotalwddemoxxaccountxx'));
                          }
                        : () {
                            Navigator.of(this.context).pop();
                            if (widget.alreadyselecteduserid != list[i].id) {
                              widget.selecteduser(list[i]);
                            }
                          },
                    title: Text(
                      list[i].fullname,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      "${getTranslatedForCurrentUser(this.context, 'xxidxx')} " +
                          list[i].id,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                );
              }),
    );
  }
}
