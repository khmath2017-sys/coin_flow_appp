import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'models.dart';
import 'widgets.dart';

void main() {
  runApp(const CoinTrackerApp());
}

class CoinTrackerApp extends StatelessWidget {
  const CoinTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CoinFlow',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.teal,
        brightness: Brightness.light,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Wallet> wallets = [
    Wallet(id: 'w1', name: 'كاش', icon: Icons.payments, color: Colors.green, balance: 1500.0),
    Wallet(id: 'w2', name: 'البطاقة', icon: Icons.credit_card, color: Colors.blue, balance: 4200.0),
    Wallet(id: 'w3', name: 'مدخرات', icon: Icons.savings, color: Colors.orange, balance: 8000.0),
  ];

  final List<ExpenseCategory> categories = [
    ExpenseCategory(id: 'c1', name: 'طعام', icon: Icons.restaurant, color: Colors.redAccent),
    ExpenseCategory(id: 'c2', name: 'مواصلات', icon: Icons.directions_car, color: Colors.indigo),
    ExpenseCategory(id: 'c3', name: 'تسوق', icon: Icons.shopping_bag, color: Colors.purple),
    ExpenseCategory(id: 'c4', name: 'فواتير', icon: Icons.receipt_long, color: Colors.teal),
    ExpenseCategory(id: 'c5', name: 'قهوة', icon: Icons.local_cafe, color: Colors.brown),
    ExpenseCategory(id: 'c6', name: 'ترفيه', icon: Icons.movie, color: Colors.pink),
  ];

  final List<TransactionRecord> transactions = [];

  void _showAmountDialog(Wallet wallet, ExpenseCategory category) {
    final TextEditingController amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            title: Text('صرف من (${wallet.name}) إلى (${category.name})'),
            content: TextField(
              controller: amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'أدخل المبلغ',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.attach_money),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('إلغاء'),
              ),
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
                    HapticFeedback.mediumImpact();
                    Navigator.pop(context);
                  }
                },
                child: const Text('تأكيد'),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double totalSpent = categories.fold(0, (sum, item) => sum + item.spent);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.grey.shade100,
        appBar: AppBar(
          title: const Text('مدير المصاريف الذكي', style: TextStyle(fontWeight: FontWeight.bold)),
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 0,
        ),
        body: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'اسحب المحفظة وأفلتها فوق المصروف:',
                    style: TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: wallets.map((wallet) {
                      return Draggable<Wallet>(
                        data: wallet,
                        onDragStarted: () => HapticFeedback.lightImpact(),
                        feedback: Material(
                          color: Colors.transparent,
                          child: CoinWidget(wallet: wallet, isDragging: true),
                        ),
                        childWhenDragging: Opacity(
                          opacity: 0.3,
                          child: CoinWidget(wallet: wallet),
                        ),
                        child: CoinWidget(wallet: wallet),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              color: Colors.teal.withOpacity(0.1),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('إجمالي مصاريف الشهر:', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(
                    totalSpent.toStringAsFixed(0),
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 0.95,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  return DragTarget<Wallet>(
                    onAcceptWithDetails: (details) {
                      _showAmountDialog(details.data, category);
                    },
                    builder: (context, candidateData, rejectedData) {
                      return CategoryCard(
                        category: category,
                        isHovering: candidateData.isNotEmpty,
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('آخر العمليات:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 8),
                    Expanded(
                      child: transactions.isEmpty
                          ? const Center(
                              child: Text('لا توجد مصاريف مسجلة بعد', style: TextStyle(color: Colors.grey)),
                            )
                          : ListView.builder(
                              itemCount: transactions.length,
                              itemBuilder: (context, index) {
                                final tx = transactions[index];
                                return Card(
                                  elevation: 0,
                                  color: Colors.white,
                                  margin: const EdgeInsets.only(bottom: 8),
                                  child: ListTile(
                                    leading: const Icon(Icons.arrow_downward, color: Colors.redAccent),
                                    title: Text('${tx.categoryName} (من ${tx.walletName})'),
                                    trailing: Text(
                                      '- ${tx.amount.toStringAsFixed(0)}',
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
      ),
    );
  }
}
