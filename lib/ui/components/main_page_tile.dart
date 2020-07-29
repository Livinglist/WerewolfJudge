import 'package:flutter/material.dart';

class MainPageTile extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  MainPageTile({@required this.title, @required this.onTap}) : assert(title != null);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(12),
      child: Material(
          color: Colors.orangeAccent,
          borderRadius: BorderRadius.all(Radius.circular(16)),
          elevation: 8,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.all(Radius.circular(16)),
            child: Container(
              child: Padding(
                padding: EdgeInsets.only(left: 12, top: 12),
                child: Text(title),
              ),
              decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(16))),
            ),
          )),
    );
  }
}
