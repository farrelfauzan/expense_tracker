# Expense Tracker

![Flutter](https://img.shields.io/badge/Flutter-v1.0-blue) ![License](https://img.shields.io/badge/license-MIT-green)

## Table of Contents
- [Introduction](#introduction)
- [Features](#features)
- [Getting Started](#getting-started)
  - [Prerequisites](#prerequisites)
  - [Installation](#installation)
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
