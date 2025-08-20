import 'dart:io';

import 'package:collection/collection.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pos_indorep/helper/helper.dart';
import 'package:pos_indorep/provider/web/warnet_transaksi_provider.dart';
import 'package:pos_indorep/web/model/member_model.dart';
import 'package:pos_indorep/web/screen/transaksi/components/warnet_card/components/member_info_container.dart';
import 'package:provider/provider.dart';

import 'package:pos_indorep/web/screen/transaksi/components/beverages_card/components/beverages_buy_dialog_stub.dart'
    if (dart.library.io) 'package:pos_indorep/web/screen/transaksi/components/warnet_card/components/member_topup_dialog.dart';

class MembersSearchList extends StatefulWidget {
  const MembersSearchList({super.key});

  @override
  State<MembersSearchList> createState() => _MembersSearchListState();
}

class _MembersSearchListState extends State<MembersSearchList> {
  final _asbKey = GlobalKey<AutoSuggestBoxState>(debugLabel: 'MembersASB');
  final _searchCtrl = TextEditingController();
  final ValueNotifier<List<Member>> selectedMembers =
      ValueNotifier<List<Member>>([]);

  @override
  void initState() {
    super.initState();

    // Add listener to search controller
    _searchCtrl.addListener(() {
      if (_asbKey.currentState?.isOverlayVisible ?? false) {
        _asbKey.currentState?.dismissOverlay();
      }
      setState(() {}); // Trigger rebuild to filter the list
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void showTopUpDialog(BuildContext context, Member member) async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => MemberTopupDialog(member: member),
    );
    setState(() {}); // Refresh state after dialog closes
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WarnetTransaksiProvider>();
    final allCustomers = provider.allWarnetCustomers;
    final commandBarKey = GlobalKey<CommandBarState>();

    if (allCustomers == null || allCustomers.members.isEmpty) {
      return const Center(child: Text('No members found.'));
    }

    // Get the full list of members
    final all = allCustomers.members.sorted(
      (a, b) => b.memberUpdateLocal
          .toLowerCase()
          .compareTo(a.memberUpdateLocal.toLowerCase()),
    );

    // Filter the list based on the search query
    final query = _searchCtrl.text.trim().toLowerCase();
    final _displayed = query.isEmpty
        ? all
        : all
            .where((m) => m.memberAccount.toLowerCase().contains(query))
            .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: AutoSuggestBox<String>(
            key: _asbKey,
            controller: _searchCtrl,
            placeholder: 'Cari member yang telah terdaftar',
            items: const <AutoSuggestBoxItem<String>>[],
            onOverlayVisibilityChanged: (v) {
              if (v) _asbKey.currentState?.dismissOverlay();
            },
          ),
        ),
        const SizedBox(height: 12),
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
              icon: Icon(FluentIcons.delete),
              label: Text('Delete', style: TextStyle()),
              tooltip: 'Delete Member',
              onPressed: () {
                // Delete what is currently selected!
              },
            ),
          ],
        ),
        // List of members
        ValueListenableBuilder<List<Member>>(
          valueListenable: selectedMembers,
          builder: (context, selected, _) {
            return SizedBox(
              height: 300,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _displayed.length,
                itemBuilder: (context, index) {
                  final member = _displayed[index];
                  final checked = selected.contains(member);
                  bool isMemberOnline = member.memberIsLogined == 1;
                  return Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Expander(
                      leading: Checkbox(
                        checked: checked,
                        onChanged: (_) {
                          final sel = List<Member>.from(selected);
                          checked ? sel.remove(member) : sel.add(member);
                          selectedMembers.value = sel;
                        },
                      ),
                      trailing: member.memberIsExpired == 0
                          ? Container(
                              decoration: BoxDecoration(
                                color: isMemberOnline
                                    ? Colors.green.withValues(alpha: 0.15)
                                    : Colors.red.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8.0, vertical: 6.0),
                                child: Text(
                                  isMemberOnline ? 'Online' : 'Offline',
                                  style: TextStyle(
                                    color: isMemberOnline
                                        ? Colors.green
                                        : Colors.red,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                            )
                          : Container(
                              decoration: BoxDecoration(
                                color: Colors.yellow.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8.0, vertical: 6.0),
                                child: Text(
                                  'Expired',
                                  style: TextStyle(
                                    color: Colors.yellow,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                            ),
                      header: Text(member.memberAccount,
                          style: GoogleFonts.inter()),
                      content: Column(
                        children: [
                          Wrap(
                            children: [
                              MemberInfoContainer(
                                  title: "Sisa waktu:",
                                  subtitle: member.leftTime,
                                  color: IndorepColor.primary),
                              MemberInfoContainer(
                                  title: "Dibuat pada:",
                                  subtitle: member.memberCreateLocal,
                                  color: IndorepColor.primary),
                              MemberInfoContainer(
                                  title: "Expire pada:",
                                  subtitle: member.memberExpireTimeLocal,
                                  color: IndorepColor.primary),
                              MemberInfoContainer(
                                  title: "Aktivitas terakhir:",
                                  subtitle: member.memberUpdateLocal,
                                  color: IndorepColor.primary),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.topRight,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Button(
                                  child: Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(FluentIcons.history, size: 12),
                                        const SizedBox(width: 8),
                                        Text(
                                          'History',
                                          style:
                                              GoogleFonts.inter(fontSize: 12),
                                        )
                                      ],
                                    ),
                                  ),
                                  onPressed: () {},
                                ),
                                const SizedBox(width: 8),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          Divider(),
                          const SizedBox(height: 8),
                          Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: 8.0, horizontal: 8.0),
                            child: Row(
                              children: [
                                Platform.isWindows
                                    ? FilledButton(
                                        child: Padding(
                                          padding: const EdgeInsets.all(4.0),
                                          child: Row(
                                            children: [
                                              Icon(FluentIcons.add, size: 12),
                                              const SizedBox(width: 8),
                                              Text(
                                                'Top Up',
                                                style: GoogleFonts.inter(
                                                    fontSize: 12),
                                              )
                                            ],
                                          ),
                                        ),
                                        onPressed: () async {
                                          showTopUpDialog(context, member);
                                        },
                                      )
                                    : const Spacer(),
                                const SizedBox(width: 8),
                                Button(
                                  child: Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: Row(
                                      children: [
                                        Icon(FluentIcons.remove, size: 12),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Refund',
                                          style:
                                              GoogleFonts.inter(fontSize: 12),
                                        )
                                      ],
                                    ),
                                  ),
                                  onPressed: () {},
                                ),
                                const Spacer(),
                                Button(
                                  child: Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(FluentIcons.edit, size: 12),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Edit',
                                          style:
                                              GoogleFonts.inter(fontSize: 12),
                                        )
                                      ],
                                    ),
                                  ),
                                  onPressed: () {},
                                ),
                                const SizedBox(width: 8),
                                FilledButton(
                                  style: ButtonStyle(
                                    backgroundColor:
                                        WidgetStateProperty.all(Colors.red),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: Icon(FluentIcons.delete,
                                        size: 16, color: Colors.white),
                                  ),
                                  onPressed: () {},
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }
}
