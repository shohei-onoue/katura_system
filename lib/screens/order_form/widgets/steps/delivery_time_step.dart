import 'package:flutter/material.dart';
import '../../../../widgets/k_choice_group.dart';
import '../../../../widgets/k_date_time_picker.dart';
import '../../../../widgets/k_time_slot_selector.dart';
import '../../../../widgets/k_responsive.dart';
import '../order_form_parts.dart';

class DeliveryTimeStep extends StatelessWidget {
  final DateTime deliveryDate;
  final String deliveryType;
  final DateTime selectedTime;
  final Function(DateTime) onDateSelected;
  final Function(String) onTypeSelected;
  final Function(DateTime) onTimeSelected;

  const DeliveryTimeStep({
    super.key,
    required this.deliveryDate,
    required this.deliveryType,
    required this.selectedTime,
    required this.onDateSelected,
    required this.onTypeSelected,
    required this.onTimeSelected,
  });

  @override
  Widget build(BuildContext context) {
    return OrderFormCard(
      title: '配達日時・区分選択',
      icon: Icons.timer,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: KDateTimePicker(label: '配達日', value: deliveryDate, icon: Icons.calendar_month, onSelected: onDateSelected)),
              SizedBox(width: rs(context, 16)),
              Expanded(child: KChoiceGroup(label: '区分', selectedValue: deliveryType, items: [KChoiceItem(label: '配送', value: '配送'), KChoiceItem(label: '引取', value: '引取')], onSelected: onTypeSelected)),
            ],
          ),
          SizedBox(height: rs(context, 24)),
          KTimeSlotSelector(label: '希望時間枠', selectedTime: selectedTime, onSelected: onTimeSelected),
        ],
      ),
    );
  }
}
