//*************   © Copyrighted by Thinkcreative_Technologies. An Exclusive item of Envato market. Make sure you have purchased a Regular License OR Extended license for the Source Code from Envato to use this product. See the License Definition attached with source code. *********************

// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:gal/gal.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:thinkcreative_technologies/Configs/my_colors.dart';
import 'package:thinkcreative_technologies/Localization/language_constants.dart';
import 'package:thinkcreative_technologies/Utils/utils.dart';

class GalleryDownloader {
  static void saveNetworkVideoInGallery(BuildContext context, String url,
      bool isFurtherOpenFile, String fileName, GlobalKey keyloader) async {
    Dialogs.showLoadingDialog(context, keyloader);
    try {
      // Gal requires downloading the file first
      final tempDir = await getTemporaryDirectory();
      String savePath = '${tempDir.path}/$fileName.mp4';
      await Dio().download(url, savePath);

      // Check permissions
      bool granted = await _requestPermission();
      if (!granted) {
        Navigator.of(keyloader.currentContext!, rootNavigator: true).pop(); // Dismiss loading
        Utils.toast(getTranslatedForCurrentUser(context, 'xxfailedxx') + ": " + getTranslatedForCurrentUser(context, 'xxpermission_deniedxx'));
        return;
      }

      await Gal.putVideo(savePath);
      Navigator.of(keyloader.currentContext!, rootNavigator: true).pop();
      Utils.toast("$fileName  " + getTranslatedForCurrentUser(context, 'xxsavedxx'));
      
      // Cleanup temp file
      File(savePath).delete().ignore();

    } catch (e) {
      if (Navigator.canPop(keyloader.currentContext!)) {
        Navigator.of(keyloader.currentContext!, rootNavigator: true).pop();
      }
      Utils.toast(e.toString());
    }
  }

  static void saveNetworkImage(BuildContext context, String url,
      bool isFurtherOpenFile, String fileName, GlobalKey keyloader) async {
    Dialogs.showLoadingDialog(context, keyloader);
    try {
      // Gal requires downloading the file first for network images if not using putImageBytes
      final tempDir = await getTemporaryDirectory();
      String savePath = '${tempDir.path}/$fileName.jpg'; // Assuming jpg, logic might need adjustment for other formats if 'url' doesn't have it
      await Dio().download(url, savePath);

      // Check permissions
      bool granted = await _requestPermission();
      if (!granted) {
        Navigator.of(keyloader.currentContext!, rootNavigator: true).pop();
        Utils.toast(getTranslatedForCurrentUser(context, 'xxfailedxx') + ": " + getTranslatedForCurrentUser(context, 'xxpermission_deniedxx'));
        return;
      }

      await Gal.putImage(savePath);
      Navigator.of(keyloader.currentContext!, rootNavigator: true).pop();
      Utils.toast("$fileName  " + getTranslatedForCurrentUser(context, 'xxsavedxx'));
      
      // Cleanup temp file
      File(savePath).delete().ignore();

    } catch (e) {
      if (Navigator.canPop(keyloader.currentContext!)) {
        Navigator.of(keyloader.currentContext!, rootNavigator: true).pop();
      }
      Utils.toast(e.toString());
    }
  }

  static Future<bool> _requestPermission() async {
    // Gal handles permissions internally for the most part, but good to be explicit for Android 10-
    // However, Gal.requestAccess() corresponds to the required access.
    return await Gal.requestAccess();
  }
}

class Dialogs {
  static Future<void> showLoadingDialog(
      BuildContext context, GlobalKey key) async {
    return showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return new WillPopScope(
              onWillPop: () async => false,
              child: SimpleDialog(
                  key: key,
                  backgroundColor: Colors.white,
                  children: <Widget>[
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(18.0),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 18,
                              ),
                              CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    Mycolors.loadingindicator),
                              ),
                              SizedBox(
                                width: 23,
                              ),
                              Text(
                                getTranslatedForCurrentUser(
                                    context, 'xxdownloadingxx'),
                                style: TextStyle(color: Colors.black87),
                              )
                            ]),
                      ),
                    )
                  ]));
        });
  }
}
