import 'package:fluent_ui/fluent_ui.dart';
import 'package:intl/intl.dart';

class FluentDateBar extends StatelessWidget {
  final DateTime selectedDate;
  final void Function(DateTime newDate) onDateChanged;

  const FluentDateBar({
    super.key,
    required this.selectedDate,
    required this.onDateChanged,
  });

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

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Button(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: const Icon(FluentIcons.chevron_left, size: 8),
          ),
          onPressed: () => _changeDate(-1),
        ),
        const SizedBox(width: 24),
        DatePicker(
          selected: selectedDate,
          fieldFlex: const [2, 3, 2], // Same order as fieldOrder
          onChanged: (time) => onDateChanged(time),
        ),
        const SizedBox(width: 24),
        (selectedDate.year == DateTime.now().year &&
                selectedDate.month == DateTime.now().month &&
                selectedDate.day == DateTime.now().day)
            ? const SizedBox(width: 32)
            : Button(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: const Icon(FluentIcons.chevron_right, size: 8),
                ),
                onPressed: () => _changeDate(1),
              ),
      ],
    );
  }
}
