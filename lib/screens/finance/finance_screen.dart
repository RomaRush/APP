import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:barcode_widget/barcode_widget.dart' as bw;
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../core/providers/finance_provider.dart';
import 'package:fl_chart/fl_chart.dart';

const Color kFinanceTeal = Color(0xFF03332D); 
const Color kFinanceCardBorder = Color(0xFF8BACA8);

class FinanceScreen extends StatefulWidget {
  const FinanceScreen({super.key});

  @override
  State<FinanceScreen> createState() => _FinanceScreenState();
}

class _FinanceScreenState extends State<FinanceScreen> {
  final ImagePicker _picker = ImagePicker();
  final MobileScannerController _scannerController = MobileScannerController();

  void _showIncomeStatsModal(BuildContext context, FinanceProvider finance) {
    final incomeTransactions = finance.transactions.where((t) => !t.isExpense).toList();
    _showTransactionsModal(context, 'Доходы 💰', incomeTransactions, Colors.greenAccent);
  }

  void _showExpenseStatsModal(BuildContext context, FinanceProvider finance) {
    final expenseTransactions = finance.transactions.where((t) => t.isExpense).toList();
    _showTransactionsModal(context, 'Расходы 💸', expenseTransactions, Colors.redAccent);
  }

  void _showTransactionsModal(BuildContext context, String title, List<Transaction> transactions, Color color) {
    // Group transactions by title for pie chart
    final Map<String, int> groupedData = {};
    for (var t in transactions) {
      groupedData[t.title] = (groupedData[t.title] ?? 0) + t.amount;
    }
    final total = transactions.fold(0, (sum, t) => sum + t.amount);
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: const BoxDecoration(
          color: Color(0xFF1E1E1E),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[700],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Всего: $total₽',
              style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            // Pie Chart
            if (groupedData.isNotEmpty)
              SizedBox(
                height: 180,
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 2,
                    centerSpaceRadius: 40,
                    sections: () {
                      final colors = [
                        Colors.blueAccent, Colors.greenAccent, Colors.orangeAccent,
                        Colors.purpleAccent, Colors.tealAccent, Colors.pinkAccent,
                        Colors.amberAccent, Colors.cyanAccent, Colors.indigoAccent,
                      ];
                      int colorIndex = 0;
                      return groupedData.entries.map((entry) {
                        final percent = total > 0 ? (entry.value / total * 100) : 0;
                        final sectionColor = colors[colorIndex % colors.length];
                        colorIndex++;
                        return PieChartSectionData(
                          value: entry.value.toDouble(),
                          title: percent > 8 ? '${percent.toStringAsFixed(0)}%' : '',
                          color: sectionColor,
                          radius: 50,
                          titleStyle: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                        );
                      }).toList();
                    }(),
                  ),
                ),
              ),
            const SizedBox(height: 8),
            // Legend
            if (groupedData.isNotEmpty)
              SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: () {
                    final colors = [
                      Colors.blueAccent, Colors.greenAccent, Colors.orangeAccent,
                      Colors.purpleAccent, Colors.tealAccent, Colors.pinkAccent,
                      Colors.amberAccent, Colors.cyanAccent, Colors.indigoAccent,
                    ];
                    int colorIndex = 0;
                    return groupedData.entries.map((entry) {
                      final legendColor = colors[colorIndex % colors.length];
                      colorIndex++;
                      return Container(
                        margin: const EdgeInsets.only(right: 12),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(width: 12, height: 12, decoration: BoxDecoration(color: legendColor, borderRadius: BorderRadius.circular(3))),
                            const SizedBox(width: 4),
                            Text(entry.key.length > 10 ? '${entry.key.substring(0, 10)}...' : entry.key, 
                              style: const TextStyle(color: Colors.white70, fontSize: 11)),
                          ],
                        ),
                      );
                    }).toList();
                  }(),
                ),
              ),
            const Divider(color: Colors.white12),
            Expanded(
              child: transactions.isEmpty
                  ? const Center(
                      child: Text('Нет транзакций', style: TextStyle(color: Colors.white54)),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: transactions.length,
                      itemBuilder: (context, index) {
                        final t = transactions[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      t.title,
                                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                                    ),
                                    Text(
                                      DateFormat('dd.MM.yyyy HH:mm').format(t.date),
                                      style: const TextStyle(color: Colors.white54, fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                '${t.amount}₽',
                                style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ],
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

  void _showAddTransactionDialog(BuildContext context) {
    bool isExpense = true;
    bool isCash = false;
    final titleController = TextEditingController();
    final amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            backgroundColor: kFinanceTeal,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: const BorderSide(color: Colors.white, width: 1),
            ),
            title: const Text('Добавить', style: TextStyle(color: Colors.white)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ChoiceChip(
                        label: const Text('Расход'),
                        selected: isExpense,
                        onSelected: (val) => setState(() => isExpense = true),
                        selectedColor: Colors.redAccent.withValues(alpha: 0.5),
                        labelStyle: TextStyle(color: isExpense ? Colors.white : Colors.black),
                      ),
                      const SizedBox(width: 10),
                      ChoiceChip(
                        label: const Text('Доход'),
                        selected: !isExpense,
                        onSelected: (val) => setState(() => isExpense = false),
                        selectedColor: Colors.greenAccent.withValues(alpha: 0.5),
                        labelStyle: TextStyle(color: !isExpense ? Colors.white : Colors.black),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: titleController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Название',
                      labelStyle: TextStyle(color: Colors.white70),
                      enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
                    ),
                  ),
                  TextField(
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Сумма',
                      labelStyle: TextStyle(color: Colors.white70),
                      enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Отмена', style: TextStyle(color: Colors.white54)),
              ),
              TextButton(
                onPressed: () {
                  final amount = int.tryParse(amountController.text);
                  if (titleController.text.isNotEmpty && amount != null) {
                    Provider.of<FinanceProvider>(context, listen: false)
                        .addTransaction(titleController.text, amount, isExpense, isCash: isCash);
                    Navigator.pop(context);
                  }
                },
                child: const Text('Добавить', style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        }
      ),
    );
  }

  void _showAddSubscriptionDialog(BuildContext context) {
    final titleController = TextEditingController();
    final amountController = TextEditingController();
    DateTime? selectedDate;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            backgroundColor: kFinanceTeal,
            shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: const BorderSide(color: Colors.white, width: 1)),
            title: const Text('Подписка', style: TextStyle(color: Colors.white)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Сервис',
                    labelStyle: TextStyle(color: Colors.white70),
                    enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
                  ),
                ),
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Стоимость (мес)',
                    labelStyle: TextStyle(color: Colors.white70),
                    enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
                  ),
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now().add(const Duration(days: 30)),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) {
                      setState(() => selectedDate = date);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
                    decoration: const BoxDecoration(
                      border: Border(bottom: BorderSide(color: Colors.white)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          selectedDate == null 
                            ? 'Дата списания (опционально)' 
                            : 'Спишется: ${DateFormat('dd.MM.yyyy').format(selectedDate!)}',
                          style: const TextStyle(color: Colors.white70),
                        ),
                        const Icon(Icons.calendar_today, color: Colors.white70, size: 20),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Отмена', style: TextStyle(color: Colors.white54)),
              ),
              TextButton(
                onPressed: () {
                  final amount = int.tryParse(amountController.text);
                  if (titleController.text.isNotEmpty && amount != null) {
                    Provider.of<FinanceProvider>(context, listen: false)
                        .addSubscription(titleController.text, amount, expiryDate: selectedDate);
                    Navigator.pop(context);
                  }
                },
                child: const Text('Добавить', style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        }
      ),
    );
  }

  void _showDeleteSubscriptionDialog(BuildContext context, Subscription sub) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: kFinanceTeal,
        title: Text('Удалить ${sub.name}?', style: const TextStyle(color: Colors.white)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Нет', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () {
              Provider.of<FinanceProvider>(context, listen: false)
                  .removeSubscription(sub.id);
              Navigator.pop(context);
            },
            child: const Text('Да', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }
  
  void _showAddCardDialog() {
    final TextEditingController nameController = TextEditingController();
    File? selectedImage;
    String? detectedCode;
    String? detectedFormat;
    bool isScanning = false;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            backgroundColor: kFinanceTeal,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: const BorderSide(color: Colors.white, width: 1)),
            title: const Text('Добавить карту', style: TextStyle(color: Colors.white)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: 'Название магазина',
                      hintStyle: TextStyle(color: Colors.white54),
                      enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: () async {
                      try {
                        final XFile? photo = await _picker.pickImage(source: ImageSource.gallery);
                        if (photo != null) {
                          setState(() {
                            selectedImage = File(photo.path);
                            isScanning = true;
                            detectedCode = null;
                            detectedFormat = null;
                          });
                          
                          // Convert XFile to path and analyze
                          final capture = await _scannerController.analyzeImage(photo.path);
                          
                          if (capture != null && capture.barcodes.isNotEmpty) {
                             final code = capture.barcodes.first;
                             if (code.rawValue != null) {
                               setState(() {
                                 detectedCode = code.rawValue;
                                 detectedFormat = code.format.name;
                                 isScanning = false;
                               });
                             } else {
                               setState(() => isScanning = false);
                             }
                          } else {
                             setState(() => isScanning = false);
                          }
                        }
                      } catch (e) {
                        debugPrint('Error picking image: $e');
                        setState(() => isScanning = false);
                      }
                    },
                    child: Container(
                      height: 140,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                        borderRadius: BorderRadius.circular(12),
                        image: selectedImage != null 
                          ? DecorationImage(image: FileImage(selectedImage!), fit: BoxFit.cover, opacity: 0.5)
                          : null,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (isScanning)
                            const CircularProgressIndicator(color: Colors.white)
                          else if (detectedCode != null)
                             Column(
                               children: [
                                 const Icon(Icons.check_circle, color: Colors.greenAccent, size: 40),
                                 const SizedBox(height: 8),
                                 Text('Найден код!', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                 Text(detectedFormat ?? 'QR', style: const TextStyle(color: Colors.white70, fontSize: 10)),
                               ],
                             )
                          else if (selectedImage != null)
                            const Column(
                               children: [
                                 Icon(Icons.warning_amber_rounded, color: Colors.orangeAccent, size: 40),
                                 SizedBox(height: 8),
                                 Text('Штрих-код не найден', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                               ],
                             )
                          else
                            const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_a_photo, color: Colors.white, size: 40),
                                SizedBox(height: 8),
                                Text('Загрузить фото / QR', style: TextStyle(color: Colors.white70, fontSize: 12)),
                              ],
                            ),
                          ],
                        ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Отмена', style: TextStyle(color: Colors.white54)),
              ),
              TextButton(
                onPressed: () {
                  if (nameController.text.isNotEmpty) {
                    Provider.of<FinanceProvider>(context, listen: false).addDiscountCard(
                      nameController.text,
                      imagePath: selectedImage?.path,
                      codeData: detectedCode,
                      codeFormat: detectedFormat,
                    );
                    Navigator.pop(context);
                  }
                },
                child: const Text('Добавить', style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        }
      ),
    );
  }

  void _showEditCashDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: kFinanceTeal,
        title: const Text('Баланс наличных', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            labelText: 'Текущая сумма',
            labelStyle: TextStyle(color: Colors.white70),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
          ),
        ),
        actions: [
           TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () {
              final val = int.tryParse(controller.text);
              if (val != null) {
                Provider.of<FinanceProvider>(context, listen: false).setCashBalance(val);
                Navigator.pop(context);
              }
            },
            child: const Text('Сохранить', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  bw.Barcode _getBarcodeType(String? format) {
    if (format == null) return bw.Barcode.qrCode();
    switch (format.toLowerCase()) {
      case 'ean13': return bw.Barcode.ean13();
      case 'ean8': return bw.Barcode.ean8();
      case 'upca': return bw.Barcode.upcA();
      case 'upce': return bw.Barcode.upcE();
      case 'code128': return bw.Barcode.code128();
      case 'code39': return bw.Barcode.code39();
      case 'code93': return bw.Barcode.code93();
      case 'codabar': return bw.Barcode.codabar();
      case 'itf': return bw.Barcode.itf();
      case 'pdf417': return bw.Barcode.pdf417();
      case 'aztec': return bw.Barcode.aztec();
      case 'datamatrix': return bw.Barcode.dataMatrix();
      default: return bw.Barcode.qrCode();
    }
  }

  void _showCardDetails(DiscountCard card) {
    // Determine view mode: Photo or Generated Code
    bool showPhoto = card.imagePath != null && card.codeData == null; 
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                       Expanded(
                         child: Text(
                          card.name,
                          style: AppTheme.headlineStyle.copyWith(color: Colors.black, fontSize: 22),
                          overflow: TextOverflow.ellipsis,
                                                 ),
                       ),
                      Row(
                        children: [
                           if (card.imagePath != null && card.codeData != null)
                            IconButton(
                              icon: Icon(showPhoto ? Icons.qr_code : Icons.image, color: Colors.blueGrey),
                              onPressed: () {
                                setState(() {
                                  showPhoto = !showPhoto;
                                });
                              },
                            ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.redAccent),
                            onPressed: () {
                              Provider.of<FinanceProvider>(context, listen: false).removeDiscountCard(card.id);
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      )
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  if (showPhoto && card.imagePath != null)
                    Container(
                      constraints: const BoxConstraints(maxHeight: 300),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          File(card.imagePath!),
                          fit: BoxFit.contain,
                        ),
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.all(10),
                      color: Colors.white,
                      height: 200,
                      width: double.infinity,
                      child: card.codeData != null
                        ? bw.BarcodeWidget(
                            barcode: _getBarcodeType(card.codeFormat),
                            data: card.codeData!,
                            color: Colors.black,
                            drawText: true,
                          )
                        : QrImageView(
                            data: card.name,
                            version: QrVersions.auto,
                            size: 200.0,
                          ),
                    ),
                    
                  const SizedBox(height: 20),
                  Text(
                    showPhoto ? 'Фото карты' : (card.codeData != null ? 'Скан: ${card.codeData}' : 'QR имя'),
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),
          );
        }
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FinanceProvider>(
      builder: (context, finance, _) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF004D40), // Deep Emerald/Teal
                  Color(0xFF000000), // Black
                ],
              ),
            ),
            child: SingleChildScrollView(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 10,
              left: 20,
              right: 20,
              bottom: 120, // Space for floating nav
            ),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Финансы',
                        style: AppTheme.headlineStyle.copyWith(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Total Balance
                  _GlassCard(
                    height: 140,
                    child: SizedBox(
                      width: double.infinity,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            '${finance.balance}р',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'ваш баланс',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.7),
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Cards Split
                  Row(
                    children: [
                      Expanded(
                        child: _GlassCard(
                          height: 120,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Align(
                                alignment: Alignment.topRight,
                                child: Padding(
                                  padding: EdgeInsets.only(right: 12, top: 4),
                                  child: Icon(Icons.credit_card, color: Colors.white, size: 20),
                                ),
                              ),
                              Text(
                                '${finance.balance}р',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'карта',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.7),
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 12),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _showEditCashDialog(context),
                          child: _GlassCard(
                            height: 120,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Align(
                                  alignment: Alignment.topRight,
                                  child: Padding(
                                    padding: EdgeInsets.only(right: 12, top: 4),
                                    child: Icon(Icons.money, color: Colors.white, size: 20),
                                  ),
                                ),
                                Text(
                                  '${finance.cashBalance}р',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'наличные',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.7),
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 12),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  const Text(
                    'Анализ финансов за месяц',
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _showIncomeStatsModal(context, finance),
                          child: _GlassCard(
                          height: 70,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '${finance.monthlyIncome}р',
                                style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                'доходы',
                                style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 10),
                              ),
                            ],
                          ),
                        ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _showExpenseStatsModal(context, finance),
                          child: _GlassCard(
                          height: 70,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '${finance.monthlyExpenses}р',
                                style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                'расходы',
                                style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 10),
                              ),
                            ],
                          ),
                        ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Подписки',
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      GestureDetector(
                        onTap: () => _showAddSubscriptionDialog(context),
                        child: const Icon(Icons.add, color: Colors.white, size: 24),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 12),

                  GridView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 2.2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: finance.subscriptions.length,
                    itemBuilder: (context, index) {
                      final sub = finance.subscriptions[index];
                      return GestureDetector(
                        onLongPress: () => _showDeleteSubscriptionDialog(context, sub),
                        child: _GlassCard(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                sub.name,
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                '${sub.amount}р/мес',
                                style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 12),
                              ),
                              if (sub.expiryDate != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    'Спишется ${DateFormat('dd.MM').format(sub.expiryDate!)}',
                                    style: const TextStyle(color: Colors.orangeAccent, fontSize: 10),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 24),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'История',
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      GestureDetector(
                        onTap: () => _showAddTransactionDialog(context),
                        child: Text(
                          'добавить',
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                  
                  if (finance.transactions.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(20),
                      alignment: Alignment.center,
                      child: Text(
                        'История пуста',
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
                      ),
                    )
                  else
                    ...finance.transactions.map((item) => Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              item.title,
                              style: const TextStyle(color: Colors.white, fontSize: 13),
                            ),
                          ),
                          Text(
                            '${item.isExpense ? "-" : "+"}${item.amount}р',
                            style: TextStyle(
                              color: item.isExpense ? Colors.redAccent : Colors.greenAccent,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    )),
                  
                  const SizedBox(height: 24),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Дисконт карты',
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      GestureDetector(
                        onTap: _showAddCardDialog,
                        child: const Icon(Icons.add, color: Colors.white, size: 24),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 4),
                  
                  GridView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 2.0,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: finance.discountCards.length + 1,
                    itemBuilder: (context, index) {
                      if (index < finance.discountCards.length) {
                        final card = finance.discountCards[index];
                        return GestureDetector(
                          onTap: () => _showCardDetails(card),
                          child: _GlassCard(
                            padding: const EdgeInsets.all(0),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                if (card.imagePath != null)
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(24),
                                    child: Image.file(
                                      File(card.imagePath!),
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return const Center(child: Icon(Icons.broken_image, color: Colors.white));
                                      },
                                    ),
                                  ),
                                if (card.imagePath != null)
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(24),
                                      color: Colors.black.withValues(alpha: 0.3),
                                    ),
                                  ),
                                Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        card.name,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          shadows: [Shadow(color: Colors.black, blurRadius: 4)],
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      if (card.codeData != null)
                                        const Padding(
                                          padding: EdgeInsets.only(top: 4),
                                          child: Icon(Icons.qr_code_scanner, color: Colors.white, size: 14),
                                        )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      } else {
                        return GestureDetector(
                          onTap: _showAddCardDialog,
                          child: _GlassCard(
                            padding: const EdgeInsets.all(0),
                            child: const Center(
                              child: Icon(Icons.add, color: Colors.white, size: 24),
                            ),
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
              ),
          ),
        );
    },
  );
}
}

class _GlassCard extends StatelessWidget {
  final Widget child;
  final double? height;
  final EdgeInsetsGeometry? padding;

  const _GlassCard({
    required this.child,
    this.height,
    this.padding,
  });

  @override
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25), // Strong blur for matte effect
        child: Container(
          height: height,
          padding: padding,
          decoration: BoxDecoration(
            color: const Color(0xFF000000).withValues(alpha: 0.15), // Very light matte black
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.12), // Subtle bright border
              width: 1,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
