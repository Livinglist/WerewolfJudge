import 'package:flutter/material.dart';

class InstructionPage extends StatefulWidget {
  @override
  _InstructionPageState createState() => _InstructionPageState();
}

class _InstructionPageState extends State<InstructionPage> {
  final scrollController = ScrollController();
  PageController pageController = PageController(
    initialPage: 0,
  );
  PageController pageController2 = PageController(
    initialPage: 0,
  );
  bool showShadow = false;

  @override
  void initState() {
    scrollController.addListener(() {
      if (this.mounted) {
        if (scrollController.offset <= 0) {
          setState(() {
            showShadow = false;
          });
        } else if (showShadow == false) {
          setState(() {
            showShadow = true;
          });
        }
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Widget cancelButton = TextButton(
        child: Text("取消"),
        onPressed: () {
          pageController.previousPage(duration: Duration(milliseconds: 200), curve: Curves.fastOutSlowIn);
        });
    Widget continueButton = TextButton(
      child: Text("确定"),
      onPressed: () {
        pageController.nextPage(duration: Duration(milliseconds: 200), curve: Curves.fastOutSlowIn);
      },
    );

    Widget continueButton2 = TextButton(
      child: Text("确定"),
      onPressed: () {
        pageController2.nextPage(duration: Duration(milliseconds: 200), curve: Curves.fastOutSlowIn);
      },
    );

    return Scaffold(
      backgroundColor: Colors.orange,
      appBar: AppBar(
        elevation: showShadow ? 8 : 0,
      ),
      body: ListView(
        controller: scrollController,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              '1. 点击空位即可入座，入座后点击自己的位置即可离席，点击其他空位可以更换座位。\n2. 待所有人入座，且房主点击"开始看牌"后，玩家方可查看自己的底牌。',
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Divider(),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              '1. 当场上有与普通狼人同时见面的技能狼时，狼人夜由技能狼开刀。\n2. 当场上没有与普通狼人同时见面的技能狼时，狼人夜由座位号最小的普通狼人开刀。\n3. 与普通狼人见面的技能狼（如狼美人，白狼王等），在其单独的回合使用其技能。\n4. 在确认完技能发动的对象或状态后，当前角色的回合会立刻结束，进行到下一个角色的回合。故狼人在狼人夜请先讨论战术后，方可开刀。',
            ),
          ),
          Container(
            height: 240,
            child: PageView(
              controller: pageController,
              children: <Widget>[
                AlertDialog(
                  title: Text("使用技能"),
                  content: Text("确定猎杀2号玩家？"),
                  elevation: 8,
                  actions: [
                    cancelButton,
                    continueButton,
                  ],
                ),
                AlertDialog(
                  title: Text("使用技能"),
                  content: Text("确定毒杀2号玩家？"),
                  elevation: 8,
                  actions: [
                    cancelButton,
                    continueButton,
                  ],
                ),
                AlertDialog(
                  title: Text("不发动技能"),
                  content: Text("确定不发动技能吗？"),
                  elevation: 8,
                  actions: [
                    cancelButton,
                    continueButton,
                  ],
                ),
              ],
            ),
          ),
          Container(
            height: 240,
            child: PageView(
              controller: pageController2,
              children: <Widget>[
                AlertDialog(
                  title: Text("你的技能发动状态是"),
                  content: Text("可以发动"),
                  elevation: 8,
                  actions: [
                    continueButton2,
                  ],
                ),
                AlertDialog(
                  title: Text("你的技能发动状态是"),
                  content: Text("不可发动"),
                  elevation: 8,
                  actions: [
                    continueButton2,
                  ],
                ),
              ],
            ),
          ),
          Center(
            child: Text(
              '猎人或白狼王的技能发动状态',
              style: TextStyle(color: Colors.black54),
            ),
          ),
          SizedBox(
            height: 36,
          )
        ],
      ),
    );
  }
}
