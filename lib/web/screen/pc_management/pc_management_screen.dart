import 'dart:async';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:pos_indorep/helper/helper.dart';
import 'package:pos_indorep/provider/web/warnet_backend_provider.dart';
import 'package:pos_indorep/provider/web/warnet_dashboard_provider.dart';
import 'package:pos_indorep/web/model/member_model.dart';
import 'package:pos_indorep/web/model/pcs_model.dart';
import 'package:provider/provider.dart';

class PcManagementScreen extends StatefulWidget {
  const PcManagementScreen({super.key});

  @override
  State<PcManagementScreen> createState() => _PcManagementScreenState();
}

class _PcManagementScreenState extends State<PcManagementScreen> {
  final ValueNotifier<List<Pc>> selectedPcs = ValueNotifier<List<Pc>>([]);
  final commandBarKey = GlobalKey<CommandBarState>();
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    // Fetch data initially
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<WarnetDashboardProvider>(context, listen: false)
          .init();
    });

    // Set up a periodic timer to fetch data every 5 seconds
    _timer = Timer.periodic(Duration(seconds: 5), (_) {
      Provider.of<WarnetDashboardProvider>(context, listen: false)
          .init;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
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
            child: Consumer<WarnetDashboardProvider>(
              builder: (context, provider, child) {
                if (provider.totalPC == 0) {
                  return const Center(child: CupertinoActivityIndicator());
                }
                final pcs = provider.pcs;
                return ValueListenableBuilder<List<Pc>>(
                  valueListenable: selectedPcs,
                  builder: (context, selected, _) {
                    final warnetBackendProvider = Provider.of<WarnetTransaksiProvider>(context);
    final members = warnetBackendProvider.allWarnetCustomers?.members ?? [];
                    return Column(
                      children: [
                        CommandBar(
  key: commandBarKey, 
  overflowBehavior: CommandBarOverflowBehavior.dynamicOverflow,
  isCompact: true,
  primaryItems: [
    CommandBarButton(
      icon: const Icon(FluentIcons.add),
      label: const Text('Top Up'),
      tooltip: 'Top Up Member',
      onPressed: () {
        // Create something new!
      },
    ),
    const CommandBarSeparator(),
    CommandBarButton(
      icon: const Icon(FluentIcons.remove),
      label: const Text('Refund'),
      tooltip: 'Refund Member',
      onPressed: () {
        // Create something new!
      },
    ),
    const CommandBarSeparator(),
    CommandBarButton(
      icon: const Icon(FluentIcons.edit),
      label: const Text('Edit'),
      tooltip: 'Edit Member!',
      onPressed: () {
        // Create something new!
      },
    ),
    const CommandBarSeparator(),
    CommandBarButton(
      icon:  Icon(FluentIcons.delete),
      label:  Text('Delete', style: TextStyle()),
      tooltip: 'Delete Member',
      onPressed: () {
        // Delete what is currently selected!
      },
    ),
  ],
),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: pcs.length,
                          itemBuilder: (context, index) {
                            final pc = pcs[index];
                            bool isPcOnline = pc.statusConnectTimeLocal != null;
                            bool checked = selected.contains(pc);
                            String? timeLeft;
            if (isPcOnline && pc.memberAccount != null) {
              final username = pc.memberAccount!;
             final member = members.firstWhere(
        (m) => m.memberAccount == username,
        orElse: () => Member(memberId: 0, memberAccount: "", memberBalance: 0, memberExpireTimeLocal: "", memberIsActive: 0, memberCreateLocal: "", memberUpdateLocal: "", memberIsExpired: 0, memberIsLogined: 1, memberGroupName: "", leftTime: ""),
      );
      timeLeft = member.leftTime;
    }
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
                              header: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const SizedBox(width: 8),
                                  Container(
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
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                               const SizedBox(width: 8),
                               Text(
                                    pc.pcName,
                                    style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 12),
                                  ),
                                  isPcOnline ?
                                    Row(
                                      children: [
                                         const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color:
                                                Colors.blue.withValues(alpha: 0.15),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            '${pc.memberAccount}',
                                            style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color:
                                                Colors.blue.withValues(alpha: 0.15),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            timeLeft ?? 'Personal',
                                            style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500),
                                          ),
                                        ),
                                      ],
                                    ) : const SizedBox.shrink(),
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
                                                          timeLeft ?? 'Personal',
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
