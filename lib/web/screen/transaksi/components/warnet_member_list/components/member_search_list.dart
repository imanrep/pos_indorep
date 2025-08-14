import 'package:collection/collection.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pos_indorep/helper/helper.dart';
import 'package:pos_indorep/provider/web/warnet_backend_provider.dart';
import 'package:pos_indorep/web/model/member_model.dart';
import 'package:pos_indorep/web/screen/transaksi/components/warnet_member_list/components/member_info_container.dart';
import 'package:pos_indorep/web/screen/transaksi/components/warnet_member_list/components/member_topup_dialog.dart';
import 'package:provider/provider.dart';

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

  late List<Member> _displayed; // what ListView shows
  @override
  void initState() {
    super.initState();
    _displayed = []; // Defensive: start with empty list

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<WarnetBackendProvider>();
      final allCustomers = provider.allWarnetCustomers;
      if (allCustomers == null || allCustomers.members.isEmpty) return;

      final all = allCustomers.members.sorted(
        (a, b) => b.memberUpdateLocal
            .toLowerCase()
            .compareTo(a.memberUpdateLocal.toLowerCase()),
      );
      setState(() {
        _displayed = List<Member>.from(all);
      });

      _searchCtrl.addListener(() {
        if (_asbKey.currentState?.isOverlayVisible ?? false) {
          _asbKey.currentState?.dismissOverlay();
        }
        final q = _searchCtrl.text.trim().toLowerCase();
        setState(() {
          if (q.isEmpty) {
            _displayed = List<Member>.from(all);
          } else {
            _displayed = all
                .where((m) => m.memberAccount.toLowerCase().contains(q))
                .toList();
          }
        });
      });
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void showContentDialog(BuildContext context, Member member) async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => MemberTopupDialog(member: member),
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WarnetBackendProvider>();
    final allCustomers = provider.allWarnetCustomers;

    if (allCustomers == null || allCustomers.members.isEmpty) {
      return const Center(child: Text('No members found.'));
    }
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
            // Give it an empty items list so it won’t pop an overlay.
            items: const <AutoSuggestBoxItem<String>>[],
            // Belt & suspenders: if something triggers overlay, hide it.
            onOverlayVisibilityChanged: (v) {
              if (v) _asbKey.currentState?.dismissOverlay();
            },
          ),
        ),
        const SizedBox(height: 12),

        // Your selectable list, but feed it from _displayed
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
                          Divider(),
                          Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: 8.0, horizontal: 8.0),
                            child: Row(
                              children: [
                                FilledButton(
                                  child: Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: Column(
                                      children: [
                                        Icon(FluentIcons.add, size: 16),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Top Up',
                                          style:
                                              GoogleFonts.inter(fontSize: 12),
                                        )
                                      ],
                                    ),
                                  ),
                                  onPressed: () async {
                                    showContentDialog(context, member);
                                  },
                                ),
                                const SizedBox(width: 8),
                                Button(
                                  child: Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: Column(
                                      children: [
                                        Icon(FluentIcons.remove, size: 16),
                                        const SizedBox(height: 8),
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
                                FilledButton(
                                  style: ButtonStyle(
                                    backgroundColor:
                                        WidgetStateProperty.all(Colors.red),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: Column(
                                      children: [
                                        Icon(FluentIcons.delete,
                                            size: 16, color: Colors.white),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Delete',
                                          style: GoogleFonts.inter(
                                              fontSize: 12,
                                              color: Colors.white),
                                        )
                                      ],
                                    ),
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
