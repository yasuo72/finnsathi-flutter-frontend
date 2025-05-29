import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/finance_models.dart';
import '../services/finance_service.dart';
import '../widgets/gradient_button.dart';

class SavingsGoalScreen extends StatefulWidget {
  const SavingsGoalScreen({Key? key}) : super(key: key);

  @override
  State<SavingsGoalScreen> createState() => _SavingsGoalScreenState();
}

class _SavingsGoalScreenState extends State<SavingsGoalScreen> {
  // Helper method to convert icon name string to IconData constant
  IconData _getIconFromName(String iconName) {
    // Try to parse the icon code point
    try {
      int iconCode = int.parse(iconName);
      
      // Map common icon code points to constant IconData objects
      switch (iconCode) {
        case 0xe578: return Icons.savings;
        case 0xe430: return Icons.monetization_on;
        case 0xef63: return Icons.account_balance;
        case 0xe263: return Icons.credit_card;
        case 0xe8f8: return Icons.shopping_cart;
        case 0xe195: return Icons.attach_money;
        case 0xf090: return Icons.trending_up;
        case 0xeb43: return Icons.favorite;
        case 0xe80e: return Icons.home;
        case 0xe571: return Icons.flight;
        case 0xea49: return Icons.school;
        case 0xe57f: return Icons.directions_car;
        // Add more mappings as needed
        default: return Icons.savings; // Default icon
      }
    } catch (e) {
      // If parsing fails, return a default icon
      return Icons.savings;
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Savings Goals'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: Consumer<FinanceService>(builder: (context, financeService, _) {
        final goals = financeService.savingsGoals;
        
        return goals.isEmpty 
            ? _buildEmptyState()
            : _buildGoalsList(goals);
      }),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddGoalDialog(context),
        label: const Text('New Goal'),
        icon: const Icon(Icons.add),
        backgroundColor: Theme.of(context).primaryColor,
      ),
    );
  }
  
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.savings_outlined, 
            size: 80, 
            color: Colors.grey.shade400
          ),
          const SizedBox(height: 16),
          Text(
            'No savings goals yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Set up savings goals to track your progress',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => _showAddGoalDialog(context),
            icon: const Icon(Icons.add),
            label: const Text('Create Goal'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildGoalsList(List<SavingsGoal> goals) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: goals.length,
      itemBuilder: (context, index) {
        final goal = goals[index];
        
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: InkWell(
            onTap: () => _showGoalDetails(context, goal),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: goal.color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          goal.iconName != null 
                            ? _getIconFromName(goal.iconName!)
                            : Icons.savings,
                          color: goal.color,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              goal.title,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (goal.description != null) ...[  
                              const SizedBox(height: 4),
                              Text(
                                goal.description!,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'u20b9${goal.currentAmount.toStringAsFixed(0)} / u20b9${goal.targetAmount.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (goal.targetDate != null) ...[  
                            const SizedBox(height: 4),
                            Text(
                              '${goal.daysRemaining} days left',
                              style: TextStyle(
                                fontSize: 12,
                                color: goal.daysRemaining < 30 ? Colors.orange : Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  LinearProgressIndicator(
                    value: goal.progress.clamp(0.0, 1.0),
                    backgroundColor: Colors.grey.shade200,
                    color: goal.isCompleted ? Colors.green : goal.color,
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Remaining: u20b9${goal.remainingAmount.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: goal.isCompleted ? Colors.green : Colors.grey.shade700,
                        ),
                      ),
                      Text(
                        '${(goal.progress * 100).toStringAsFixed(0)}%',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: goal.color,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
  
  void _showGoalDetails(BuildContext context, SavingsGoal goal) {
    final addAmountController = TextEditingController();
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) {
          return ListView(
            controller: scrollController,
            padding: const EdgeInsets.all(16),
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: goal.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      goal.iconName != null 
                        ? _getIconFromName(goal.iconName!)
                        : Icons.savings,
                      color: goal.color,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      goal.title,
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              if (goal.description != null) ...[  
                const SizedBox(height: 8),
                Text(
                  goal.description!,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
              const SizedBox(height: 16),
              // Goal progress
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Goal Progress',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                          Text(
                            '${(goal.progress * 100).toStringAsFixed(0)}%',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: goal.color,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: goal.progress.clamp(0.0, 1.0),
                        backgroundColor: Colors.grey.shade200,
                        color: goal.isCompleted ? Colors.green : goal.color,
                        minHeight: 8,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Saved'),
                              Text(
                                'u20b9${goal.currentAmount.toStringAsFixed(0)}',
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Text('Target'),
                              Text(
                                'u20b9${goal.targetAmount.toStringAsFixed(0)}',
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text('Remaining'),
                              Text(
                                'u20b9${goal.remainingAmount.toStringAsFixed(0)}',
                                style: TextStyle(
                                  fontSize: 18, 
                                  fontWeight: FontWeight.bold,
                                  color: goal.isCompleted ? Colors.green : Colors.grey.shade700,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Goal details
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Goal Details',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 16),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.calendar_today),
                        title: const Text('Created On'),
                        subtitle: Text(
                          DateFormat('MMM d, yyyy').format(goal.createdDate),
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
                      if (goal.targetDate != null)
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.event),
                          title: const Text('Target Date'),
                          subtitle: Text(
                            DateFormat('MMM d, yyyy').format(goal.targetDate!),
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Add funds section
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Add Funds',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: addAmountController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Amount',
                          prefixText: 'u20b9 ',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            final amount = double.tryParse(addAmountController.text);
                            if (amount == null || amount < 0) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Please enter a valid amount')),
                              );
                              return;
                            }
                            
                            Provider.of<FinanceService>(context, listen: false)
                                .addToSavingsGoal(goal.id, amount);
                                
                            Navigator.pop(context);
                            
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('u20b9${amount.toStringAsFixed(0)} added to ${goal.title}'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: goal.color,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('Add Funds'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _showEditGoalDialog(context, goal);
                      },
                      icon: const Icon(Icons.edit),
                      label: const Text('Edit Goal'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _confirmDeleteGoal(context, goal),
                      icon: const Icon(Icons.delete, color: Colors.red),
                      label: const Text('Delete', style: TextStyle(color: Colors.red)),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
  
  void _showAddGoalDialog(BuildContext context, [SavingsGoal? goal]) {
    final isEditing = goal != null;
    final titleController = TextEditingController(text: isEditing ? goal.title : '');
    final descriptionController = TextEditingController(text: isEditing ? goal.description ?? '' : '');
    final targetAmountController = TextEditingController(
        text: isEditing ? goal.targetAmount.toString() : '');
    final currentAmountController = TextEditingController(
        text: isEditing ? goal.currentAmount.toString() : '0');
    
    DateTime? targetDate = isEditing ? goal.targetDate : null;
    Color selectedColor = isEditing ? goal.color : Colors.blue;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            Future<void> pickTargetDate() async {
              final picked = await showDatePicker(
                context: context,
                initialDate: targetDate ?? DateTime.now().add(const Duration(days: 30)),
                firstDate: DateTime.now(),
                lastDate: DateTime(DateTime.now().year + 10),
              );
              if (picked != null) {
                setState(() {
                  targetDate = picked;
                });
              }
            }

            return Padding(
              padding: EdgeInsets.only(
                top: 20,
                left: 16,
                right: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Text(
                    isEditing ? 'Edit Savings Goal' : 'Create New Savings Goal',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: 'Goal Title',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description (Optional)',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: targetAmountController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Target Amount (u20b9)',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: currentAmountController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Initial Amount (u20b9)',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: pickTargetDate,
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'Target Date (Optional)',
                              border: OutlineInputBorder(),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  targetDate != null
                                      ? DateFormat('MMM d, yyyy').format(targetDate!)
                                      : 'No deadline',
                                  style: const TextStyle(fontSize: 16),
                                ),
                                targetDate != null
                                    ? IconButton(
                                        icon: const Icon(Icons.clear, size: 18),
                                        onPressed: () {
                                          setState(() {
                                            targetDate = null;
                                          });
                                        },
                                      )
                                    : const Icon(Icons.calendar_today),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Color:',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 50,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      children: [
                        Colors.blue,
                        Colors.green,
                        Colors.red,
                        Colors.orange,
                        Colors.purple,
                        Colors.pink,
                        Colors.teal,
                        Colors.indigo,
                      ].map((color) {
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedColor = color;
                            });
                          },
                          child: Container(
                            width: 40,
                            height: 40,
                            margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: selectedColor == color
                                    ? Colors.white
                                    : Colors.transparent,
                                width: 2,
                              ),
                              boxShadow: selectedColor == color
                                  ? [
                                      BoxShadow(
                                        color: color.withOpacity(0.5),
                                        spreadRadius: 1,
                                        blurRadius: 4,
                                      )
                                    ]
                                  : null,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 24),
                  GradientButton(
                    onPressed: () {
                      if (titleController.text.isEmpty || targetAmountController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please fill all required fields')),
                        );
                        return;
                      }

                      final double? targetAmount = double.tryParse(targetAmountController.text);
                      if (targetAmount == null || targetAmount < 0) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please enter a valid target amount')),
                        );
                        return;
                      }

                      final double? currentAmount = double.tryParse(currentAmountController.text);
                      if (currentAmount == null || currentAmount < 0) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please enter a valid current amount')),
                        );
                        return;
                      }

                      if (currentAmount > targetAmount) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Current amount cannot exceed target amount')),
                        );
                        return;
                      }

                      final financeService = Provider.of<FinanceService>(context, listen: false);
                      
                      final newGoal = SavingsGoal(
                        id: isEditing ? goal!.id : null,
                        title: titleController.text,
                        description: descriptionController.text.isNotEmpty ? descriptionController.text : null,
                        targetAmount: targetAmount,
                        currentAmount: currentAmount,
                        targetDate: targetDate,
                        color: selectedColor,
                        iconName: 'savings',
                      );

                      if (isEditing) {
                        financeService.updateSavingsGoal(newGoal);
                      } else {
                        financeService.addSavingsGoal(newGoal);
                      }

                      Navigator.pop(context);
                      
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(isEditing ? 'Goal updated!' : 'New savings goal created!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    },
                    gradient: LinearGradient(
                      colors: [selectedColor, selectedColor.withOpacity(0.7)],
                    ),
                    child: Text(isEditing ? 'Update Goal' : 'Create Goal'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
  
  void _showEditGoalDialog(BuildContext context, SavingsGoal goal) {
    _showAddGoalDialog(context, goal);
  }
  
  void _confirmDeleteGoal(BuildContext context, SavingsGoal goal) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Savings Goal'),
        content: Text('Are you sure you want to delete "${goal.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Provider.of<FinanceService>(context, listen: false).deleteSavingsGoal(goal.id);
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close bottom sheet
              
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Savings goal deleted'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
