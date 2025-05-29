import '../models/finance_models.dart';
import 'api_service.dart';
import '../app_config.dart';
import '../config/api_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BudgetService {
  static const String _endpoint = '/budgets';
  
  // Get all budgets for the current user
  static Future<List<Budget>> getAllBudgets() async {
    try {
      print('Fetching budgets from: ${ApiConfig.budgets}');
      
      // Check if auth token exists before making the request
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token == null || token.isEmpty) {
        print('⚠️ No auth token found. User may not be logged in properly.');
        return [];
      }
      
      print('🔑 Using auth token: ${token.substring(0, token.length > 10 ? 10 : token.length)}...');
      final data = await ApiService.get(ApiConfig.budgets);

      if (data != null && data['success'] == true && data['data'] != null) {
        final List<dynamic> budgetsJson = data['data'];
        print('✅ Successfully fetched ${budgetsJson.length} budgets');
        return budgetsJson.map((json) => _convertBackendBudget(json)).toList();
      } else {
        print('❌ API response format issue: ${data?.toString() ?? 'null response'}');
      }
      
      print('No budgets found or invalid response format');
      return [];
    } catch (e) {
      print('❌ Error fetching budgets: $e');
      return [];
    }
  }
  
  // Get a single budget by ID
  static Future<Budget?> getBudgetById(String id) async {
    try {
      print('Fetching budget with ID: $id from: ${ApiConfig.budgets}/$id');
      
      // Check if auth token exists before making the request
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token == null || token.isEmpty) {
        print('⚠️ No auth token found. User may not be logged in properly.');
        return null;
      }
      
      print('🔑 Using auth token: ${token.substring(0, token.length > 10 ? 10 : token.length)}...');
      final data = await ApiService.get('${ApiConfig.budgets}/$id');

      if (data != null && data['success'] == true && data['data'] != null) {
        print('✅ Successfully fetched budget with ID: $id');
        return _convertBackendBudget(data['data']);
      } else {
        print('❌ API response format issue: ${data?.toString() ?? 'null response'}');
      }
      
      print('Budget not found or invalid response format');
      return null;
    } catch (e) {
      print('❌ Error fetching budget: $e');
      return null;
    }
  }
  
  // Create a new budget
  static Future<Budget?> createBudget(Budget budget) async {
    try {
      print('Creating budget at: ${ApiConfig.budgets}');
      print('Budget data: ${_convertToBackendFormat(budget)}');
      
      // Check if auth token exists before making the request
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token == null || token.isEmpty) {
        print('⚠️ No auth token found. User may not be logged in properly.');
        return null;
      }
      
      print('🔑 Using auth token: ${token.substring(0, token.length > 10 ? 10 : token.length)}...');
      final data = await ApiService.post(
        ApiConfig.budgets,
        _convertToBackendFormat(budget)
      );
      
      if (data != null && data['success'] == true && data['data'] != null) {
        print('✅ Budget created successfully with ID: ${data['data']['_id'] ?? data['data']['id']}');
        return _convertBackendBudget(data['data']);
      }
      
      print('❌ Failed to create budget: ${data?['message'] ?? 'Unknown error'}');
      return null;
    } catch (e) {
      print('❌ Error creating budget: $e');
      return null;
    }
  }
  
  // Update an existing budget
  static Future<Budget?> updateBudget(Budget budget) async {
    try {
      print('Updating budget with ID: ${budget.id} at: ${ApiConfig.budgets}/${budget.id}');
      print('Budget data: ${_convertToBackendFormat(budget)}');
      
      // Check if auth token exists before making the request
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token == null || token.isEmpty) {
        print('⚠️ No auth token found. User may not be logged in properly.');
        return null;
      }
      
      print('🔑 Using auth token: ${token.substring(0, token.length > 10 ? 10 : token.length)}...');
      final data = await ApiService.put(
        '${ApiConfig.budgets}/${budget.id}',
        _convertToBackendFormat(budget)
      );
      
      if (data != null && data['success'] == true && data['data'] != null) {
        print('✅ Budget updated successfully with ID: ${budget.id}');
        return _convertBackendBudget(data['data']);
      } else {
        print('❌ Failed to update budget: ${data?['message'] ?? 'Unknown error'}');
      }
      
      return null;
    } catch (e) {
      print('❌ Error updating budget: $e');
      return null;
    }
  }
  
  // Delete a budget
  static Future<bool> deleteBudget(String id) async {
    try {
      print('Deleting budget with ID: $id from: ${ApiConfig.budgets}/$id');
      
      // Check if auth token exists before making the request
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token == null || token.isEmpty) {
        print('⚠️ No auth token found. User may not be logged in properly.');
        return false;
      }
      
      print('🔑 Using auth token: ${token.substring(0, token.length > 10 ? 10 : token.length)}...');
      final data = await ApiService.delete('${ApiConfig.budgets}/$id');
      
      if (data != null && data['success'] == true) {
        print('✅ Budget deleted successfully with ID: $id');
        return true;
      } else {
        print('❌ Failed to delete budget: ${data?['message'] ?? 'Unknown error'}');
        return false;
      }
    } catch (e) {
      print('❌ Error deleting budget: $e');
      return false;
    }
  }
  
  // Get active budgets
  static Future<List<Budget>> getActiveBudgets() async {
    try {
      final data = await ApiService.get('${AppConfig.apiBaseUrl}$_endpoint/active');
      
      if (data != null && data['success'] == true && data['data'] != null) {
        final List<dynamic> budgetsJson = data['data'];
        return budgetsJson.map((json) => _convertBackendBudget(json)).toList();
      }
      
      return [];
    } catch (e) {
      print('Error fetching active budgets: $e');
      return [];
    }
  }
  
  // Helper method to convert backend budget format to frontend Budget model
  static Budget _convertBackendBudget(Map<String, dynamic> json) {
    // Convert category string to TransactionCategory enum if it exists
    TransactionCategory? category;
    if (json['category'] != null) {
      try {
        final categoryStr = json['category'] as String;
        category = TransactionCategory.values.firstWhere(
          (e) => e.name == categoryStr,
          orElse: () => TransactionCategory.other_expense
        );
      } catch (_) {
        category = TransactionCategory.other_expense;
      }
    }
    
    return Budget(
      id: json['_id'] ?? json['id'],
      title: json['title'],
      limit: json['limit'].toDouble(),
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      category: category,
      transactionIds: json['transactionIds'] != null 
          ? List<String>.from(json['transactionIds']) 
          : [],
      spent: json['spent']?.toDouble() ?? 0.0,
    );
  }
  
  // Helper method to convert frontend Budget model to backend format
  static Map<String, dynamic> _convertToBackendFormat(Budget budget) {
    return {
      'title': budget.title,
      'limit': budget.limit,
      'startDate': budget.startDate.toIso8601String(),
      'endDate': budget.endDate.toIso8601String(),
      'category': budget.category?.name,
      'transactionIds': budget.transactionIds,
      'spent': budget.spent,
    };
  }
}
