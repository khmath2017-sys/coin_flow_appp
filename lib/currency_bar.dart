import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';

class CurrencyRatesBar extends StatefulWidget {
  const CurrencyRatesBar({super.key});

  @override
  State<CurrencyRatesBar> createState() => _CurrencyRatesBarState();
}

class _CurrencyRatesBarState extends State<CurrencyRatesBar> {
  double? usdRate;
  double? eurRate;
  bool isLoading = true;
  String errorText = '';

  @override
  void initState() {
    super.initState();
    fetchCbrRates();
  }

  Future<String> _getUrl(String url) async {
    final client = HttpClient()
      ..badCertificateCallback = (cert, host, port) => true;

    final req = await client.getUrl(Uri.parse(url));
    req.headers.set('User-Agent', 'Mozilla/5.0');
    final res = await req.close();
    final bytes = await res.fold<List<int>>([], (p, e) => p..addAll(e));
    client.close();
    if (res.statusCode != 200) throw Exception('HTTP ${res.statusCode}');
    return utf8.decode(bytes, allowMalformed: true);
  }

  Future<void> fetchCbrRates() async {
    setState(() {
      isLoading = true;
      errorText = '';
    });

    try {
final body = await _getUrl('https://cbr-xml-daily.ru' + '/daily_json.js');

      final data = json.decode(body);
      setState(() {
        usdRate = (data['Valute']['USD']['Value'] as num).toDouble();
        eurRate = (data['Valute']['EUR']['Value'] as num).toDouble();
        isLoading = false;
      });
      return;
    } catch (e1) {
      final body2 = await _getUrl('https://er-api.com' + '/v6/latest/USD');

        final body2 = await _getUrl('https://er-api.com');
        final data2 = json.decode(body2);
        final rub = (data2['rates']['RUB'] as num).toDouble();
        final eur = (data2['rates']['EUR'] as num).toDouble();
        setState(() {
          usdRate = rub;
          eurRate = rub / eur;
          isLoading = false;
        });
        return;
      } catch (e2) {
        setState(() {
          errorText = e1.toString().replaceAll('Exception:', '').trim();
          isLoading = false;
        });
      }
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
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Закрыть')),
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
            : errorText.isNotEmpty
                ? Row(
                    children: [
                      Expanded(
                        child: Text(
                          errorText,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 11, color: Colors.redAccent),
                        ),
                      ),
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
