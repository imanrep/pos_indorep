import 'package:collection/collection.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pos_indorep/helper/helper.dart';
import 'package:pos_indorep/provider/web/warnet_transaksi_provider.dart';
import 'package:pos_indorep/web/model/kulkas_item_response.dart';
import 'package:provider/provider.dart';

class BeveragesSearchList extends StatefulWidget {
  const BeveragesSearchList({super.key});

  @override
  State<BeveragesSearchList> createState() => _BeveragesSearchListState();
}

class _BeveragesSearchListState extends State<BeveragesSearchList> {
  final _asbKey = GlobalKey<AutoSuggestBoxState>(debugLabel: 'MembersASB');
  final _searchCtrl = TextEditingController();
  final ValueNotifier<List<KulkasItem>> selectedItems =
      ValueNotifier<List<KulkasItem>>([]);

  late List<KulkasItem> _displayed; // what ListView shows
  final commandBarKey = GlobalKey<CommandBarState>();
  @override
  void initState() {
    super.initState();
    _displayed = []; // Defensive: start with empty list

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<WarnetTransaksiProvider>();
      final kulkasItems = provider.kulkasItems;
      if (kulkasItems.isEmpty) return;

      final all = kulkasItems.sorted(
        (a, b) => b.name.toLowerCase().compareTo(a.name.toLowerCase()),
      );
      setState(() {
        _displayed = List<KulkasItem>.from(all);
      });

      _searchCtrl.addListener(() {
        if (_asbKey.currentState?.isOverlayVisible ?? false) {
          _asbKey.currentState?.dismissOverlay();
        }
        final q = _searchCtrl.text.trim().toLowerCase();
        setState(() {
          if (q.isEmpty) {
            _displayed = List<KulkasItem>.from(all);
          } else {
            _displayed =
                all.where((m) => m.name.toLowerCase().contains(q)).toList();
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

  // void showContentDialog(BuildContext context, KulkasItem item) async {
  //   final result = await showDialog<String>(
  //     context: context,
  //     builder: (context) => MemberTopupDialog(member: member),
  //   );
  //   setState(() {});
  // }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WarnetTransaksiProvider>();
    final kulkasItems = provider.kulkasItems;

    // Update _displayed if kulkasItems changes and _searchCtrl is empty
    if (_searchCtrl.text.isEmpty && kulkasItems.isNotEmpty) {
      _displayed = kulkasItems.sorted(
        (a, b) => b.name.toLowerCase().compareTo(a.name.toLowerCase()),
      );
    }

    if (kulkasItems.isEmpty) {
      return const Center(child: Text('No items found.'));
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
            placeholder: 'Cari item',
            // Give it an empty items list so it won’t pop an overlay.
            items: const <AutoSuggestBoxItem<String>>[],
            // Belt & suspenders: if something triggers overlay, hide it.
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
        // Your selectable list, but feed it from _displayed
        ValueListenableBuilder<List<KulkasItem>>(
          valueListenable: selectedItems,
          builder: (context, selected, _) {
            return SizedBox(
              height: 300,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _displayed.length,
                itemBuilder: (context, index) {
                  final item = _displayed[index];
                  final checked = selected.contains(item);
                  bool isReady = item.onStock;
                  return Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Expander(
                      leading: Checkbox(
                        checked: checked,
                        onChanged: (_) {
                          final sel = List<KulkasItem>.from(selected);
                          checked ? sel.remove(item) : sel.add(item);
                          selectedItems.value = sel;
                        },
                      ),
                      trailing: Container(
                        decoration: BoxDecoration(
                          color: isReady
                              ? Colors.green.withValues(alpha: 0.15)
                              : Colors.red.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8.0, vertical: 6.0),
                          child: Text(
                            isReady ? 'Ready' : 'Out of Stock',
                            style: TextStyle(
                              color: isReady ? Colors.green : Colors.red,
                              fontWeight: FontWeight.w600,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ),
                      header: Text(
                          '${item.name} - ${Helper.rupiahFormatter(item.price.toDouble())}',
                          style: GoogleFonts.inter()),
                      content: Column(
                        children: [
                          Wrap(
                            children: [],
                          ),
                          const SizedBox(height: 8),
                          Divider(),
                          Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: 8.0, horizontal: 8.0),
                            child: Row(
                              children: [
                                Button(
                                  child: Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: Column(
                                      children: [
                                        Icon(FluentIcons.edit, size: 16),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Edit',
                                          style:
                                              GoogleFonts.inter(fontSize: 12),
                                        )
                                      ],
                                    ),
                                  ),
                                  onPressed: () async {
                                    // showContentDialog(context, item);
                                  },
                                ),
                                const SizedBox(width: 8),
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
