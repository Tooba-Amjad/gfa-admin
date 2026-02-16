//*************   © Copyrighted by Thinkcreative_Technologies. An Exclusive item of Envato market. Make sure you have purchased a Regular License OR Extended license for the Source Code from Envato to use this product. See the License Defination attached with source code. *********************

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';
import 'package:thinkcreative_technologies/Configs/my_colors.dart';

class PDFViewerCachedFromUrl extends StatelessWidget {
  const PDFViewerCachedFromUrl({
    Key? key,
    required this.url,
    required this.title,
    this.localFile,
  }) : super(key: key);

  final String? url;
  final File? localFile;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Icon(
            Icons.keyboard_arrow_left,
            size: 30,
            color: Colors.white,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        backgroundColor: Mycolors.primary,
      ),
      body: localFile == null
          ? const PDF().cachedFromUrl(
              url!,
              placeholder: (double progress) =>
                  Center(child: Text('$progress %')),
              errorWidget: (dynamic error) =>
                  Center(child: Text(error.toString())),
            )
          : const PDF().fromPath(
              localFile!.path,
            ),
    );
  }
}
