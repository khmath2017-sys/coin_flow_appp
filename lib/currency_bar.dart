import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CurrencyRatesBar extends StatefulWidget {
  const CurrencyRatesBar({super.key});

  @override
  State<CurrencyRatesBar> createState() => _CurrencyRatesBarState();
}

class _CurrencyRatesBarState extends State<CurrencyRatesBar> {
  double? usdRate;
  double? usdPrev;
  double? eurRate;
  double? eurPrev;
  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    fetchCbrRates();
  }

  Future<void> fetchCbrRates() async {
    setState(() {
      isLoading = true;
      hasError = false;
    });

    try {
      final response = await http.get(
        Uri.parse('https://cbr-xml-daily.ru'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        setState(() {
          usdRate = (data['Valute']['USD']['Value'] as num).toDouble();
          usdPrev = (data['Valute']['USD']['Previous'] as num).toDouble();
          eurRate = (data['Valute']['EUR']['Value'] as num).toDouble();
          eurPrev = (data['Valute']['EUR']['Previous'] as num).toDouble();
          isLoading = false;
        });
      } else {
        setState(() {
          hasError = true;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        hasError = true;
        isLoading = false;
      });
    }
  }
  void _showCalculatorDialog() {
    if (usdRate == null || eurRate == null) return;
    final TextEditingController inputCtrl = TextEditingController(text: '100');
    String selectedCurrency = 'USD';
    bool toRub = true;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            double val = double.tryParse(inputCtrl.text) ?? 0;
            double rate = selectedCurrency == 'USD' ? usdRate! : eurRate!;
            double result = toRub ? (val * rate) : (val / rate);

            return AlertDialog(
              title: const Text('Калькулятор ЦБ РФ'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ChoiceChip(
                        label: const Text('Доллар USD'),
                        selected: selectedCurrency == 'USD',
                        onSelected: (_) => setDialogState(() => selectedCurrency = 'USD'),
                      ),
                      ChoiceChip(
                        label: const Text('Евро EUR'),
                        selected: selectedCurrency == 'EUR',
                        onSelected: (_) => setDialogState(() => selectedCurrency = 'EUR'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: inputCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: toRub ? 'Сумма в $selectedCurrency' : 'Сумма в рублях ₽',
                      border: const OutlineInputBorder(),
                    ),
                    onChanged: (_) => setDialogState(() {}),
                  ),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: () => setDialogState(() => toRub = !toRub),
                    icon: const Icon(Icons.swap_vert),
                    label: Text(toRub ? 'Перевести в рубли (₽)' : 'Перевести в ($selectedCurrency)'),
                  ),
                  const Divider(),
                  Text(
                    toRub
                        ? '${result.toStringAsFixed(2)} ₽'
                        : '${result.toStringAsFixed(2)} $selectedCurrency',
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.teal),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Закрыть'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _showCalculatorDialog,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 10, 16, 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.teal.withOpacity(0.25)),
        ),
        child: isLoading
            ? const Center(child: SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)))
            : hasError
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Ошибка загрузки курса ЦБ РФ', style: TextStyle(fontSize: 12, color: Colors.redAccent)),
                      IconButton(icon: const Icon(Icons.refresh, size: 18), onPressed: fetchCbrRates, padding: EdgeInsets.zero, constraints: const BoxConstraints()),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildRateItem('USD', usdRate!, usdPrev!),
                      Container(width: 1, height: 26, color: Colors.grey.shade300),
                      _buildRateItem('EUR', eurRate!, eurPrev!),
                      Container(width: 1, height: 26, color: Colors.grey.shade300),
                      const Icon(Icons.calculate_outlined, color: Colors.teal, size: 22),
                    ],
                  ),
      ),
    );
  }

  Widget _buildRateItem(String title, double current, double previous) {
    final isUp = (current - previous) >= 0;
    return Row(
      children: [
        Text('$title: ', style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
        Text('${current.toStringAsFixed(2)} ₽', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
        Icon(isUp ? Icons.arrow_drop_up : Icons.arrow_drop_down, color: isUp ? Colors.red : Colors.green, size: 18),
      ],
    );
  }
}
