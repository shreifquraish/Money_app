import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/money_model.dart';
import '../models/purchase_model.dart';
import '../models/debt_model.dart';

// --- State ---
class FinanceState {
  final List<MoneyModel> incomes;
  final List<PurchaseModel> purchases;
  final List<DebtModel> debts;
  final bool isLoading;

  FinanceState({
    this.incomes = const [],
    this.purchases = const [],
    this.debts = const [],
    this.isLoading = true,
  });

  FinanceState copyWith({
    List<MoneyModel>? incomes,
    List<PurchaseModel>? purchases,
    List<DebtModel>? debts,
    bool? isLoading,
  }) {
    return FinanceState(
      incomes: incomes ?? this.incomes,
      purchases: purchases ?? this.purchases,
      debts: debts ?? this.debts,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

// --- Cubit ---
class FinanceCubit extends Cubit<FinanceState> {
  FinanceCubit() : super(FinanceState()) {
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    
    final incomesStr = prefs.getStringList('incomes') ?? [];
    final purchasesStr = prefs.getStringList('purchases') ?? [];
    final debtsStr = prefs.getStringList('debts') ?? [];

    final incomes = incomesStr.map((e) => MoneyModel.fromJson(jsonDecode(e))).toList();
    final purchases = purchasesStr.map((e) => PurchaseModel.fromJson(jsonDecode(e))).toList();
    final debts = debtsStr.map((e) => DebtModel.fromJson(jsonDecode(e))).toList();

    emit(state.copyWith(
      incomes: incomes,
      purchases: purchases,
      debts: debts,
      isLoading: false,
    ));
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    
    final incomesStr = state.incomes.map((e) => jsonEncode(e.toJson())).toList();
    final purchasesStr = state.purchases.map((e) => jsonEncode(e.toJson())).toList();
    final debtsStr = state.debts.map((e) => jsonEncode(e.toJson())).toList();

    await prefs.setStringList('incomes', incomesStr);
    await prefs.setStringList('purchases', purchasesStr);
    await prefs.setStringList('debts', debtsStr);
  }

  void addIncome(MoneyModel income) {
    final updatedList = List<MoneyModel>.from(state.incomes)..add(income);
    emit(state.copyWith(incomes: updatedList));
    _saveData();
  }

  void deleteIncome(String id) {
    final updatedList = state.incomes.where((e) => e.id != id).toList();
    emit(state.copyWith(incomes: updatedList));
    _saveData();
  }

  void addPurchase(PurchaseModel purchase) {
    final updatedList = List<PurchaseModel>.from(state.purchases)..add(purchase);
    emit(state.copyWith(purchases: updatedList));
    _saveData();
  }

  void deletePurchase(String id) {
    final updatedList = state.purchases.where((e) => e.id != id).toList();
    emit(state.copyWith(purchases: updatedList));
    _saveData();
  }

  void addDebt(DebtModel debt) {
    final updatedList = List<DebtModel>.from(state.debts)..add(debt);
    emit(state.copyWith(debts: updatedList));
    _saveData();
  }

  void payDebt(String id) {
    final updatedDebts = state.debts.map((e) {
      if (e.id == id) {
        return e.copyWith(isPaid: true);
      }
      return e;
    }).toList();
    
    emit(state.copyWith(debts: updatedDebts));
    _saveData();
  }

  void deleteDebt(String id) {
    final updatedList = state.debts.where((e) => e.id != id).toList();
    emit(state.copyWith(debts: updatedList));
    _saveData();
  }

  void clearAllData() {
    emit(state.copyWith(incomes: [], purchases: [], debts: []));
    _saveData();
  }

  double get totalIncome => state.incomes.fold(0, (sum, item) => sum + item.amount);
  double get totalPurchases => state.purchases.fold(0, (sum, item) => sum + item.price);
  double get totalUnpaidDebts => state.debts.where((e) => !e.isPaid).fold(0, (sum, item) => sum + item.amount);
  double get totalPaidDebts => state.debts.where((e) => e.isPaid).fold(0, (sum, item) => sum + item.amount);
  
  // الرصيد = الدخل - المشتريات - الديون المدفوعة (لأن المدفوعة استنفذت من الرصيد)
  double get balance => totalIncome - totalPurchases - totalPaidDebts;
}