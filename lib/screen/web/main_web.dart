import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pos_indorep/helper/helper.dart';
import 'package:pos_indorep/screen/transaction/components/widget/date_bar.dart';
import 'package:pos_indorep/screen/web/web_model.dart';
import 'package:pos_indorep/services/web_services.dart';
import 'package:intl/intl.dart';

class WarnetDashboard extends StatefulWidget {
  const WarnetDashboard({super.key});

  @override
  _WarnetDashboardState createState() => _WarnetDashboardState();
}

class _WarnetDashboardState extends State<WarnetDashboard> {
  final WebServices _services = WebServices();
  String _selectedOperator = 'Agung';
  String _selectedBeverages = 'Pristine 400ml';
  final _usernameController = TextEditingController();
  final _selectedBeveragesQtyController = TextEditingController();
  late WarnetPaket _selectedPackage;
  String _selectedMethod = 'Cash';
  final _newPCController = TextEditingController();
  DateTime _selectedWarnetDate = DateTime.now();
  DateTime _selectedBeveragesDate = DateTime.now();

  List<QueryDocumentSnapshot> _currentWarnetEntries = [];
  List<QueryDocumentSnapshot> _currentBeveragesEntries = [];
  bool _isLoadingEntries = true;

  final List<String> _operators = ['Agung', 'Asep', 'Fajar', 'Gume'];
  final List<WarnetPaket> _packages = [
    WarnetPaket(nama: 'Paket 1 Jam', harga: 15000),
    WarnetPaket(nama: 'Paket 2 Jam', harga: 30000),
    WarnetPaket(nama: 'Paket 3 Jam', harga: 45000),
    WarnetPaket(nama: 'Paket Bocah', harga: 50000),
    WarnetPaket(nama: 'Paket Levelling', harga: 100000),
    WarnetPaket(nama: 'Paket Malam', harga: 50000),
  ];

  final List<Beverages> _beverages = [
    Beverages(nama: 'Pristine 400ml', harga: 5000),
    Beverages(nama: 'Pristine 600ml', harga: 7000),
  ];

  final List<String> _methods = ['Cash', 'QRIS'];

  @override
  void initState() {
    super.initState();
    _selectedPackage = _packages.first;
    _fetchCurrentOperator();
    _fetchWarnetEntriesByDate(DateTime.now());
    _fetchBeveragesEntriesByDate(DateTime.now());
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _selectedBeveragesQtyController.dispose();
    _newPCController.dispose();
    super.dispose();
  }

  Future<void> _fetchCurrentOperator() async {
    final currentOperator = await _services.getCurrentOperator();
    setState(() {
      _selectedOperator = currentOperator ?? _operators.first;
    });
  }

  Future<void> _fetchBeveragesEntriesByDate(DateTime date) async {
    setState(() {
      _isLoadingEntries = true;
    });
    final snapshot = await _services.getBeveragesByDate(date).first;
    setState(() {
      _currentBeveragesEntries = snapshot.docs;
      _isLoadingEntries = false;
    });
  }

  Future<void> _fetchWarnetEntriesByDate(DateTime date) async {
    setState(() {
      _isLoadingEntries = true;
    });
    final snapshot = await _services.getWarnetEntriesByDate(date).first;
    setState(() {
      _currentWarnetEntries = snapshot.docs;
      _isLoadingEntries = false;
    });
  }

  Future<void> _onWarnetDateChanged(DateTime newDate) async {
    setState(() {
      _selectedWarnetDate = newDate;
    });
    _fetchWarnetEntriesByDate(newDate);
    setState(() {});
  }

  Future<void> _onBeveragesDateChanged(DateTime newDate) async {
    setState(() {
      _selectedBeveragesDate = newDate;
    });
    _fetchBeveragesEntriesByDate(newDate);
    setState(() {});
  }

  Future<void> _submitCashierEntry() async {
    if (_usernameController.text.isNotEmpty) {
      _services
          .addCashierEntry(
        entry: IndorepWarnetModel(
          timestamp: Timestamp.now(),
          username: _usernameController.text,
          paket: _selectedPackage,
          metode: _selectedMethod,
          operator: _selectedOperator,
        ),
      )
          .then((_) {
        _fetchWarnetEntriesByDate(DateTime.now());
        setState(() {
          _selectedWarnetDate = DateTime.now();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Berhasil menambahkan entri kasir')),
        );
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add entry: $error')),
        );
      });
      _usernameController.clear();
    }
  }

  Future<void> _submitBeveragesEntry() async {
    if (_selectedBeveragesQtyController.text.isNotEmpty) {
      _services
          .addBeveragesEntry(
              entry: IndorepBeveragesModel(
        timestamp: Timestamp.now(),
        beverages: Beverages(
          nama: _selectedBeverages,
          harga:
              _beverages.firstWhere((b) => b.nama == _selectedBeverages).harga,
        ),
        qty: int.parse(_selectedBeveragesQtyController.text),
        grandTotal: int.parse(_selectedBeveragesQtyController.text) *
            _beverages.firstWhere((b) => b.nama == _selectedBeverages).harga,
        metode: _selectedMethod,
        operator: _selectedOperator,
      ))
          .then((_) {
        _fetchBeveragesEntriesByDate(DateTime.now());
        setState(() {
          _selectedBeveragesDate = DateTime.now();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Beverages entry added successfully')),
        );
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add entry: $error')),
        );
      });
      _usernameController.clear();
    }
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
              // <-- Add this
              child: Text(
                'INDOREP Net Dashboard',
                style: GoogleFonts.inter(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis, // <-- Add this
                maxLines: 1, // <-- Add this
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
        length: 2,
        child: Column(
          children: [
            SizedBox(
              child: TabBar(
                tabs: const [
                  Tab(text: 'Transaksi'),
                  Tab(text: 'PC Update List'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: TabBarView(
                children: [
                  SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 1,
                                child: SizedBox(
                                  child: StreamBuilder<QuerySnapshot>(
                                    stream: _services
                                        .getWarnetEntriesByDate(DateTime.now()),
                                    builder: (context, snapshot) {
                                      if (!snapshot.hasData) {
                                        return Center(
                                            child:
                                                CupertinoActivityIndicator());
                                      }
                                      final entries = snapshot.data!.docs;
                                      return Column(
                                        children: [
                                          warnetForm(context),
                                          warnetTransactionList(),
                                        ],
                                      );
                                    },
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: SizedBox(
                                  child: StreamBuilder<QuerySnapshot>(
                                    stream: _services
                                        .getWarnetEntriesByDate(DateTime.now()),
                                    builder: (context, snapshot) {
                                      if (!snapshot.hasData) {
                                        return Center(
                                            child:
                                                CupertinoActivityIndicator());
                                      }
                                      final entries = snapshot.data!.docs;
                                      return Column(
                                        children: [
                                          beveragesForm(context),
                                          beveragesTransactionList(),
                                        ],
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
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

  Padding beveragesTransactionList() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: IndorepColor.primary, width: 1.5),
        ),
        elevation: 2,
        child: Column(
          children: [
            const SizedBox(height: 12),
            DateBar(
              selectedDate: _selectedBeveragesDate,
              onDateChanged: _onBeveragesDateChanged,
            ),
            _isLoadingEntries
                ? const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(child: CupertinoActivityIndicator()),
                  )
                : _currentBeveragesEntries.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Center(
                          child: Text('Tidak ada Penjualan',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                color: Colors.grey,
                              )),
                        ),
                      )
                    : Column(
                        children: [
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _currentBeveragesEntries.length,
                            itemBuilder: (context, index) {
                              final e = _currentBeveragesEntries[index];
                              final rawTimestamp = e['timestamp'];
                              final dt = rawTimestamp is Timestamp
                                  ? rawTimestamp.toDate()
                                  : DateTime.now();
                              final formattedDate =
                                  DateFormat('HH:mm', 'id_ID').format(dt);
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                child: ListTile(
                                  leading: Icon(Icons.receipt_long_rounded),
                                  title: Text(
                                      '${e['qty']}x - ${e['beverages.nama']}'),
                                  subtitle: Text(
                                      '$formattedDate | ${Helper.rupiahFormatter(e['grandTotal'])} | ${e['metode']} | OP: ${e['operator']}'),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 16),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Padding(
                              padding: const EdgeInsets.only(right: 24.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    'Total Transaksi: ${_currentBeveragesEntries.length}',
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Total Pendapatan: ${Helper.rupiahFormatter(_currentBeveragesEntries.fold(0, (sum, e) => sum + e['grandTotal']))}',
                                    style: GoogleFonts.inter(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
          ],
        ),
      ),
    );
  }

  Padding beveragesForm(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: IndorepColor.primary, width: 1.5),
        ),
        elevation: 2,
        child: Column(
          children: [
            const SizedBox(height: 16),
            Center(
              child: Text(
                'Beverages',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Item',
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 0, horizontal: 12), // Match TextField
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.primary,
                            width: 1.2,
                          ),
                        ),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          isDense: true,
                          value: _selectedBeverages,
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedBeverages = newValue!;
                            });
                          },
                          items: _beverages.map((Beverages beverage) {
                            return DropdownMenuItem<String>(
                              value: beverage.nama,
                              child: Text(
                                  '${beverage.nama} - ${Helper.rupiahFormatter(beverage.harga.toDouble())}'),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: TextField(
                    controller: _selectedBeveragesQtyController,
                    decoration: InputDecoration(
                      counterText: "",
                      labelText: 'Qty',
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 0, horizontal: 12), // Match TextField
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.primary,
                          width: 1.2,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.primary,
                          width: 2,
                        ),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    maxLength: 3,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 1,
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Metode',
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 0, horizontal: 12), // Match TextField
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.primary,
                          width: 1.2,
                        ),
                      ),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedMethod,
                        isExpanded: true,
                        isDense: true, // Make dropdown less tall
                        onChanged: (val) =>
                            setState(() => _selectedMethod = val!),
                        items: _methods
                            .map((m) => DropdownMenuItem(
                                  value: m,
                                  child: Text(m),
                                ))
                            .toList(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Add Button
                Material(
                  color: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: IndorepColor.primary,
                      width: 1.5,
                    ),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () async {
                      await _submitBeveragesEntry();
                      _selectedBeveragesQtyController.clear();
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Icon(
                        Icons.add,
                        color: Theme.of(context).colorScheme.primary,
                        size: 28,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 18),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Padding warnetTransactionList() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: IndorepColor.primary, width: 1.5),
        ),
        elevation: 2,
        child: Column(
          children: [
            const SizedBox(height: 12),
            DateBar(
              selectedDate: _selectedWarnetDate,
              onDateChanged: _onWarnetDateChanged,
            ),
            _isLoadingEntries
                ? const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(child: CupertinoActivityIndicator()),
                  )
                : _currentWarnetEntries.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Center(
                          child: Text('Tidak ada Penjualan',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                color: Colors.grey,
                              )),
                        ),
                      )
                    : Column(
                        children: [
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _currentWarnetEntries.length,
                            itemBuilder: (context, index) {
                              final e = _currentWarnetEntries[index];
                              final rawTimestamp = e['timestamp'];
                              final dt = rawTimestamp is Timestamp
                                  ? rawTimestamp.toDate()
                                  : DateTime.now();
                              final formattedDate =
                                  DateFormat('HH:mm', 'id_ID').format(dt);
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                child: ListTile(
                                  leading: Icon(Icons.receipt_long_rounded),
                                  title: Text(
                                      '${e['username']} - ${e['paket.nama']}'),
                                  subtitle: Text(
                                      '$formattedDate | ${Helper.rupiahFormatter(e['paket.harga'])} | ${e['metode']} | OP: ${e['operator']}'),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 16),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Padding(
                              padding: const EdgeInsets.only(right: 24.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    'Total Transaksi: ${_currentWarnetEntries.length}',
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Total Pendapatan: ${Helper.rupiahFormatter(_currentWarnetEntries.fold(0, (sum, e) => sum + e['paket.harga']))}',
                                    style: GoogleFonts.inter(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
          ],
        ),
      ),
    );
  }

  Padding warnetForm(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: IndorepColor.primary, width: 1.5),
        ),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  'Transaksi Warnet',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  // Username TextField
                  Expanded(
                    flex: 3,
                    child: TextField(
                      controller: _usernameController,
                      decoration: InputDecoration(
                        counterText: "",
                        labelText: 'Username',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.primary,
                            width: 1.2,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.primary,
                            width: 2,
                          ),
                        ),
                      ),
                      maxLength: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Package Dropdown
                  Expanded(
                    flex: 4,
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Paket',
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 0, horizontal: 12), // Match TextField
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.primary,
                            width: 1.2,
                          ),
                        ),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedPackage.nama,
                          isExpanded: true,
                          isDense: true, // Make dropdown less tall
                          onChanged: (val) {
                            setState(() {
                              _selectedPackage = _packages.firstWhere(
                                  (p) => p.nama == val,
                                  orElse: () => _packages.first);
                            });
                          },
                          items: _packages
                              .map((p) => DropdownMenuItem<String>(
                                    value: p.nama,
                                    child: Text(
                                        '${p.nama} - ${Helper.rupiahFormatter(p.harga.toDouble())}'),
                                  ))
                              .toList(),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Metode',
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 0, horizontal: 12), // Match TextField
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.primary,
                            width: 1.2,
                          ),
                        ),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedMethod,
                          isExpanded: true,
                          isDense: true, // Make dropdown less tall
                          onChanged: (val) =>
                              setState(() => _selectedMethod = val!),
                          items: _methods
                              .map((m) => DropdownMenuItem(
                                    value: m,
                                    child: Text(m),
                                  ))
                              .toList(),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Add Button
                  Material(
                    color: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: IndorepColor.primary,
                        width: 1.5,
                      ),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () async {
                        await _submitCashierEntry();
                        _usernameController.clear();
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Icon(
                          Icons.add,
                          color: Theme.of(context).colorScheme.primary,
                          size: 28,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
