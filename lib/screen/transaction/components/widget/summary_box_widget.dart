import 'package:flutter/material.dart';

class SummaryBoxWidget extends StatefulWidget {
  final String title;
  final String subtitle;
  const SummaryBoxWidget({super.key, required this.title, required this.subtitle});

  @override
  State<SummaryBoxWidget> createState() => _SummaryBoxWidgetState();
}

class _SummaryBoxWidgetState extends State<SummaryBoxWidget> {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.title,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(widget.subtitle),
          ],
        ),
      ),
    );
  }
}