import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../models/money_model.dart';
import '../utils/validators.dart';
import '../utils/formatters.dart';
import '../utils/helpers.dart';
import '../widgets/custom_widgets.dart';

class MoneyManagementPage extends StatefulWidget {
  const MoneyManagementPage({super.key});

  @override
  State<MoneyManagementPage> createState() => _MoneyManagementPageState();
}

class _MoneyManagementPageState extends State<MoneyManagementPage> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  final _sourceController = TextEditingController();

  final List<MoneyModel> _moneyRecords = [];
  MoneyType _selectedType = MoneyType.income;
  bool _isLoading = false;

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    _sourceController.dispose();
    super.dispose();
  }

  Future<void> _addMoneyRecord() async {
    if (!_formKey.currentState!.validate()) {
      SnackBarService.showError(context, 'يرجى التحقق من البيانات');
      return;
    }

    try {
      setState(() => _isLoading = true);
      await Future.delayed(const Duration(milliseconds: 300));

      final moneyRecord = MoneyModel(
        description: _descriptionController.text.trim(),
        amount: double.parse(_amountController.text.trim()),
        type: _selectedType,
        source: _sourceController.text.isEmpty
            ? null
            : _sourceController.text.trim(),
      );

      if (!moneyRecord.isValid()) {
        if (mounted) {
          SnackBarService.showError(
              context, 'بيانات السجل المالي غير صحيحة');
        }
        return;
      }

      setState(() {
        _moneyRecords.add(moneyRecord);
        _descriptionController.clear();
        _amountController.clear();
        _sourceController.clear();
      });

      if (mounted) {
        SnackBarService.showSuccess(
            context, 'تم إضافة السجل المالي بنجاح');
      }
    } catch (e) {
      if (mounted) {
        SnackBarService.showError(context, 'حدث خطأ: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _deleteRecord(int index) {
    DialogService.showConfirmDialog(
      context,
      title: 'حذف السجل',
      message: 'هل أنت متأكد من حذف هذا السجل المالي؟',
      confirmText: 'حذف',
      cancelText: 'إلغاء',
    ).then((confirmed) {
      if (confirmed == true) {
        setState(() => _moneyRecords.removeAt(index));
        SnackBarService.showSuccess(context, 'تم حذف السجل');
      }
    });
  }

  double _getTotalByType(MoneyType type) {
    return _moneyRecords.fold(
      0,
      (sum, record) => record.type == type ? sum + record.amount : sum,
    );
  }

  List<MoneyModel> _getRecordsByType(MoneyType type) {
    return _moneyRecords
        .where((record) => record.type == type)
        .toList()
        .reversed
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final totalIncome = _getTotalByType(MoneyType.income);
    final totalExpense = _getTotalByType(MoneyType.expense);
    final totalSaving = _getTotalByType(MoneyType.saving);
    final balance = totalIncome - totalExpense;

    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة الأموال'),
        backgroundColor: AppColors.primaryColor,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // رأس القسم
            CustomGradientHeader(
              title: 'إدارة أموالك',
              subtitle: 'سجل كل العمليات المالية',
              gradientColors: AppColors.primaryGradient,
              child: Column(
                children: [
                  // الرصيد الحالي
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppPadding.lg),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      border: Border.all(color: Colors.white.withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'رصيدك الحالي:',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                                color: Colors.white70,
                              ),
                        ),
                        const SizedBox(height: AppPadding.sm),
                        Text(
                          Formatters.formatCurrencyWithSymbol(balance),
                          style: Theme.of(context)
                              .textTheme
                              .displaySmall
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppPadding.lg),

                  // إحصائيات سريعة
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'الدخل',
                          totalIncome,
                          AppColors.incomeColor,
                        ),
                      ),
                      const SizedBox(width: AppPadding.md),
                      Expanded(
                        child: _buildStatCard(
                          'المصروف',
                          totalExpense,
                          AppColors.expenseColor,
                        ),
                      ),
                      const SizedBox(width: AppPadding.md),
                      Expanded(
                        child: _buildStatCard(
                          'التوفير',
                          totalSaving,
                          AppColors.savingColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // نموذج إضافة سجل مالي
            Padding(
              padding: const EdgeInsets.all(AppPadding.lg),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // اختيار النوع
                    Text(
                      'نوع العملية',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppPadding.md),
                    Wrap(
                      spacing: AppPadding.md,
                      children: [
                        for (final type in MoneyType.values)
                          FilterChip(
                            label: Text(type.displayName),
                            selected: _selectedType == type,
                            onSelected: (selected) {
                              setState(() => _selectedType = type);
                            },
                            selectedColor: _getTypeColor(type)
                                .withOpacity(0.3),
                            side: BorderSide(
                              color: _getTypeColor(type),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: AppPadding.lg),

                    // الوصف
                    CustomTextField(
                      controller: _descriptionController,
                      label: 'الوصف',
                      hintText: 'ما طبيعة العملية؟',
                      validator: Validators.validateDescription,
                      prefixIcon: const Icon(Icons.description_outlined),
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: AppPadding.lg),

                    // المبلغ
                    CustomTextField(
                      controller: _amountController,
                      label: 'المبلغ',
                      hintText: '0.00',
                      validator: Validators.validateAmount,
                      prefixIcon: const Icon(Icons.attach_money),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: AppPadding.lg),

                    // المصدر/الوجهة (اختياري)
                    CustomTextField(
                      controller: _sourceController,
                      label: 'المصدر/الوجهة (اختياري)',
                      hintText: 'من أين أو إلى أين؟',
                      prefixIcon: const Icon(Icons.location_on_outlined),
                      textInputAction: TextInputAction.done,
                    ),
                    const SizedBox(height: AppPadding.xl),

                    // زر الإضافة
                    CustomButton(
                      label: 'إضافة سجل مالي',
                      onPressed: _addMoneyRecord,
                      isLoading: _isLoading,
                      backgroundColor: AppColors.primaryColor,
                    ),
                  ],
                ),
              ),
            ),

            // السجلات المالية حسب النوع
            Padding(
              padding: const EdgeInsets.all(AppPadding.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_moneyRecords.isEmpty)
                    const EmptyStateWidget(
                      icon: Icons.attach_money,
                      title: 'لا توجد سجلات مالية',
                      subtitle: 'ابدأ بإضافة عملياتك المالية الأولى',
                      iconColor: AppColors.primaryColor,
                    )
                  else ...[
                    for (final type in MoneyType.values)
                      if (_getRecordsByType(type).isNotEmpty) ...[
                        Text(
                          '${type.displayName} (${_getRecordsByType(type).length})',
                          style:
                              Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: AppPadding.md),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _getRecordsByType(type).length,
                          itemBuilder: (context, index) {
                            final record =
                                _getRecordsByType(type)[index];
                            final originalIndex =
                                _moneyRecords.indexOf(record);
                            return _buildMoneyCard(
                              record,
                              originalIndex,
                            );
                          },
                        ),
                        const SizedBox(height: AppPadding.lg),
                      ],
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getTypeColor(MoneyType type) {
    switch (type) {
      case MoneyType.income:
        return AppColors.incomeColor;
      case MoneyType.expense:
        return AppColors.expenseColor;
      case MoneyType.saving:
        return AppColors.savingColor;
    }
  }

  Widget _buildStatCard(String label, double amount, Color color) {
    return Container(
      padding: const EdgeInsets.all(AppPadding.md),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white70,
                ),
          ),
          const SizedBox(height: AppPadding.sm),
          Text(
            Formatters.formatCurrency(amount),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoneyCard(MoneyModel record, int index) {
    final color = _getTypeColor(record.type);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppPadding.md),
      child: CustomCard(
        backgroundColor: color.withOpacity(0.1),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        record.description,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: AppPadding.sm),
                      Text(
                        Formatters.formatDateReadable(record.date),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppPadding.md,
                    vertical: AppPadding.sm,
                  ),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Text(
                    Formatters.formatCurrencyWithSymbol(record.amount),
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: color,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ],
            ),
            if (record.source != null && record.source!.isNotEmpty) ...[
              const SizedBox(height: AppPadding.md),
              Row(
                children: [
                  const Icon(Icons.location_on_outlined, size: 16),
                  const SizedBox(width: AppPadding.sm),
                  Text(
                    record.source!,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ],
            const SizedBox(height: AppPadding.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () => _deleteRecord(index),
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('حذف'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.errorColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
