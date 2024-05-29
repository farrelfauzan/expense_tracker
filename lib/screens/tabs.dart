import 'dart:convert';

import 'package:expense_tracker/models/expense.dart';
import 'package:expense_tracker/providers/expenses_provider.dart';
import 'package:expense_tracker/screens/expenses.dart';
import 'package:expense_tracker/screens/filters.dart';
import 'package:expense_tracker/widgets/new_expense.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

class TabScreen extends ConsumerStatefulWidget {
  const TabScreen({super.key});

  @override
  ConsumerState<TabScreen> createState() {
    return _TabScreenState();
  }
}

class _TabScreenState extends ConsumerState<TabScreen> {
  int _selectedPageIndex = 0;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadExpenses();
  }

  Future<void> _loadExpenses() async {
    final url = Uri.https(
      'shopping-list-a5c2e-default-rtdb.asia-southeast1.firebasedatabase.app',
      'shopping-list.json',
    );

    try {
      final expenses = ref.read(expensesProvider.notifier);
      final response = await http.get(url);

      if (response.statusCode >= 400) {
        throw Exception('Failed to load items.');
      }

      if (response.body == 'null') {
        setState(() {
          _isLoading = false;
        });
        return; // Add return statement to prevent further processing
      }

      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      final List<Expense> loadedExpenses = [];

      for (final item in extractedData.entries) {
        loadedExpenses.add(
          Expense(
            id: item.key,
            title: item.value['title'],
            amount: item.value['amount'],
            date: DateTime.parse(item.value['date']),
            category: Category.values[item.value['category']],
          ),
        );
      }

      expenses.addExpenses(loadedExpenses);

      setState(() {
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _error = error.toString();
        _isLoading = false;
      });
    }
  }

  void _selectPage(int index) {
    setState(() {
      _selectedPageIndex = index;
    });
  }

  void _openAddExpenseOverlay() {
    showModalBottomSheet(
      useSafeArea: true,
      isScrollControlled: true,
      context: context,
      showDragHandle: true,
      builder: (ctx) => const NewExpense(),
    );
  }

  void _removeExpense(int index, Expense item, BuildContext context) async {
    final expense = ref.watch(filteredExpensesProvider);
    final removedItem = expense[index];

    final url = Uri.https(
      'shopping-list-a5c2e-default-rtdb.asia-southeast1.firebasedatabase.app',
      'shopping-list/${removedItem.id}.json',
    );

    final response = await http.delete(url);

    if (!mounted) {
      return;
    }

    if (response.statusCode >= 400) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.red,
          content: Text('Failed to delete item.'),
        ),
      );
      return;
    }

    ref.read(expensesProvider.notifier).removeExpense(removedItem);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: Colors.red,
        content: Text('Item deleted.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final availableExpenses = ref.watch(filteredExpensesProvider);
    Widget activePage = _isLoading
        ? const Center(child: CircularProgressIndicator())
        : _error != null
            ? Center(child: Text('Error: $_error'))
            : Expenses(
                expenses: availableExpenses,
                onRemoveExpense: _removeExpense,
              );

    var activePageTitle = 'Expenses';

    if (_selectedPageIndex == 1) {
      activePage = const FiltersScreen();
      activePageTitle = 'Filters';
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(activePageTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              _openAddExpenseOverlay();
            },
          ),
        ],
      ),
      body: activePage,
      bottomNavigationBar: BottomNavigationBar(
        onTap: _selectPage,
        currentIndex: _selectedPageIndex,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Filter',
          ),
        ],
      ),
    );
  }
}
