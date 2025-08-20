import 'package:fluent_ui/fluent_ui.dart';
import 'package:intl/intl.dart';
import 'package:pos_indorep/helper/helper.dart';
import 'package:pos_indorep/services/warnet_backend_services.dart';
import 'package:pos_indorep/web/model/get_transaction_warnet_response.dart';

class DetailTransaksiPage extends StatefulWidget {
  const DetailTransaksiPage({super.key});

  @override
  State<DetailTransaksiPage> createState() => _DetailTransaksiPageState();
}

class _DetailTransaksiPageState extends State<DetailTransaksiPage> {
  final TextEditingController _search = TextEditingController();
  int _selectedIndex = -1;
  final services = WarnetBackendServices();
  int currentPage = 1;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _openDetailDialog(WarnetTransaction transaction) async {
    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return ContentDialog(
          title: Text('Detail Transaksi ${transaction.id}'),
          constraints: const BoxConstraints(maxWidth: 600),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              InfoLabel(label: 'Username', child: Text(transaction.username)),
              const SizedBox(height: 8),
              InfoLabel(label: 'Password', child: Text(transaction.password)),
              const SizedBox(height: 8),
              InfoLabel(label: 'Payment', child: Text(transaction.payment)),
              const SizedBox(height: 8),
              InfoLabel(
                  label: 'Amount', child: Text('Rp ${transaction.amount}')),
              const SizedBox(height: 8),
              InfoLabel(label: 'Status', child: Text(transaction.status)),
              const SizedBox(height: 8),
              InfoLabel(
                label: 'Date',
                child: Text(
                    DateFormat('yyyy-MM-dd HH:mm:ss').format(transaction.date)),
              ),
              const SizedBox(height: 8),
              InfoLabel(label: 'Note', child: Text(transaction.note)),
            ],
          ),
          actions: [
            Button(
              child: const Text('Tutup'),
              onPressed: () => Navigator.pop(context),
            ),
            FilledButton(
              child: const Text('Cetak'),
              onPressed: () {
                // TODO: implement print
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);

    return ScaffoldPage.scrollable(
      header: PageHeader(
        leading: Padding(
          padding: const EdgeInsets.all(12.0),
          child: IconButton(
            icon: const Icon(FluentIcons.back, size: 18),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: Padding(
          padding: const EdgeInsets.only(bottom: 4.0),
          child: Text('Detail Transaksi',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600)),
        ),
        commandBar: CommandBar(
          mainAxisAlignment: MainAxisAlignment.end,
          primaryItems: [
            CommandBarButton(
              icon: const Icon(FluentIcons.refresh),
              label: const Text('Refresh'),
              onPressed: () => setState(() {}),
            ),
            CommandBarButton(
              icon: const Icon(FluentIcons.print),
              label: const Text('Print'),
              onPressed: () {
                // TODO: implement print
              },
            ),
          ],
        ),
      ),
      children: [
        // Top summary / search
        Card(
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Wrap(
              runSpacing: 12,
              spacing: 12,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                const Text(
                  'Ringkasan',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(width: 16),
                InfoLabel(label: 'Total Items', child: Text('22')),
                const SizedBox(width: 16),
                SizedBox(
                  width: 320,
                  child: TextBox(
                    controller: _search,
                    placeholder: 'Cari transaksi…',
                    suffix: const Padding(
                      padding: EdgeInsets.only(right: 6),
                      child: Icon(FluentIcons.search),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        // List
        Card(
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: FutureBuilder(
                future: services.getTransactionWarnet(currentPage),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: ProgressRing());
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: Text('Error: ${snapshot.error}',
                          style: TextStyle(color: Colors.red)),
                    );
                  }
                  if (!snapshot.hasData || snapshot.data == null) {
                    return const Center(
                        child: Text('Tidak ada transaksi ditemukan.'));
                  } else {
                    return ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: snapshot.data!.data.length,
                      separatorBuilder: (_, __) => const Divider(size: 1),
                      itemBuilder: (context, index) {
                        final transaction = snapshot.data!.data[index];
                        // final transaction = _filtered[index];
                        final selected = index == _selectedIndex;
                        String dateInHours = DateFormat('HH:mm', 'id_ID')
                            .format(transaction.date);
                        String dateWithoutTime =
                            DateFormat('dd-MM-yyyy').format(transaction.date);

                        // Determine order status
                        String orderStatus;
                        if (transaction.status == 'cancelled') {
                          orderStatus = 'Dibatalkan';
                        } else if (transaction.status == 'pending') {
                          orderStatus = 'Pending';
                        } else if (transaction.status == 'paid') {
                          orderStatus = 'Sukses';
                        } else {
                          orderStatus = transaction.status; // fallback
                        }
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor:
                                IndorepColor.primary.withValues(alpha: 0.2),
                            child: Text(
                              transaction.username.characters.first
                                  .toUpperCase(),
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          title: Text(
                            '$dateInHours - ${transaction.note}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow
                                .ellipsis, // Handle overflow with ellipsis
                            maxLines: 1, // Limit to a single line
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2.0),
                            child: Row(
                              children: [
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 4),
                                  child: Text(
                                      '$dateWithoutTime | ${Helper.rupiahFormatterTwo(transaction.amount)} | ${transaction.payment.toUpperCase()}',
                                      style: TextStyle(fontSize: 14)),
                                ),
                                const SizedBox(width: 8.0),
                                Flexible(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color:
                                          IndorepColor.primary.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      '${transaction.username}',
                                      style: const TextStyle(fontSize: 14),
                                      overflow: TextOverflow
                                          .ellipsis, // Handle overflow with ellipsis
                                      maxLines: 1, // Limit to a single line
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          onPressed: () {
                            setState(() => _selectedIndex = index);
                            _openDetailDialog(transaction);
                          },
                          trailing: statusChip(transaction.status),
                        );
                      },
                    );
                  }
                }),
          ),
        ),
      ],
    );
  }

  Widget statusChip(String status) {
    Color fillColor;
    Color borderColor;
    String statusText;

    switch (status) {
      case 'pending':
        fillColor = Colors.orange.withOpacity(0.1);
        borderColor = Colors.orange;
        statusText = 'PENDING';
        break;
      case 'paid':
        fillColor = Colors.green.withOpacity(0.1);
        borderColor = Colors.green;
        statusText = 'SUKSES';
        break;
      default:
        fillColor = Colors.red.withOpacity(0.1);
        borderColor = Colors.red;
        statusText = 'BATAL';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: fillColor,
        border: Border.all(color: borderColor, width: 1.3),
        borderRadius: BorderRadius.circular(50),
      ),
      child: Text(
        statusText,
        style: TextStyle(
          color: borderColor,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}

class DetailFullPage extends StatelessWidget {
  final WarnetTransaction transaction;
  const DetailFullPage({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage.scrollable(
      header: PageHeader(
        leading: IconButton(
          icon: const Icon(FluentIcons.back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Detail: ${transaction.username}'),
      ),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InfoLabel(label: 'Username', child: Text(transaction.username)),
                const SizedBox(height: 8),
                InfoLabel(label: 'Password', child: Text(transaction.password)),
                const SizedBox(height: 8),
                InfoLabel(label: 'Payment', child: Text(transaction.payment)),
                const SizedBox(height: 8),
                InfoLabel(
                    label: 'Amount', child: Text('Rp ${transaction.amount}')),
                const SizedBox(height: 8),
                InfoLabel(label: 'Status', child: Text(transaction.status)),
                const SizedBox(height: 8),
                InfoLabel(
                  label: 'Date',
                  child: Text(DateFormat('yyyy-MM-dd HH:mm:ss')
                      .format(transaction.date)),
                ),
                const SizedBox(height: 8),
                InfoLabel(label: 'Note', child: Text(transaction.note)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
