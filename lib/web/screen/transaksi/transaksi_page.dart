import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:pos_indorep/provider/web/warnet_backend_provider.dart';
import 'package:pos_indorep/services/web_services.dart';
import 'package:pos_indorep/web/screen/transaksi/components/beverages_form.dart';
import 'package:pos_indorep/web/screen/transaksi/components/beverages_list/beverages_list.dart';
import 'package:pos_indorep/web/screen/transaksi/components/warnet_form.dart';
import 'package:pos_indorep/web/screen/transaksi/components/warnet_member_list/warnet_member_list.dart';
import 'package:provider/provider.dart';

class TransaksiPage extends StatefulWidget {
  const TransaksiPage({super.key});

  @override
  State<TransaksiPage> createState() => _TransaksiPageState();
}

class _TransaksiPageState extends State<TransaksiPage> {
  final WebServices _services = WebServices();
  @override
  Widget build(BuildContext context) {
    return Consumer<WarnetBackendProvider>(builder: (context, provider, child) {
      return ScaffoldPage.scrollable(
        header: PageHeader(
          title: Text(
            'Transaksi',
            style: FluentTheme.of(context).typography.title,
          ),
        ),
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              bool isWide = constraints.maxWidth > 800;
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
                      ],
                    );
                  },
                ),
              );
              Widget memberListSection = SizedBox(
                  width:
                      isWide ? constraints.maxWidth / 2 - 12 : double.infinity,
                  child: provider.allWarnetCustomers == null
                      ? Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Center(child: ProgressRing()),
                        )
                      : WarnetMemberList());
              Widget beveragesListSection = SizedBox(
                  width:
                      isWide ? constraints.maxWidth / 2 - 12 : double.infinity,
                  child: provider.allWarnetCustomers == null
                      ? Center(child: ProgressRing())
                      : BeveragesList());
              if (isWide) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        memberListSection,
                        beveragesListSection,
                      ],
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        warnetSection,
                        beveragesSection,
                      ],
                    ),
                  ],
                );
              } else {
                return Column(
                  children: [
                    memberListSection,
                    beveragesListSection,
                    warnetSection,
                    beveragesSection,
                  ],
                );
              }
            },
          ),
        ],
      );
    });
  }
}
