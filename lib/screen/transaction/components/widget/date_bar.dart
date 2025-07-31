import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateBar extends StatelessWidget {
  final DateTime selectedDate;
  final void Function(DateTime newDate) onDateChanged;

  const DateBar({
    super.key,
    required this.selectedDate,
    required this.onDateChanged,
  });

  void _pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2025),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != selectedDate) {
      onDateChanged(picked);
    }
  }

  void _changeDate(int offset) {
    final newDate = selectedDate.add(Duration(days: offset));
    onDateChanged(newDate);
  }

  @override
  Widget build(BuildContext context) {
    final formatted = DateFormat('dd MMM yyyy').format(selectedDate);
    String isToday = selectedDate.year == DateTime.now().year &&
            selectedDate.month == DateTime.now().month &&
            selectedDate.day == DateTime.now().day
        ? 'Hari Ini'
        : formatted;

    return Padding(
      padding: const EdgeInsets.all(0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_left_rounded, size: 32),
            onPressed: () => _changeDate(-1),
          ),
          const SizedBox(width: 24),
          GestureDetector(
            onTap: () => _pickDate(context),
            child: Text(
              isToday,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 20,
                  ),
            ),
          ),
          const SizedBox(width: 24),
          (selectedDate.year == DateTime.now().year &&
                  selectedDate.month == DateTime.now().month &&
                  selectedDate.day == DateTime.now().day)
              ? const SizedBox(width: 32)
              : IconButton(
                  icon: const Icon(Icons.arrow_right_rounded, size: 32),
                  onPressed: () => _changeDate(1),
                ),
          // ...existing code...
        ],
      ),
    );
  }
}
