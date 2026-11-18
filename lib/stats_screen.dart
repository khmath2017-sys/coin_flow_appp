import 'package:flutter/material.dart';
import 'models.dart';

class StatsScreen extends StatelessWidget {
  final List<ExpenseCategory> categories;
  final VoidCallback onResetMonth;

  const StatsScreen({
    super.key,
    required this.categories,
    required this.onResetMonth,
  });

  @override
  Widget build(BuildContext context) {
    double totalSpent = categories.fold(0, (sum, item) => sum + item.spent);

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('Статистика расходов', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.restart_alt, color: Colors.redAccent),
            tooltip: 'Новый месяц',
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Сбросить расходы?'),
                  content: const Text('Все расходы за текущий месяц будут обнулены, а баланс счетов сохранится.'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Отмена')),
                    FilledButton(
                      onPressed: () {
                        onResetMonth();
                        Navigator.pop(ctx);
                      },
                      child: const Text('Сбросить'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.teal,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Text('Всего потрачено за месяц', style: TextStyle(color: Colors.white70, fontSize: 14)),
                  const SizedBox(height: 6),
                  Text(
                    '${totalSpent.toStringAsFixed(0)} ₽',
                    style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final cat = categories[index];
                  double percent = totalSpent > 0 ? (cat.spent / totalSpent) : 0;

                  return Card(
                    elevation: 0,
                    color: Colors.white,
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(14.0),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(cat.icon, color: cat.color, size: 22),
                                  const SizedBox(width: 10),
                                  Text(cat.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                ],
                              ),
                              Text(
                                '${cat.spent.toStringAsFixed(0)} ₽ (${(percent * 100).toStringAsFixed(1)}%)',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          LinearProgressIndicator(
                            value: percent,
                            backgroundColor: Colors.grey.shade200,
                            color: cat.color,
                            minHeight: 8,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
