import 'package:fluent_ui/fluent_ui.dart';
import 'package:pos_indorep/helper/helper.dart';
import 'package:pos_indorep/provider/web/warnet_transaksi_provider.dart';
import 'package:pos_indorep/services/warnet_backend_services.dart';
import 'package:pos_indorep/web/model/create_member_response.dart';
import 'package:pos_indorep/web/model/member_model.dart';
import 'package:pos_indorep/web/model/topup_member_request.dart';
import 'package:pos_indorep/web/model/topup_member_response.dart';
import 'package:pos_indorep/web/screen/transaksi/components/warnet_card/components/qris_print_dialog.dart';
import 'package:provider/provider.dart';

class MemberTopupDialog extends StatefulWidget {
  final Member member;
  const MemberTopupDialog({super.key, required this.member});

  @override
  State<MemberTopupDialog> createState() => _MemberTopupDialogState();
}

class _MemberTopupDialogState extends State<MemberTopupDialog> {
  bool _isLoading = false;

  bool isFormValid(WarnetTransaksiProvider provider) {
    return provider.selectedMethod.isNotEmpty &&
        provider.selectedPaket.harga > 0;
  }

  Future<void> _handlePayment(WarnetTransaksiProvider provider) async {
    WarnetBackendServices services = WarnetBackendServices();
    setState(() {
      _isLoading = true;
    });
    if (provider.selectedMethod == 'Cash') {
      TopUpMemberResponse res = await services.topUpMember(
        TopUpMemberRequest(
          username: widget.member.memberAccount,
          memberId: widget.member.memberId,
          payment: provider.selectedMethod.toLowerCase(),
          amount: provider.selectedPaket.harga,
        ),
      );
      if (res.success) {
        await displayInfoBar(context, builder: (context, close) {
          return InfoBar(
            title: Text(
                'Member ${widget.member.memberAccount} berhasil ditambahkan'),
            content: Text(
                '${widget.member.memberAccount} - ${provider.selectedPaket.nama} (${Helper.rupiahFormatter(provider.selectedPaket.harga.toDouble())})'),
            action: IconButton(
              icon: Icon(FluentIcons.clear),
              onPressed: close,
            ),
            severity: InfoBarSeverity.success,
          );
        });
        provider.getAllCustomerWarnet('');
      }
      setState(() {
        _isLoading = false;
      });
      await showDialog<String>(
        context: context,
        builder: (context) => QrisPrintDialog(
            response: CreateMemberResponse(
                message: res.message,
                orderID: res.orderID,
                password: "",
                qris: res.qris ?? "",
                success: res.success,
                username: widget.member.memberAccount),
            paket: provider.selectedPaket),
      );
      provider.getAllCustomerWarnet('');
      Navigator.pop(context);
    } else if (provider.selectedMethod == 'QRIS') {
      TopUpMemberResponse res = await services.topUpMember(
        TopUpMemberRequest(
          username: widget.member.memberAccount,
          memberId: widget.member.memberId,
          payment: provider.selectedMethod.toLowerCase(),
          amount: provider.selectedPaket.harga,
        ),
      );
      if (res.success) {
        await displayInfoBar(context, builder: (ctx, close) {
          return InfoBar(
            title: const Text('Topup berhasil dibuat'),
            content: Text(
                'Silakan scan QRIS di layar. Total: ${Helper.rupiahFormatter(provider.selectedPaket.harga.toDouble())}'),
            action: IconButton(
                icon: const Icon(FluentIcons.clear), onPressed: close),
            severity: InfoBarSeverity.success,
          );
        });
        await showDialog<String>(
          context: context,
          builder: (context) => QrisPrintDialog(
              response: CreateMemberResponse(
                  message: res.message,
                  orderID: res.orderID,
                  password: "",
                  qris: res.qris ?? "",
                  success: res.success,
                  username: widget.member.memberAccount),
              paket: provider.selectedPaket),
        );
      }
      setState(() {
        _isLoading = false;
      });
      provider.getAllCustomerWarnet('');
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WarnetTransaksiProvider>(
        builder: (context, provider, child) {
      return ContentDialog(
        constraints: BoxConstraints(
          maxWidth: 450,
        ),
        title: Text('Top Up - ${widget.member.memberAccount}'),
        content: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Consumer<WarnetTransaksiProvider>(
                builder: (context, provider, child) {
              return ComboBox<String>(
                value: provider.selectedPaket.nama,
                placeholder: const Text('Pilih Paket'),
                items: provider.packages
                    .map((p) => ComboBoxItem<String>(
                          value: p.nama,
                          child: Text(
                              '${p.nama} - ${Helper.rupiahFormatter(p.harga.toDouble())}'),
                        ))
                    .toList(),
                onChanged: (val) {
                  if (val != null) {
                    provider.setSelectedPaket(
                      provider.packages.firstWhere(
                        (p) => p.nama == val,
                        orElse: () => provider.packages.first,
                      ),
                    );
                  }
                },
              );
            }),
            const SizedBox(width: 12),
            ComboBox<String>(
              value: provider.selectedMethod,
              placeholder: const Text('Metode pembayaran'),
              items: provider.methods
                  .map((m) => ComboBoxItem<String>(
                        value: m,
                        child: Text(m),
                      ))
                  .toList(),
              onChanged: (val) {
                if (val != null) {
                  provider.setSelectedMethod(val);
                }
              },
            ),
          ],
        ),
        actions: [
          Button(
            child: const Text(
              'Batalkan',
            ),
            onPressed: () {
              Navigator.pop(context, 'User deleted file');
              // Delete file here
            },
          ),
          Consumer<WarnetTransaksiProvider>(
            builder: (context, provider, child) {
              final isValid = isFormValid(provider);
              return FilledButton(
                onPressed: _isLoading || !isValid
                    ? null
                    : () async {
                        _handlePayment(provider);
                      },
                child: _isLoading
                    ? SizedBox(
                        height: 16,
                        width: 16,
                        child: ProgressRing(
                          strokeWidth: 3,
                        ))
                    : Text(
                        'Top Up',
                      ),
              );
            },
          ),
        ],
      );
    });
  }
}
