# Expense Tracker

![Flutter](https://img.shields.io/badge/Flutter-v1.0-blue) ![License](https://img.shields.io/badge/license-MIT-green)

## Table of Contents
- [Introduction](#introduction)
- [Features](#features)
- [Getting Started](#getting-started)
  - [Prerequisites](#prerequisites)
  - [Installation](#installation)
- [Screenshoot](#screenshoot)
- [App Structure](#app-structure)
- [State Management with Riverpod](#state-management-with-riverpod)
- [Usage](#usage)
- [Contact](#contact)

## Introduction
A brief description of what your project is about. Explain the purpose and motivation behind the project.

## Features
- Adding Expense to the dashboard
- Viewing Dashboard with chart
- Filters the expenses

## Getting Started

### Prerequisites
Make sure you have the following installed:
- Flutter SDK: [Installation Guide](https://flutter.dev/docs/get-started/install)
- Dart SDK
- IDE (VS Code, Android Studio, etc.)

### Installation
1. Clone the repository:
    ```bash
    git clone https://github.com/farrelfauzan/expense_tracker.git
    ```
2. Navigate to the project directory:
    ```bash
    cd expense_tracker
    ```
3. Install dependencies:
    ```bash
    flutter pub get
    ```

## Usage
1. Run the app on your device/emulator:
    ```bash
    flutter run
    ```
## Screenshoot
![Screenshot 2024-05-30 052825](https://github.com/farrelfauzan/expense_tracker/assets/97167243/9626314c-9849-4fe5-9eb0-b3a28e06b764)

* Click Add Button to add your expense

![Screenshot 2024-05-30 053154](https://github.com/farrelfauzan/expense_tracker/assets/97167243/07724254-f638-4f30-a961-c9ce719cf2b9)

* Add Expenses Page

![image](https://github.com/farrelfauzan/expense_tracker/assets/97167243/450f5ff3-0c10-4882-94b4-647c213a06cd)

* Filter Page, you can filter by expenses category

## App Structure

The code all beginning in `main.dart`, where all the setup like theme and provider are there

```dart
import 'package:expense_tracker/screens/tabs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

var kColorScheme = ColorScheme.fromSeed(
  seedColor: const Color.fromARGB(255, 96, 59, 181),
);

var kDarkColorScheme = ColorScheme.fromSeed(
  brightness: Brightness.dark,
  seedColor: const Color.fromARGB(255, 5, 99, 125),
);

void main() {
  runApp(
    const ProviderScope(
      child: App(),
    ),
  );
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      darkTheme: ThemeData.dark().copyWith(
        useMaterial3: true,
        colorScheme: kDarkColorScheme,
        cardTheme: const CardTheme().copyWith(
          color: kDarkColorScheme.secondaryContainer,
          margin: const EdgeInsets.symmetric(
            vertical: 8,
            horizontal: 16,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: kDarkColorScheme.primaryContainer,
            foregroundColor: kDarkColorScheme.onPrimaryContainer,
          ),
        ),
      ),
      theme: ThemeData().copyWith(
        useMaterial3: true,
        colorScheme: kColorScheme,
        appBarTheme: const AppBarTheme().copyWith(
          backgroundColor: kColorScheme.onPrimaryContainer,
          foregroundColor: kColorScheme.primaryContainer,
        ),
        cardTheme: const CardTheme().copyWith(
          color: kColorScheme.secondaryContainer,
          margin: const EdgeInsets.symmetric(
            vertical: 8,
            horizontal: 16,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: kColorScheme.primaryContainer,
          ),
        ),
        textTheme: ThemeData().textTheme.copyWith(
              titleLarge: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.normal,
                color: kColorScheme.onSecondaryContainer,
              ),
            ),
      ),
      // themeMode: ThemeMode.system,
      home: const TabScreen(),
    );
  }
}
```

If you see ini main function it run the app with App class that inside the provider, provider use for the global state management. So, we can access the same state in different screen.

I use TabScreen as home, that can help to navigate between screen using bottom navigation.

```dart
// tabs.dart

//...
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
//...
```

So if you can see I return the BottomNavigationBar in Scaffold widget to navigate between home screen and filter screen.

Here's the logic to move between screen.

```dart

class _TabScreenState extends ConsumerState<TabScreen> {
  int _selectedPageIndex = 0;
  bool _isLoading = true;
  String? _error;
  //...
  void _selectPage(int index) {
    setState(() {
      _selectedPageIndex = index;
    });
  }

  //...

  @override
  Widget build(BuildContext context) {
    //...

     if (_selectedPageIndex == 1) {
      activePage = const FiltersScreen();
      activePageTitle = 'Filters';
    }

    //...
  }

}

```

In this code the OnTap properties in BottomNavigationBar widget trigger this function that makes you move to other screen each time you click the navigation.

## State Management with [Riverpod](https://riverpod.dev/)

This project uses [Riverpod](https://riverpod.dev/) for state management. Below is an example of how state management is implemented in this project for handling filters.

### Filter Enumeration

We define an enumeration `Filter` to categorize different types of filters:
```dart
enum Filter {
  food,
  travel,
  leisure,
  work,
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FilterScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final filters = watch(filtersProvider);

    return Scaffold(
      appBar: AppBar(title: Text('Filters')),
      body: ListView(
        children: filters.entries.map((entry) {
          return SwitchListTile(
            title: Text(entry.key.toString().split('.').last),
            value: entry.value,
            onChanged: (bool value) {
              context.read(filtersProvider.notifier).setFilter(entry.key, value);
            },
          );
        }).toList(),
      ),
    );
  }
}


final filtersProvider =
    StateNotifierProvider<FilterNotifier, Map<Filter, bool>>(
  (ref) => FilterNotifier(),
);

```

2. Create a `FilterNotifier` class that extends `StateNotifier<Map<Filter, bool>>`. This class will handle the state management for the filters:

```dart
class FilterNotifier extends StateNotifier<Map<Filter, bool>> {
  FilterNotifier()
      : super(
          {
            Filter.food: true,
            Filter.travel: true,
            Filter.leisure: true,
            Filter.work: true,
          },
        );

  void setFilter(Filter filter, bool value) {
    state = {
      ...state,
      filter: value,
    };
  }

  void setFilters(Map<Filter, bool> filters) {
    state = filters;
  }
}
```
* Constructor: Initializes the state with all filters set to true.
* setFilter: Updates the state for a specific filter.
* setFilters: Replaces the current state with a new set of filters.

> Usage Example

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FilterScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final filters = watch(filtersProvider);

    return Scaffold(
      appBar: AppBar(title: Text('Filters')),
      body: ListView(
        children: filters.entries.map((entry) {
          return SwitchListTile(
            title: Text(entry.key.toString().split('.').last),
            value: entry.value,
            onChanged: (bool value) {
              context.read(filtersProvider.notifier).setFilter(entry.key, value);
            },
          );
        }).toList(),
      ),
    );
  }
}
```


## Contact
Muhammad Farrel Fauzan - [farrelfauzan78@gmail.com](mailto:farrelfauzan78@gmail.com)

Project Link: [https://github.com/farrelfauzan/expense_tracker.git](https://github.com/farrelfauzan/expense_tracker.git)
