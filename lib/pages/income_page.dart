import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../constants/app_constants.dart';
import '../models/money_model.dart';
import '../utils/validators.dart';
import '../utils/formatters.dart';
import '../widgets/custom_widgets.dart';
import '../blocs/finance_cubit.dart';

class IncomePage extends StatefulWidget {
  const IncomePage({super.key});

  @override
  State<IncomePage> createState() => _IncomePageState();
}

class _IncomePageState extends State<IncomePage> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  final _sourceController = TextEditingController();

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    _sourceController.dispose();
    super.dispose();
  }

  void _addIncome() {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى التحقق من البيانات'), backgroundColor: Colors.red),
      );
      return;
    }

    final moneyRecord = MoneyModel(
      description: _descriptionController.text.trim(),
      amount: double.parse(_amountController.text.trim()),
      type: MoneyType.income,
      source: _sourceController.text.isEmpty ? null : _sourceController.text.trim(),
    );

    context.read<FinanceCubit>().addIncome(moneyRecord);

    _descriptionController.clear();
    _amountController.clear();
    _sourceController.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم إضافة الدخل بنجاح'), backgroundColor: Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FinanceCubit, FinanceState>(
      builder: (context, state) {
        final incomes = state.incomes.reversed.toList();
        final totalIncome = context.read<FinanceCubit>().totalIncome;

        return SingleChildScrollView(
          child: Column(
            children: [
              CustomGradientHeader(
                title: 'سجل الدخل',
                subtitle: 'الفلوس اللي دخلت ليك',
                gradientColors: [Colors.teal, Colors.tealAccent.shade700],
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
                          Text('إجمالي الدخل:', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70)),
                          const SizedBox(height: AppPadding.sm),
                          Text(
                            Formatters.formatCurrencyWithSymbol(totalIncome),
                            style: Theme.of(context).textTheme.displaySmall?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppPadding.lg),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('إضافة دخل جديد', style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: AppPadding.lg),
                      CustomTextField(
                        controller: _descriptionController,
                        label: 'الوصف',
                        hintText: 'من أين جاء هذا الدخل؟',
                        validator: Validators.validateDescription,
                        prefixIcon: const Icon(Icons.description_outlined),
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: AppPadding.lg),
                      CustomTextField(
                        controller: _amountController,
                        label: 'المبلغ',
                        hintText: '0.00',
                        validator: Validators.validateAmount,
                        prefixIcon: const Icon(Icons.attach_money),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: AppPadding.lg),
                      CustomButton(
                        label: 'إضافة الدخل',
                        onPressed: _addIncome,
                        backgroundColor: Colors.teal,
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppPadding.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (incomes.isEmpty)
                      const EmptyStateWidget(
                        icon: Icons.account_balance_wallet_outlined,
                        title: 'لا يوجد دخل مسجل',
                        subtitle: 'ابدأ بتسجيل أول مبلغ دخل لك',
                        iconColor: Colors.teal,
                      )
                    else ...[
                      Text('سجل الدخل (${incomes.length})', style: Theme.of(context).textTheme.headlineSmall),
                      const SizedBox(height: AppPadding.md),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: incomes.length,
                        itemBuilder: (context, index) {
                          final record = incomes[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: AppPadding.md),
                            child: CustomCard(
                              backgroundColor: Colors.teal.withOpacity(0.1),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(record.description, style: Theme.of(context).textTheme.titleMedium),
                                        Text(Formatters.formatDateReadable(record.date), style: Theme.of(context).textTheme.bodySmall),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    Formatters.formatCurrencyWithSymbol(record.amount),
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.teal, fontWeight: FontWeight.bold),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => context.read<FinanceCubit>().deleteIncome(record.id),
                                  )
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
