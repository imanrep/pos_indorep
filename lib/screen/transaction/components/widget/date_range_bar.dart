import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateRangeBar extends StatelessWidget {
  final DateTimeRange selectedRange;
  final void Function(DateTimeRange newRange) onRangeChanged;

  const DateRangeBar({
    super.key,
    required this.selectedRange,
    required this.onRangeChanged,
  });

  void _pickRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2025),
      lastDate: DateTime.now(),
      initialDateRange: selectedRange,
    );

    if (picked != null && picked != selectedRange) {
      onRangeChanged(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isToday = selectedRange.end.year == DateTime.now().year &&
        selectedRange.end.month == DateTime.now().month &&
        selectedRange.end.day == DateTime.now().day;

    final String startText = DateFormat('dd MMM').format(selectedRange.start);
    final String endText = DateFormat('dd MMM yyyy').format(selectedRange.end);

    final String label = '$startText - $endText';

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () => _pickRange(context),
            child: Text(
              label,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
