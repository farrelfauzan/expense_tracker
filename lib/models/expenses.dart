import 'package:expense_tracker/models/expense.dart';

class ExpenseItem {
  const ExpenseItem({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
  });

  final String id;
  final String title;
  final double amount;
  final Category category;
  final DateTime date;
}
