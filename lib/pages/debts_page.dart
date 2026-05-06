import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../models/debt_model.dart';
import '../utils/validators.dart';
import '../utils/formatters.dart';
import '../utils/helpers.dart';
import '../widgets/custom_widgets.dart';

class DebtsPage extends StatefulWidget {
  const DebtsPage({super.key});

  @override
  State<DebtsPage> createState() => _DebtsPageState();
}

class _DebtsPageState extends State<DebtsPage> {
  final _formKey = GlobalKey<FormState>();
  final _personNameController = TextEditingController();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();

  final List<DebtModel> _debts = [];
  bool _isLoading = false;

  @override
  void dispose() {
    _personNameController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _addDebt() async {
    if (!_formKey.currentState!.validate()) {
      SnackBarService.showError(context, 'يرجى التحقق من البيانات');
      return;
    }

    try {
      setState(() => _isLoading = true);
      await Future.delayed(const Duration(milliseconds: 300));

      final debt = DebtModel(
        personName: _personNameController.text.trim(),
        amount: double.parse(_amountController.text.trim()),
        notes:
            _notesController.text.isEmpty ? null : _notesController.text.trim(),
      );

      if (!debt.isValid()) {
        if (mounted) {
          SnackBarService.showError(context, 'بيانات الدين غير صحيحة');
        }
        return;
      }

      setState(() {
        _debts.add(debt);
        _personNameController.clear();
        _amountController.clear();
        _notesController.clear();
      });

      if (mounted) {
        SnackBarService.showSuccess(context, 'تم إضافة الدين بنجاح');
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

  void _toggleDebtPayment(int index) {
    setState(() {
      final debt = _debts[index];
      _debts[index] = debt.copyWith(isPaid: !debt.isPaid);
    });
    SnackBarService.showSuccess(
      context,
      _debts[index].isPaid
          ? 'تم تحديد الدين كمدفوع'
          : 'تم تحديد الدين كغير مدفوع',
    );
  }

  void _deleteDebt(int index) {
    final debt = _debts[index];
    DialogService.showConfirmDialog(
      context,
      title: 'حذف الدين',
      message: 'هل أنت متأكد من حذف الدين على "${debt.personName}"؟',
      confirmText: 'حذف',
      cancelText: 'إلغاء',
    ).then((confirmed) {
      if (confirmed == true) {
        setState(() => _debts.removeAt(index));
        SnackBarService.showSuccess(context, 'تم حذف الدين');
      }
    });
  }

  double _getTotalDebts({bool paidOnly = false}) {
    return _debts.fold(
      0,
      (sum, debt) {
        if (paidOnly && !debt.isPaid) return sum;
        if (!paidOnly && debt.isPaid) return sum;
        return sum + debt.amount;
      },
    );
  }

  List<DebtModel> _getUnpaidDebts() {
    return _debts.where((debt) => !debt.isPaid).toList();
  }

  @override
  Widget build(BuildContext context) {
    final unpaidDebts = _getUnpaidDebts();
    final totalUnpaid = _getTotalDebts(paidOnly: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('الديون'),
        backgroundColor: AppColors.debtColor,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // رأس القسم
            CustomGradientHeader(
              title: 'سجل الديون',
              subtitle: 'تابع جميع الفلوس التي عليك',
              gradientColors: [
                AppColors.debtColor,
                AppColors.debtColor.withOpacity(0.7),
              ],
              child: Column(
                children: [
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
                          'إجمالي الديون:',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.white70,
                                  ),
                        ),
                        const SizedBox(height: AppPadding.sm),
                        Text(
                          Formatters.formatCurrencyWithSymbol(totalUnpaid),
                          style: Theme.of(context)
                              .textTheme
                              .displaySmall
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: AppPadding.md),
                        Row(
                          children: [
                            Expanded(
                              child: _buildDebtStat(
                                'غير مدفوع',
                                unpaidDebts.length.toString(),
                              ),
                            ),
                            const SizedBox(width: AppPadding.md),
                            Expanded(
                              child: _buildDebtStat(
                                'مدفوع',
                                (_debts.length - unpaidDebts.length).toString(),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // نموذج إضافة دين
            Padding(
              padding: const EdgeInsets.all(AppPadding.lg),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    CustomTextField(
                      controller: _personNameController,
                      label: 'اسم الشخص',
                      hintText: 'من يجب عليك المال؟',
                      validator: Validators.validatePersonName,
                      prefixIcon: const Icon(Icons.person_outline),
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: AppPadding.lg),
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
                    CustomTextField(
                      controller: _notesController,
                      label: 'ملاحظات (اختياري)',
                      hintText: 'أضف ملاحظة عن الدين',
                      maxLines: 3,
                      prefixIcon: const Icon(Icons.note_outlined),
                      textInputAction: TextInputAction.newline,
                    ),
                    const SizedBox(height: AppPadding.xl),
                    CustomButton(
                      label: 'إضافة دين جديد',
                      onPressed: _addDebt,
                      isLoading: _isLoading,
                      backgroundColor: AppColors.debtColor,
                    ),
                  ],
                ),
              ),
            ),

            // قائمة الديون
            Padding(
              padding: const EdgeInsets.all(AppPadding.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_debts.isNotEmpty)
                    Text(
                      'الديون (${_debts.length})',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  const SizedBox(height: AppPadding.lg),
                  if (_debts.isEmpty)
                    const EmptyStateWidget(
                      icon: Icons.check_circle_outline,
                      title: 'لا توجد ديون',
                      subtitle: 'مبروك! أنت خالي من الديون',
                      iconColor: AppColors.successColor,
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _debts.length,
                      itemBuilder: (context, index) {
                        final debt = _debts[index];
                        return _buildDebtCard(debt, index);
                      },
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDebtStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white70,
              ),
        ),
        const SizedBox(height: AppPadding.sm),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }

  Widget _buildDebtCard(DebtModel debt, int index) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppPadding.md),
      child: CustomCard(
        backgroundColor: debt.isPaid
            ? AppColors.successColor.withOpacity(0.1)
            : AppColors.debtColor.withOpacity(0.1),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              debt.personName,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    decoration: debt.isPaid
                                        ? TextDecoration.lineThrough
                                        : TextDecoration.none,
                                  ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppPadding.md,
                              vertical: AppPadding.sm,
                            ),
                            decoration: BoxDecoration(
                              color: debt.isPaid
                                  ? AppColors.successColor.withOpacity(0.2)
                                  : AppColors.warningColor.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(AppRadius.md),
                            ),
                            child: Text(
                              debt.isPaid ? 'مدفوع' : 'غير مدفوع',
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall
                                  ?.copyWith(
                                    color: debt.isPaid
                                        ? AppColors.successColor
                                        : AppColors.warningColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppPadding.sm),
                      Text(
                        Formatters.formatDateReadable(debt.debtDate),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppPadding.md),
                Text(
                  Formatters.formatCurrencyWithSymbol(debt.amount),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: debt.isPaid
                            ? AppColors.successColor
                            : AppColors.debtColor,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            if (debt.notes != null && debt.notes!.isNotEmpty) ...[
              const SizedBox(height: AppPadding.md),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppPadding.md),
                decoration: BoxDecoration(
                  color: AppColors.bgGray,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Text(
                  debt.notes!,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
            const SizedBox(height: AppPadding.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () => _toggleDebtPayment(index),
                  icon: Icon(
                    debt.isPaid
                        ? Icons.radio_button_checked
                        : Icons.radio_button_unchecked,
                  ),
                  label: Text(
                    debt.isPaid ? 'إلغاء الدفع' : 'تحديد مدفوع',
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: debt.isPaid
                        ? AppColors.successColor
                        : AppColors.primaryColor,
                  ),
                ),
                const SizedBox(width: AppPadding.sm),
                TextButton.icon(
                  onPressed: () => _deleteDebt(index),
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
