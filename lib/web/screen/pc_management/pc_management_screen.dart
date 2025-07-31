import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pos_indorep/helper/helper.dart';
import 'package:pos_indorep/services/icafe_services.dart';
import 'package:pos_indorep/web/components/pcs_list_view.dart';

class PcManagementScreen extends StatefulWidget {
  const PcManagementScreen({super.key});

  @override
  State<PcManagementScreen> createState() => _PcManagementScreenState();
}

class _PcManagementScreenState extends State<PcManagementScreen> {
  final ICafeServices _icafeServices = ICafeServices();
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: IndorepColor.primary, width: 1.5),
                ),
                elevation: 2,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Center(
                        child: Text(
                          "INDOREP PC's Management",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                    ),
                    FutureBuilder(
                        future: _icafeServices.getPCs('', ''),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CupertinoActivityIndicator());
                          }
                          if (snapshot.hasError) {
                            return Center(
                                child: Text('Error: ${snapshot.error}'));
                          }
                          final pcs = snapshot.data!.data;
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8.0, vertical: 4.0),
                            child: ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: pcs.length,
                              itemBuilder: (context, index) {
                                final pcData = pcs[index];
                                return PcsTableView(pcs: [pcData]);
                              },
                            ),
                            // Wrap(
                            //   children: List.generate(
                            //     pcs.length,
                            //     (index) => SizedBox(
                            //       width:
                            //           180, // Set a fixed or calculated width for each card
                            //       child:
                            //           PcsGrid(pcData: pcs[index]),
                            //     ),
                            //   ),
                            // ),
                          );
                        }),
                  ],
                ),
              ),
            ],
          )),
    );
  }
}
