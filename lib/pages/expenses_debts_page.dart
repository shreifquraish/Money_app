import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../constants/app_constants.dart';
import '../models/purchase_model.dart';
import '../models/debt_model.dart';
import '../utils/validators.dart';
import '../utils/formatters.dart';
import '../widgets/custom_widgets.dart';
import '../blocs/finance_cubit.dart';

class ExpensesDebtsPage extends StatefulWidget {
  const ExpensesDebtsPage({super.key});

  @override
  State<ExpensesDebtsPage> createState() => _ExpensesDebtsPageState();
}

class _ExpensesDebtsPageState extends State<ExpensesDebtsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final _purchaseFormKey = GlobalKey<FormState>();
  final _itemController = TextEditingController();
  final _priceController = TextEditingController();

  final _debtFormKey = GlobalKey<FormState>();
  final _personNameController = TextEditingController();
  final _debtAmountController = TextEditingController();

  String _selectedCategory = 'بدون قسم';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _itemController.dispose();
    _priceController.dispose();
    _personNameController.dispose();
    _debtAmountController.dispose();
    super.dispose();
  }

  void _addPurchase() {
    if (!_purchaseFormKey.currentState!.validate()) return;

    final purchase = PurchaseModel(
      itemName: _itemController.text.trim(),
      price: double.parse(_priceController.text.trim()),
      category: _selectedCategory == 'بدون قسم' ? null : _selectedCategory,
    );
    context.read<FinanceCubit>().addPurchase(purchase);

    _itemController.clear();
    _priceController.clear();
    setState(() => _selectedCategory = 'بدون قسم');

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم إضافة المشترى بنجاح'), backgroundColor: Colors.green));
  }

  void _showAddCategoryDialog() {
    final catController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إضافة قسم جديد', style: TextStyle(fontFamily: 'Cairo')),
        content: TextField(
          controller: catController,
          decoration: const InputDecoration(hintText: 'اسم القسم... (مثال: أكل، مواصلات)'),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () {
              if (catController.text.trim().isNotEmpty) {
                setState(() {
                  _selectedCategory = catController.text.trim();
                });
                Navigator.pop(context);
              }
            },
            child: const Text('إضافة'),
          ),
        ],
      ),
    );
  }

  void _addDebt() {
    if (!_debtFormKey.currentState!.validate()) return;

    final debt = DebtModel(
      personName: _personNameController.text.trim(),
      amount: double.parse(_debtAmountController.text.trim()),
    );
    context.read<FinanceCubit>().addDebt(debt);

    _personNameController.clear();
    _debtAmountController.clear();

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم إضافة الدين بنجاح'), backgroundColor: Colors.green));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FinanceCubit, FinanceState>(
      builder: (context, state) {
        return Column(
          children: [
            Container(
              color: AppColors.primaryColor,
              child: TabBar(
                controller: _tabController,
                indicatorColor: Colors.white,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                tabs: const [
                  Tab(text: 'المشتريات'),
                  Tab(text: 'الديون (عليا لمين)'),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // المشتريات
                  SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(AppPadding.lg),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('إضافة مشترى', style: Theme.of(context).textTheme.titleLarge),
                          const SizedBox(height: AppPadding.lg),
                          Form(
                            key: _purchaseFormKey,
                            child: Column(
                              children: [
                                CustomTextField(
                                  controller: _itemController,
                                  label: 'اسم المنتج',
                                  hintText: 'ماذا اشتريت؟',
                                  validator: Validators.validateItemName,
                                  prefixIcon: const Icon(Icons.shopping_bag_outlined),
                                ),
                                const SizedBox(height: AppPadding.lg),
                                CustomTextField(
                                  controller: _priceController,
                                  label: 'السعر',
                                  hintText: '0.00',
                                  validator: Validators.validateAmount,
                                  prefixIcon: const Icon(Icons.attach_money),
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                ),
                                const SizedBox(height: AppPadding.lg),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: Text('القسم (اختياري)', style: Theme.of(context).textTheme.titleMedium),
                                ),
                                const SizedBox(height: AppPadding.sm),
                                Builder(
                                  builder: (context) {
                                    final usedCategories = state.purchases
                                        .where((p) => p.category != null)
                                        .map((p) => p.category!)
                                        .toSet()
                                        .toList();
                                    
                                    final List<String> displayCategories = ['بدون قسم', ...usedCategories];
                                    if (_selectedCategory != 'بدون قسم' && !usedCategories.contains(_selectedCategory)) {
                                      displayCategories.add(_selectedCategory);
                                    }

                                    return Wrap(
                                      spacing: 8.0,
                                      runSpacing: 4.0,
                                      children: [
                                        ...displayCategories.map((cat) {
                                          return ChoiceChip(
                                            label: Text(cat),
                                            selected: _selectedCategory == cat,
                                            onSelected: (selected) {
                                              if (selected) setState(() => _selectedCategory = cat);
                                            },
                                            selectedColor: Colors.blue.withOpacity(0.3),
                                          );
                                        }),
                                        ActionChip(
                                          label: const Text('+ قسم جديد', style: TextStyle(color: Colors.white)),
                                          backgroundColor: Colors.blue.shade700,
                                          onPressed: _showAddCategoryDialog,
                                        ),
                                      ],
                                    );
                                  }
                                ),
                                const SizedBox(height: AppPadding.lg),
                                CustomButton(
                                  label: 'إضافة المشترى',
                                  onPressed: _addPurchase,
                                  backgroundColor: AppColors.expenseColor,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: AppPadding.xl),
                          Text('المشتريات السابقة', style: Theme.of(context).textTheme.titleLarge),
                          const SizedBox(height: AppPadding.md),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: state.purchases.length,
                            itemBuilder: (context, index) {
                              final p = state.purchases.reversed.toList()[index];
                              return Card(
                                child: ListTile(
                                  title: Text(p.itemName),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      if (p.category != null)
                                        Container(
                                          margin: const EdgeInsets.only(top: 4, bottom: 4),
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                                          child: Text(p.category!, style: const TextStyle(color: Colors.blue, fontSize: 12)),
                                        ),
                                      Text(Formatters.formatDateReadable(p.purchaseDate)),
                                    ],
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(Formatters.formatCurrencyWithSymbol(p.price), style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                                      IconButton(
                                        icon: const Icon(Icons.delete, color: Colors.grey),
                                        onPressed: () => context.read<FinanceCubit>().deletePurchase(p.id),
                                      )
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  // الديون
                  SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(AppPadding.lg),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('إضافة دين', style: Theme.of(context).textTheme.titleLarge),
                          const SizedBox(height: AppPadding.lg),
                          Form(
                            key: _debtFormKey,
                            child: Column(
                              children: [
                                CustomTextField(
                                  controller: _personNameController,
                                  label: 'اسم الشخص',
                                  hintText: 'لمن تدين بالمال؟',
                                  validator: Validators.validatePersonName,
                                  prefixIcon: const Icon(Icons.person_outline),
                                ),
                                const SizedBox(height: AppPadding.lg),
                                CustomTextField(
                                  controller: _debtAmountController,
                                  label: 'المبلغ',
                                  hintText: '0.00',
                                  validator: Validators.validateAmount,
                                  prefixIcon: const Icon(Icons.attach_money),
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                ),
                                const SizedBox(height: AppPadding.lg),
                                CustomButton(
                                  label: 'إضافة دين جديد',
                                  onPressed: _addDebt,
                                  backgroundColor: AppColors.debtColor,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: AppPadding.xl),
                          Text('الديون الحالية (عليا لمين)', style: Theme.of(context).textTheme.titleLarge),
                          const SizedBox(height: AppPadding.md),
                          Builder(
                            builder: (context) {
                              final activeDebts = state.debts.where((d) => !d.isPaid).toList().reversed.toList();
                              if (activeDebts.isEmpty) {
                                return const Center(child: Text('لا توجد ديون حالية'));
                              }
                              return ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: activeDebts.length,
                                itemBuilder: (context, index) {
                                  final d = activeDebts[index];
                                  return Card(
                                    color: Colors.white,
                                    child: ListTile(
                                  title: Text(d.personName),
                                  subtitle: const Text('غير مدفوع', style: TextStyle(color: Colors.red)),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(Formatters.formatCurrencyWithSymbol(d.amount), style: const TextStyle(fontWeight: FontWeight.bold)),
                                      const SizedBox(width: 8),
                                      ElevatedButton(
                                        onPressed: () => context.read<FinanceCubit>().payDebt(d.id),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.green,
                                          padding: const EdgeInsets.symmetric(horizontal: 12),
                                          minimumSize: const Size(0, 32),
                                        ),
                                        child: const Text('دفع', style: TextStyle(color: Colors.white, fontSize: 12)),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete, color: Colors.grey),
                                        onPressed: () => context.read<FinanceCubit>().deleteDebt(d.id),
                                      )
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                            }
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
