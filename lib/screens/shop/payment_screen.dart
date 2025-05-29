import 'package:flutter/material.dart';
import 'order_success_screen.dart';

class PaymentScreen extends StatelessWidget {
  final int total;
  const PaymentScreen({super.key, required this.total});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Payment'), backgroundColor: Colors.white, elevation: 0),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            leading: Icon(Icons.credit_card, color: Theme.of(context).colorScheme.primary),
            title: Text('Cards', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
            subtitle: Text('Debit / Credit card', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7))),
            trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Theme.of(context).iconTheme.color),
          ),
          ListTile(
            leading: Icon(Icons.account_balance_wallet, color: Theme.of(context).colorScheme.primary),
            title: Text('UPI', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
            subtitle: Text('Pay with UPI', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7))),
            trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Theme.of(context).iconTheme.color),
          ),
          ListTile(
            leading: Icon(Icons.wallet, color: Theme.of(context).colorScheme.primary),
            title: Text('Wallets', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
            subtitle: Text('Paytm wallet, PhonePe wallet', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7))),
            trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Theme.of(context).iconTheme.color),
          ),
          const Divider(),
          ListTile(
            leading: Icon(Icons.delivery_dining, color: Theme.of(context).colorScheme.secondary),
            title: Text('Pay on delivery', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
            subtitle: Text('Cash on delivery', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7))),
            trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Theme.of(context).iconTheme.color),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.secondary,
              foregroundColor: Theme.of(context).colorScheme.onSecondary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const OrderSuccessScreen()),
              );
            },
            child: const Text('Place Order'),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Total:', style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
            Text('₹$total', style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary)),
          ],
        ),
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    );
  }
}
