import 'package:flutter/material.dart';
import 'models.dart';

// تصميم أيقونة العملة (المحفظة القابلة للسحب)
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
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: wallet.color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: wallet.color.withOpacity(0.4),
                blurRadius: isDragging ? 15 : 6,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(wallet.icon, color: Colors.white, size: 30),
        ),
        const SizedBox(height: 6),
        Text(
          wallet.name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
        Text(
          wallet.balance.toStringAsFixed(0),
          style: TextStyle(
            color: wallet.color,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

// تصميم بطاقة فئة المصاريف (هدف الإفلات)
class CategoryCard extends StatelessWidget {
  final ExpenseCategory category;
  final bool isHovering;

  const CategoryCard({
    super.key,
    required this.category,
    required this.isHovering,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: isHovering ? category.color.withOpacity(0.2) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isHovering ? category.color : Colors.grey.shade200,
          width: isHovering ? 2.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: category.color.withOpacity(0.15),
            child: Icon(category.icon, color: category.color),
          ),
          const SizedBox(height: 6),
          Text(
            category.name,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
          Text(
            category.spent.toStringAsFixed(0),
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
