import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class DateBar extends StatelessWidget {
  final DateTime selectedDate;
  final bool isLoading;
  final void Function(DateTime newDate) onDateChanged;

  const DateBar({
    super.key,
    required this.selectedDate,
    this.isLoading = false,
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
            icon: CircleAvatar(
              backgroundColor: Theme.of(context)
                  .colorScheme
                  .primaryContainer
                  .withValues(alpha: 0.2),
              child: Icon(
                Icons.arrow_left_rounded,
                size: 32,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
            onPressed: isLoading ? null : () => _changeDate(-1),
          ),
          const SizedBox(width: 24),
          GestureDetector(
            onTap: () => _pickDate(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .primaryContainer
                    .withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(32),
              ),
              child: Text(
                isToday,
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
            ),
          ),
          const SizedBox(width: 24),
          (selectedDate.year == DateTime.now().year &&
                  selectedDate.month == DateTime.now().month &&
                  selectedDate.day == DateTime.now().day)
              ? const SizedBox(width: 32)
              : IconButton(
                  icon: CircleAvatar(
                    backgroundColor: Theme.of(context)
                        .colorScheme
                        .primaryContainer
                        .withValues(alpha: 0.2),
                    child: Icon(
                      Icons.arrow_right_rounded,
                      size: 32,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                  onPressed: isLoading ? null : () => _changeDate(1),
                ),
          // ...existing code...
        ],
      ),
    );
  }
}
