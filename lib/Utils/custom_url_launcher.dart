import 'package:url_launcher/url_launcher.dart';

void customUrlLauncher(String myurl) async {
  if (myurl.startsWith("http")) {
    if (!await launchUrl(Uri.parse(myurl),
        mode: LaunchMode.externalApplication)) throw 'Could not launch $myurl';
  } else {
    var newUrl = "http://$myurl";
    if (!await launchUrl(Uri.parse(newUrl),
        mode: LaunchMode.externalApplication)) throw 'Could not launch $newUrl';
  }
}
