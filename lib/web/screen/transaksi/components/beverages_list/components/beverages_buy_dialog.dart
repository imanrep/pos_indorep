// import 'package:fluent_ui/fluent_ui.dart';
// import 'package:pos_indorep/helper/helper.dart';
// import 'package:pos_indorep/provider/web/warnet_backend_provider.dart';
// import 'package:pos_indorep/services/warnet_backend_services.dart';
// import 'package:pos_indorep/web/model/member_model.dart';
// import 'package:pos_indorep/web/model/topup_member_request.dart';
// import 'package:pos_indorep/web/model/topup_member_response.dart';
// import 'package:provider/provider.dart';

// class BeveragesBuyDialog extends StatefulWidget {
//   const BeveragesBuyDialog({super.key});

//   @override
//   State<BeveragesBuyDialog> createState() => _BeveragesBuyDialogState();
// }

// class _BeveragesBuyDialogState extends State<BeveragesBuyDialog> {
//   bool _isLoading = false;

//   bool isFormValid(WarnetBackendProvider provider) {
//     return provider.selectedMethod.isNotEmpty &&
//         provider.selectedPaket.harga > 0;
//   }

//   Future<void> _handlePayment(WarnetBackendProvider provider) async {
//     WarnetBackendServices services = WarnetBackendServices();
//     setState(() {
//       _isLoading = true;
//     });
//     if (provider.selectedMethod == 'Cash') {
//       TopUpMemberResponse res = await services.topUpMember(
//         TopUpMemberRequest(
//           username: widget.member.memberAccount,
//           memberId: widget.member.memberId,
//           payment: provider.selectedMethod.toLowerCase(),
//           amount: provider.selectedPaket.harga,
//         ),
//       );
//       // if (res.success) {
//       //   await displayInfoBar(context, builder: (context, close) {
//       //     return InfoBar(
//       //       title: Text(
//       //           'Member ${widget.member.memberAccount} berhasil ditambahkan'),
//       //       content: Text(
//       //           '${widget.member.memberAccount} - ${provider.selectedPaket.nama} (${Helper.rupiahFormatter(provider.selectedPaket.harga.toDouble())})'),
//       //       action: IconButton(
//       //         icon: Icon(FluentIcons.clear),
//       //         onPressed: close,
//       //       ),
//       //       severity: InfoBarSeverity.success,
//       //     );
//       //   });
//       //   provider.getAllCustomerWarnet('');
//       // }
//       setState(() {
//         _isLoading = false;
//       });
//       Navigator.pop(context);
//     } else if (provider.selectedMethod == 'QRIS') {
//       // TopUpMemberResponse res = await services.topUpMember(
//       //   TopUpMemberRequest(
//       //     username: widget.member.memberAccount,
//       //     memberId: widget.member.memberId,
//       //     payment: provider.selectedMethod.toLowerCase(),
//       //     amount: provider.selectedPaket.harga,
//       //   ),
//       // );
//       // if (res.success) {
//       //   await displayInfoBar(context, builder: (context, close) {
//       //     return InfoBar(
//       //       title: Text(
//       //           'Member ${widget.member.memberAccount} berhasil ditambahkan'),
//       //       content: Text(
//       //           '${widget.member.memberAccount} - ${provider.selectedPaket.nama} (${Helper.rupiahFormatter(provider.selectedPaket.harga.toDouble())})'),
//       //       action: IconButton(
//       //         icon: Icon(FluentIcons.clear),
//       //         onPressed: close,
//       //       ),
//       //       severity: InfoBarSeverity.success,
//       //     );
//       //   });
//         provider.getAllCustomerWarnet('');
//       }
//       setState(() {
//         _isLoading = false;
//       });
//       Navigator.pop(context);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Consumer<WarnetBackendProvider>(builder: (context, provider, child) {
//       return ContentDialog(
//         constraints: BoxConstraints(
//           maxWidth: 450,
//         ),
//         title: Text('Beli Item'),
//         content: Row(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Consumer<WarnetBackendProvider>(
//                 builder: (context, provider, child) {
//               return ComboBox<String>(
//                 value: provider.selectedPaket.nama,
//                 placeholder: const Text('Pilih Paket'),
//                 items: provider.kulkasItems
//                     .map((p) => ComboBoxItem<String>(
//                           value: p.name,
//                           child: Text(
//                               '${p.name} - ${Helper.rupiahFormatter(p.price.toDouble())}'),
//                         ))
//                     .toList(),
//                 onChanged: (val) {
//                   if (val != null) {
//                     provider.setSelectedPaket(
//                       provider.packages.firstWhere(
//                         (p) => p.nama == val,
//                         orElse: () => provider.packages.first,
//                       ),
//                     );
//                   }
//                 },
//               );
//             }),
//             const SizedBox(width: 12),
//             ComboBox<String>(
//               value: provider.selectedMethod,
//               placeholder: const Text('Metode pembayaran'),
//               items: provider.methods
//                   .map((m) => ComboBoxItem<String>(
//                         value: m,
//                         child: Text(m),
//                       ))
//                   .toList(),
//               onChanged: (val) {
//                 if (val != null) {
//                   provider.setSelectedMethod(val);
//                 }
//               },
//             ),
//           ],
//         ),
//         actions: [
//           Button(
//             child: const Text(
//               'Batalkan',
//             ),
//             onPressed: () {
//               Navigator.pop(context, 'User deleted file');
//               // Delete file here
//             },
//           ),
//           // Consumer<WarnetBackendProvider>(
//           //   builder: (context, provider, child) {
//           //     final isValid = isFormValid(provider);
//           //     return FilledButton(
//           //       onPressed: _isLoading || !isValid
//           //           ? null
//           //           : () async {
//           //               _handlePayment(provider);
//           //             },
//           //       child: _isLoading
//           //           ? SizedBox(
//           //               height: 16,
//           //               width: 16,
//           //               child: ProgressRing(
//           //                 strokeWidth: 3,
//           //               ))
//           //           : Text(
//           //               'Top Up',
//           //             ),
//           //     );
//           //   },
//           // ),
//         ],
//       );
//     });
//   }
