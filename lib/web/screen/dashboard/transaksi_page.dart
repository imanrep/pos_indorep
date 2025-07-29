import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:pos_indorep/services/web_services.dart';
import 'package:pos_indorep/web/screen/dashboard/components/beverages_form.dart';
import 'package:pos_indorep/web/screen/dashboard/components/beverages_transaction_list.dart';
import 'package:pos_indorep/web/screen/dashboard/components/warnet_form.dart';
import 'package:pos_indorep/web/screen/dashboard/components/warnet_transaction_list.dart';

class TransaksiPage extends StatefulWidget {
  const TransaksiPage({super.key});

  @override
  State<TransaksiPage> createState() => _TransaksiPageState();
}

class _TransaksiPageState extends State<TransaksiPage> {
  final WebServices _services = WebServices();
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: LayoutBuilder(
          builder: (context, constraints) {
            bool isWide =
                constraints.maxWidth > 800; // adjust breakpoint as needed
            Widget warnetSection = SizedBox(
              width: isWide ? constraints.maxWidth / 2 - 12 : double.infinity,
              child: StreamBuilder<QuerySnapshot>(
                stream: _services.getWarnetEntriesByDate(DateTime.now()),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CupertinoActivityIndicator());
                  }
                  return Column(
                    children: [
                      WarnetForm(),
                      WarnetTransactionList(),
                    ],
                  );
                },
              ),
            );
            Widget beveragesSection = SizedBox(
              width: isWide ? constraints.maxWidth / 2 - 12 : double.infinity,
              child: StreamBuilder<QuerySnapshot>(
                stream: _services.getWarnetEntriesByDate(DateTime.now()),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CupertinoActivityIndicator());
                  }
                  return Column(
                    children: [
                      BeveragesForm(),
                      BeveragesTransactionList(),
                    ],
                  );
                },
              ),
            );
            if (isWide) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  warnetSection,
                  const SizedBox(width: 8),
                  beveragesSection,
                ],
              );
            } else {
              return Column(
                children: [
                  warnetSection,
                  const SizedBox(height: 24),
                  beveragesSection,
                ],
              );
            }
          },
        ),
      ),
    );
  }
}
