import 'package:flutter/material.dart';

class Shop {
  final String name;
  final String imageUrl;
  final String description;
  final double rating;
  final List<String> tags;
  final List<MenuItem> menu;
  final String location;
  final bool isVerified;
  final int deliveryTimeMinutes;
  final double deliveryFee;
  final bool isFavorite;
  
  Shop({
    required this.name,
    required this.imageUrl,
    this.description = '',
    this.rating = 0.0,
    this.tags = const [],
    required this.menu,
    this.location = '',
    this.isVerified = false,
    this.deliveryTimeMinutes = 30,
    this.deliveryFee = 0.0,
    this.isFavorite = false,
  });

  Shop copyWith({
    String? name,
    String? imageUrl,
    String? description,
    double? rating,
    List<String>? tags,
    List<MenuItem>? menu,
    String? location,
    bool? isVerified,
    int? deliveryTimeMinutes,
    double? deliveryFee,
    bool? isFavorite,
  }) {
    return Shop(
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      description: description ?? this.description,
      rating: rating ?? this.rating,
      tags: tags ?? this.tags,
      menu: menu ?? this.menu,
      location: location ?? this.location,
      isVerified: isVerified ?? this.isVerified,
      deliveryTimeMinutes: deliveryTimeMinutes ?? this.deliveryTimeMinutes,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}

class MenuItem {
  final String name;
  final int price;
  final String description;
  final String imageUrl;
  final List<String> ingredients;
  final bool isVegetarian;
  final bool isRecommended;
  final bool isPopular;
  final double rating;
  final int calories;
  final int prepTimeMinutes;
  final bool isAvailable;
  final Map<String, dynamic>? customizations;
  
  MenuItem({
    required this.name,
    required this.price,
    this.description = '',
    this.imageUrl = '',
    this.ingredients = const [],
    this.isVegetarian = false,
    this.isRecommended = false,
    this.isPopular = false,
    this.rating = 0.0,
    this.calories = 0,
    this.prepTimeMinutes = 15,
    this.isAvailable = true,
    this.customizations,
  });
}

class CartItem {
  final MenuItem item;
  int quantity;
  final Map<String, dynamic>? selectedCustomizations;
  final String? specialInstructions;
  
  CartItem({
    required this.item,
    this.quantity = 1,
    this.selectedCustomizations,
    this.specialInstructions,
  });

  int get totalPrice {
    int basePrice = item.price * quantity;
    int customizationPrice = 0;
    
    if (selectedCustomizations != null) {
      selectedCustomizations!.forEach((key, value) {
        if (value is Map && value.containsKey('price')) {
          customizationPrice += (value['price'] as int? ?? 0);
        }
      });
    }
    
    return basePrice + (customizationPrice * quantity);
  }
}

class Order {
  final String id;
  final List<CartItem> items;
  final int totalAmount;
  final String deliveryAddress;
  final DateTime orderTime;
  final OrderStatus status;
  final PaymentMethod paymentMethod;
  final String? trackingId;
  
  Order({
    required this.id,
    required this.items,
    required this.totalAmount,
    required this.deliveryAddress,
    required this.orderTime,
    this.status = OrderStatus.placed,
    required this.paymentMethod,
    this.trackingId,
  });
}

enum OrderStatus {
  placed,
  confirmed,
  preparing,
  outForDelivery,
  delivered,
  cancelled
}

enum PaymentMethod {
  card,
  upi,
  wallet,
  cashOnDelivery
}

class Review {
  final String userId;
  final String userName;
  final String userAvatar;
  final double rating;
  final String comment;
  final DateTime date;
  final List<String>? images;
  
  Review({
    required this.userId,
    required this.userName,
    required this.userAvatar,
    required this.rating,
    required this.comment,
    required this.date,
    this.images,
  });
}
