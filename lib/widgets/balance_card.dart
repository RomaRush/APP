import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/theme/app_theme.dart';
import '../widgets/minimal_card.dart';

class BalanceCard extends StatelessWidget {
  final int balance;
  final int? income;
  final int? expenses;

  const BalanceCard({
    super.key,
    this.balance = 0,
    this.income,
    this.expenses,
  });

  String _fmt(int value) {
    final f = NumberFormat('#,###', 'ru_RU');
    return '${f.format(value.abs())} ₽';
  }

  @override
  Widget build(BuildContext context) {
    final isPositive = balance >= 0;
    final accent = isPositive ? AppTheme.accentGreen : AppTheme.errorRed;

    return MinimalCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(
                  isPositive
                      ? Icons.account_balance_wallet_rounded
                      : Icons.trending_down_rounded,
                  color: accent,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Text('Баланс', style: AppTheme.titleStyle.copyWith(fontSize: 16)),
            ],
          ),

          const SizedBox(height: 28),

          // Big balance number
          Center(
            child: Column(
              children: [
                RichText(
                  text: TextSpan(
                    children: [
                      if (!isPositive)
                        TextSpan(
                          text: '−',
                          style: AppTheme.headlineStyle.copyWith(
                            fontSize: 36,
                            color: accent,
                            letterSpacing: -1,
                          ),
                        ),
                      TextSpan(
                        text: _fmt(balance),
                        style: AppTheme.headlineStyle.copyWith(
                          fontSize: 36,
                          color: isPositive ? AppTheme.white : accent,
                          letterSpacing: -1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'доступно сейчас',
                  style: AppTheme.captionStyle.copyWith(fontSize: 11),
                ),
              ],
            ),
          ),

          // Income/Expense row
          if (income != null && expenses != null) ...[
            const SizedBox(height: 24),
            Container(
              height: 1,
              color: AppTheme.white12,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _FlowItem(
                    label: 'Доход',
                    value: _fmt(income!),
                    icon: Icons.arrow_downward_rounded,
                    color: AppTheme.accentGreen,
                  ),
                ),
                Container(width: 1, height: 36, color: AppTheme.white12),
                Expanded(
                  child: _FlowItem(
                    label: 'Расход',
                    value: _fmt(expenses!),
                    icon: Icons.arrow_upward_rounded,
                    color: AppTheme.errorRed,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _FlowItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _FlowItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 13),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: AppTheme.captionStyle.copyWith(fontSize: 10)),
            const SizedBox(height: 1),
            Text(
              value,
              style: AppTheme.bodyStyle.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
