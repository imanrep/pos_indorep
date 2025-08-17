import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart';
import 'package:pos_indorep/helper/helper.dart';
import 'package:pos_indorep/provider/web/warnet_backend_provider.dart';
import 'package:pos_indorep/provider/web/web_transaksi_provider.dart';
import 'package:pos_indorep/services/warnet_backend_services.dart';
import 'package:pos_indorep/web/model/create_member_request.dart';
import 'package:pos_indorep/web/screen/transaksi/components/warnet_card/components/qris_print_dialog.dart';
import 'package:provider/provider.dart';

class NewTopupDialog extends StatefulWidget {
  const NewTopupDialog({super.key});

  @override
  State<NewTopupDialog> createState() => _NewTopupDialogState();
}

class _NewTopupDialogState extends State<NewTopupDialog> {
  bool _isLoading = false;

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  
bool isFormValid(WarnetTransaksiProvider provider) {
  return usernameController.text.trim().isNotEmpty &&
      usernameController.text.trim().length >= 4 && // Ensure minimum 4 characters
      !provider.allWarnetCustomers!.members
          .any((m) => m.memberAccount == usernameController.text.trim()) &&
      passwordController.text.trim().isNotEmpty &&
      provider.selectedMethod.isNotEmpty &&
      provider.selectedPaket.harga > 0;
}

  Future<void> _handlePayment(WarnetTransaksiProvider provider) async {
    WarnetBackendServices services = WarnetBackendServices();
    setState(() {
      _isLoading = true;
    });
    if (provider.selectedMethod == 'Cash') {
      var res = await services.createMember(
        CreateMemberRequest(
          username: usernameController.text,
          password: passwordController.text,
          payment: provider.selectedMethod.toLowerCase(),
          amount: provider.selectedPaket.harga,
          isPaketMalam: provider.isPaketMalam,
        ),
      );
      if (res.success) {
        await displayInfoBar(context, builder: (context, close) {
          return InfoBar(
            title:
                Text('Member ${usernameController.text} berhasil ditambahkan'),
            content: Text(
                '${usernameController.text} - ${provider.selectedPaket.nama} (${Helper.rupiahFormatter(provider.selectedPaket.harga.toDouble())})'),
            action: IconButton(
              icon: Icon(FluentIcons.clear),
              onPressed: close,
            ),
            severity: InfoBarSeverity.success,
          );
        });
      }
      setState(() {
        _isLoading = false;
      });
      await showDialog<String>(
          context: context,
          builder: (context) => QrisPrintDialog(
            response: res,
            paket: provider.selectedPaket
          ),
        );
        provider.getAllCustomerWarnet('');
        Navigator.pop(context);
    } else if (provider.selectedMethod == 'QRIS') {
      var res = await services.createMember(
        CreateMemberRequest(
          username: usernameController.text,
          password: passwordController.text,
          payment: provider.selectedMethod.toLowerCase(),
          amount: provider.selectedPaket.harga,
          isPaketMalam: provider.isPaketMalam,
        ),
      );
      if (res.success) {
        await showDialog<String>(
          context: context,
          builder: (context) => QrisPrintDialog(
            response: res,
            paket: provider.selectedPaket
          ),
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
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ContentDialog(
      constraints: BoxConstraints(
        maxWidth: 450,
        maxHeight: 260,
      ),
      title: Text('Tambah Member'),
      content: Column(
        children: [
          Row(
            children: [
              SizedBox(
                width: 220,
                child: Consumer<WebTransaksiProvider>(
                  builder: (context, provider, child) {
                    return TextBox(
                      controller: usernameController,
                      autofocus: true,
                      inputFormatters: [
                         FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9/\s]')),
                      ],
                      placeholder: 'Username',
                      maxLength: 20,
                      onChanged: (_) => setState(() {}),
                    );
                  },
                ),
              ),
              const SizedBox(
                width: 12,
                height: 50,
              ),
              SizedBox(
                width: 170,
                child: Consumer<WebTransaksiProvider>(
                  builder: (context, provider, child) {
                    return TextBox(
                      controller: passwordController,
                      obscureText: true,
                      placeholder: 'Password',
                      maxLength: 20,
                      onChanged: (_) => setState(() {}),
                    );
                  },
                ),
              ),
            ],
          ),
          Row(
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
                      setState(() {});
                    }
                  },
                );
              }),
              const SizedBox(width: 12),
              Consumer<WarnetTransaksiProvider>(
                  builder: (context, provider, child) {
                return ComboBox<String>(
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
                      setState(() {});
                    }
                  },
                );
              }),
            ],
          ),
        ],
      ),
      actions: [
        Button(
          child: const Text('Batal'),
          onPressed: () {
            Navigator.pop(context);
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
  }
}
