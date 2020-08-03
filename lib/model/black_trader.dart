import 'god.dart';

class BlackTrader extends God {
  BlackTrader() : super(roleName: '黑商'){
    super.actionMessage = "请选择收礼玩家";
    super.actionConfirmMessage  = "赠送";
  }
}
