import 'package:flutter/material.dart';
import 'models.dart';

// تصميم أيقونة العملة بتدرج لوني احترافي
class CoinWidget extends StatelessWidget {
  final Wallet wallet;
  final bool isDragging;

  const CoinWidget({
    super.key,
    required this.wallet,
    this.isDragging = false,
  });

  @override
  Widget build(BuildContext context) {
    final HSLColor hsl = HSLColor.fromColor(wallet.color);
    final Color lightColor = hsl.withLightness((hsl.lightness + 0.15).clamp(0.0, 1.0)).toColor();
    final Color darkColor = hsl.withLightness((hsl.lightness - 0.15).clamp(0.0, 1.0)).toColor();

    return Column(
      children: [
        Container(
          width: 68,
          height: 68,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [lightColor, wallet.color, darkColor],
            ),
            border: Border.all(color: Colors.white.withOpacity(0.5), width: 2),
            boxShadow: [
              BoxShadow(
                color: wallet.color.withOpacity(isDragging ? 0.6 : 0.35),
                blurRadius: isDragging ? 18 : 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Center(
            child: Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withOpacity(0.25), width: 1),
              ),
              child: Icon(wallet.icon, color: Colors.white, size: 28),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          wallet.name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87),
        ),
        Text(
          '${wallet.balance.toStringAsFixed(0)} ₽',
          style: TextStyle(
            color: darkColor,
            fontWeight: FontWeight.w800,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
// تصميم بطاقة فئة المصاريف بأسلوب عصري ملون
class CategoryCard extends StatelessWidget {
  final ExpenseCategory category;
  final bool isHovering;

  const CategoryCard({
    super.key,
    required this.category,
    this.isHovering = false,
  });

  @override
  Widget build(BuildContext context) {
    final HSLColor hsl = HSLColor.fromColor(category.color);
    final Color lightBg = hsl.withLightness((hsl.lightness + 0.12).clamp(0.0, 1.0)).toColor();

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      transform: isHovering ? (Matrix4.identity()..scale(1.05)) : Matrix4.identity(),
      decoration: BoxDecoration(
        gradient: isHovering
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [category.color.withOpacity(0.25), category.color.withOpacity(0.1)],
              )
            : null,
        color: isHovering ? null : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isHovering ? category.color : category.color.withOpacity(0.15),
          width: isHovering ? 2.5 : 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: category.color.withOpacity(isHovering ? 0.25 : 0.08),
            blurRadius: isHovering ? 12 : 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [lightBg, category.color],
              ),
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: category.color.withOpacity(0.35),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Icon(category.icon, color: Colors.white, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            category.name,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87),
          ),
          const SizedBox(height: 2),
          Text(
            '${category.spent.toStringAsFixed(0)} ₽',
            style: TextStyle(
              color: category.spent > 0 ? category.color : Colors.grey.shade500,
              fontWeight: category.spent > 0 ? FontWeight.bold : FontWeight.normal,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
