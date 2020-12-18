import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:visual_sorter/constants.dart';

class PrivacyPolicy extends StatelessWidget {
  const PrivacyPolicy({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        iconTheme: IconThemeData(color: kTextLightColor),
        title: Text(
          "Privacy Policy",
          style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: kTextLightColor),
        ),
      ),
      body: FutureBuilder(
        future: rootBundle.loadString("assets/text/privacy_policy.md"),
        builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
          if (snapshot.hasData) {
            return Markdown(data: snapshot.data);
          }
          return Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}
