class IngredientRequirement {
  final String name;
  final double totalQuantity;
  final String unit;
  final List<String> usedInMenus;

  IngredientRequirement({
    required this.name,
    required this.totalQuantity,
    required this.unit,
    required this.usedInMenus,
  });
}

class CookingTask {
  final String menuName;
  final int quantity;
  final String startTime;
  final String endTime;
  final String deliveryTime;
  final String customerName;
  final String branchName;

  CookingTask({
    required this.menuName,
    required this.quantity,
    required this.startTime,
    required this.endTime,
    required this.deliveryTime,
    required this.customerName,
    required this.branchName,
  });
}
