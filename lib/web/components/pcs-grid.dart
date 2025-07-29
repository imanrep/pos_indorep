// import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pos_indorep/web/model/pcs_model.dart';

class PcsGrid extends StatelessWidget {
  final PcData pcData;
  const PcsGrid({super.key, required this.pcData});

  @override
  Widget build(BuildContext context) {
    bool isOnline = pcData.pcInUsing == 1;
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Theme.of(context).colorScheme.primary,
          width: 1.5,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          // showDialog(
          //   context: context,
          //   builder: (context) {
          //     return AlertDialog(
          //       title: Text('Add New PC'),
          //       content: Column(
          //         mainAxisSize: MainAxisSize.min,
          //         children: [
          //         ],
          //       ),
          //       actions: [
          //         TextButton(
          //           onPressed: () async {
          //             await _addNewPC();
          //             Navigator.of(context).pop();
          //           },
          //           child: Text('OK'),
          //         ),
          //       ],
          //     );
          //   },
          // );
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Text(
              pcData.pcName,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Image.asset(
                'assets/images/pc.png',
                width: 50,
                height: 50,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: isOnline ? Colors.green : Colors.grey,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                isOnline ? 'Online' : 'Offline',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
