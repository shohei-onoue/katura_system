import '../models/order_model.dart';
import '../models/menu_model.dart';
import '../models/planning_models.dart';

class PlanningService {
  /// 受注データとメニューマスタから必要な食材の総量を集計する（店舗フィルタ対応）
  Map<String, IngredientRequirement> calculateTotalIngredients(
    List<OrderModel> orders,
    List<MenuModel> allMenus,
    String? branchName,
  ) {
    final Map<String, IngredientRequirement> totals = {};
    final Map<String, MenuModel> menuMap = {for (var m in allMenus) m.id: m};

    final filteredOrders = branchName == null || branchName == 'すべて'
        ? orders
        : orders.where((o) => o.branchName == branchName).toList();

    for (var order in filteredOrders) {
      for (var item in order.items) {
        final menuId = item['id']; // OrderModel.items の map には 'id' (menuId) が入っている
        final quantity = item['quantity'] as int;
        final menu = menuMap[menuId];

        if (menu != null) {
          menu.ingredients.forEach((name, valueStr) {
            final parsed = _parseIngredientValue(valueStr);
            final amount = parsed.amount * quantity;

            if (totals.containsKey(name)) {
              final existing = totals[name]!;
              totals[name] = IngredientRequirement(
                name: name,
                amount: existing.amount + amount,
                unit: existing.unit,
              );
            } else {
              totals[name] = IngredientRequirement(
                name: name,
                amount: amount,
                unit: parsed.unit,
              );
            }
          });
        }
      }
    }
    return totals;
  }

  /// 文字列（例: "100g", "2個"）から数値と単位を抽出する
  ({double amount, String unit}) _parseIngredientValue(String valueStr) {
    final numberMatch = RegExp(r'^(\d+(\.\d+)?)').firstMatch(valueStr);
    if (numberMatch != null) {
      final amount = double.parse(numberMatch.group(1)!);
      final unit = valueStr.substring(numberMatch.end).trim();
      return (amount: amount, unit: unit);
    }
    // 数値が取れない場合は、その文字列全体を単位とし、数量を1とする
    return (amount: 1.0, unit: valueStr);
  }

  /// 配達時間から逆算して調理スケジュール（タスク一覧）を生成する（店舗フィルタ対応）
  List<CookingTask> generateCookingSchedule(
    List<OrderModel> orders,
    String? branchName,
  ) {
    final List<CookingTask> tasks = [];
    final filteredOrders = branchName == null || branchName == 'すべて'
        ? orders
        : orders.where((o) => o.branchName == branchName).toList();

    for (var order in filteredOrders) {
      final timeParts = order.deliveryTime.split(':');
      if (timeParts.length == 2) {
        final hour = int.tryParse(timeParts[0]) ?? 0;
        final minute = int.tryParse(timeParts[1]) ?? 0;
        
        final deliveryDateTime = DateTime(
          order.deliveryDate.year,
          order.deliveryDate.month,
          order.deliveryDate.day,
          hour,
          minute,
        );

        for (var item in order.items) {
          // 調理開始時間の簡易見積もり（配達の90分前を準備・調理開始とする）
          final startTime = deliveryDateTime.subtract(const Duration(minutes: 90));

          tasks.add(CookingTask(
            menuName: item['name'] ?? '不明',
            quantity: item['quantity'] as int,
            deliveryTime: order.deliveryTime,
            customerName: order.customerName,
            estimatedStartTime: startTime,
            deliveryDateTime: deliveryDateTime,
          ));
        }
      }
    }

    // 調理開始時間の早い順にソート
    tasks.sort((a, b) => a.estimatedStartTime.compareTo(b.estimatedStartTime));
    return tasks;
  }
}
