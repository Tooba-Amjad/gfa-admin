import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thinkcreative_technologies/Configs/my_colors.dart';
import 'package:thinkcreative_technologies/Localization/language_constants.dart';
import 'package:thinkcreative_technologies/Utils/custom_tiles.dart';
import 'package:thinkcreative_technologies/Widgets/boxdecoration.dart';
import 'package:thinkcreative_technologies/Widgets/my_scaffold.dart';

class AllModules extends StatefulWidget {
  final SharedPreferences prefs;
  const AllModules({super.key, required this.prefs});

  @override
  State<AllModules> createState() => _AllModulesState();
}

class _AllModulesState extends State<AllModules> {
  List<dynamic> allmodules = [];
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      // allmodules.add({
      //   "modulename": "Product Selling Module",
      //   "moduledesc": "Manage Categories, Products & Sales",
      //   "translateavailable": false,
      //   "modulepath": () {
      //     pageNavigator(
      //         this.context,
      //         PSMinitialize(
      //           prefs: widget.prefs,
      //           path: PSMContants.k12,
      //         ));
      //   }
      // });
      //---Add modules below this line----------

      //---Add modules above this line----------
    });
  }

  @override
  Widget build(BuildContext context) {
    return MyScaffold(
      title: getTranslatedForCurrentUser(this.context, 'xxmodulesxx'),
      body: ListView.builder(
          itemCount: allmodules.length,
          itemBuilder: (BuildContext context, int i) {
            var module = allmodules[i];

            return customTile(
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
                title: module['translateavailable'] == true
                    ? getTranslatedForCurrentUser(
                        this.context, module['modulename'])
                    : module['modulename'],
                subtitle: module['translateavailable'] == true
                    ? getTranslatedForCurrentUser(
                        this.context, module['moduledesc'])
                    : module['moduledesc'],
                leadingicondata: Icons.payment_rounded,
                leadingiconcolor: Mycolors.purple,
                ontap: module['modulepath']);
          }),
    );
  }
}
