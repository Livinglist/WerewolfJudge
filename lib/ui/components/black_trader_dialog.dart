import 'package:flutter/material.dart';

import 'package:werewolfjudge/model/role.dart';


class BlackTraderDialog extends StatefulWidget {
  final int index;
  final VoidCallback onCancel;
  final ValueChanged<Type> onContinue;

  BlackTraderDialog({@required this.index, @required this.onCancel, @required this.onContinue});

  @override
  _BlackTraderDialogState createState() => _BlackTraderDialogState();
}

class _BlackTraderDialogState extends State<BlackTraderDialog> {
  Type selectedType = Witch;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Widget cancelButton = FlatButton(
        child: Text("取消"),
        onPressed: widget.onCancel);

    Widget continueButton = FlatButton(
      child: Text(
        "确认",
      ),
      onPressed: (){
        widget.onContinue(selectedType);
      },
    );

    return AlertDialog(
      title: Text("选择以下礼物给${widget.index + 1}号玩家"),
      content: Row(
        children: <Widget>[
          Radio<Type>(
              value: Witch,
              groupValue: selectedType,
              onChanged: (value) {
                print(value);
                setState(() {
                  selectedType = value;
                });
              }),
          Text('毒'),
          Radio<Type>(
              value: Hunter,
              groupValue: selectedType,
              onChanged: (value) {
                print(value);
                setState(() {
                  selectedType = value;
                });
              }),
          Text('枪'),
          Radio<Type>(
              value: Seer,
              groupValue: selectedType,
              onChanged: (value) {
                print(value);
                setState(() {
                  selectedType = value;
                });
              }),
          Text('眼镜'),
        ],
      ),
      actions: [
        cancelButton,
        continueButton,
      ],
    );
  }
}
