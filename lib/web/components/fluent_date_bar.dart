import 'package:fluent_ui/fluent_ui.dart';
import 'package:intl/intl.dart';

class FluentDateBar extends StatelessWidget {
  final DateTime selectedDate;
  final bool isLoading;
  final void Function(DateTime newDate) onDateChanged;

  const FluentDateBar({
    super.key,
    required this.selectedDate,
    this.isLoading = false,
    required this.onDateChanged,
  });

  // ---- Bounds ----
  static DateTime _minDate = DateTime(2025, 7, 26);

  DateTime _todayDateOnly() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  DateTime _clamp(DateTime d) {
    final date = _dateOnly(d);
    final maxDate = _todayDateOnly();
    if (date.isBefore(_minDate)) return _minDate;
    if (date.isAfter(maxDate)) return maxDate;
    return date;
  }

  void _pickDate(BuildContext context) async {
    final DateTime? picked = await showDialog<DateTime>(
      context: context,
      builder: (context) {
        return ContentDialog(
          title: const Text("Pilih Tanggal"),
          content: DatePicker(
            // The FluentUI DatePicker doesn't expose min/max;
            // we clamp in onChanged + after dialog returns.
            selected: _clamp(selectedDate),
            onChanged: (date) {
              Navigator.pop(context, _clamp(date));
            },
          ),
          actions: [
            Button(
              child: const Text("Batal"),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        );
      },
    );

    if (picked != null) {
      final clamped = _clamp(picked);
      if (clamped != _dateOnly(selectedDate)) {
        onDateChanged(clamped);
      }
    }
  }

  void _changeDate(int offset) {
    final newDate = _clamp(selectedDate.add(Duration(days: offset)));
    if (newDate != _dateOnly(selectedDate)) {
      onDateChanged(newDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    final maxDate = _todayDateOnly();
    final current = _dateOnly(selectedDate);

    final isAtMin = !current.isAfter(_minDate); // current <= min
    final isAtMax = !current.isBefore(maxDate); // current >= max (today)

    final formatted = DateFormat('dd MMM yyyy').format(current);
    final isTodayLabel = current == maxDate ? 'Hari Ini' : formatted;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Previous (disabled at min)
        Button(
          onPressed: (isLoading || isAtMin) ? null : () => _changeDate(-1),
          child: const Padding(
            padding: EdgeInsets.symmetric(vertical: 5.0),
            child: Icon(FluentIcons.chevron_left, size: 14),
          ),
        ),

        const SizedBox(width: 16),

        // Date display (tap to open picker; picker result is clamped)
        Button(
          onPressed: isLoading ? null : () => _pickDate(context),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              isTodayLabel,
              style: theme.typography.bodyStrong?.copyWith(fontSize: 18),
            ),
          ),
        ),

        const SizedBox(width: 16),

        // Next (disabled at max/today; never allows tomorrow)
        Button(
          onPressed: (isLoading || isAtMax) ? null : () => _changeDate(1),
          child: const Padding(
            padding: EdgeInsets.symmetric(vertical: 5.0),
            child: Icon(FluentIcons.chevron_right, size: 14),
          ),
        ),
      ],
    );
  }
}
