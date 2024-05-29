import 'package:expense_tracker/models/expense.dart';
import 'package:expense_tracker/providers/filters_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ExpenseNotifier extends StateNotifier<List<Expense>> {
  ExpenseNotifier() : super([]);

  void addExpense(Expense expense) {
    state = [...state, expense];
  }

  void addExpenses(List<Expense> expenses) {
    state = expenses;
  }

  void removeExpense(Expense expense) {
    state = state.where((e) => e != expense).toList();
  }
}

final expensesProvider = StateNotifierProvider<ExpenseNotifier, List<Expense>>(
  (ref) => ExpenseNotifier(),
);

final filteredExpensesProvider = Provider((ref) {
  final expenses = ref.watch(expensesProvider);
  final activeFilters = ref.watch(filtersProvider);

  return expenses.where(
    (expense) {
      if (activeFilters[Filter.food]! && expense.category == Category.food) {
        return true;
      }
      if (activeFilters[Filter.travel]! &&
          expense.category == Category.travel) {
        return true;
      }
      if (activeFilters[Filter.leisure]! &&
          expense.category == Category.leisure) {
        return true;
      }
      if (activeFilters[Filter.work]! && expense.category == Category.work) {
        return true;
      }
      return false;
    },
  ).toList();
});
