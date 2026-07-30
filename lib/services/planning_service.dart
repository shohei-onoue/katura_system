import '../models/order_model.dart';
import '../models/menu_model.dart';
import '../models/planning_models.dart';

class PlanningService {
  /// 受注データとメニューマスタから必要な食材の総量を集計する
  Map<String, IngredientRequirement> calculateIngredientTotals(
    List<OrderModel> orders,
    List<MenuModel> allMenus,
  ) {
    final Map<String, ({double amount, String unit, Set<String> usedIn})> totals = {};
    final Map<String, MenuModel> menuMap = {for (var m in allMenus) m.id: m};

    for (var order in orders) {
      for (var item in order.items) {
        final menuId = item['id'];
        final quantity = item['quantity'] as int;
        final menu = menuMap[menuId];

        if (menu != null) {
          menu.ingredients.forEach((name, valueStr) {
            final parsed = _parseIngredientValue(valueStr);
            final amount = parsed.amount * quantity;

            if (totals.containsKey(name)) {
              final existing = totals[name]!;
              existing.usedIn.add(menu.name);
              totals[name] = (
                amount: existing.amount + amount,
                unit: existing.unit,
                usedIn: existing.usedIn
              );
            } else {
              totals[name] = (
                amount: amount,
                unit: parsed.unit,
                usedIn: {menu.name}
              );
            }
          });
        }
      }
    }

    return totals.map((name, data) => MapEntry(
      name,
      IngredientRequirement(
        name: name,
        totalQuantity: data.amount,
        unit: data.unit,
        usedInMenus: data.usedIn.toList(),
      ),
    ));
  }

  /// 文字列（例: "100g", "2個"）から数値と単位を抽出する
  ({double amount, String unit}) _parseIngredientValue(String valueStr) {
    final numberMatch = RegExp(r'^(\d+(\.\d+)?)').firstMatch(valueStr);
    if (numberMatch != null) {
      final amount = double.parse(numberMatch.group(1)!);
      final unit = valueStr.substring(numberMatch.end).trim();
      return (amount: amount, unit: unit);
    }
    return (amount: 1.0, unit: valueStr);
  }

  /// 配達時間から逆算して調理スケジュール（タスク一覧）を生成する
  List<CookingTask> generateCookingSchedule(List<OrderModel> orders) {
    final List<CookingTask> tasks = [];

    for (var order in orders) {
      final timeParts = order.deliveryTime.split(':');
      if (timeParts.length == 2) {
        final hour = int.tryParse(timeParts[0]) ?? 0;
        final minute = int.tryParse(timeParts[1]) ?? 0;
        
        final deliveryDateTime = DateTime(2024, 1, 1, hour, minute);

        for (var item in order.items) {
          // 調理開始時間の簡易見積もり（配達の90分前を準備・調理開始とする）
          final startDt = deliveryDateTime.subtract(const Duration(minutes: 90));
          
          final startTime = "${startDt.hour}:${startDt.minute.toString().padLeft(2, '0')}";
          final endTime = "${deliveryDateTime.hour}:${deliveryDateTime.minute.toString().padLeft(2, '0')}";

          tasks.add(CookingTask(
            menuName: item['name'] ?? '不明',
            quantity: item['quantity'] as int,
            startTime: startTime,
            endTime: endTime,
            deliveryTime: order.deliveryTime,
            customerName: order.customerName,
            branchName: order.branchName,
          ));
        }
      }
    }

    // 開始時間の早い順にソート
    tasks.sort((a, b) => a.startTime.compareTo(b.startTime));
    return tasks;
  }
}
