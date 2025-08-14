import 'package:fluent_ui/fluent_ui.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pos_indorep/provider/web/warnet_backend_provider.dart';
import 'package:pos_indorep/web/model/member_model.dart';
import 'package:pos_indorep/web/screen/transaksi/components/warnet_member_list/components/member_search_list.dart';
import 'package:pos_indorep/web/screen/transaksi/components/warnet_member_list/components/new_topup_dialog.dart';
import 'package:provider/provider.dart';

class WarnetMemberList extends StatefulWidget {
  const WarnetMemberList({super.key});

  @override
  State<WarnetMemberList> createState() => _WarnetMemberListState();
}

class _WarnetMemberListState extends State<WarnetMemberList> {
  void showContentDialog(BuildContext context) async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => NewTopupDialog(),
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final ValueNotifier<List<Member>> selectedMembers =
        ValueNotifier<List<Member>>([]);
    String? selectedMember;

    return Consumer<WarnetBackendProvider>(
      builder: (context, provider, child) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Card(
            borderRadius: BorderRadius.circular(12),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'INDOREP Net Billing',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                provider.isLoadingEntries
                    ? const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Center(child: ProgressRing()),
                      )
                    : provider.allWarnetCustomers == null
                        ? Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Center(
                              child: Text(
                                'Tidak ada Data',
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          )
                        : Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Member Baru',
                                    style: GoogleFonts.inter(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600)),
                                const SizedBox(
                                  height: 16,
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0),
                                  child: FilledButton(
                                      child: Padding(
                                        padding: const EdgeInsets.all(4.0),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(FluentIcons.add, size: 12),
                                            const SizedBox(
                                              width: 8,
                                            ),
                                            Text('Tambah Member',
                                                style: GoogleFonts.inter(
                                                    fontWeight:
                                                        FontWeight.w500)),
                                          ],
                                        ),
                                      ),
                                      onPressed: () async {
                                        showContentDialog(context);
                                      }),
                                ),
                                const SizedBox(
                                  height: 16,
                                ),
                                Text('Cari Member',
                                    style: GoogleFonts.inter(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600)),
                                const SizedBox(
                                  height: 16,
                                ),
                                MembersSearchList(),
                              ],
                            ),
                          ),
              ],
            ),
          ),
        );
      },
    );
  }
}
