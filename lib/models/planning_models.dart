class IngredientRequirement {
  final String name;
  final double amount;
  final String unit;

  IngredientRequirement({
    required this.name,
    required this.amount,
    required this.unit,
  });
}

class CookingTask {
  final String menuName;
  final int quantity;
  final String deliveryTime;
  final String customerName;
  final DateTime estimatedStartTime;
  final DateTime deliveryDateTime; // 追加

  CookingTask({
    required this.menuName,
    required this.quantity,
    required this.deliveryTime,
    required this.customerName,
    required this.estimatedStartTime,
    required this.deliveryDateTime,
  });
}
