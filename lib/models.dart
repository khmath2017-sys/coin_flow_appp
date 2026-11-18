import 'package:flutter/material.dart';

class Wallet {
  final String id;
  final String name;
  final int iconCode;
  final int colorValue;
  double balance;

  Wallet({
    required this.id,
    required this.name,
    required this.iconCode,
    required this.colorValue,
    required this.balance,
  });

  IconData get icon => IconData(iconCode, fontFamily: 'MaterialIcons');
  Color get color => Color(colorValue);

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'iconCode': iconCode,
        'colorValue': colorValue,
        'balance': balance,
      };

  factory Wallet.fromJson(Map<String, dynamic> json) => Wallet(
        id: json['id'],
        name: json['name'],
        iconCode: json['iconCode'],
        colorValue: json['colorValue'],
        balance: (json['balance'] as num).toDouble(),
      );
}
class ExpenseCategory {
  final String id;
  final String name;
  final int iconCode;
  final int colorValue;
  double spent;

  ExpenseCategory({
    required this.id,
    required this.name,
    required this.iconCode,
    required this.colorValue,
    this.spent = 0.0,
  });

  IconData get icon => IconData(iconCode, fontFamily: 'MaterialIcons');
  Color get color => Color(colorValue);

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'iconCode': iconCode,
        'colorValue': colorValue,
        'spent': spent,
      };

  factory ExpenseCategory.fromJson(Map<String, dynamic> json) => ExpenseCategory(
        id: json['id'],
        name: json['name'],
        iconCode: json['iconCode'],
        colorValue: json['colorValue'],
        spent: (json['spent'] as num).toDouble(),
      );
}

class TransactionRecord {
  final String walletName;
  final String categoryName;
  final double amount;
  final DateTime date;

  TransactionRecord({
    required this.walletName,
    required this.categoryName,
    required this.amount,
    required this.date,
  });

  Map<String, dynamic> toJson() => {
        'walletName': walletName,
        'categoryName': categoryName,
        'amount': amount,
        'date': date.toIso8601String(),
      };

  factory TransactionRecord.fromJson(Map<String, dynamic> json) => TransactionRecord(
        walletName: json['walletName'],
        categoryName: json['categoryName'],
        amount: (json['amount'] as num).toDouble(),
        date: DateTime.parse(json['date']),
      );
}
