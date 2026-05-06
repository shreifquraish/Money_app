import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../models/purchase_model.dart';
import '../utils/validators.dart';
import '../utils/formatters.dart';
import '../utils/helpers.dart';
import '../widgets/custom_widgets.dart';

class PurchasesPage extends StatefulWidget {
  const PurchasesPage({super.key});

  @override
  State<PurchasesPage> createState() => _PurchasesPageState();
}

class _PurchasesPageState extends State<PurchasesPage> {
  final _formKey = GlobalKey<FormState>();
  final _itemController = TextEditingController();
  final _priceController = TextEditingController();
  final _notesController = TextEditingController();

  final List<PurchaseModel> _purchases = [];
  bool _isLoading = false;

  @override
  void dispose() {
    _itemController.dispose();
    _priceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _addPurchase() async {
    if (!_formKey.currentState!.validate()) {
      SnackBarService.showError(context, 'يرجى التحقق من البيانات');
      return;
    }

    try {
      setState(() => _isLoading = true);
      await Future.delayed(const Duration(milliseconds: 300));

      final purchase = PurchaseModel(
        itemName: _itemController.text.trim(),
        price: double.parse(_priceController.text.trim()),
        notes:
            _notesController.text.isEmpty ? null : _notesController.text.trim(),
      );

      if (!purchase.isValid()) {
        if (mounted) {
          SnackBarService.showError(context, 'بيانات المشترى غير صحيحة');
        }
        return;
      }

      setState(() {
        _purchases.add(purchase);
        _itemController.clear();
        _priceController.clear();
        _notesController.clear();
      });

      if (mounted) {
        SnackBarService.showSuccess(context, 'تم إضافة المشترى بنجاح');
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

  void _deletePurchase(int index) {
    final purchase = _purchases[index];
    DialogService.showConfirmDialog(
      context,
      title: 'حذف المشترى',
      message: 'هل أنت متأكد من حذف "${purchase.itemName}"؟',
      confirmText: 'حذف',
      cancelText: 'إلغاء',
    ).then((confirmed) {
      if (confirmed == true) {
        setState(() => _purchases.removeAt(index));
        SnackBarService.showSuccess(context, 'تم حذف المشترى');
      }
    });
  }

  double _getTotalPrice() {
    return _purchases.fold(0, (sum, purchase) => sum + purchase.price);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('المشتريات'),
        backgroundColor: AppColors.expenseColor,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // رأس القسم
            CustomGradientHeader(
              title: 'سجل مشترياتك',
              subtitle: 'تابع كل مشترياتك يومياً',
              gradientColors: [
                AppColors.expenseColor,
                AppColors.expenseColor.withOpacity(0.7),
              ],
              child: Container(
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
                      'الإجمالي:',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white70,
                          ),
                    ),
                    const SizedBox(height: AppPadding.sm),
                    Text(
                      Formatters.formatCurrencyWithSymbol(_getTotalPrice()),
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
              ),
            ),

            // نموذج إضافة مشترى
            Padding(
              padding: const EdgeInsets.all(AppPadding.lg),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    CustomTextField(
                      controller: _itemController,
                      label: 'اسم المنتج',
                      hintText: 'ماذا اشتريت؟',
                      validator: Validators.validateItemName,
                      prefixIcon: const Icon(Icons.shopping_bag_outlined),
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: AppPadding.lg),
                    CustomTextField(
                      controller: _priceController,
                      label: 'السعر',
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
                      hintText: 'أضف ملاحظة عن المشترى',
                      maxLines: 3,
                      prefixIcon: const Icon(Icons.note_outlined),
                      textInputAction: TextInputAction.newline,
                    ),
                    const SizedBox(height: AppPadding.xl),
                    CustomButton(
                      label: 'إضافة المشترى',
                      onPressed: _addPurchase,
                      isLoading: _isLoading,
                      backgroundColor: AppColors.expenseColor,
                    ),
                  ],
                ),
              ),
            ),

            // قائمة المشتريات
            Padding(
              padding: const EdgeInsets.all(AppPadding.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_purchases.isNotEmpty)
                    Text(
                      'المشتريات (${_purchases.length})',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  const SizedBox(height: AppPadding.lg),
                  if (_purchases.isEmpty)
                    const EmptyStateWidget(
                      icon: Icons.shopping_cart_outlined,
                      title: 'لا توجد مشتريات',
                      subtitle: 'ابدأ بإضافة مشترياتك الأولى',
                      iconColor: AppColors.expenseColor,
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _purchases.length,
                      itemBuilder: (context, index) {
                        final purchase = _purchases[index];
                        return _buildPurchaseCard(purchase, index);
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

  Widget _buildPurchaseCard(PurchaseModel purchase, int index) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppPadding.md),
      child: CustomCard(
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
                        purchase.itemName,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: AppPadding.sm),
                      Text(
                        Formatters.formatDateReadable(purchase.purchaseDate),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                Text(
                  Formatters.formatCurrencyWithSymbol(purchase.price),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.expenseColor,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            if (purchase.notes != null && purchase.notes!.isNotEmpty) ...[
              const SizedBox(height: AppPadding.md),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppPadding.md),
                decoration: BoxDecoration(
                  color: AppColors.bgGray,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Text(
                  purchase.notes!,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
            const SizedBox(height: AppPadding.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () => _deletePurchase(index),
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
