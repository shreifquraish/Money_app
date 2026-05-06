import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import '../constants/app_constants.dart';
import '../utils/formatters.dart';
import '../widgets/custom_widgets.dart';
import '../blocs/finance_cubit.dart';

class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key});

  Future<String> _getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userName') ?? 'المستخدم';
  }

  String _formatDateTime(DateTime date) {
    String hour = date.hour.toString().padLeft(2, '0');
    String minute = date.minute.toString().padLeft(2, '0');
    String period = int.parse(hour) >= 12 ? 'مساءً' : 'صباحاً';
    int hour12 = int.parse(hour) % 12;
    if (hour12 == 0) hour12 = 12;
    return '${date.day}/${date.month}/${date.year} - $hour12:$minute $period';
  }

  // ✅ تصحيح: إضافة context كبارامتر
  String _buildReportText(BuildContext context, FinanceState state, String userName) {
    final cubit = context.read<FinanceCubit>();
    final totalIncome = cubit.totalIncome;
    final totalPurchases = cubit.totalPurchases;
    final totalUnpaidDebts = cubit.totalUnpaidDebts;
    final totalPaidDebts = cubit.totalPaidDebts;
    final balance = cubit.balance;

    final buffer = StringBuffer();

    buffer.writeln('تقرير حسابي المالي');
    buffer.writeln('━━━━━━━━━━━━━━━━━━━━━━━━━━');
    buffer.writeln('المستخدم: $userName');
    buffer.writeln('التاريخ: ${_formatDateTime(DateTime.now())}');
    buffer.writeln('');

    buffer.writeln('الدخل:');
    if (state.incomes.isEmpty) {
      buffer.writeln('لا يوجد دخل مسجل');
    } else {
      for (var income in state.incomes.reversed) {
        buffer.writeln('• ${income.description}: ${income.amount.toStringAsFixed(0)} ج.م');
      }
    }
    buffer.writeln('');

    buffer.writeln('المشتريات:');
    Map<String, double> categoryTotals = {};
    double uncategorizedTotal = 0;
    
    for (var p in state.purchases) {
      if (p.category == null || p.category!.isEmpty) {
        uncategorizedTotal += p.price;
      } else {
        categoryTotals[p.category!] = (categoryTotals[p.category!] ?? 0) + p.price;
      }
    }
    
    if (categoryTotals.isEmpty && uncategorizedTotal == 0) {
      buffer.writeln('لا توجد مشتريات مسجلة');
    } else {
      for (var entry in categoryTotals.entries) {
        buffer.writeln('${entry.key}: ${entry.value.toStringAsFixed(0)} ج.م');
      }
      if (uncategorizedTotal > 0) {
        buffer.writeln('بدون قسم: ${uncategorizedTotal.toStringAsFixed(0)} ج.م');
      }
    }
    buffer.writeln('');

    buffer.writeln('الديون:');
    final unpaidDebts = state.debts.where((d) => !d.isPaid).toList();
    if (unpaidDebts.isEmpty) {
      buffer.writeln('لا توجد ديون حالية');
    } else {
      for (var d in unpaidDebts) {
        buffer.writeln('• ${d.personName}: ${d.amount.toStringAsFixed(0)} ج.م');
      }
    }
    buffer.writeln('');

    buffer.writeln('الديون المدفوعة:');
    final paidDebts = state.debts.where((d) => d.isPaid).toList();
    if (paidDebts.isEmpty) {
      buffer.writeln('لا توجد ديون مدفوعة');
    } else {
      for (var d in paidDebts) {
        buffer.writeln('• ${d.personName}: ${d.amount.toStringAsFixed(0)} ج.م');
        buffer.writeln('  تم الدفع: ${_formatDateTime(d.debtDate)}');
      }
    }
    buffer.writeln('');

    buffer.writeln('━━━━━━━━━━━━━━━━━━━━━━━━━━');
    buffer.writeln('الرصيد المتبقي: ${balance.toStringAsFixed(0)} ج.م');
    buffer.writeln('━━━━━━━━━━━━━━━━━━━━━━━━━━');
    buffer.writeln('');
    buffer.writeln('تطبيق "حسابي"');

    return buffer.toString();
  }

  Future<void> _sendReportToWhatsApp(BuildContext context, String message) async {
    final encodedMessage = Uri.encodeComponent(message);
    final phoneNumber = '201003041351';
    
    final whatsappUrl = 'https://wa.me/$phoneNumber?text=$encodedMessage';

    try {
      final uri = Uri.parse(whatsappUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        return;
      }
    } catch (e) {
      // لو فشلت
    }

    // لو فشل، نعرض خيار نسخ التقرير
    if (context.mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('❌ لم يتم العثور على واتساب', style: TextStyle(fontFamily: 'Cairo')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('لم يتم العثور على تطبيق واتساب على جهازك.', style: TextStyle(fontFamily: 'Cairo')),
              const SizedBox(height: 12),
              const Text('يمكنك:', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
              const Text('1. تثبيت واتساب من متجر التطبيقات', style: TextStyle(fontFamily: 'Cairo')),
              const Text('2. نسخ التقرير يدوياً وإرساله', style: TextStyle(fontFamily: 'Cairo')),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _copyToClipboard(context, message);
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                child: const Text('نسخ التقرير إلى الحافظة', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إغلاق', style: TextStyle(fontFamily: 'Cairo')),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _copyToClipboard(BuildContext context, String message) async {
    await Clipboard.setData(ClipboardData(text: message));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ تم نسخ التقرير إلى الحافظة، يمكنك لصقه في واتساب')),
      );
    }
  }

  void _showClearDataConfirmation(BuildContext context, FinanceCubit cubit) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد مسح البيانات', style: TextStyle(fontFamily: 'Cairo')),
        content: const Text(
          'هل أنت متأكد من رغبتك في مسح كافة بيانات (الدخل، المشتريات، الديون) لبدء فترة جديدة؟\n\nملاحظة: هذا الإجراء لن يحذف حسابك.',
          style: TextStyle(fontFamily: 'Cairo'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء', style: TextStyle(fontFamily: 'Cairo')),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              cubit.clearAllData();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('✅ تم مسح البيانات وبدء فترة جديدة بنجاح')),
              );
            },
            child: const Text('نعم، مسح البيانات', style: TextStyle(color: Colors.white, fontFamily: 'Cairo')),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FinanceCubit, FinanceState>(
      builder: (context, state) {
        final cubit = context.read<FinanceCubit>();
        final totalIncome = cubit.totalIncome;
        final totalPurchases = cubit.totalPurchases;
        final totalUnpaidDebts = cubit.totalUnpaidDebts;
        final totalPaidDebts = cubit.totalPaidDebts;
        final balance = cubit.balance;

        return SingleChildScrollView(
          child: Column(
            children: [
              CustomGradientHeader(
                title: 'تقرير مالي شامل',
                subtitle: 'كل تحركاتك المالية في مكان واحد',
                gradientColors: [Colors.blue.shade900, Colors.blue.shade700],
                child: Column(
                  children: [
                    Text(
                      'المتبقي الفعلي معك',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: Colors.white70),
                    ),
                    const SizedBox(height: AppPadding.sm),
                    Text(
                      Formatters.formatCurrencyWithSymbol(balance),
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: AppPadding.lg),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _showClearDataConfirmation(context, cubit),
                            icon: const Icon(Icons.delete_sweep, color: Colors.blue),
                            label: const Text('بدء فترة جديدة', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              final userName = await _getUserName();
                              // ✅ تصحيح: تمرير context
                              final reportText = _buildReportText(context, state, userName);
                              _sendReportToWhatsApp(context, reportText);
                            },
                            icon: const Icon(Icons.send, color: Colors.green),
                            label: const Text('إرسال التقرير واتساب', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppPadding.lg),
                child: Column(
                  children: [
                    _buildReportCard(context, 'إجمالي الدخل', totalIncome,
                        Colors.green, Icons.arrow_downward),
                    const SizedBox(height: AppPadding.md),

                    Container(
                      padding: const EdgeInsets.all(AppPadding.md),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 5))
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                    color: Colors.redAccent.withOpacity(0.1),
                                    shape: BoxShape.circle),
                                child: const Icon(Icons.shopping_cart,
                                    color: Colors.redAccent),
                              ),
                              const SizedBox(width: AppPadding.lg),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('إجمالي المشتريات',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium
                                            ?.copyWith(
                                                color: Colors.grey.shade700)),
                                    Text(
                                        Formatters.formatCurrencyWithSymbol(
                                            totalPurchases),
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge
                                            ?.copyWith(
                                                color: Colors.redAccent,
                                                fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          if (state.purchases.isNotEmpty) ...[
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 8.0),
                              child: Divider(),
                            ),
                            Text('تفاصيل الصرف حسب الأقسام:',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall
                                    ?.copyWith(color: Colors.grey.shade600)),
                            const SizedBox(height: 8),
                            Builder(builder: (context) {
                              Map<String, double> categoryTotals = {};
                              double uncategorizedTotal = 0;

                              for (var p in state.purchases) {
                                if (p.category == null || p.category!.isEmpty) {
                                  uncategorizedTotal += p.price;
                                } else {
                                  categoryTotals[p.category!] =
                                      (categoryTotals[p.category!] ?? 0) +
                                          p.price;
                                }
                              }

                              return Column(
                                children: [
                                  ...categoryTotals.entries.map(
                                      (e) => _buildCategoryRow(e.key, e.value)),
                                  if (uncategorizedTotal > 0)
                                    _buildCategoryRow(
                                        'بدون قسم', uncategorizedTotal),
                                ],
                              );
                            }),
                          ]
                        ],
                      ),
                    ),
                    const SizedBox(height: AppPadding.md),

                    _buildReportCard(context, 'الديون الحالية',
                        totalUnpaidDebts, Colors.red, Icons.money_off),
                    const SizedBox(height: AppPadding.md),
                    _buildReportCard(
                        context,
                        'الديون المدفوعة',
                        totalPaidDebts,
                        Colors.blue,
                        Icons.check_circle_outline),
                    const SizedBox(height: AppPadding.lg),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildReportCard(BuildContext context, String title, double amount,
      Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(AppPadding.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5))
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: color.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: AppPadding.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(color: Colors.grey.shade700)),
                Text(Formatters.formatCurrencyWithSymbol(amount),
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(color: color, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryRow(String title, double amount) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.circle, size: 8, color: Colors.grey),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontSize: 14)),
            ],
          ),
          Text(Formatters.formatCurrencyWithSymbol(amount),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        ],
      ),
    );
  }
}