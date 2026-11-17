import 'package:flutter/material.dart';

class Wallet {
  final String id;
  final String name;
  final IconData icon;
  final Color color;
  double balance;

  Wallet({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.balance,
  });
}

class ExpenseCategory {
  final String id;
  final String name;
  final IconData icon;
  final Color color;
  double spent;

  ExpenseCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    this.spent = 0.0,
  });
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
}
