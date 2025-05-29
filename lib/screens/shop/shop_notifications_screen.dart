import 'package:flutter/material.dart';

class ShopNotificationPage extends StatefulWidget {
  const ShopNotificationPage({Key? key}) : super(key: key);

  @override
  _ShopNotificationPageState createState() => _ShopNotificationPageState();
}

class _ShopNotificationPageState extends State<ShopNotificationPage> {
  bool isTodaySelected = true;
  List<ShopNotificationItemData> notifications = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      isLoading = false;
      notifications = [
        ShopNotificationItemData(
          icon: Icons.local_shipping_outlined,
          iconColor: Colors.purple,
          bgColor: const Color(0xFFF3E5F5),
          title: 'Order Out for Delivery',
          subtitle: 'Your order from Spice Junction will arrive in 15 minutes',
          isToday: true,
          time: '15 min ago',
        ),
        ShopNotificationItemData(
          icon: Icons.discount_outlined,
          iconColor: Colors.orange,
          bgColor: const Color(0xFFFFECB3),
          title: 'Special Offer',
          subtitle: '20% off on your next order from Green Leaf',
          isToday: true,
          time: '2 hours ago',
        ),
        ShopNotificationItemData(
          icon: Icons.star_outline,
          iconColor: Colors.amber,
          bgColor: const Color(0xFFFFF8E1),
          title: 'Rate Your Order',
          subtitle: 'How was your experience with Caffeine Fix?',
          isToday: true,
          time: '5 hours ago',
        ),
        ShopNotificationItemData(
          icon: Icons.check_circle_outline,
          iconColor: Colors.green,
          bgColor: const Color(0xFFC8E6C9),
          title: 'Order Confirmed',
          subtitle: 'Your order from Size Zero has been confirmed',
          isToday: false,
          time: 'Yesterday',
        ),
        ShopNotificationItemData(
          icon: Icons.receipt_long_outlined,
          iconColor: Colors.deepOrange,
          bgColor: const Color(0xFFFFCCBC),
          title: 'New Menu Items',
          subtitle: 'Spice Junction added 5 new items to their menu',
          isToday: false,
          time: '2 days ago',
        ),
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final List<ShopNotificationItemData> currentList =
        notifications.where((n) => n.isToday == isTodaySelected).toList();

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0A0E21) : Colors.grey[50],
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100),
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1A1F38) : Colors.black,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(24),
              bottomRight: Radius.circular(24),
            ),
          ),
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 16,
            left: 16,
            right: 16,
            bottom: 16,
          ),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Colors.white,
                ),
                onPressed: () => Navigator.pop(context),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Shop Notifications',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Icon(Icons.notifications_none, color: Colors.white),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Center(
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[800] : Colors.grey[200],
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: const EdgeInsets.all(4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          isTodaySelected = true;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isTodaySelected
                              ? isDark
                                  ? Colors.purpleAccent
                                  : Colors.black
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Text(
                          'Today',
                          style: TextStyle(
                            color: isTodaySelected
                                ? Colors.white
                                : isDark
                                    ? Colors.white70
                                    : Colors.black54,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          isTodaySelected = false;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: !isTodaySelected
                              ? isDark
                                  ? Colors.purpleAccent
                                  : Colors.black
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Text(
                          'Earlier',
                          style: TextStyle(
                            color: !isTodaySelected
                                ? Colors.white
                                : isDark
                                    ? Colors.white70
                                    : Colors.black54,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : currentList.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.notifications_off_outlined,
                              size: 80,
                              color: isDark ? Colors.white38 : Colors.black26,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No notifications',
                              style: TextStyle(
                                fontSize: 18,
                                color: isDark ? Colors.white38 : Colors.black38,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: currentList.length,
                        itemBuilder: (context, index) {
                          final item = currentList[index];
                          return ShopNotificationCard(
                            item: item,
                            onTap: () {
                              showModalBottomSheet(
                                context: context,
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(24),
                                  ),
                                ),
                                backgroundColor:
                                    isDark ? const Color(0xFF1A1F38) : Colors.white,
                                builder: (context) {
                                  return ShopNotificationBottomSheet(
                                    icon: item.icon,
                                    iconColor: item.iconColor,
                                    bgColor: item.bgColor,
                                    title: item.title,
                                    subtitle: item.subtitle,
                                    isDark: isDark,
                                  );
                                },
                              );
                            },
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            // Mark all as read
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('All notifications marked as read'),
                duration: Duration(seconds: 2),
              ),
            );
          });
        },
        backgroundColor: isDark ? Colors.purpleAccent : Colors.black,
        child: const Icon(Icons.done_all),
      ),
    );
  }
}

class ShopNotificationItemData {
  final IconData icon;
  final Color iconColor;
  final Color bgColor;
  final String title;
  final String subtitle;
  final bool isToday;
  final String time;

  ShopNotificationItemData({
    required this.icon,
    required this.iconColor,
    required this.bgColor,
    required this.title,
    required this.subtitle,
    required this.isToday,
    required this.time,
  });
}

class ShopNotificationCard extends StatelessWidget {
  final ShopNotificationItemData item;
  final VoidCallback onTap;

  const ShopNotificationCard({
    Key? key,
    required this.item,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      color: isDark ? const Color(0xFF1A1F38) : Colors.white,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: item.bgColor,
                child: Icon(item.icon, color: item.iconColor, size: 30),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            item.title,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                        ),
                        Text(
                          item.time,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.white54 : Colors.black54,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item.subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ShopNotificationBottomSheet extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color bgColor;
  final String title;
  final String subtitle;
  final bool isDark;

  const ShopNotificationBottomSheet({
    Key? key,
    required this.icon,
    required this.iconColor,
    required this.bgColor,
    required this.title,
    required this.subtitle,
    required this.isDark,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.drag_handle, color: isDark ? Colors.white38 : Colors.grey[400]),
          const SizedBox(height: 12),
          CircleAvatar(
            radius: 30,
            backgroundColor: bgColor,
            child: Icon(icon, color: iconColor, size: 30),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 16,
              color: isDark ? Colors.white70 : Colors.grey[700],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark ? Colors.grey[800] : Colors.grey[200],
                  foregroundColor: isDark ? Colors.white : Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
                label: const Text('Dismiss'),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark ? Colors.purpleAccent : Colors.black,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  // Add action based on notification type
                  if (title.contains('Order')) {
                    Navigator.pushNamed(context, '/shop/order-tracking');
                  } else if (title.contains('Offer')) {
                    Navigator.pushNamed(context, '/shop/menu');
                  }
                },
                icon: const Icon(Icons.arrow_forward),
                label: const Text('View'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
