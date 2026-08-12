import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'k_responsive.dart';

class KDrumDatePicker extends StatefulWidget {
  final DateTime selectedDate;
  final Function(DateTime) onDateSelected;
  final Color themeColor;
  final DateTime? firstDate;
  final DateTime? lastDate;

  const KDrumDatePicker({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
    this.themeColor = Colors.deepPurple,
    this.firstDate,
    this.lastDate,
  });

  @override
  State<KDrumDatePicker> createState() => _KDrumDatePickerState();
}

class _KDrumDatePickerState extends State<KDrumDatePicker> {
  late List<DateTime> _dates;
  FixedExtentScrollController? _scrollController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _generateDates();
    _updateSelectedIndex();
  }

  @override
  void didUpdateWidget(KDrumDatePicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.firstDate != widget.firstDate || oldWidget.lastDate != widget.lastDate) {
      _generateDates();
      _updateSelectedIndex();
      _scrollController?.jumpToItem(_currentIndex);
    } else if (!DateUtils.isSameDay(oldWidget.selectedDate, widget.selectedDate)) {
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

  void _generateDates() {
    _dates = [];
    final first = widget.firstDate ?? DateTime.now().subtract(const Duration(days: 30));
    final last = widget.lastDate ?? DateTime.now().add(const Duration(days: 365));
    
    DateTime current = DateTime(first.year, first.month, first.day);
    final end = DateTime(last.year, last.month, last.day);
    
    while (!current.isAfter(end)) {
      _dates.add(current);
      current = current.add(const Duration(days: 1));
    }

    if (_dates.isEmpty) {
      _dates.add(DateTime.now());
    }
  }

  void _updateSelectedIndex() {
    _currentIndex = _dates.indexWhere((d) => DateUtils.isSameDay(d, widget.selectedDate));
    if (_currentIndex == -1) _currentIndex = 0;
    
    _scrollController?.dispose();
    _scrollController = FixedExtentScrollController(initialItem: _currentIndex);
  }

  @override
  void dispose() {
    _scrollController?.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    final formatter = DateFormat('yyyy年M月d日(E)', 'ja_JP');
    return formatter.format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: rav(context, 100),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(rav(context, 12)),
        border: Border.all(color: widget.themeColor.withValues(alpha: 0.2)),
      ),
      child: CupertinoPicker(
        scrollController: _scrollController,
        itemExtent: rav(context, 44),
        onSelectedItemChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
          widget.onDateSelected(_dates[index]);
        },
        children: _dates.map((date) {
          final isSelected = _dates.indexOf(date) == _currentIndex;
          final isWeekend = date.weekday == DateTime.saturday || date.weekday == DateTime.sunday;
          
          return Center(
            child: Text(
              _formatDate(date),
              style: TextStyle(
                fontSize: rf(context, 18),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected 
                    ? widget.themeColor 
                    : (isWeekend ? Colors.red.shade400 : Colors.black87),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
