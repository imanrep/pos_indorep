import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pos_indorep/screen/transaction/components/widget/date_range_picker.dart';
import 'package:pos_indorep/screen/transaction/components/widget/summary_box_widget.dart';

class RekapBottomSheet extends StatefulWidget {
  const RekapBottomSheet({super.key});

  @override
  State<RekapBottomSheet> createState() => _RekapBottomSheetState();
}

class _RekapBottomSheetState extends State<RekapBottomSheet> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Rekap Transaksi', style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 18)),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Hari ini', style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 16)),
              const SizedBox(height: 8),
              Wrap(
                children: [
                  SummaryBoxWidget(title: "Total Income", subtitle: "Rp.1.000.000"),
                  SummaryBoxWidget(title: "Total Keuntungan", subtitle: "Rp.600.000"),
                  SummaryBoxWidget(title: "Total Item Terjual", subtitle: "10"),
                  SummaryBoxWidget(title: "Total Transaksi", subtitle: "10"),
                ],
              ),
              const SizedBox(height: 16),
          
              ElevatedButton(
                onPressed: () {
                  // Implement export functionality
                },
                child: Text('Export to CSV'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}