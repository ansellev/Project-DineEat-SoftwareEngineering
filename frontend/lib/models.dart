import 'dart:convert';

class User {
  final String id;
  final String fullName;
  final String email;
  final bool isLoggedIn;
  final String? profileImage;
  final String? password;

  User({
    required this.id,
    required this.fullName,
    required this.email,
    required this.isLoggedIn,
    this.profileImage,
    this.password,
  });

  User copyWith({
    String? id,
    String? fullName,
    String? email,
    bool? isLoggedIn,
    String? profileImage,
    String? password,
  }) {
    return User(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      profileImage: profileImage ?? this.profileImage,
      password: password ?? this.password,
    );
  }
}

enum FoodCategory {
  makananUtama,
  minuman,
  pencuciMulut,
  camilan;

  String toIndonesianString() {
    switch (this) {
      case FoodCategory.makananUtama:
        return 'Makanan Utama';
      case FoodCategory.minuman:
        return 'Minuman';
      case FoodCategory.pencuciMulut:
        return 'Pencuci Mulut';
      case FoodCategory.camilan:
        return 'Camilan';
    }
  }

  static FoodCategory fromString(String val) {
    switch (val) {
      case 'Makanan Utama':
        return FoodCategory.makananUtama;
      case 'Minuman':
        return FoodCategory.minuman;
      case 'Pencuci Mulut':
        return FoodCategory.pencuciMulut;
      case 'Camilan':
      default:
        return FoodCategory.camilan;
    }
  }
}

class MenuItem {
  final String id;
  final String name;
  final int price;
  final String image;
  final FoodCategory category;
  final String description;

  MenuItem({
    required this.id,
    required this.name,
    required this.price,
    required this.image,
    required this.category,
    required this.description,
  });
}

class Review {
  final String id;
  final String userName;
  final int rating;
  final String comment;
  final String date;

  Review({
    required this.id,
    required this.userName,
    required this.rating,
    required this.comment,
    required this.date,
  });
}

class Restaurant {
  final String id;
  final String name;
  final String address;
  final String image;
  final String category;
  final double distance;
  final String priceRange; // '$', '$$', '$$$'
  final double averageRating;
  final int totalReviews;
  final int occupancyPercent;
  final int totalTables;
  final Map<int, int> availableTables;
  final int estimatedWaitMinutes;
  final String phone;
  final String operatingHours;
  final String? description;
  final List<Review> reviews;
  final List<MenuItem> menu;
  final int? emptyTablesCount;

  Restaurant({
    required this.id,
    required this.name,
    required this.address,
    required this.image,
    required this.category,
    required this.distance,
    required this.priceRange,
    required this.averageRating,
    required this.totalReviews,
    required this.occupancyPercent,
    required this.totalTables,
    required this.availableTables,
    required this.estimatedWaitMinutes,
    required this.phone,
    required this.operatingHours,
    this.description,
    required this.reviews,
    required this.menu,
    this.emptyTablesCount,
  });

  Restaurant copyWith({
    double? averageRating,
    int? totalReviews,
    List<Review>? reviews,
    int? occupancyPercent,
    int? emptyTablesCount,
    Map<int, int>? availableTables,
  }) {
    return Restaurant(
      id: id,
      name: name,
      address: address,
      image: image,
      category: category,
      distance: distance,
      priceRange: priceRange,
      averageRating: averageRating ?? this.averageRating,
      totalReviews: totalReviews ?? this.totalReviews,
      occupancyPercent: occupancyPercent ?? this.occupancyPercent,
      totalTables: totalTables,
      availableTables: availableTables ?? this.availableTables,
      estimatedWaitMinutes: estimatedWaitMinutes,
      phone: phone,
      operatingHours: operatingHours,
      description: description,
      reviews: reviews ?? this.reviews,
      menu: menu,
      emptyTablesCount: emptyTablesCount ?? this.emptyTablesCount,
    );
  }
}

class PreOrderedFoodItem {
  final String menuItemId;
  final String name;
  final int quantity;
  final int price;

  PreOrderedFoodItem({
    required this.menuItemId,
    required this.name,
    required this.quantity,
    required this.price,
  });
}

enum BookingStatus {
  menunggu,
  selesai,
  dibatalkan,
  pengingatDikirim;

  String toIndonesianString() {
    switch (this) {
      case BookingStatus.menunggu:
        return 'Menunggu';
      case BookingStatus.selesai:
        return 'Selesai';
      case BookingStatus.dibatalkan:
        return 'Dibatalkan';
      case BookingStatus.pengingatDikirim:
        return 'Pengingat Dikirim';
    }
  }

  static BookingStatus fromString(String val) {
    switch (val) {
      case 'Selesai':
        return BookingStatus.selesai;
      case 'Dibatalkan':
        return BookingStatus.dibatalkan;
      case 'Pengingat Dikirim':
        return BookingStatus.pengingatDikirim;
      case 'Menunggu':
      default:
        return BookingStatus.menunggu;
    }
  }
}

class Booking {
  final String id;
  final String restaurantId;
  final String restaurantName;
  final String restaurantImage;
  final String restaurantAddress;
  final String date;
  final String timeSlot;
  final int partySize;
  final String tableId;
  final List<PreOrderedFoodItem> preOrderedFood;
  final int totalPayment;
  final BookingStatus status;
  final String createdAt;
  final String? reviewId;
  final int? reviewRating;
  final String? reviewComment;

  Booking({
    required this.id,
    required this.restaurantId,
    required this.restaurantName,
    required this.restaurantImage,
    required this.restaurantAddress,
    required this.date,
    required this.timeSlot,
    required this.partySize,
    required this.tableId,
    required this.preOrderedFood,
    required this.totalPayment,
    required this.status,
    required this.createdAt,
    this.reviewId,
    this.reviewRating,
    this.reviewComment,
  });

  Booking copyWith({
    BookingStatus? status,
    String? reviewId,
    int? reviewRating,
    String? reviewComment,
  }) {
    return Booking(
      id: id,
      restaurantId: restaurantId,
      restaurantName: restaurantName,
      restaurantImage: restaurantImage,
      restaurantAddress: restaurantAddress,
      date: date,
      timeSlot: timeSlot,
      partySize: partySize,
      tableId: tableId,
      preOrderedFood: preOrderedFood,
      totalPayment: totalPayment,
      status: status ?? this.status,
      createdAt: createdAt,
      reviewId: reviewId ?? this.reviewId,
      reviewRating: reviewRating ?? this.reviewRating,
      reviewComment: reviewComment ?? this.reviewComment,
    );
  }
}

enum NotificationType {
  alert,
  success,
  booking,
  food,
}

class AppNotification {
  final String id;
  final String title;
  final String body;
  final DateTime timestamp;
  final bool isRead;
  final NotificationType type;

  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.timestamp,
    required this.isRead,
    required this.type,
  });

  AppNotification copyWith({
    bool? isRead,
  }) {
    return AppNotification(
      id: id,
      title: title,
      body: body,
      timestamp: timestamp,
      isRead: isRead ?? this.isRead,
      type: type,
    );
  }
}
