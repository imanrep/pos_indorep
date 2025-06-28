import 'package:flutter/material.dart';

class DateRangePicker extends StatefulWidget {
  @override
  _DateRangePickerState createState() => _DateRangePickerState();
}

class _DateRangePickerState extends State<DateRangePicker> {
  DateTime? _startDate;
  DateTime? _endDate;

  Future<void> _pickStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime(2025, 1, 1), // Set start limit
    lastDate: _endDate ?? DateTime(2035, 12, 31), // Set end limit
    );
    if (picked != null && picked != _startDate) {
      setState(() {
        _startDate = picked;
        if (_endDate != null && _endDate!.isBefore(_startDate!)) {
          _endDate = null;
        }
      });
    }
  }

  Future<void> _pickEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? (_startDate ?? DateTime.now()),
      firstDate: DateTime(2025, 1, 1), // Set start limit
    lastDate: _endDate ?? DateTime(2035, 12, 31), // Set end limit
    );
    if (picked != null && picked != _endDate) {
      setState(() {
        _endDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => _pickStartDate(context),
            child: Text(_startDate == null
                ? 'Select Start Date'
                : _startDate!.toLocal().toString().split(' ')[0]),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: OutlinedButton(
            onPressed: _startDate == null ? null : () => _pickEndDate(context),
            child: Text(_endDate == null
                ? 'Select End Date'
                : _endDate!.toLocal().toString().split(' ')[0]),
          ),
        ),
      ],
    );
  }
}