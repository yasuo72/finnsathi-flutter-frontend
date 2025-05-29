import 'package:flutter/material.dart';
import '../../models/shop_models.dart';
import 'payment_screen.dart';
import 'address_picker_screen.dart';

class CartScreen extends StatefulWidget {
  final List<CartItem> cart;
  const CartScreen({super.key, required this.cart});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  int get total {
    int sum = widget.cart.fold(0, (sum, item) => sum + item.item.price * item.quantity);
    if (appliedCoupon != null && appliedCoupon!.isNotEmpty && appliedCoupon!.toLowerCase() == 'chai') {
      sum -= 10; // Example: 'chai' coupon gives ₹10 off
    }
    return sum < 0 ? 0 : sum;
  }

  String? appliedCoupon;
  String? deliveryAddress;
  String? addressError;
  final TextEditingController _couponController = TextEditingController();

  // Google Maps address picker stub
  Future<void> pickAddressFromMap() async {
    // Open the actual OSM address picker and get the human-readable address
    final pickedAddress = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const AddressPickerScreen()),
    );
    if (pickedAddress != null && pickedAddress.isNotEmpty) {
      setState(() {
        deliveryAddress = pickedAddress;
        addressError = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Address picked from map!')),
      );
    }
  }

  void updateQty(int index, int delta) {
    setState(() {
      widget.cart[index].quantity += delta;
      if (widget.cart[index].quantity <= 0) {
        widget.cart.removeAt(index);
      }
    });
  }

  void applyCoupon() {
    setState(() {
      appliedCoupon = _couponController.text.trim();
    });
    if (appliedCoupon != null && appliedCoupon!.isNotEmpty) {
      String msg = 'Coupon "$appliedCoupon" applied!';
      if (appliedCoupon!.toLowerCase() == 'chai') {
        msg += ' ₹10 discount applied.';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg)),
      );
    }
  }

  void editAddress() async {
    final controller = TextEditingController(text: deliveryAddress);
    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Address'),
          content: TextField(
            controller: controller,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Enter delivery address',
              errorText: addressError,
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
            ElevatedButton(onPressed: () {
              final value = controller.text.trim();
              if (value.isEmpty || value.length < 10) {
                setState(() { addressError = 'Please enter a valid address (min 10 chars)'; });
              } else {
                Navigator.pop(context, value);
              }
            }, child: Text('Save')),
            TextButton(onPressed: pickAddressFromMap, child: Text('Pick from Map')),
          ],
        );
      },
    );
    if (result != null && result.isNotEmpty) {
      setState(() {
        deliveryAddress = result;
        addressError = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Address updated!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Theme.of(context).iconTheme.color ?? Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage('https://randomuser.me/api/portraits/men/32.jpg'),
              radius: 16,
              backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.15),
            ),
            const SizedBox(width: 8),
            Text('Cart', style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Icon(Icons.more_vert, color: Theme.of(context).iconTheme.color ?? Colors.grey),
          ),
        ],
        centerTitle: true,
      ),
      body: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: widget.cart.isEmpty
            ? Center(child: Text('Your cart is empty.', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)))
            : Column(
                children: [
                  // Offer/Coupon Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _couponController,
                            decoration: InputDecoration(
                              hintText: 'Enter offer or coupon code',
                              filled: true,
                              fillColor: Theme.of(context).cardColor,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.secondary,
                            foregroundColor: Theme.of(context).colorScheme.onSecondary,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: applyCoupon,
                          child: Text(appliedCoupon == null || appliedCoupon!.isEmpty ? 'Apply' : 'Applied'),
                        ),
                      ],
                    ),
                  ),
                  // Address Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.location_on, color: Theme.of(context).colorScheme.primary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Delivery Address', style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
                              const SizedBox(height: 2),
                              Text(
                                deliveryAddress == null || deliveryAddress!.isEmpty ? 'Add your address' : deliveryAddress!,
                                style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7)),
                              ),
                              if (addressError != null)
                                Text(addressError!, style: TextStyle(color: Colors.red, fontSize: 12)),
                            ],
                          ),
                        ),
                        TextButton(
                          onPressed: editAddress,
                          child: Text(
                            deliveryAddress == null || deliveryAddress!.isEmpty ? 'Add' : 'Edit',
                            style: TextStyle(color: Theme.of(context).colorScheme.primary),
                          ),
                        )
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: widget.cart.length,
                      itemBuilder: (context, index) {
                        final cartItem = widget.cart[index];
                        return Card(
                          color: Theme.of(context).cardColor,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: ListTile(
                            leading: Icon(Icons.fastfood, color: Theme.of(context).colorScheme.secondary),
                            title: Text(cartItem.item.name, style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.w600)),
                            subtitle: Text('₹${cartItem.item.price} x ${cartItem.quantity}', style: TextStyle(color: Theme.of(context).colorScheme.primary)),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.remove_circle, color: Theme.of(context).colorScheme.secondary),
                                  onPressed: () => updateQty(index, -1),
                                ),
                                Text('${cartItem.quantity}', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
                                IconButton(
                                  icon: Icon(Icons.add_circle, color: Theme.of(context).colorScheme.primary),
                                  onPressed: () => updateQty(index, 1),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  // Discount Breakdown Section
                  if (appliedCoupon != null && appliedCoupon!.toLowerCase() == 'chai')
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Coupon Discount (chai)', style: TextStyle(color: Theme.of(context).colorScheme.secondary)),
                          Text('- ₹10', style: TextStyle(color: Theme.of(context).colorScheme.secondary, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context).brightness == Brightness.dark ? Colors.black54 : Colors.black12,
                          blurRadius: 10,
                          offset: Offset(0, -2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Total:', style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface, fontSize: 18)),
                        Text('₹$total', style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary, fontSize: 20)),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.secondary,
                            foregroundColor: Theme.of(context).colorScheme.onSecondary,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => PaymentScreen(total: total),
                              ),
                            );
                          },
                          child: const Text('Checkout'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
