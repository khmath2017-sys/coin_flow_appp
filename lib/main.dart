import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models.dart';
import 'widgets.dart';
import 'currency_bar.dart';
import 'stats_screen.dart';

void main() {
  runApp(const CoinTrackerApp());
}

class CoinTrackerApp extends StatelessWidget {
  const CoinTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CoinFlow RU',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.teal,
        brightness: Brightness.light,
      ),
      home: const MainNavigationScreen(),
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  List<Wallet> wallets = [
    Wallet(id: 'w1', name: 'Наличные', iconCode: Icons.payments.codePoint, colorValue: Colors.green.value, balance: 15000.0),
    Wallet(id: 'w2', name: 'Карта', iconCode: Icons.credit_card.codePoint, colorValue: Colors.blue.value, balance: 45000.0),
    Wallet(id: 'w3', name: 'Копилка', iconCode: Icons.savings.codePoint, colorValue: Colors.orange.value, balance: 80000.0),
  ];

  List<ExpenseCategory> categories = [
    ExpenseCategory(id: 'c1', name: 'Еда', iconCode: Icons.restaurant.codePoint, colorValue: Colors.redAccent.value),
    ExpenseCategory(id: 'c2', name: 'Транспорт', iconCode: Icons.directions_car.codePoint, colorValue: Colors.indigo.value),
    ExpenseCategory(id: 'c3', name: 'Покупки', iconCode: Icons.shopping_bag.codePoint, colorValue: Colors.purple.value),
    ExpenseCategory(id: 'c4', name: 'Счета', iconCode: Icons.receipt_long.codePoint, colorValue: Colors.teal.value),
    ExpenseCategory(id: 'c5', name: 'Кофе', iconCode: Icons.local_cafe.codePoint, colorValue: Colors.brown.value),
    ExpenseCategory(id: 'c6', name: 'Досуг', iconCode: Icons.movie.codePoint, colorValue: Colors.pink.value),
  ];

  List<TransactionRecord> transactions = [];
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final wStr = prefs.getString('wallets');
    final cStr = prefs.getString('categories');
    final tStr = prefs.getString('transactions');

    setState(() {
      if (wStr != null) {
        wallets = (json.decode(wStr) as List).map((e) => Wallet.fromJson(e)).toList();
      }
      if (cStr != null) {
        categories = (json.decode(cStr) as List).map((e) => ExpenseCategory.fromJson(e)).toList();
      }
      if (tStr != null) {
        transactions = (json.decode(tStr) as List).map((e) => TransactionRecord.fromJson(e)).toList();
      }
    });
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('wallets', json.encode(wallets.map((e) => e.toJson()).toList()));
    await prefs.setString('categories', json.encode(categories.map((e) => e.toJson()).toList()));
    await prefs.setString('transactions', json.encode(transactions.map((e) => e.toJson()).toList()));
  }

  void _resetMonth() {
    setState(() {
      for (var c in categories) {
        c.spent = 0.0;
      }
      transactions.clear();
    });
    _saveData();
  }
  void _showAmountDialog(Wallet wallet, ExpenseCategory category) {
    final TextEditingController amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Расход: ${wallet.name} → ${category.name}'),
          content: TextField(
            controller: amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Введите сумму (₽)',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Отмена')),
            FilledButton(
              onPressed: () {
                final double? amount = double.tryParse(amountController.text);
                if (amount != null && amount > 0) {
                  setState(() {
                    wallet.balance -= amount;
                    category.spent += amount;
                    transactions.insert(
                      0,
                      TransactionRecord(
                        walletName: wallet.name,
                        categoryName: category.name,
                        amount: amount,
                        date: DateTime.now(),
                      ),
                    );
                  });
                  _saveData();
                  HapticFeedback.mediumImpact();
                  Navigator.pop(context);
                }
              },
              child: const Text('Подтвердить'),
            ),
          ],
        );
      },
    );
  }

  void _showEditWalletDialog(Wallet wallet) {
    final TextEditingController balanceCtrl = TextEditingController(text: wallet.balance.toStringAsFixed(0));

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Счет: ${wallet.name}'),
          content: TextField(
            controller: balanceCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Текущий баланс (₽)',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Отмена')),
            FilledButton(
              onPressed: () {
                final double? newBal = double.tryParse(balanceCtrl.text);
                if (newBal != null) {
                  setState(() => wallet.balance = newBal);
                  _saveData();
                  Navigator.pop(context);
                }
              },
              child: const Text('Сохранить'),
            ),
          ],
        );
      },
    );
  }
  String _getShortRussianDate() {
    final now = DateTime.now();
    const days = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];
    const months = ['янв', 'фев', 'мар', 'апр', 'мая', 'июн', 'июл', 'авг', 'сен', 'окт', 'ноя', 'дек'];
    return '${days[now.weekday - 1]}, ${now.day} ${months[now.month - 1]}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _selectedIndex == 0
          ? _buildHomeTab()
          : StatsScreen(categories: categories, onResetMonth: _resetMonth),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (idx) => setState(() => _selectedIndex = idx),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.account_balance_wallet), label: 'Главная'),
          NavigationDestination(icon: Icon(Icons.pie_chart), label: 'Статистика'),
        ],
      ),
    );
  }

  Widget _buildHomeTab() {
    double totalSpent = categories.fold(0, (sum, item) => sum + item.spent);

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Column(
          children: [
            const Text('Умный Бюджет', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            Text(
              _getShortRussianDate(),
              style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.normal),
            ),
          ],
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          const CurrencyRatesBar(),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Перетащите счет на категорию (нажмите для изменения баланса):',
                  style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: wallets.map((wallet) {
                    return GestureDetector(
                      onTap: () => _showEditWalletDialog(wallet),
                      child: Draggable<Wallet>(
                        data: wallet,
                        onDragStarted: () => HapticFeedback.lightImpact(),
                        feedback: Material(
                          color: Colors.transparent,
                          child: CoinWidget(wallet: wallet, isDragging: true),
                        ),
                        childWhenDragging: Opacity(opacity: 0.3, child: CoinWidget(wallet: wallet)),
                        child: CoinWidget(wallet: wallet),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            color: Colors.teal.withOpacity(0.1),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Расходы за месяц:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text(
                  '${totalSpent.toStringAsFixed(0)} ₽',
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.teal),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 1.0,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                return DragTarget<Wallet>(
                  onAcceptWithDetails: (details) => _showAmountDialog(details.data, category),
                  builder: (context, candidateData, rejectedData) {
                    return CategoryCard(category: category, isHovering: candidateData.isNotEmpty);
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Последние операции:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 6),
                  Expanded(
                    child: transactions.isEmpty
                        ? const Center(child: Text('Нет операций', style: TextStyle(color: Colors.grey)))
                        : ListView.builder(
                            itemCount: transactions.length,
                            itemBuilder: (context, index) {
                              final tx = transactions[index];
                              return Card(
                                elevation: 0,
                                color: Colors.white,
                                margin: const EdgeInsets.only(bottom: 6),
                                child: ListTile(
                                  dense: true,
                                  leading: const Icon(Icons.arrow_downward, color: Colors.redAccent, size: 18),
                                  title: Text('${tx.categoryName} (${tx.walletName})'),
                                  trailing: Text(
                                    '- ${tx.amount.toStringAsFixed(0)} ₽',
                                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.redAccent),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
