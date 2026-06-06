import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sp;
import '../models.dart';

class AppState extends ChangeNotifier {
  final _supabase = sp.Supabase.instance.client;

  User? _currentUser;
  User? get currentUser => _currentUser;

  List<Restaurant> _restaurants = [];
  List<Booking> _bookings = [];
  List<AppNotification> _notifications = [];

  bool isLoading = true;

  AppState() {
    _initData();
  }

  Future<void> _initData() async {
    isLoading = true;
    notifyListeners();

    try {
      final restoData = await _supabase.from('restaurants').select();
      final menuData = await _supabase.from('menu_items').select();
      final reviewData = await _supabase.from('reviews').select();

      _restaurants = restoData.map((rData) {
        final restoMenus = menuData
            .where((m) => m['restaurant_id'] == rData['id'])
            .map(
              (m) => MenuItem(
                id: m['id'],
                name: m['name'],
                price: m['price'],
                image: m['image'],
                category: FoodCategory.fromString(m['category']),
                description: m['description'] ?? '',
              ),
            )
            .toList();

        final restoReviews = reviewData
            .where((rev) => rev['restaurant_id'] == rData['id'])
            .map(
              (rev) => Review(
                id: rev['id'],
                userName: rev['user_name'],
                rating: rev['rating'],
                comment: rev['comment'],
                date: rev['date'],
              ),
            )
            .toList();

        Map<int, int> tables = {};
        if (rData['available_tables'] != null) {
          (rData['available_tables'] as Map<String, dynamic>).forEach((
            key,
            value,
          ) {
            tables[int.parse(key)] = value as int;
          });
        }

        return Restaurant(
          id: rData['id'],
          name: rData['name'],
          address: rData['address'],
          category: rData['category'],
          distance: rData['distance'].toDouble(),
          priceRange: rData['price_range'],
          image: rData['image'],
          averageRating: rData['average_rating']?.toDouble() ?? 0.0,
          totalReviews: rData['total_reviews'] ?? 0,
          occupancyPercent: rData['occupancy_percent'] ?? 0,
          totalTables: rData['total_tables'] ?? 0,
          estimatedWaitMinutes: rData['estimated_wait_minutes'] ?? 0,
          phone: rData['phone'],
          operatingHours: rData['operating_hours'],
          description: rData['description'],
          availableTables: tables,
          menu: restoMenus,
          reviews: restoReviews,
        );
      }).toList();

      final bookingData = await _supabase.from('bookings').select();
      _bookings = bookingData.map((b) {
        List<PreOrderedFoodItem> foodList = [];
        if (b['pre_ordered_food'] != null) {
          var foods = b['pre_ordered_food'] as List<dynamic>;
          foodList = foods
              .map(
                (f) => PreOrderedFoodItem(
                  menuItemId: f['menuItemId'],
                  name: f['name'],
                  quantity: f['quantity'],
                  price: f['price'],
                ),
              )
              .toList();
        }

        return Booking(
          id: b['id'],
          restaurantId: b['restaurant_id'],
          restaurantName: b['restaurant_name'],
          restaurantImage: b['restaurant_image'],
          restaurantAddress: b['restaurant_address'],
          date: b['date'],
          timeSlot: b['time_slot'],
          partySize: b['party_size'],
          tableId: b['table_id'],
          preOrderedFood: foodList,
          totalPayment: b['total_payment'],
          status: BookingStatus.fromString(b['status']),
          createdAt: b['created_at'],
          reviewId: b['review_id'],
          reviewRating: b['review_rating'],
          reviewComment: b['review_comment'],
        );
      }).toList();

      final session = _supabase.auth.currentSession;
      if (session != null && session.user != null) {
        _currentUser = User(
          id: session.user!.id,
          fullName: session.user!.userMetadata?['full_name'] ?? 'User',
          email: session.user!.email ?? '',
          isLoggedIn: true,
        );
      }
    } catch (e) {
      print('Error fetching data: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  List<Restaurant> get restaurants {
    return _restaurants.map((resto) {
      final activeUserBookings = _bookings
          .where(
            (b) =>
                b.restaurantId == resto.id &&
                b.status != BookingStatus.dibatalkan,
          )
          .toList();
      final activeUserBookingsCount = activeUserBookings.length;
      final baselineOccupied =
          (resto.occupancyPercent * resto.totalTables) ~/ 100;
      final totalOccupied = min(
        resto.totalTables,
        baselineOccupied + activeUserBookingsCount,
      );

      int dynamicOccupancy = 0;
      if (resto.totalTables > 0) {
        dynamicOccupancy = ((totalOccupied / resto.totalTables) * 100).round();
      }
      final emptyTables = max(0, resto.totalTables - totalOccupied);
      Map<int, int> dynamicAvailableTables = Map<int, int>.from(
        resto.availableTables,
      );

      if (activeUserBookingsCount > 0) {
        final totalAvailableFromGrid = resto.availableTables.values.fold<int>(
          0,
          (sum, val) => sum + val,
        );
        if (totalAvailableFromGrid > 0) {
          final double scaleFactor = emptyTables / totalAvailableFromGrid;
          resto.availableTables.forEach((key, val) {
            dynamicAvailableTables[key] = max(0, (val * scaleFactor).round());
          });
        } else {
          resto.availableTables.forEach((key, val) {
            dynamicAvailableTables[key] = max(0, emptyTables ~/ 4);
          });
        }
      }
      return resto.copyWith(
        occupancyPercent: dynamicOccupancy,
        emptyTablesCount: emptyTables,
        availableTables: dynamicAvailableTables,
      );
    }).toList();
  }

  List<Booking> get bookings => _bookings;
  List<AppNotification> get notifications => _notifications;
  int get unreadNotificationsCount =>
      _notifications.where((n) => !n.isRead).length;

  Future<void> createBooking({
    required String restaurantId,
    required String restaurantName,
    required String restaurantImage,
    required String restaurantAddress,
    required String date,
    required String timeSlot,
    required int partySize,
    required String tableId,
    required List<PreOrderedFoodItem> preOrderedFood,
    required int totalPayment,
  }) async {
    final foodJson = preOrderedFood
        .map(
          (f) => {
            'menuItemId': f.menuItemId,
            'name': f.name,
            'quantity': f.quantity,
            'price': f.price,
          },
        )
        .toList();

    try {
      final response = await _supabase
          .from('bookings')
          .insert({
            'restaurant_id': restaurantId,
            'restaurant_name': restaurantName,
            'restaurant_image': restaurantImage,
            'restaurant_address': restaurantAddress,
            'date': date,
            'time_slot': timeSlot,
            'party_size': partySize,
            'table_id': tableId,
            'pre_ordered_food': foodJson,
            'total_payment': totalPayment,
            'status': BookingStatus.menunggu.toIndonesianString(),
            'created_at': DateTime.now().toIso8601String(),
          })
          .select()
          .single();

      await _initData();
    } catch (e) {
      print('Error create booking: $e');
    }
  }

  Future<bool> loginUser(String email, String password) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      if (response.user != null) {
        _currentUser = User(
          id: response.user!.id,
          fullName: response.user!.userMetadata?['full_name'] ?? 'User',
          email: response.user!.email ?? email,
          isLoggedIn: true,
        );
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print('Login error: $e');
      return false;
    }
  }

  Future<bool> registerUser(String name, String email, String password) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': name},
      );
      if (response.user != null) {
        _currentUser = User(
          id: response.user!.id,
          fullName: name,
          email: email,
          isLoggedIn: true,
        );
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print('Register error: $e');
      return false;
    }
  }

  Future<void> logout() async {
    await _supabase.auth.signOut();
    _currentUser = null;
    notifyListeners();
  }

  void markAllNotificationsAsRead() {
    for (int i = 0; i < _notifications.length; i++) {
      _notifications[i] = _notifications[i].copyWith(isRead: true);
    }
    notifyListeners();
  }

  void cancelBooking(String bookingId) {
    final index = _bookings.indexWhere((b) => b.id == bookingId);
    if (index != -1) {
      _bookings[index] = _bookings[index].copyWith(
        status: BookingStatus.dibatalkan,
      );
      notifyListeners();
    }
  }

  void updateBookingStatus(String bookingId, BookingStatus newStatus) {
    final index = _bookings.indexWhere((b) => b.id == bookingId);
    if (index != -1) {
      _bookings[index] = _bookings[index].copyWith(status: newStatus);
      notifyListeners();
    }
  }

  void handleAddReview({
    required String restaurantId,
    required String bookingId,
    required int rating,
    required String comment,
  }) {}

  void updateProfile({
    required String name,
    required String email,
    required String password,
    required String profileImage,
  }) {}
}

extension ListFilter<E> on List<E> {
  List<E> filter(bool Function(E element) test) {
    final List<E> results = [];
    for (var element in this) {
      if (test(element)) {
        results.add(element);
      }
    }
    return results;
  }
}
