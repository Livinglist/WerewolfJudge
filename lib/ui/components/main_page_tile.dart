import 'package:flutter/material.dart';

class MainPageTile extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  final String iconTitle;

  MainPageTile({@required this.title, @required this.onTap, this.iconTitle}) : assert(title != null);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(12),
      child: Material(
          color: Colors.orange,
          borderRadius: BorderRadius.all(Radius.circular(16)),
          elevation: 8,
          child: InkWell(
            onTap: onTap,
            splashColor: Colors.orangeAccent,
            borderRadius: BorderRadius.all(Radius.circular(16)),
            child: Container(
              child: Stack(
                children: <Widget>[
                  Positioned(
                    left: 12,
                    top: 12,
                    child: Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  ),
                  if (iconTitle != null)
                    Align(
                      alignment: Alignment.center,
                      child: Text(
                        iconTitle,
                        style: TextStyle(fontFamily: 'Regular', fontSize: 48,color: Colors.black54),
                      ),
                    )
                ],
              ),
              decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(16))),
            ),
          )),
    );
  }
}
