import 'package:cloud_firestore/cloud_firestore.dart';

class PcsUpdate {
  final DateTime timeStamp;
  final String operator;

  PcsUpdate({
    required this.timeStamp,
    required this.operator,
  });

  factory PcsUpdate.fromJson(Map<String, dynamic> json) {
    return PcsUpdate(
      timeStamp: DateTime.parse(json['timeStamp']),
      operator: json['operator'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'timeStamp': timeStamp.toIso8601String(),
      'operator': operator,
    };
  }
}

class IndorepPcsUpdateModel {
  final String pcId;
  final List<PcsUpdate> updates;

  IndorepPcsUpdateModel({
    required this.pcId,
    required this.updates,
  });

  factory IndorepPcsUpdateModel.fromJson(Map<String, dynamic> json) {
    return IndorepPcsUpdateModel(
      pcId: json['pcId'],
      updates: (json['updates'] as List)
          .map((e) => PcsUpdate.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pcId': pcId,
      'updates': updates.map((e) => e.toJson()).toList(),
    };
  }
}

class IndorepWarnetModel {
  final Timestamp timestamp;
  final String username;
  final WarnetPaket paket;
  final String metode;
  final String operator;

  IndorepWarnetModel({
    required this.timestamp,
    required this.username,
    required this.paket,
    required this.metode,
    required this.operator,
  });

  factory IndorepWarnetModel.fromJson(Map<String, dynamic> json) {
    return IndorepWarnetModel(
      timestamp: json['timestamp'] as Timestamp,
      username: json['username'],
      paket: WarnetPaket.fromJson(json['paket']),
      metode: json['metode'],
      operator: json['operator'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp,
      'username': username,
      'paket': paket.toJson(),
      'metode': metode,
      'operator': operator,
    };
  }
}

class IndorepBeveragesModel {
  final Timestamp timestamp;
  final Beverages beverages;
  final int qty;
  int grandTotal;
  final String metode;
  final String operator;

  IndorepBeveragesModel({
    required this.timestamp,
    required this.beverages,
    required this.qty,
    required this.grandTotal,
    required this.metode,
    required this.operator,
  });

  factory IndorepBeveragesModel.fromJson(Map<String, dynamic> json) {
    return IndorepBeveragesModel(
      timestamp: json['timestamp'] as Timestamp,
      beverages: Beverages.fromJson(json['beverages']),
      qty: (json['qty'] as num).toInt(),
      metode: json['metode'],
      grandTotal: (json['grandTotal'] as num).toInt(),
      operator: json['operator'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp,
      'beverages': beverages.toJson(),
      'qty': qty,
      'metode': metode,
      'grandTotal': grandTotal,
      'operator': operator,
    };
  }
}

class Beverages {
  final String nama;
  final int harga;

  Beverages({required this.nama, required this.harga});

  factory Beverages.fromJson(Map<String, dynamic> json) {
    return Beverages(
      nama: json['nama'],
      harga: (json['harga'] as num).toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nama': nama,
      'harga': harga,
    };
  }
}

class WarnetPaket {
  final String nama;
  final int harga;
  int? hargaAsli;

  WarnetPaket({required this.nama, required this.harga, this.hargaAsli});

  factory WarnetPaket.fromJson(Map<String, dynamic> json) {
    return WarnetPaket(
      nama: json['nama'],
      harga: (json['harga'] as num).toInt(),
      hargaAsli: (json['hargaAsli'] as num?)?.toInt(),
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'nama': nama,
      'harga': harga,
      'hargaAsli': hargaAsli,
    };
  }
}
