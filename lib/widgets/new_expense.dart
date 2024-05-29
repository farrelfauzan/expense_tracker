import 'dart:convert';
import 'dart:io';
import 'package:expense_tracker/providers/expenses_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:flutter/cupertino.dart';
import 'package:expense_tracker/models/expense.dart';
import 'package:http/http.dart' as http;

class NewExpense extends ConsumerStatefulWidget {
  const NewExpense({super.key, this.onAddExpense});

  final void Function(Expense expense)? onAddExpense;

  @override
  ConsumerState<NewExpense> createState() => _NewExpenseState();
}

class _NewExpenseState extends ConsumerState<NewExpense> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  DateTime? _selectedDate;
  Category _selectedCategory = Category.food;

  void _presentDatePicker() async {
    final now = DateTime.now();
    final firstDate = DateTime(now.year - 1, now.month, now.day);
    final lastDate = DateTime(now.year + 1);
    final pickedDate = await showDatePicker(
      context: context,
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color.fromARGB(255, 240, 124, 136),
            ),
          ),
          child: child!,
        );
      },
      initialDate: now,
      firstDate: firstDate,
      lastDate: lastDate,
    );

    setState(() {
      _selectedDate = pickedDate;
    });
  }

  void _showDialog() {
    if (Platform.isIOS) {
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text(
            'Invalid Input',
            style: TextStyle(color: Colors.red),
          ),
          content: const Text('Please enter valid title, amount and date'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Okay'),
            )
          ],
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text(
              'Invalid Input',
              style: TextStyle(color: Colors.red),
            ),
            content: const Text('Please enter valid title, amount and date'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Okay'),
              )
            ],
          );
        },
      );
    }
  }

  void _submitExpenseData() async {
    if (!_formKey.currentState!.validate() || _selectedDate == null) {
      _showDialog();
      return;
    }

    final url = Uri.https(
      'shopping-list-a5c2e-default-rtdb.asia-southeast1.firebasedatabase.app',
      'shopping-list.json',
    );

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode(
        {
          'title': _titleController.text,
          'amount': double.parse(_amountController.text),
          'date': _selectedDate!.toIso8601String(),
          'category': _selectedCategory.index,
        },
      ),
    );

    final Map<String, dynamic> responseData = json.decode(response.body);

    if (!context.mounted) {
      return;
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final expenses = ref.read(expensesProvider.notifier);
      FocusScope.of(context).unfocus();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Expense added successfully'),
        ),
      );
      _formKey.currentState!.reset();
      expenses.addExpense(
        Expense(
          id: responseData['name'],
          title: _titleController.text,
          amount: double.parse(_amountController.text),
          date: _selectedDate!,
          category: _selectedCategory,
        ),
      );
      Navigator.pop(context);
    }

    if (response.statusCode >= 400) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(responseData['error']),
        ),
      );
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final keyboardSpace = MediaQuery.of(context).viewInsets.bottom;

    return LayoutBuilder(builder: (ctx, constraints) {
      final width = constraints.maxWidth;

      return SizedBox(
        height: double.infinity,
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, keyboardSpace + 16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  if (width >= 600)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _titleController,
                            maxLength: 50,
                            decoration: const InputDecoration(
                              label: Text("Title"),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter a title';
                              }
                              return null;
                            },
                          ),
                        ),
                        const Gap(6),
                        Expanded(
                          child: TextFormField(
                            controller: _amountController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              prefixText: '\$ ',
                              label: Text("Amount"),
                            ),
                            validator: (value) {
                              final amount = double.tryParse(value!);
                              if (amount == null || amount <= 0) {
                                return 'Please enter a valid amount';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    )
                  else
                    TextFormField(
                      controller: _titleController,
                      maxLength: 50,
                      decoration: const InputDecoration(
                        label: Text("Title"),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a title';
                        }
                        return null;
                      },
                    ),
                  const Gap(6),
                  if (width >= 600)
                    Row(
                      children: [
                        DropdownButton<Category>(
                          value: _selectedCategory,
                          hint: const Expanded(
                            child: Text('Select Category'),
                          ),
                          items: Category.values.map((Category category) {
                            return DropdownMenuItem<Category>(
                              value: category,
                              child: Text(
                                category.name.toUpperCase(),
                              ),
                            );
                          }).toList(),
                          onChanged: (Category? value) {
                            if (value == null) {
                              return;
                            }
                            setState(() {
                              _selectedCategory = value;
                            });
                          },
                        ),
                        const Gap(6),
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                _selectedDate == null
                                    ? 'No Date Selected'
                                    : DateFormat.yMd()
                                        .format(_selectedDate!)
                                        .toString(),
                              ),
                              IconButton(
                                onPressed: _presentDatePicker,
                                icon: const Icon(Icons.calendar_month),
                              )
                            ],
                          ),
                        )
                      ],
                    )
                  else
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _amountController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              prefixText: '\$ ',
                              label: Text("Amount"),
                            ),
                            validator: (value) {
                              final amount = double.tryParse(value!);
                              if (amount == null || amount <= 0) {
                                return 'Please enter a valid amount';
                              }
                              return null;
                            },
                          ),
                        ),
                        const Gap(6),
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                _selectedDate == null
                                    ? 'No Date Selected'
                                    : DateFormat.yMd()
                                        .format(_selectedDate!)
                                        .toString(),
                              ),
                              IconButton(
                                onPressed: _presentDatePicker,
                                icon: const Icon(Icons.calendar_month),
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  const Gap(6),
                  if (width >= 600)
                    Row(
                      children: [
                        const Gap(9),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                style: ButtonStyle(
                                  shape: MaterialStateProperty.all(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                                child: const Text('Cancel'),
                              ),
                            ),
                            const Gap(8),
                            Expanded(
                              child: ElevatedButton(
                                style: ButtonStyle(
                                  shape: MaterialStateProperty.all(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                                onPressed: _submitExpenseData,
                                child: const Text('Add Expense'),
                              ),
                            ),
                          ],
                        )
                      ],
                    )
                  else
                    Row(
                      children: [
                        DropdownButton<Category>(
                          value: _selectedCategory,
                          hint: const Expanded(
                            child: Text('Select Category'),
                          ),
                          items: Category.values.map((Category category) {
                            return DropdownMenuItem<Category>(
                              value: category,
                              child: Text(
                                category.name.toUpperCase(),
                              ),
                            );
                          }).toList(),
                          onChanged: (Category? value) {
                            if (value == null) {
                              return;
                            }
                            setState(() {
                              _selectedCategory = value;
                            });
                          },
                        ),
                      ],
                    ),
                  const Gap(9),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          style: ButtonStyle(
                            shape: MaterialStateProperty.all(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const Gap(8),
                      Expanded(
                        child: ElevatedButton(
                          style: ButtonStyle(
                            shape: MaterialStateProperty.all(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                          onPressed: _submitExpenseData,
                          child: const Text('Add Expense'),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}
