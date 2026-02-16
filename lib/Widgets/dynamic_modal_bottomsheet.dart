import 'package:flutter/material.dart';
import 'package:thinkcreative_technologies/Configs/my_colors.dart';

showDynamicModalBottomSheet({
  required BuildContext context,
  required List<Widget> widgetList,
  required String title,
  String? desc,
  bool? isextraMargin = true,
  bool isCentre = true,
  double padding = 7,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            color: Color.fromRGBO(0, 0, 0, 0.001),
            child: GestureDetector(
              onTap: () {},
              child: DraggableScrollableSheet(
                initialChildSize: widgetList.length <= 2
                    ? 0.3
                    : widgetList.length > 7
                        ? 0.8
                        : widgetList.length * 0.079 > 0.85
                            ? 0.85
                            : widgetList.length * 0.079,
                minChildSize: 0.1,
                maxChildSize: 0.85,
                builder: (_, controller) {
                  return Container(
                    padding: EdgeInsets.all(isextraMargin == true ? 20 : 0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(25.0),
                        topRight: const Radius.circular(25.0),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Icon(
                              Icons.cancel,
                              color: Colors.transparent,
                            ),
                            Icon(
                              Icons.remove,
                              color: Mycolors.grey.withOpacity(0.4),
                            ),
                            IconButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                icon: Icon(
                                  Icons.cancel,
                                  color: Mycolors.grey.withOpacity(0.4),
                                ))
                          ],
                        ),
                        title == ""
                            ? SizedBox()
                            : Padding(
                                padding: EdgeInsets.all(15),
                                child: Text(
                                  title,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Mycolors.black,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                        Expanded(
                          child: ListView.builder(
                            shrinkWrap: true,
                            controller: controller,
                            itemCount: widgetList.length,
                            itemBuilder: (_, index) {
                              return widgetList[index];
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      );
    },
  );
}
