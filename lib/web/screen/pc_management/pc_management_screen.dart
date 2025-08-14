import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:pos_indorep/helper/helper.dart';
import 'package:pos_indorep/services/warnet_backend_services.dart';
import 'package:pos_indorep/web/model/pcs_model.dart';

class PcManagementScreen extends StatefulWidget {
  const PcManagementScreen({super.key});

  @override
  State<PcManagementScreen> createState() => _PcManagementScreenState();
}

class _PcManagementScreenState extends State<PcManagementScreen> {
  final WarnetBackendServices _icafeServices = WarnetBackendServices();
  final ValueNotifier<List<Pc>> selectedPcs = ValueNotifier<List<Pc>>([]);

  @override
  void dispose() {
    selectedPcs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage.scrollable(
      header: PageHeader(
        title: Text(
          'PC Management',
          style: FluentTheme.of(context).typography.title,
        ),
      ),
      children: [
        Card(
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 4.0),
            child: FutureBuilder(
              future: _icafeServices.getPCs(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CupertinoActivityIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                      child: Text('Error! Cek kembali apakah API online'));
                }
                final pcs = snapshot.data!.data.pcsInit.pcList;
                return ValueListenableBuilder<List<Pc>>(
                  valueListenable: selectedPcs,
                  builder: (context, selected, _) {
                    return Column(
                      children: [
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: pcs.length,
                          itemBuilder: (context, index) {
                            final pc = pcs[index];
                            bool isPcOnline = pc.statusConnectTimeLocal != null;
                            bool checked = selected.contains(pc);
                            return Expander(
                              leading: Checkbox(
                                  checked: checked,
                                  onChanged: (_) {
                                    if (selected.contains(pc)) {
                                      selected.remove(pc);
                                    } else {
                                      selected.add(pc);
                                    }
                                    selectedPcs.value = List.from(selected);
                                  }),
                              trailing: Container(
                                decoration: BoxDecoration(
                                  color: isPcOnline
                                      ? Colors.green.withValues(alpha: 0.15)
                                      : Colors.red.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0, vertical: 6.0),
                                  child: Text(
                                    isPcOnline ? 'Online' : 'Offline',
                                    style: TextStyle(
                                      color: isPcOnline
                                          ? Colors.green
                                          : Colors.red,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                              ),
                              header: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const SizedBox(width: 8),
                                  Text(
                                    pc.pcName,
                                    style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 12),
                                  ),
                                  const SizedBox(width: 8),
                                  if (isPcOnline)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color:
                                            Colors.blue.withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        '${pc.memberAccount}',
                                        style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500),
                                      ),
                                    )
                                ],
                              ),
                              content: SizedBox(
                                  child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      if (isPcOnline)
                                        Row(
                                          children: [
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 4),
                                              decoration: BoxDecoration(
                                                color: Colors.black
                                                    .withValues(alpha: 0.1),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 8.0,
                                                        vertical: 4.0),
                                                child: Row(
                                                  children: [
                                                    Icon(
                                                      FluentIcons.timer,
                                                    ),
                                                    const SizedBox(width: 12),
                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          'Sisa Waktu :',
                                                          style: TextStyle(
                                                              fontSize: 11,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400),
                                                        ),
                                                        const SizedBox(
                                                            height: 4),
                                                        Text(
                                                          '${Helper.formatPcDateTime(pc.statusConnectTimeLocal!)}',
                                                          style: TextStyle(
                                                            fontSize: 12,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 7),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 4),
                                              decoration: BoxDecoration(
                                                color: Colors.black
                                                    .withValues(alpha: 0.1),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 8.0,
                                                        vertical: 4.0),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      'Start :',
                                                      style: TextStyle(
                                                          fontSize: 11,
                                                          fontWeight:
                                                              FontWeight.w400),
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Text(
                                                      '${Helper.formatPcDateTime(pc.statusConnectTimeLocal!)}',
                                                      style: TextStyle(
                                                          fontSize: 11,
                                                          fontWeight:
                                                              FontWeight.w600),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 7),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 4),
                                              decoration: BoxDecoration(
                                                color: Colors.black
                                                    .withValues(alpha: 0.1),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 8.0,
                                                        vertical: 4.0),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      'End :',
                                                      style: TextStyle(
                                                          fontSize: 11,
                                                          fontWeight:
                                                              FontWeight.w400),
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Text(
                                                      '${Helper.formatPcDateTime(pc.statusConnectTimeLocal!)}',
                                                      style: TextStyle(
                                                          fontSize: 11,
                                                          fontWeight:
                                                              FontWeight.w600),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                    ],
                                  ),
                                  if (isPcOnline) const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Button(
                                          child: Column(
                                            children: [
                                              Icon(CupertinoIcons.play_arrow,
                                                  size: 16),
                                              const SizedBox(height: 4),
                                              Text('Wake Up',
                                                  style:
                                                      TextStyle(fontSize: 10)),
                                            ],
                                          ),
                                          onPressed: () {
                                            // Restart PC logic
                                          }),
                                      const SizedBox(width: 8),
                                      Button(
                                          child: Column(
                                            children: [
                                              Icon(CupertinoIcons.power,
                                                  size: 16),
                                              const SizedBox(height: 4),
                                              Text('Shut Down',
                                                  style:
                                                      TextStyle(fontSize: 10)),
                                            ],
                                          ),
                                          onPressed: () {
                                            // Restart PC logic
                                          }),
                                      const SizedBox(width: 8),
                                      Button(
                                          child: Column(
                                            children: [
                                              Icon(CupertinoIcons.restart,
                                                  size: 16),
                                              const SizedBox(height: 4),
                                              Text('Restart',
                                                  style:
                                                      TextStyle(fontSize: 10)),
                                            ],
                                          ),
                                          onPressed: () {
                                            // Restart PC logic
                                          }),
                                    ],
                                  ),
                                ],
                              )),
                            );
                          },
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
