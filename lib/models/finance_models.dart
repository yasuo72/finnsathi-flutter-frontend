import 'package:flutter/material.dart';
import 'dart:math';

enum TransactionType { income, expense }
enum TransactionCategory {
  // Income categories
  salary,
  investment,
  gifts,
  business,
  rent,
  other_income,
  
  // Expense categories
  shopping,
  food,
  transport,
  entertainment,
  bills,
  health,
  education,
  travel,
  home,
  groceries,
  other_expense
}

// Extension to get category metadata
extension CategoryMetadata on TransactionCategory {
  String get name {
    return toString().split('.').last.replaceAll('_', ' ');
  }
  
  String get displayName {
    return name[0].toUpperCase() + name.substring(1);
  }
  
  Color get color {
    switch (this) {
      case TransactionCategory.salary: return Colors.green.shade500;
      case TransactionCategory.investment: return Colors.blue.shade500;
      case TransactionCategory.gifts: return Colors.purple.shade400;
      case TransactionCategory.business: return Colors.amber.shade600;
      case TransactionCategory.rent: return Colors.cyan.shade500;
      case TransactionCategory.other_income: return Colors.teal.shade500;
      
      case TransactionCategory.shopping: return Colors.red.shade400;
      case TransactionCategory.food: return Colors.orange.shade500;
      case TransactionCategory.transport: return Colors.indigo.shade400;
      case TransactionCategory.entertainment: return Colors.pink.shade400;
      case TransactionCategory.bills: return Colors.red.shade600;
      case TransactionCategory.health: return Colors.teal.shade500;
      case TransactionCategory.education: return Colors.blue.shade700;
      case TransactionCategory.travel: return Colors.green.shade600;
      case TransactionCategory.home: return Colors.brown.shade500;
      case TransactionCategory.groceries: return Colors.deepOrange.shade500;
      case TransactionCategory.other_expense: return Colors.grey.shade600;
    }
  }
  
  IconData get icon {
    switch (this) {
      case TransactionCategory.salary: return Icons.account_balance_wallet;
      case TransactionCategory.investment: return Icons.trending_up;
      case TransactionCategory.gifts: return Icons.card_giftcard;
      case TransactionCategory.business: return Icons.business;
      case TransactionCategory.rent: return Icons.home_work;
      case TransactionCategory.other_income: return Icons.money;
      
      case TransactionCategory.shopping: return Icons.shopping_bag;
      case TransactionCategory.food: return Icons.restaurant;
      case TransactionCategory.transport: return Icons.directions_car;
      case TransactionCategory.entertainment: return Icons.movie;
      case TransactionCategory.bills: return Icons.receipt_long;
      case TransactionCategory.health: return Icons.healing;
      case TransactionCategory.education: return Icons.school;
      case TransactionCategory.travel: return Icons.flight;
      case TransactionCategory.home: return Icons.home;
      case TransactionCategory.groceries: return Icons.shopping_cart;
      case TransactionCategory.other_expense: return Icons.category;
    }
  }
  
  TransactionType get transactionType {
    switch (this) {
      case TransactionCategory.salary:
      case TransactionCategory.investment:
      case TransactionCategory.gifts:
      case TransactionCategory.business:
      case TransactionCategory.rent:
      case TransactionCategory.other_income:
        return TransactionType.income;
      default:
        return TransactionType.expense;
    }
  }
  
  static List<TransactionCategory> incomeCategories = [
    TransactionCategory.salary,
    TransactionCategory.investment,
    TransactionCategory.gifts,
    TransactionCategory.business,
    TransactionCategory.rent,
    TransactionCategory.other_income,
  ];
  
  static List<TransactionCategory> expenseCategories = [
    TransactionCategory.shopping,
    TransactionCategory.food,
    TransactionCategory.transport,
    TransactionCategory.entertainment,
    TransactionCategory.bills,
    TransactionCategory.health,
    TransactionCategory.education,
    TransactionCategory.travel,
    TransactionCategory.home,
    TransactionCategory.groceries,
    TransactionCategory.other_expense,
  ];
}

class Transaction {
  final String id;
  final String title;
  final String? description;
  final double amount;
  final DateTime date;
  final TransactionCategory category;
  final TransactionType type;
  final String? attachmentPath;
  
  Transaction({
    String? id,
    required this.title,
    this.description,
    required this.amount,
    required this.date,
    required this.category,
    required this.type,
    this.attachmentPath,
  }) : id = id ?? _generateId();
  
  static String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString() + 
           Random().nextInt(10000).toString();
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'amount': amount,
      'date': date.toIso8601String(),
      'category': category.toString(),
      'type': type.toString(),
      'attachmentPath': attachmentPath,
    };
  }
  
  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      amount: json['amount'],
      date: DateTime.parse(json['date']),
      category: TransactionCategory.values.firstWhere(
        (e) => e.toString() == json['category'],
        orElse: () => json['type'] == TransactionType.income.toString() 
            ? TransactionCategory.other_income 
            : TransactionCategory.other_expense
      ),
      type: TransactionType.values.firstWhere(
        (e) => e.toString() == json['type'],
        orElse: () => TransactionType.expense
      ),
      attachmentPath: json['attachmentPath'],
    );
  }
  
  Transaction copyWith({
    String? id,
    String? title,
    String? description,
    double? amount,
    DateTime? date,
    TransactionCategory? category,
    TransactionType? type,
    String? attachmentPath,
  }) {
    return Transaction(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      category: category ?? this.category,
      type: type ?? this.type,
      attachmentPath: attachmentPath ?? this.attachmentPath,
    );
  }
}

class Budget {
  final String id;
  final String title;
  final double limit;
  final DateTime startDate;
  final DateTime endDate;
  final TransactionCategory? category;
  final List<String> transactionIds; // IDs of transactions to track
  final double spent;
  
  Budget({
    String? id,
    required this.title,
    required this.limit,
    required this.startDate,
    required this.endDate,
    this.category,
    List<String>? transactionIds,
    double? spent,
  }) : 
    id = id ?? _generateId(),
    transactionIds = transactionIds ?? [],
    spent = spent ?? 0.0;
    
  static String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString() + 
           Random().nextInt(10000).toString();
  }
  
  // Remaining budget amount
  double get remaining => limit - spent;
  
  // Progress percentage (0.0 to 1.0)
  double get progress => spent / limit;
  
  // Determine if budget is exceeded
  bool get isExceeded => spent > limit;
  
  // Determine if budget is active
  bool get isActive {
    final now = DateTime.now();
    return now.isAfter(startDate) && now.isBefore(endDate);
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'limit': limit,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'category': category?.toString(),
      'transactionIds': transactionIds,
      'spent': spent,
    };
  }
  
  factory Budget.fromJson(Map<String, dynamic> json) {
    return Budget(
      id: json['id'],
      title: json['title'],
      limit: json['limit'],
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      category: json['category'] != null ? 
          TransactionCategory.values.firstWhere(
            (e) => e.toString() == json['category'],
            orElse: () => TransactionCategory.other_expense
          ) : null,
      transactionIds: List<String>.from(json['transactionIds'] ?? []),
      spent: json['spent'] ?? 0.0,
    );
  }
  
  Budget copyWith({
    String? id,
    String? title,
    double? limit,
    DateTime? startDate,
    DateTime? endDate,
    TransactionCategory? category,
    List<String>? transactionIds,
    double? spent,
  }) {
    return Budget(
      id: id ?? this.id,
      title: title ?? this.title,
      limit: limit ?? this.limit,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      category: category ?? this.category,
      transactionIds: transactionIds ?? this.transactionIds,
      spent: spent ?? this.spent,
    );
  }
}

class SavingsGoal {
  final String id;
  final String title;
  final String? description;
  final double targetAmount;
  final double currentAmount;
  final DateTime createdDate;
  final DateTime? targetDate;
  final Color color;
  final String? iconName;
  
  SavingsGoal({
    String? id,
    required this.title,
    this.description,
    required this.targetAmount,
    double? currentAmount,
    DateTime? createdDate,
    this.targetDate,
    Color? color,
    this.iconName,
  }) : 
    id = id ?? _generateId(),
    currentAmount = currentAmount ?? 0.0,
    createdDate = createdDate ?? DateTime.now(),
    color = color ?? Colors.primaries[Random().nextInt(Colors.primaries.length)];
  
  static String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString() + 
           Random().nextInt(10000).toString();
  }
  
  // Progress percentage (0.0 to 1.0)
  double get progress => currentAmount / targetAmount;
  
  // Remaining amount to save
  double get remainingAmount => targetAmount - currentAmount;
  
  // Determine if goal is completed
  bool get isCompleted => currentAmount >= targetAmount;
  
  // Days remaining until target date
  int get daysRemaining {
    if (targetDate == null) return 0;
    final today = DateTime.now();
    return targetDate!.difference(today).inDays;
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'targetAmount': targetAmount,
      'currentAmount': currentAmount,
      'createdDate': createdDate.toIso8601String(),
      'targetDate': targetDate?.toIso8601String(),
      'color': color.value,
      'iconName': iconName,
    };
  }
  
  factory SavingsGoal.fromJson(Map<String, dynamic> json) {
    return SavingsGoal(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      targetAmount: json['targetAmount'],
      currentAmount: json['currentAmount'],
      createdDate: DateTime.parse(json['createdDate']),
      targetDate: json['targetDate'] != null ? DateTime.parse(json['targetDate']) : null,
      color: Color(json['color']),
      iconName: json['iconName'],
    );
  }
  
  SavingsGoal copyWith({
    String? id,
    String? title,
    String? description,
    double? targetAmount,
    double? currentAmount,
    DateTime? createdDate,
    DateTime? targetDate,
    Color? color,
    String? iconName,
  }) {
    return SavingsGoal(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      createdDate: createdDate ?? this.createdDate,
      targetDate: targetDate ?? this.targetDate,
      color: color ?? this.color,
      iconName: iconName ?? this.iconName,
    );
  }
}
