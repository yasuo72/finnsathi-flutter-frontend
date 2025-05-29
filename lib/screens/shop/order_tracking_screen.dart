import 'package:flutter/material.dart';
import 'dart:async';
import '../../models/shop_models.dart';

class OrderTrackingScreen extends StatefulWidget {
  final Order order;
  
  const OrderTrackingScreen({super.key, required this.order});

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> with TickerProviderStateMixin {
  late AnimationController _progressAnimationController;
  late Animation<double> _progressAnimation;
  late Timer _statusUpdateTimer;
  OrderStatus _currentStatus = OrderStatus.placed;
  int _deliveryTimeRemaining = 0; // in minutes
  
  // Simulated delivery person details
  final Map<String, dynamic> _deliveryPerson = {
    'name': 'Rahul Singh',
    'phone': '+91 98765 43210',
    'avatar': 'https://randomuser.me/api/portraits/men/45.jpg',
    'rating': 4.8,
    'totalDeliveries': 1243,
  };

  @override
  void initState() {
    super.initState();
    _currentStatus = widget.order.status;
    _deliveryTimeRemaining = 30; // Default 30 minutes
    
    // Setup animation controller for progress indicator
    _progressAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: _getProgressValue(_currentStatus),
    ).animate(CurvedAnimation(
      parent: _progressAnimationController,
      curve: Curves.easeInOut,
    ));
    
    _progressAnimationController.forward();
    
    // Simulate order status updates
    _statusUpdateTimer = Timer.periodic(const Duration(seconds: 15), (timer) {
      _simulateStatusUpdate();
    });
  }

  @override
  void dispose() {
    _progressAnimationController.dispose();
    _statusUpdateTimer.cancel();
    super.dispose();
  }

  double _getProgressValue(OrderStatus status) {
    switch (status) {
      case OrderStatus.placed:
        return 0.2;
      case OrderStatus.confirmed:
        return 0.4;
      case OrderStatus.preparing:
        return 0.6;
      case OrderStatus.outForDelivery:
        return 0.8;
      case OrderStatus.delivered:
        return 1.0;
      case OrderStatus.cancelled:
        return 0.0;
      default:
        return 0.0;
    }
  }

  void _simulateStatusUpdate() {
    if (_currentStatus == OrderStatus.delivered || 
        _currentStatus == OrderStatus.cancelled) {
      _statusUpdateTimer.cancel();
      return;
    }
    
    setState(() {
      switch (_currentStatus) {
        case OrderStatus.placed:
          _currentStatus = OrderStatus.confirmed;
          break;
        case OrderStatus.confirmed:
          _currentStatus = OrderStatus.preparing;
          break;
        case OrderStatus.preparing:
          _currentStatus = OrderStatus.outForDelivery;
          break;
        case OrderStatus.outForDelivery:
          _deliveryTimeRemaining = (_deliveryTimeRemaining / 2).round();
          if (_deliveryTimeRemaining <= 5) {
            _currentStatus = OrderStatus.delivered;
          }
          break;
        default:
          break;
      }
      
      // Animate to new progress value
      _progressAnimationController.reset();
      _progressAnimation = Tween<double>(
        begin: _progressAnimation.value,
        end: _getProgressValue(_currentStatus),
      ).animate(CurvedAnimation(
        parent: _progressAnimationController,
        curve: Curves.easeInOut,
      ));
      _progressAnimationController.forward();
    });
  }

  String _getStatusText(OrderStatus status) {
    switch (status) {
      case OrderStatus.placed:
        return 'Order Placed';
      case OrderStatus.confirmed:
        return 'Order Confirmed';
      case OrderStatus.preparing:
        return 'Preparing Your Order';
      case OrderStatus.outForDelivery:
        return 'Out for Delivery';
      case OrderStatus.delivered:
        return 'Order Delivered';
      case OrderStatus.cancelled:
        return 'Order Cancelled';
      default:
        return 'Unknown Status';
    }
  }

  String _getStatusDescription(OrderStatus status) {
    switch (status) {
      case OrderStatus.placed:
        return 'Your order has been received by the restaurant';
      case OrderStatus.confirmed:
        return 'Restaurant has confirmed your order';
      case OrderStatus.preparing:
        return 'Your food is being prepared';
      case OrderStatus.outForDelivery:
        return 'Your order is on the way';
      case OrderStatus.delivered:
        return 'Your order has been delivered. Enjoy!';
      case OrderStatus.cancelled:
        return 'Your order has been cancelled';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;
    final secondaryColor = Theme.of(context).colorScheme.secondary;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Track Order'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Order ID and Time
            Container(
              padding: const EdgeInsets.all(16),
              color: isDark ? Colors.black12 : Colors.grey.shade50,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Order #${widget.order.id}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Placed on ${widget.order.orderTime.hour}:${widget.order.orderTime.minute} ${widget.order.orderTime.day}/${widget.order.orderTime.month}/${widget.order.orderTime.year}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _currentStatus == OrderStatus.delivered
                          ? Colors.green.withOpacity(0.2)
                          : _currentStatus == OrderStatus.cancelled
                              ? Colors.red.withOpacity(0.2)
                              : primaryColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      _getStatusText(_currentStatus),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: _currentStatus == OrderStatus.delivered
                            ? Colors.green
                            : _currentStatus == OrderStatus.cancelled
                                ? Colors.red
                                : primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Progress Tracker
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  AnimatedBuilder(
                    animation: _progressAnimation,
                    builder: (context, child) {
                      return LinearProgressIndicator(
                        value: _progressAnimation.value,
                        backgroundColor: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _currentStatus == OrderStatus.cancelled ? Colors.red : secondaryColor,
                        ),
                        minHeight: 8,
                        borderRadius: BorderRadius.circular(4),
                      );
                    },
                  ),
                  const SizedBox(height: 32),
                  
                  // Status Steps
                  _buildStatusStep(
                    OrderStatus.placed,
                    Icons.receipt_long_rounded,
                    _currentStatus.index >= OrderStatus.placed.index,
                  ),
                  _buildStatusConnector(
                    _currentStatus.index >= OrderStatus.confirmed.index,
                  ),
                  _buildStatusStep(
                    OrderStatus.confirmed,
                    Icons.check_circle_outline,
                    _currentStatus.index >= OrderStatus.confirmed.index,
                  ),
                  _buildStatusConnector(
                    _currentStatus.index >= OrderStatus.preparing.index,
                  ),
                  _buildStatusStep(
                    OrderStatus.preparing,
                    Icons.restaurant,
                    _currentStatus.index >= OrderStatus.preparing.index,
                  ),
                  _buildStatusConnector(
                    _currentStatus.index >= OrderStatus.outForDelivery.index,
                  ),
                  _buildStatusStep(
                    OrderStatus.outForDelivery,
                    Icons.delivery_dining,
                    _currentStatus.index >= OrderStatus.outForDelivery.index,
                  ),
                  _buildStatusConnector(
                    _currentStatus.index >= OrderStatus.delivered.index,
                  ),
                  _buildStatusStep(
                    OrderStatus.delivered,
                    Icons.home,
                    _currentStatus.index >= OrderStatus.delivered.index,
                  ),
                ],
              ),
            ),
            
            // Estimated Delivery Time
            if (_currentStatus != OrderStatus.delivered && _currentStatus != OrderStatus.cancelled)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey.shade800 : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: secondaryColor.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.access_time,
                        color: secondaryColor,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Estimated Delivery Time',
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$_deliveryTimeRemaining minutes',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            
            // Delivery Person Details
            if (_currentStatus == OrderStatus.outForDelivery)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey.shade800 : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Delivery Partner',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundImage: NetworkImage(_deliveryPerson['avatar']),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _deliveryPerson['name'],
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    Icons.star,
                                    size: 16,
                                    color: Colors.amber,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${_deliveryPerson['rating']} • ${_deliveryPerson['totalDeliveries']} deliveries',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            // Call delivery person
                          },
                          icon: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: primaryColor.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.phone,
                              color: primaryColor,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            
            // Order Items
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey.shade800 : Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Order Items',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                  const Divider(height: 1),
                  ListView.separated(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: widget.order.items.length,
                    separatorBuilder: (context, index) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final item = widget.order.items[index];
                      return ListTile(
                        title: Text(
                          item.item.name,
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        subtitle: Text(
                          'Qty: ${item.quantity}',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                        trailing: Text(
                          '₹${item.totalPrice}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        Text(
                          '₹${widget.order.totalAmount}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Delivery Address
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey.shade800 : Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Delivery Address',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.location_on,
                        color: primaryColor,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          widget.order.deliveryAddress,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Support Section
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey.shade800.withOpacity(0.5) : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.headset_mic,
                    color: secondaryColor,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Need help with your order?',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Contact our support team',
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      // Open support chat
                    },
                    child: Text(
                      'Get Help',
                      style: TextStyle(
                        color: secondaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusStep(OrderStatus status, IconData icon, bool isCompleted) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final secondaryColor = Theme.of(context).colorScheme.secondary;
    
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isCompleted
                ? secondaryColor.withOpacity(0.2)
                : Colors.grey.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Icon(
              icon,
              color: isCompleted ? secondaryColor : Colors.grey,
              size: 20,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _getStatusText(status),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isCompleted
                      ? Theme.of(context).colorScheme.onSurface
                      : Colors.grey,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _getStatusDescription(status),
                style: TextStyle(
                  fontSize: 12,
                  color: isCompleted
                      ? Theme.of(context).colorScheme.onSurface.withOpacity(0.7)
                      : Colors.grey,
                ),
              ),
            ],
          ),
        ),
        if (isCompleted && status != OrderStatus.delivered)
          Icon(
            Icons.check_circle,
            color: Colors.green,
            size: 20,
          ),
      ],
    );
  }

  Widget _buildStatusConnector(bool isActive) {
    return Container(
      margin: const EdgeInsets.only(left: 20),
      width: 2,
      height: 30,
      color: isActive
          ? Theme.of(context).colorScheme.secondary.withOpacity(0.5)
          : Colors.grey.withOpacity(0.2),
    );
  }
}
