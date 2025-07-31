// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:intl/intl.dart';
// import 'package:pos_indorep/helper/helper.dart';
// import 'package:pos_indorep/services/icafe_services.dart';
// import 'package:pos_indorep/services/web_services.dart';
// import 'package:pos_indorep/web/model/web_model.dart';

// class PcUpdateScreen extends StatefulWidget {
//   const PcUpdateScreen({super.key});

//   @override
//   State<PcUpdateScreen> createState() => _PcUpdateScreenState();
// }

// class _PcUpdateScreenState extends State<PcUpdateScreen> {
//   final WebServices _services = WebServices();
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//                     padding: const EdgeInsets.all(16.0),
//                     child: SizedBox(
//                       height: 300,
//                       child: StreamBuilder<QuerySnapshot>(
//                         stream: _services.getPCsStream(),
//                         builder: (context, snapshot) {
//                           if (!snapshot.hasData) {
//                             return Center(child: CupertinoActivityIndicator());
//                           }
//                           final pcs = snapshot.data!.docs;
//                           return GridView.builder(
//                             gridDelegate:
//                                 const SliverGridDelegateWithFixedCrossAxisCount(
//                               crossAxisCount: 5,
//                               crossAxisSpacing: 12,
//                               mainAxisSpacing: 12,
//                             ),
//                             itemCount: pcs.length + 1,
//                             itemBuilder: (context, index) {
//                               if (index == pcs.length) {
//                                 // Last grid: Add PC button
//                                 return Card(
//                                   shape: RoundedRectangleBorder(
//                                     borderRadius: BorderRadius.circular(12),
//                                     side: BorderSide(
//                                       color:
//                                           Theme.of(context).colorScheme.primary,
//                                       width: 1.5,
//                                     ),
//                                   ),
//                                   child: InkWell(
//                                     borderRadius: BorderRadius.circular(12),
//                                     onTap: () {
//                                       showDialog(
//                                         context: context,
//                                         builder: (context) {
//                                           return AlertDialog(
//                                             title: Text('Add New PC'),
//                                             content: Column(
//                                               mainAxisSize: MainAxisSize.min,
//                                               children: [
//                                                 TextField(
//                                                   controller: _newPCController,
//                                                   decoration: InputDecoration(
//                                                       labelText: 'PC Name',
//                                                       hintText: 'INDOREP - 00'),
//                                                 ),
//                                               ],
//                                             ),
//                                             actions: [
//                                               TextButton(
//                                                 onPressed: () async {
//                                                   await _addNewPC();
//                                                   Navigator.of(context).pop();
//                                                 },
//                                                 child: Text('OK'),
//                                               ),
//                                             ],
//                                           );
//                                         },
//                                       );
//                                     },
//                                     child: Center(
//                                       child: Icon(Icons.add,
//                                           size: 40,
//                                           color: Theme.of(context)
//                                               .colorScheme
//                                               .primary),
//                                     ),
//                                   ),
//                                 );
//                               }
//                               final pc = pcs[index];
//                               final updates = pc['updates'] ?? [];

//                               return Card(
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(12),
//                                   side: BorderSide(
//                                     color:
//                                         Theme.of(context).colorScheme.primary,
//                                     width: 1.5,
//                                   ),
//                                 ),
//                                 child: InkWell(
//                                   onTap: () {
//                                     showDialog(
//                                       context: context,
//                                       builder: (context) {
//                                         return AlertDialog(
//                                           title: Text('${pc['pcId']}'),
//                                           content: updates.isEmpty
//                                               ? Text('Belum pernah update')
//                                               : SizedBox(
//                                                   width: 350,
//                                                   child: ListView.builder(
//                                                     shrinkWrap: true,
//                                                     itemCount: updates.length,
//                                                     itemBuilder:
//                                                         (context, index) {
//                                                       final update =
//                                                           updates[index];
//                                                       final dateTimeString =
//                                                           update['timeStamp'];
//                                                       final formattedDate = DateFormat(
//                                                               'EEEE, dd MMMM yyyy HH:mm',
//                                                               'id_ID')
//                                                           .format(DateTime.parse(
//                                                               dateTimeString));
//                                                       return ListTile(
//                                                         leading:
//                                                             Icon(Icons.update),
//                                                         subtitle: Text(
//                                                             'Oleh : ${update['operator']}'),
//                                                         title:
//                                                             Text(formattedDate),
//                                                       );
//                                                     },
//                                                   ),
//                                                 ),
//                                           actions: [
//                                             TextButton(
//                                               onPressed: () {
//                                                 Navigator.of(context).pop();
//                                               },
//                                               child: Text('Close'),
//                                             ),
//                                             TextButton(
//                                               style: TextButton.styleFrom(
//                                                 backgroundColor:
//                                                     IndorepColor.primary,
//                                                 foregroundColor: Colors.white,
//                                               ),
//                                               onPressed: () {
//                                                 var newUpdate =
//                                                     IndorepPcsUpdateModel(
//                                                   pcId: pc['pcId'],
//                                                   updates: [
//                                                     PcsUpdate(
//                                                       timeStamp: DateTime.now(),
//                                                       operator:
//                                                           _selectedOperator,
//                                                     ),
//                                                   ],
//                                                 );
//                                                 _services
//                                                     .addUpdatetoPC(newUpdate);
//                                                 Navigator.of(context).pop();
//                                               },
//                                               child: Text('Update Sekarang!'),
//                                             ),
//                                           ],
//                                         );
//                                       },
//                                     );
//                                   },
//                                   child: Column(
//                                     mainAxisAlignment: MainAxisAlignment.center,
//                                     children: [
//                                       Text(
//                                         '${pc['pcId']}',
//                                         overflow: TextOverflow.ellipsis,
//                                         style: GoogleFonts.inter(
//                                             fontWeight: FontWeight.bold,
//                                             fontSize: 18),
//                                       ),
//                                       const SizedBox(height: 8),
//                                       Icon(
//                                         Icons.computer,
//                                         size: 40,
//                                         color: Theme.of(context)
//                                             .colorScheme
//                                             .primary,
//                                       ),
//                                       const SizedBox(height: 8),
//                                       Padding(
//                                         padding: const EdgeInsets.all(8.0),
//                                         child: Center(
//                                           child: Text(
//                                             'Last Update: ${updates.isNotEmpty ? DateFormat('EEEE, dd MMMM yyyy HH:mm', 'id_ID').format(DateTime.parse(updates.last['timeStamp'])) : 'N/A'}',
//                                             style: GoogleFonts.inter(
//                                               fontSize: 14,
//                                               color: Colors.grey,
//                                             ),
//                                             overflow: TextOverflow.ellipsis,
//                                             maxLines: 2,
//                                             textAlign: TextAlign.center,
//                                           ),
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               );
//                             },
//                           );
//                         },
//                       ),
//                     ),
//                   );
//   }
// }
