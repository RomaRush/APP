import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:barcode_widget/barcode_widget.dart' as bw;
import '../../core/theme/app_theme.dart';
import '../../core/providers/finance_provider.dart';
import '../../core/providers/user_provider.dart';
import '../../widgets/minimal_card.dart';

class FinanceScreen extends StatefulWidget {
  const FinanceScreen({super.key});
  @override
  State<FinanceScreen> createState() => _FinanceScreenState();
}

class _FinanceScreenState extends State<FinanceScreen> {
  final _fmt = NumberFormat('#,###', 'ru_RU');

  String _fmtMoney(num v) => '${_fmt.format(v.abs())} ₽';

  // ── Add Transaction ─────────────────────────────────────────────────────────
  void _showAddTransactionDialog(BuildContext context) {
    final titleCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    bool isExpense = true;
    bool isCash = false;
    TransactionCategory selectedCategory = TransactionCategory.other;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: _DarkSheet(
          child: StatefulBuilder(
            builder: (context, setModal) => Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Новая транзакция', style: AppTheme.titleStyle),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _TypeChip(
                        label: 'Расход',
                        icon: Icons.arrow_upward_rounded,
                        selected: isExpense,
                        color: AppTheme.errorRed,
                        onTap: () => setModal(() => isExpense = true),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _TypeChip(
                        label: 'Доход',
                        icon: Icons.arrow_downward_rounded,
                        selected: !isExpense,
                        color: AppTheme.accentGreen,
                        onTap: () => setModal(() => isExpense = false),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                _SheetTextField(controller: titleCtrl, label: 'Название', hint: 'Кофе, зарплата...'),
                const SizedBox(height: 12),
                _SheetTextField(
                  controller: amountCtrl,
                  label: 'Сумма',
                  hint: '0 ₽',
                  inputType: const TextInputType.numberWithOptions(decimal: false),
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
                if (isExpense) ...[
                  const SizedBox(height: 16),
                  Text('Категория', style: AppTheme.captionStyle.copyWith(fontSize: 12, color: AppTheme.white54)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final cat in TransactionCategory.values.where((c) => c != TransactionCategory.income))
                        GestureDetector(
                          onTap: () => setModal(() => selectedCategory = cat),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: selectedCategory == cat ? cat.color.withValues(alpha: 0.2) : AppTheme.white08,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: selectedCategory == cat ? cat.color : Colors.transparent,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(cat.icon, size: 13, color: selectedCategory == cat ? cat.color : AppTheme.white38),
                                const SizedBox(width: 4),
                                Text(cat.label, style: AppTheme.captionStyle.copyWith(
                                  color: selectedCategory == cat ? cat.color : AppTheme.white54,
                                  fontSize: 12,
                                )),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(Icons.money_rounded, color: AppTheme.white54, size: 20),
                    const SizedBox(width: 12),
                    Text('Наличные', style: AppTheme.bodyStyle),
                    const Spacer(),
                    Switch(
                      value: isCash,
                      onChanged: (val) => setModal(() => isCash = val),
                      activeColor: AppTheme.accentGreen,
                      activeTrackColor: AppTheme.accentGreen.withValues(alpha: 0.2),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _PrimaryButton(
                  label: 'Добавить',
                  onPressed: () {
                    final amount = int.tryParse(amountCtrl.text.replaceAll(' ', '')) ?? 0;
                    if (titleCtrl.text.isNotEmpty && amount > 0) {
                      context.read<FinanceProvider>().addTransaction(
                        titleCtrl.text, amount, isExpense,
                        isCash: isCash,
                        category: isExpense ? selectedCategory : TransactionCategory.income,
                      );
                      Navigator.pop(ctx);
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Add Subscription ────────────────────────────────────────────────────────
  void _showAddSubscriptionDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    DateTime? selectedDate;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: _DarkSheet(
          child: StatefulBuilder(
            builder: (context, setModalState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Новая подписка', style: AppTheme.titleStyle),
                  const SizedBox(height: 24),
                  _SheetTextField(controller: nameCtrl, label: 'Сервис', hint: 'Netflix, Spotify...'),
                  const SizedBox(height: 14),
                  _SheetTextField(
                    controller: amountCtrl,
                    label: 'Сумма в месяц',
                    hint: '0 ₽',
                    inputType: TextInputType.number,
                  ),
                  const SizedBox(height: 14),
                  GestureDetector(
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (date != null) {
                        setModalState(() => selectedDate = date);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      decoration: BoxDecoration(
                        color: AppTheme.white05,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.calendar_today_rounded, color: AppTheme.white54, size: 20),
                          const SizedBox(width: 12),
                          Text(
                            selectedDate != null ? DateFormat('d MMMM yyyy', 'ru').format(selectedDate!) : 'Дата списания',
                            style: AppTheme.bodyStyle.copyWith(
                              color: selectedDate != null ? AppTheme.white : AppTheme.white54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  _PrimaryButton(
                    label: 'Добавить',
                    onPressed: () {
                      final amount = double.tryParse(amountCtrl.text.replaceAll(' ', '')) ?? 0;
                      if (nameCtrl.text.isNotEmpty && amount > 0) {
                        context.read<FinanceProvider>().addSubscription(nameCtrl.text, amount.toInt(), expiryDate: selectedDate);
                        Navigator.pop(ctx);
                      }
                    },
                  ),
                ],
              );
            }
          ),
        ),
      ),
    );
  }

  // ── Add Loyalty Card ────────────────────────────────────────────────────────
  void _showAddCardDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final codeCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: _DarkSheet(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Карта лояльности', style: AppTheme.titleStyle),
              const SizedBox(height: 24),
              _SheetTextField(controller: nameCtrl, label: 'Магазин', hint: 'Пятёрочка, Лента...'),
              const SizedBox(height: 14),
              _SheetTextField(controller: codeCtrl, label: 'Штрихкод / номер карты', hint: '1234567890'),
              const SizedBox(height: 28),
              _PrimaryButton(
                label: 'Сохранить',
                onPressed: () {
                  if (nameCtrl.text.isNotEmpty) {
                    context.read<FinanceProvider>().addDiscountCard(
                      nameCtrl.text,
                      codeData: codeCtrl.text.isEmpty ? null : codeCtrl.text,
                    );
                    Navigator.pop(ctx);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Card QR details ─────────────────────────────────────────────────────────
  void _showCardDetails(BuildContext context, DiscountCard card) {
    final GlobalKey qrKey = GlobalKey();

    Future<void> shareQr() async {
      try {
        final boundary = qrKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
        if (boundary == null) return;
        final image = await boundary.toImage(pixelRatio: 3.0);
        final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
        if (byteData == null) return;

        final tempDir = await getTemporaryDirectory();
        final file = File('${tempDir.path}/qr_${card.id}.png');
        await file.writeAsBytes(byteData.buffer.asUint8List());

        await Share.shareXFiles([XFile(file.path)], text: card.name);
      } catch (e) {
        debugPrint('Error sharing QR: $e');
      }
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _DarkSheet(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(card.name, style: AppTheme.headlineStyle.copyWith(fontSize: 22)),
            const SizedBox(height: 28),
            RepaintBoundary(
              key: qrKey,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: card.codeData != null
                    ? bw.BarcodeWidget(
                        barcode: bw.Barcode.qrCode(),
                        data: card.codeData!,
                        width: 200, height: 200,
                      )
                    : QrImageView(data: card.name, size: 200, backgroundColor: Colors.white),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text('Закрыть', style: AppTheme.captionStyle.copyWith(color: AppTheme.white54, fontSize: 14)),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: shareQr,
                  icon: const Icon(Icons.share_rounded, size: 16, color: AppTheme.primaryDark),
                  label: Text('Поделиться', style: AppTheme.titleStyle.copyWith(color: AppTheme.primaryDark, fontSize: 14)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accentGold,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FinanceProvider>(
      builder: (context, finance, _) {
        final totalIncome = finance.transactions
            .where((t) => !t.isExpense)
            .fold(0.0, (s, t) => s + t.amount);
        final totalExpense = finance.transactions
            .where((t) => t.isExpense)
            .fold(0.0, (s, t) => s + t.amount);
        final monthlySubscriptions = finance.subscriptions
            .fold(0.0, (s, sub) => s + sub.amount);

        return Scaffold(
          backgroundColor: AppTheme.primaryDark,
          body: Stack(
            fit: StackFit.expand,
            children: [
              // Wallpaper
              Positioned.fill(
                child: Consumer<UserProvider>(
                  builder: (_, user, __) =>
                      Image.asset(user.wallpaperPath, fit: BoxFit.cover),
                ),
              ),
              Positioned.fill(
                child: Container(color: Colors.black.withValues(alpha: 0.18)),
              ),

              SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: AppTheme.screenPadding),
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      Text('Финансы', style: AppTheme.headlineStyle),
                      const SizedBox(height: 28),

                      MinimalCard(
                        padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 24),
                        child: Column(
                          children: [
                            Text(
                              'БАЛАНС',
                              style: AppTheme.labelStyle,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _fmtMoney(finance.balance),
                              style: AppTheme.headlineStyle.copyWith(
                                fontSize: 42,
                                letterSpacing: -2,
                                color: finance.balance >= 0 ? AppTheme.white : AppTheme.errorRed,
                              ),
                            ),
                            const SizedBox(height: 28),
                            // Income / Expense row
                            Row(
                              children: [
                                Expanded(
                                  child: _FlowCell(
                                    label: 'Доход',
                                    value: _fmtMoney(totalIncome),
                                    icon: Icons.arrow_downward_rounded,
                                    color: AppTheme.accentGreen,
                                  ),
                                ),
                                Container(width: 1, height: 40, color: AppTheme.white12),
                                Expanded(
                                  child: _FlowCell(
                                    label: 'Расход',
                                    value: _fmtMoney(totalExpense),
                                    icon: Icons.arrow_upward_rounded,
                                    color: AppTheme.errorRed,
                                  ),
                                ),
                                Container(width: 1, height: 40, color: AppTheme.white12),
                                Expanded(
                                  child: _FlowCell(
                                    label: 'Подписки',
                                    value: _fmtMoney(monthlySubscriptions),
                                    icon: Icons.autorenew_rounded,
                                    color: AppTheme.accentIndigo,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ).animate().fadeIn(duration: 600.ms).scale(begin: const Offset(0.95, 0.95), curve: Curves.easeOutBack),

                      const SizedBox(height: 20),

                      // ── Card & Cash mini row ───────────────────────────────
                      Row(
                        children: [
                          Expanded(
                            child: _MiniStatCard(
                              title: 'Карта',
                              value: _fmtMoney(finance.balance),
                              icon: Icons.credit_card_rounded,
                              color: AppTheme.accentBlue,
                            ).animate().fadeIn(duration: 400.ms, delay: 200.ms).slideX(begin: -0.1),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: _MiniStatCard(
                              title: 'Наличные',
                              value: _fmtMoney(finance.cashBalance),
                              icon: Icons.payments_rounded,
                              color: AppTheme.accentGreen,
                            ).animate().fadeIn(duration: 400.ms, delay: 300.ms).slideX(begin: 0.1),
                          ),
                        ],
                      ),

                      const SizedBox(height: 32),

                      // ── Spending Analytics ────────────────────────────────
                      if (finance.monthlyExpensesByCategory.isNotEmpty) ...[
                        _SectionHeader(
                          title: 'Расходы за месяц',
                          onAdd: () => _showBudgetDialog(context),
                          addIcon: Icons.tune_rounded,
                        ),
                        const SizedBox(height: 12),
                        MinimalCard(
                          padding: const EdgeInsets.all(20),
                          child: _SpendingChart(
                            data: finance.monthlyExpensesByCategory,
                            totalExpenses: finance.monthlyExpenses,
                            monthlyBudget: finance.monthlyBudget,
                          ),
                        ).animate().fadeIn(duration: 400.ms, delay: 100.ms),
                        const SizedBox(height: 32),
                      ],

                      // ── Transactions ──────────────────────────────────────
                      _SectionHeader(
                        title: 'Транзакции',
                        onAdd: () => _showAddTransactionDialog(context),
                      ),
                      const SizedBox(height: 12),

                      if (finance.transactions.isEmpty)
                        _EmptyHint(label: 'Добавьте первую транзакцию')
                      else
                        MinimalCard(
                          padding: EdgeInsets.zero,
                          child: ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: finance.transactions.take(8).length,
                            separatorBuilder: (_, __) => const _CardDivider(),
                            itemBuilder: (_, i) {
                              final t = finance.transactions[i];
                              return Dismissible(
                                key: Key(t.id),
                                direction: DismissDirection.endToStart,
                                background: Container(
                                  alignment: Alignment.centerRight,
                                  padding: const EdgeInsets.only(right: 20),
                                  color: AppTheme.errorRed.withValues(alpha: 0.15),
                                  child: const Icon(Icons.delete_rounded, color: AppTheme.errorRed, size: 22),
                                ),
                                onDismissed: (_) {
                                  HapticFeedback.mediumImpact();
                                  context.read<FinanceProvider>().deleteTransaction(t.id);
                                },
                                child: _TransactionRow(transaction: t)
                                  .animate()
                                  .fadeIn(duration: 300.ms, delay: (i * 40).ms)
                                  .slideX(begin: 0.05),
                              );
                            },
                          ),
                        ),

                      const SizedBox(height: 32),

                      // ── Subscriptions ─────────────────────────────────────
                      _SectionHeader(
                        title: 'Подписки',
                        onAdd: () => _showAddSubscriptionDialog(context),
                      ),
                      const SizedBox(height: 12),

                      if (finance.subscriptions.isEmpty)
                        _EmptyHint(label: 'Нет активных подписок')
                      else
                        MinimalCard(
                          padding: EdgeInsets.zero,
                          child: ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: finance.subscriptions.length,
                            separatorBuilder: (_, __) => const _CardDivider(),
                            itemBuilder: (_, i) =>
                                _SubscriptionRow(subscription: finance.subscriptions[i])
                                .animate()
                                .fadeIn(duration: 300.ms, delay: (i * 50).ms)
                                .slideX(begin: 0.05),
                          ),
                        ),

                      const SizedBox(height: 32),

                      // ── Loyalty Cards ─────────────────────────────────────
                      _SectionHeader(
                        title: 'Карты лояльности',
                        onAdd: () => _showAddCardDialog(context),
                        addIcon: Icons.add_card_rounded,
                      ),
                      const SizedBox(height: 12),

                      if (finance.discountCards.isEmpty)
                        _EmptyHint(label: 'Добавьте карту магазина')
                      else
                        SizedBox(
                          height: 108,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            itemCount: finance.discountCards.length,
                            separatorBuilder: (_, __) => const SizedBox(width: 12),
                            itemBuilder: (_, i) {
                              final card = finance.discountCards[i];
                              return GestureDetector(
                                onTap: () => _showCardDetails(context, card),
                                child: Container(
                                  width: 150,
                                  decoration: BoxDecoration(
                                    color: AppTheme.white08,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: AppTheme.white12),
                                  ),
                                  alignment: Alignment.center,
                                  padding: const EdgeInsets.all(14),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.qr_code_rounded, color: AppTheme.white38, size: 28),
                                      const SizedBox(height: 8),
                                      Text(
                                        card.name,
                                        style: AppTheme.titleStyle.copyWith(fontSize: 14),
                                        textAlign: TextAlign.center,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

                      const SizedBox(height: 120),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── Local components ──────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback onAdd;
  final IconData addIcon;

  const _SectionHeader({
    required this.title,
    required this.onAdd,
    this.addIcon = Icons.add_circle_outline_rounded,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: AppTheme.titleStyle),
        GestureDetector(
          onTap: onAdd,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.white08,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(addIcon, color: AppTheme.white70, size: 18),
          ),
        ),
      ],
    );
  }
}

class _FlowCell extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _FlowCell({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 14),
        ),
        const SizedBox(height: 8),
        Text(value, style: AppTheme.titleStyle.copyWith(fontSize: 13), textAlign: TextAlign.center),
        const SizedBox(height: 2),
        Text(label, style: AppTheme.captionStyle.copyWith(fontSize: 10), textAlign: TextAlign.center),
      ],
    );
  }
}

class _MiniStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _MiniStatCard({required this.title, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return MinimalCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 14),
          Text(value, style: AppTheme.titleStyle.copyWith(fontSize: 16)),
          const SizedBox(height: 3),
          Text(title, style: AppTheme.captionStyle),
        ],
      ),
    );
  }
}

class _TransactionRow extends StatelessWidget {
  final Transaction transaction;
  const _TransactionRow({required this.transaction});

  @override
  Widget build(BuildContext context) {
    final color = transaction.isExpense ? AppTheme.errorRed : AppTheme.accentGreen;
    final sign = transaction.isExpense ? '−' : '+';
    final fmt = NumberFormat('#,###', 'ru_RU');
    final cat = transaction.category;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: cat.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(cat.icon, color: cat.color, size: 16),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(transaction.title, style: AppTheme.bodyStyle.copyWith(color: AppTheme.white, fontWeight: FontWeight.w500)),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      DateFormat('d MMM', 'ru').format(transaction.date),
                      style: AppTheme.captionStyle.copyWith(fontSize: 11),
                    ),
                    if (transaction.isExpense) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: cat.color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(cat.label, style: AppTheme.captionStyle.copyWith(fontSize: 10, color: cat.color)),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          Text(
            '$sign${fmt.format(transaction.amount)} ₽',
            style: AppTheme.titleStyle.copyWith(color: color, fontSize: 15),
          ),
        ],
      ),
    );
  }
}

class _SubscriptionRow extends StatelessWidget {
  final Subscription subscription;
  const _SubscriptionRow({required this.subscription});

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat('#,###', 'ru_RU');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: AppTheme.accentIndigo.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.autorenew_rounded, color: AppTheme.accentIndigo, size: 16),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(subscription.name, style: AppTheme.bodyStyle.copyWith(color: AppTheme.white, fontWeight: FontWeight.w500)),
                if (subscription.expiryDate != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    'Списание ${DateFormat('d MMM', 'ru').format(subscription.expiryDate!)}',
                    style: AppTheme.captionStyle.copyWith(fontSize: 11),
                  ),
                ],
              ],
            ),
          ),
          Text(
            '−${fmt.format(subscription.amount)} ₽',
            style: AppTheme.titleStyle.copyWith(color: AppTheme.white70, fontSize: 15),
          ),
        ],
      ),
    );
  }
}

class _EmptyHint extends StatelessWidget {
  final String label;
  const _EmptyHint({required this.label});

  @override
  Widget build(BuildContext context) {
    return MinimalCard(
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
      child: Center(
        child: Text(label, style: AppTheme.captionStyle.copyWith(fontSize: 13)),
      ),
    );
  }
}

class _CardDivider extends StatelessWidget {
  const _CardDivider();
  @override
  Widget build(BuildContext context) {
    return Divider(height: 1, thickness: 0.6, color: Colors.white.withValues(alpha: 0.07), indent: 18, endIndent: 18);
  }
}

class _TypeChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  const _TypeChip({required this.label, required this.icon, required this.selected, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.15) : AppTheme.white08,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: selected ? color.withValues(alpha: 0.4) : Colors.transparent),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: selected ? color : AppTheme.white38, size: 16),
            const SizedBox(width: 8),
            Text(label, style: AppTheme.bodyStyle.copyWith(color: selected ? color : AppTheme.white38, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

class _DarkSheet extends StatelessWidget {
  final Widget child;
  const _DarkSheet({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF13131F),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              width: 36, height: 4,
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(color: AppTheme.white12, borderRadius: BorderRadius.circular(2)),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

// ── Budget Dialog ─────────────────────────────────────────────────────────────

extension on _FinanceScreenState {
  void _showBudgetDialog(BuildContext context) {
    final ctrl = TextEditingController(
      text: context.read<FinanceProvider>().monthlyBudget > 0
          ? context.read<FinanceProvider>().monthlyBudget.toString()
          : '',
    );
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: _DarkSheet(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Бюджет на месяц', style: AppTheme.titleStyle),
              const SizedBox(height: 8),
              Text('Установите лимит расходов, чтобы не выходить за рамки', style: AppTheme.captionStyle),
              const SizedBox(height: 20),
              _SheetTextField(
                controller: ctrl,
                label: 'Лимит (₽)',
                hint: '50000',
                inputType: const TextInputType.numberWithOptions(decimal: false),
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              const SizedBox(height: 24),
              _PrimaryButton(
                label: 'Сохранить',
                onPressed: () {
                  final val = int.tryParse(ctrl.text) ?? 0;
                  context.read<FinanceProvider>().setMonthlyBudget(val);
                  Navigator.pop(ctx);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Spending Pie Chart ────────────────────────────────────────────────────────

class _SpendingChart extends StatelessWidget {
  final Map<TransactionCategory, int> data;
  final int totalExpenses;
  final int monthlyBudget;

  const _SpendingChart({
    required this.data,
    required this.totalExpenses,
    required this.monthlyBudget,
  });

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat('#,###', 'ru_RU');
    final total = data.values.fold<int>(0, (s, v) => s + v);
    if (total == 0) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SizedBox(
              width: 120,
              height: 120,
              child: CustomPaint(
                painter: _PieChartPainter(data: data, total: total),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('${fmt.format(totalExpenses)}₽',
                        style: AppTheme.titleStyle.copyWith(fontSize: 13)),
                      Text('расходы', style: AppTheme.captionStyle.copyWith(fontSize: 10)),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...data.entries.map((e) {
                    final pct = (e.value / total * 100).toInt();
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        children: [
                          Container(width: 8, height: 8, decoration: BoxDecoration(
                            color: e.key.color, shape: BoxShape.circle)),
                          const SizedBox(width: 6),
                          Expanded(child: Text(e.key.label,
                            style: AppTheme.captionStyle.copyWith(fontSize: 11),
                            overflow: TextOverflow.ellipsis)),
                          Text('$pct%', style: AppTheme.captionStyle.copyWith(
                            fontSize: 11, color: AppTheme.white70, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
        if (monthlyBudget > 0) ...[
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Бюджет', style: AppTheme.captionStyle),
              Text('${fmt.format(totalExpenses)} / ${fmt.format(monthlyBudget)} ₽',
                style: AppTheme.captionStyle.copyWith(
                  color: totalExpenses > monthlyBudget ? AppTheme.errorRed : AppTheme.white70,
                  fontWeight: FontWeight.w600,
                )),
            ],
          ),
          const SizedBox(height: 6),
          LayoutBuilder(
            builder: (_, c) => Stack(
              children: [
                Container(height: 6, width: c.maxWidth, decoration: BoxDecoration(
                  color: AppTheme.white08, borderRadius: BorderRadius.circular(3))),
                Container(
                  height: 6,
                  width: c.maxWidth * (totalExpenses / monthlyBudget).clamp(0.0, 1.0),
                  decoration: BoxDecoration(
                    color: totalExpenses > monthlyBudget ? AppTheme.errorRed : AppTheme.accentGreen,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _PieChartPainter extends CustomPainter {
  final Map<TransactionCategory, int> data;
  final int total;

  _PieChartPainter({required this.data, required this.total});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    double startAngle = -pi / 2;

    for (final entry in data.entries) {
      final sweepAngle = 2 * pi * entry.value / total;
      final paint = Paint()
        ..color = entry.key.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 14
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - 7),
        startAngle + 0.04,
        sweepAngle - 0.08,
        false,
        paint,
      );
      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(_PieChartPainter oldDelegate) => oldDelegate.data != data;
}

class _SheetTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final TextInputType inputType;
  final List<TextInputFormatter>? inputFormatters;

  const _SheetTextField({
    required this.controller,
    required this.label,
    required this.hint,
    this.inputType = TextInputType.text,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTheme.captionStyle.copyWith(fontSize: 12, color: AppTheme.white54)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: inputType,
          inputFormatters: inputFormatters,
          style: AppTheme.bodyStyle.copyWith(color: AppTheme.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTheme.captionStyle.copyWith(fontSize: 14),
            filled: true,
            fillColor: AppTheme.white08,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          ),
        ),
      ],
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _PrimaryButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.white,
          foregroundColor: Colors.black,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        ),
        child: Text(label, style: AppTheme.buttonTextStyle),
      ),
    );
  }
}
