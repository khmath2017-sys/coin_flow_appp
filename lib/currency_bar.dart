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
  double? eurRate;
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
      // الاتصال بمصدر البنك المركزي الروسي الرسمي أو المرآة الاحتياطية
      final response = await http
          .get(Uri.parse('https://cbr.ru'))
          .timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final body = latin1.decode(response.bodyBytes);
        final usdMatch = RegExp(r'R01235.*?<Value>(.*?)</Value>', dotAll: true).firstMatch(body);
        final eurMatch = RegExp(r'R01239.*?<Value>(.*?)</Value>', dotAll: true).firstMatch(body);

        if (usdMatch != null && eurMatch != null) {
          setState(() {
            usdRate = double.parse(usdMatch.group(1)!.replaceAll(',', '.'));
            eurRate = double.parse(eurMatch.group(1)!.replaceAll(',', '.'));
            isLoading = false;
          });
          return;
        }
      }
      throw Exception('Failed');
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
                      const Text('Нет связи с ЦБ РФ (нажмите ↻)', style: TextStyle(fontSize: 12, color: Colors.redAccent)),
                      IconButton(icon: const Icon(Icons.refresh, size: 18), onPressed: fetchCbrRates, padding: EdgeInsets.zero, constraints: const BoxConstraints()),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildRateItem('USD ЦБ', usdRate!),
                      Container(width: 1, height: 26, color: Colors.grey.shade300),
                      _buildRateItem('EUR ЦБ', eurRate!),
                      Container(width: 1, height: 26, color: Colors.grey.shade300),
                      const Icon(Icons.calculate_outlined, color: Colors.teal, size: 22),
                    ],
                  ),
      ),
    );
  }

  Widget _buildRateItem(String title, double current) {
    return Row(
      children: [
        Text('$title: ', style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
        Text('${current.toStringAsFixed(2)} ₽', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.teal)),
      ],
    );
  }
}
