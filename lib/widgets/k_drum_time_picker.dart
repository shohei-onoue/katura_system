import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'k_responsive.dart';

class KDrumTimePicker extends StatefulWidget {
  final TimeOfDay minTime;
  final TimeOfDay maxTime;
  final int interval;
  final DateTime? selectedDateTime;
  final Function(DateTime) onTimeSelected;
  final Color themeColor;

  const KDrumTimePicker({
    super.key,
    required this.minTime,
    required this.maxTime,
    required this.interval,
    this.selectedDateTime,
    required this.onTimeSelected,
    this.themeColor = Colors.deepPurple,
  });

  @override
  State<KDrumTimePicker> createState() => _KDrumTimePickerState();
}

class _KDrumTimePickerState extends State<KDrumTimePicker> {
  late List<DateTime> _slots;
  FixedExtentScrollController? _scrollController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _generateSlots();
    _updateSelectedIndex();
  }

  @override
  void didUpdateWidget(KDrumTimePicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.minTime != widget.minTime ||
        oldWidget.maxTime != widget.maxTime ||
        oldWidget.interval != widget.interval ||
        oldWidget.selectedDateTime?.day != widget.selectedDateTime?.day) {
      _generateSlots();
      _updateSelectedIndex();
      // スロットが変わった場合、現在のインデックスを再設定
      _scrollController?.jumpToItem(_currentIndex);
    } else if (oldWidget.selectedDateTime != widget.selectedDateTime) {
      _updateSelectedIndex();
      if (_scrollController != null && _scrollController!.hasClients) {
        _scrollController!.animateToItem(
          _currentIndex,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    }
  }

  void _generateSlots() {
    _slots = [];
    final now = widget.selectedDateTime ?? DateTime.now();
    
    final startMinutes = widget.minTime.hour * 60 + widget.minTime.minute;
    final endMinutes = widget.maxTime.hour * 60 + widget.maxTime.minute;
    
    int currentM = startMinutes;
    while (currentM <= endMinutes) {
      _slots.add(DateTime(now.year, now.month, now.day, currentM ~/ 60, currentM % 60));
      currentM += widget.interval;
    }

    if (_slots.isEmpty) {
      _slots.add(DateTime(now.year, now.month, now.day, 12, 0));
    }
  }

  void _updateSelectedIndex() {
    if (widget.selectedDateTime == null) {
      _currentIndex = 0;
      return;
    }
    
    _currentIndex = _slots.indexWhere((dt) => 
      dt.hour == widget.selectedDateTime!.hour && 
      dt.minute == widget.selectedDateTime!.minute
    );
    
    if (_currentIndex == -1) _currentIndex = 0;
    
    _scrollController?.dispose();
    _scrollController = FixedExtentScrollController(initialItem: _currentIndex);
  }

  @override
  void dispose() {
    _scrollController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: rav(context, 80),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(rav(context, 12)),
        border: Border.all(color: widget.themeColor.withValues(alpha: 0.2)),
      ),
      child: CupertinoPicker(
        scrollController: _scrollController,
        itemExtent: rav(context, 40),
        onSelectedItemChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
          widget.onTimeSelected(_slots[index]);
        },
        children: _slots.map((dt) {
          final isSelected = _slots.indexOf(dt) == _currentIndex;
          return Center(
            child: Text(
              "${dt.hour}:${dt.minute.toString().padLeft(2, '0')}",
              style: TextStyle(
                fontSize: rf(context, 18),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? widget.themeColor : Colors.black87,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
