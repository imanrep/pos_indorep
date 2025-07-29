import 'package:flutter/material.dart';
import 'package:pos_indorep/web/model/pcs_model.dart';

class PcsTableView extends StatelessWidget {
  final List<PcData> pcs;
  const PcsTableView({super.key, required this.pcs});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: const [
          DataColumn(label: Text('PC Name')),
          DataColumn(label: Text('Status')),
        ],
        rows: List.generate(pcs.length, (index) {
          final pc = pcs[index];
          final isOnline = pc.pcInUsing == 1;
          return DataRow(
            cells: [
              DataCell(Row(
                children: [
                  CircleAvatar(
                    backgroundImage: AssetImage('assets/images/pc.png'),
                    backgroundColor: Colors.transparent,
                    radius: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(pc.pcName),
                ],
              )),
              DataCell(
                Text(
                  isOnline ? 'Online' : 'Offline',
                  style: TextStyle(
                    color: isOnline ? Colors.green : Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
