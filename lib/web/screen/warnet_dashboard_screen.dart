import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pos_indorep/helper/helper.dart';
import 'package:pos_indorep/web/components/pcs_list_view.dart';
import 'package:pos_indorep/web/model/pcs_model.dart';
import 'package:pos_indorep/web/model/web_model.dart';
import 'package:pos_indorep/services/icafe_services.dart';
import 'package:pos_indorep/services/web_services.dart';
import 'package:intl/intl.dart';
import 'package:pos_indorep/web/screen/dashboard/transaksi_page.dart';

class WarnetDashboardScreen extends StatefulWidget {
  const WarnetDashboardScreen({super.key});

  @override
  _WarnetDashboardScreenState createState() => _WarnetDashboardScreenState();
}

class _WarnetDashboardScreenState extends State<WarnetDashboardScreen> {
  final WebServices _services = WebServices();
  final ICafeServices _icafeServices = ICafeServices();
  String _selectedOperator = 'Agung';
  final _newPCController = TextEditingController();
  bool _isLoadingPCs = true;

  late PcResponse _pcs;

  final List<String> _operators = ['Agung', 'Asep', 'Fajar', 'Gume'];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _newPCController.dispose();
    super.dispose();
  }

  Future<void> _addNewPC() async {
    _services
        .addPC(
      IndorepPcsUpdateModel(
        pcId: _newPCController.text,
        updates: [],
      ),
    )
        .then((_) {
      _newPCController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('PC added successfully')),
      );
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add PC: $error')),
      );
    });
  }

  Future<void> _getPCs() async {
    var cafeId = 'your_cafe_id_here';
    var auth = 'your_auth_token_here';
    setState(() {
      _isLoadingPCs = true;
    });
    _icafeServices.getPCs(cafeId, auth).then((pcs) {
      setState(() {
        _pcs = pcs;
        _isLoadingPCs = false;
      });
    }).catchError((error) {
      setState(() {
        _isLoadingPCs = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load PCs: $error')),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        centerTitle: false,
        title: Row(
          children: [
            Image.asset('assets/images/app_icon.png', width: 48, height: 48),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'INDOREP Net Dashboard',
                style: GoogleFonts.inter(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ),
        actions: [
          Row(
            children: [
              Text(
                'Shift OP : ',
                style: GoogleFonts.inter(
                    fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(right: 12.0),
                child: Center(
                  child: DropdownButton<String>(
                    value: _selectedOperator,
                    underline: SizedBox(),
                    onChanged: (value) {
                      if (value != null) {
                        _services.setCurrentOperator(value);
                        setState(() => _selectedOperator = value);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Operator saat ini adalah $value'),
                          ),
                        );
                      }
                    },
                    items: _operators
                        .map((op) => DropdownMenuItem(
                              value: op,
                              child: Text(op),
                            ))
                        .toList(),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
      body: DefaultTabController(
        length: 3,
        child: Column(
          children: [
            SizedBox(
              child: TabBar(
                tabs: const [
                  Tab(text: 'Transaksi'),
                  Tab(text: 'PC Management'),
                  Tab(text: 'PC Game Update'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: TabBarView(
                children: [
                  TransaksiPage(),
                  SingleChildScrollView(
                    child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(
                                    color: IndorepColor.primary, width: 1.5),
                              ),
                              elevation: 2,
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(32.0),
                                    child: Center(
                                      child: Text(
                                        "INDOREP PC's Management",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 24,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                        ),
                                      ),
                                    ),
                                  ),
                                  FutureBuilder(
                                      future: _icafeServices.getPCs('', ''),
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return const Center(
                                              child:
                                                  CupertinoActivityIndicator());
                                        }
                                        if (snapshot.hasError) {
                                          return Center(
                                              child: Text(
                                                  'Error: ${snapshot.error}'));
                                        }
                                        final pcs = snapshot.data!.data ?? [];
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8.0, vertical: 4.0),
                                          child: ListView.builder(
                                            shrinkWrap: true,
                                            physics:
                                                const NeverScrollableScrollPhysics(),
                                            itemCount: pcs.length,
                                            itemBuilder: (context, index) {
                                              final pcData = pcs[index];
                                              return PcsTableView(
                                                  pcs: [pcData]);
                                            },
                                          ),
                                          // Wrap(
                                          //   children: List.generate(
                                          //     pcs.length,
                                          //     (index) => SizedBox(
                                          //       width:
                                          //           180, // Set a fixed or calculated width for each card
                                          //       child:
                                          //           PcsGrid(pcData: pcs[index]),
                                          //     ),
                                          //   ),
                                          // ),
                                        );
                                      }),
                                ],
                              ),
                            ),
                          ],
                        )),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SizedBox(
                      height: 300,
                      child: StreamBuilder<QuerySnapshot>(
                        stream: _services.getPCsStream(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return Center(child: CupertinoActivityIndicator());
                          }
                          final pcs = snapshot.data!.docs;
                          return GridView.builder(
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 5,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                            ),
                            itemCount: pcs.length + 1,
                            itemBuilder: (context, index) {
                              if (index == pcs.length) {
                                // Last grid: Add PC button
                                return Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    side: BorderSide(
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                      width: 1.5,
                                    ),
                                  ),
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(12),
                                    onTap: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            title: Text('Add New PC'),
                                            content: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                TextField(
                                                  controller: _newPCController,
                                                  decoration: InputDecoration(
                                                      labelText: 'PC Name',
                                                      hintText: 'INDOREP - 00'),
                                                ),
                                              ],
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () async {
                                                  await _addNewPC();
                                                  Navigator.of(context).pop();
                                                },
                                                child: Text('OK'),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    },
                                    child: Center(
                                      child: Icon(Icons.add,
                                          size: 40,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary),
                                    ),
                                  ),
                                );
                              }
                              final pc = pcs[index];
                              final updates = pc['updates'] ?? [];

                              return Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: BorderSide(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    width: 1.5,
                                  ),
                                ),
                                child: InkWell(
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          title: Text('${pc['pcId']}'),
                                          content: updates.isEmpty
                                              ? Text('Belum pernah update')
                                              : SizedBox(
                                                  width: 350,
                                                  child: ListView.builder(
                                                    shrinkWrap: true,
                                                    itemCount: updates.length,
                                                    itemBuilder:
                                                        (context, index) {
                                                      final update =
                                                          updates[index];
                                                      final dateTimeString =
                                                          update['timeStamp'];
                                                      final formattedDate = DateFormat(
                                                              'EEEE, dd MMMM yyyy HH:mm',
                                                              'id_ID')
                                                          .format(DateTime.parse(
                                                              dateTimeString));
                                                      return ListTile(
                                                        leading:
                                                            Icon(Icons.update),
                                                        subtitle: Text(
                                                            'Oleh : ${update['operator']}'),
                                                        title:
                                                            Text(formattedDate),
                                                      );
                                                    },
                                                  ),
                                                ),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              child: Text('Close'),
                                            ),
                                            TextButton(
                                              style: TextButton.styleFrom(
                                                backgroundColor:
                                                    IndorepColor.primary,
                                                foregroundColor: Colors.white,
                                              ),
                                              onPressed: () {
                                                var newUpdate =
                                                    IndorepPcsUpdateModel(
                                                  pcId: pc['pcId'],
                                                  updates: [
                                                    PcsUpdate(
                                                      timeStamp: DateTime.now(),
                                                      operator:
                                                          _selectedOperator,
                                                    ),
                                                  ],
                                                );
                                                _services
                                                    .addUpdatetoPC(newUpdate);
                                                Navigator.of(context).pop();
                                              },
                                              child: Text('Update Sekarang!'),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        '${pc['pcId']}',
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.inter(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18),
                                      ),
                                      const SizedBox(height: 8),
                                      Icon(
                                        Icons.computer,
                                        size: 40,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                      ),
                                      const SizedBox(height: 8),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Center(
                                          child: Text(
                                            'Last Update: ${updates.isNotEmpty ? DateFormat('EEEE, dd MMMM yyyy HH:mm', 'id_ID').format(DateTime.parse(updates.last['timeStamp'])) : 'N/A'}',
                                            style: GoogleFonts.inter(
                                              fontSize: 14,
                                              color: Colors.grey,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 2,
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
