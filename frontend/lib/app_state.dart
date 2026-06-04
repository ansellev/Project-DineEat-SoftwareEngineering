import 'dart:math';
import 'package:flutter/foundation.dart';
import '../models.dart';

class AppState extends ChangeNotifier {
  // 1. Current user profile session state
  User? _currentUser = User(
    id: 'user-007',
    fullName: 'Anselma Putri',
    email: 'ansel1804@gmail.com',
    isLoggedIn: true,
    profileImage: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&q=80&w=150',
  );

  User? get currentUser => _currentUser;

  // 2. Active restaurants local list with dynamic rating computation
  final List<Restaurant> _restaurants = [
    Restaurant(
      id: 'ambrosia',
      name: 'Ambrosia Hotel & Restaurant',
      address: 'Jalan MH Thamrin No. 5, Jakarta Pusat',
      category: 'Indo-Western & Grill',
      distance: 1.2,
      priceRange: '\$\$',
      image: 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?auto=format&fit=crop&q=80&w=600',
      averageRating: 4.8,
      totalReviews: 240,
      occupancyPercent: 88,
      totalTables: 25,
      estimatedWaitMinutes: 15,
      phone: '+62-812-4040-5050',
      operatingHours: '10:00 - 22:00',
      description: 'Restoran dengan perpaduan cita rasa barat dan bumbu rempah timur yang autentik. Menyajikan hidangan porsi melimpah dengan ruang makan premium ber-AC, pemandangan kota yang menawan, serta pertunjukan live music akustik setiap akhir pekan.',
      availableTables: {2: 2, 4: 1, 6: 0, 8: 1},
      reviews: [
        Review(
          id: 'rev1',
          userName: 'Sadek Hossen Rony',
          rating: 5,
          comment: 'Tempatnya sangat nyaman dan makanannya luar biasa lezat! Pelayanan ramah.',
          date: '2026-05-28',
        ),
        Review(
          id: 'rev2',
          userName: 'Anselma Putri',
          rating: 4,
          comment: 'Pilihan buffet-nya variatif, sangat merekomendasikan untuk reservasi sebelum ke sini.',
          date: '2026-05-15',
        )
      ],
      menu: [
        MenuItem(
          id: 'amb-m1',
          name: 'Chicken Biryani Premium',
          price: 75000,
          category: FoodCategory.makananUtama,
          image: 'https://images.unsplash.com/photo-1563379091339-03b21ab4a4f8?auto=format&fit=crop&q=80&w=250',
          description: 'Nasi bumbu rempah premium dengan potongan daging ayam empuk, disajikan dengan acar dan kerupuk.',
        ),
        MenuItem(
          id: 'amb-m2',
          name: 'Sauce Tonkatsu Crispy',
          price: 85000,
          category: FoodCategory.makananUtama,
          image: 'https://images.unsplash.com/photo-1591814468924-caf88d1232e1?auto=format&fit=crop&q=80&w=250',
          description: 'Daging katsu garing disiram saus gurih khas dengan salad segar pendamping.',
        ),
        MenuItem(
          id: 'amb-m3',
          name: 'Spaghetti Carbonara Creamy',
          price: 68000,
          category: FoodCategory.makananUtama,
          image: 'https://images.unsplash.com/photo-1612874742237-6526221588e3?auto=format&fit=crop&q=80&w=250',
          description: 'Pasta spaghetti saus krim susu padat dangan taburan daging asap dan oregano segar.',
        ),
        MenuItem(
          id: 'amb-m4',
          name: 'Iced Matcha Latte',
          price: 32000,
          category: FoodCategory.minuman,
          image: 'https://images.unsplash.com/photo-1536256263959-770b48d82b0a?auto=format&fit=crop&q=80&w=250',
          description: 'Teh matcha Kyoto murni yang disajikan dingin dengan susu segar lembut.',
        ),
        MenuItem(
          id: 'amb-m5',
          name: 'Fresh Mango Mint Juice',
          price: 28000,
          category: FoodCategory.minuman,
          image: 'https://images.unsplash.com/photo-1534353436294-0dbd4bdac845?auto=format&fit=crop&q=80&w=250',
          description: 'Jus mangga arumanis segar dipadukan dengan sensasi daun mint menyegarkan.',
        ),
        MenuItem(
          id: 'amb-m6',
          name: 'Warm Choco Lava Cake',
          price: 40000,
          category: FoodCategory.pencuciMulut,
          image: 'https://images.unsplash.com/photo-1606313564200-e75d5e30476c?auto=format&fit=crop&q=80&w=250',
          description: 'Kue cokelat hangat meleleh di dalam dengan satu skup es krim vanila lembut.',
        )
      ],
    ),
    Restaurant(
      id: 'tava',
      name: 'Tava Restaurant',
      address: 'Jalan Iskandar Muda No.35, Jakarta Selatan',
      category: 'Asian, Indian & Turkish',
      distance: 2.5,
      priceRange: '\$\$\$',
      image: 'https://images.unsplash.com/photo-1544025162-d76694265947?auto=format&fit=crop&q=80&w=600',
      averageRating: 4.6,
      totalReviews: 189,
      occupancyPercent: 40,
      totalTables: 20,
      estimatedWaitMinutes: 0,
      phone: '+62-812-9988-7766',
      operatingHours: '10:00 AM - 12:00 PM',
      description: 'Menyajikan hidangan premium khas Asia Selatan dan Turki dengan rempah-rempah yang melimpah dan resep turun-temurun. Nikmati suasana interior bergaya maroko yang estetik dan kehangatan roti Naan segar langsung dari oven tandoor di depan Anda.',
      availableTables: {2: 4, 4: 5, 6: 2, 8: 2},
      reviews: [
        Review(
          id: 'rev3',
          userName: 'Ahmad Faiz',
          rating: 4,
          comment: 'Rasa kari kambingnya autentik sekali. Desain ruangannya juga sangat estetik.',
          date: '2026-05-24',
        )
      ],
      menu: [
        MenuItem(
          id: 'tav-m1',
          name: 'Lamb Curry & Garlic Naan',
          price: 110000,
          category: FoodCategory.makananUtama,
          image: 'https://plus.unsplash.com/premium_photo-1723708871094-2c02cf5f5394?q=80&w=1964&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
          description: 'Kari domba rempah pekat disajikan hangat dengan roti naan mentega bawang putih.',
        ),
        MenuItem(
          id: 'tav-m2',
          name: 'Chicken Tandoori Platter',
          price: 95000,
          category: FoodCategory.makananUtama,
          image: 'https://plus.unsplash.com/premium_photo-1661419883163-bb4df1c10109?q=80&w=687&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
          description: 'Ayam panggang oven tandoor dengan bumbu yogurt dan jeruk nipis pedas khas.',
        ),
        MenuItem(
          id: 'tav-m3',
          name: 'Syrian Baklava Sweet',
          price: 45000,
          category: FoodCategory.pencuciMulut,
          image: 'https://images.unsplash.com/photo-1519420573924-65fcd45245f8?auto=format&fit=crop&q=80&w=250',
          description: 'Lapisan pastry renyah madu dengan taburan kacang pistacio cincang panggang.',
        ),
        MenuItem(
          id: 'tav-m4',
          name: 'Kopi Kapulaga Arabika',
          price: 35000,
          category: FoodCategory.minuman,
          image: 'https://images.unsplash.com/photo-1514432324607-a09d9b4aefdd?auto=format&fit=crop&q=80&w=250',
          description: 'Espresso arabika pekat beraroma rempah kapulaga murni disajikan tradisional.',
        )
      ],
    ),
    Restaurant(
      id: 'haatkhola',
      name: 'Haatkhola Dine',
      address: 'Jalan Fatmawati No. 33, Jakarta Pusat',
      category: 'Indonesian Tradisional & Nusantara',
      distance: 3.1,
      priceRange: '\$',
      image: 'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?auto=format&fit=crop&q=80&w=600',
      averageRating: 4.5,
      totalReviews: 98,
      occupancyPercent: 95,
      totalTables: 15,
      estimatedWaitMinutes: 25,
      phone: '+62-811-3322-1100',
      operatingHours: '09:00 - 21:00',
      description: 'Surga kuliner Nusantara autentik dengan spesialisasi hidangan tradisional khas Jawa dan Sunda. Bahan-bahan segar lokal berpadu dengan bumbu racikan ulek legendaris, disajikan dalam suasana joglo kayu klasik yang asri dan sejuk.',
      availableTables: {2: 1, 4: 0, 6: 0, 8: 0},
      reviews: [
        Review(
          id: 'rev4',
          userName: 'Zack Hussain',
          rating: 5,
          comment: 'Harga sangat bersahabat, porsi melimpah! Favorit keluarga kami sejak lama.',
          date: '2026-05-19',
        )
      ],
      menu: [
        MenuItem(
          id: 'hat-m1',
          name: 'Sate Ayam Madura Legendaris',
          price: 38000,
          category: FoodCategory.makananUtama,
          image: 'https://images.unsplash.com/photo-1529042410759-befb1204b468?auto=format&fit=crop&q=80&w=250',
          description: '10 tusuk sate ayam panggang arang legendaris disiram dengan bumbu kacang gurih manis.',
        ),
        MenuItem(
          id: 'hat-m2',
          name: 'Nasi Goreng Spesial Haatkhola',
          price: 32000,
          category: FoodCategory.makananUtama,
          image: 'https://images.unsplash.com/photo-1512058564366-18510be2db19?auto=format&fit=crop&q=80&w=250',
          description: 'Nasi goreng bumbu jawa dengan pelengkap ayam suwir, telur mata sapi, telur dadar iris, serta kerupuk.',
        ),
        MenuItem(
          id: 'hat-m3',
          name: 'Es Kelapa Muda Gula Aren',
          price: 18000,
          category: FoodCategory.minuman,
          image: 'https://images.unsplash.com/photo-1540189549336-e6e99c3679fe?auto=format&fit=crop&q=80&w=250',
          description: 'Kelapa muda serut dengan es serutan, gula aren murni, dan siraman kental manis.',
        )
      ],
    ),
    Restaurant(
      id: 'zaman',
      name: 'Hotel Zaman Restaurant',
      address: 'Jalan Kemanggisan No.19, Jakarta Barat',
      category: 'Nusantara & Asian Fusion',
      distance: 4.8,
      priceRange: '\$\$',
      image: 'https://images.unsplash.com/photo-1552566626-52f8b828add9?auto=format&fit=crop&q=80&w=600',
      averageRating: 4.2,
      totalReviews: 120,
      occupancyPercent: 60,
      totalTables: 30,
      estimatedWaitMinutes: 10,
      phone: '+62-813-8899-7711',
      operatingHours: '08:00 - 22:00',
      description: 'Menyajikan kekayaan kuliner khas Indonesia barat dengan rasa otentik yang pekat dan porsi yang cocok untuk berkumpul bersama keluarga besar. Nikmati rendang legendaris dan ayam kalasan hangat dalam ruangan berkapasitas besar.',
      availableTables: {2: 4, 4: 3, 6: 1, 8: 1},
      reviews: [
        Review(
          id: 'rev5',
          userName: 'Dedi Kurniawan',
          rating: 4,
          comment: 'Sangat cocok untuk rombongan keluarga besar. Meja luas dan bersih.',
          date: '2026-05-10',
        )
      ],
      menu: [
        MenuItem(
          id: 'zam-m1',
          name: 'Rendang Daging Sapi Minang',
          price: 52000,
          category: FoodCategory.makananUtama,
          image: 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?auto=format&fit=crop&q=80&w=250',
          description: 'Daging sapi yang dimasak perlahan bersama santan kelapa dan rempah asli Minang selama berjam-jam.',
        ),
        MenuItem(
          id: 'zam-m2',
          name: 'Ayam Goreng Kalasan Gurih',
          price: 45000,
          category: FoodCategory.makananUtama,
          image: 'https://images.unsplash.com/photo-1732185269471-b62b52ca46f9?q=80&w=1170&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
          description: 'Ayam kampung berbumbu tradisional, digoreng garing di luar dengan sensasi kremes renyah bumbu ungkep.',
        ),
        MenuItem(
          id: 'zam-m3',
          name: 'Aneka Gorengan Pisang Keju',
          price: 24000,
          category: FoodCategory.camilan,
          image: 'https://images.unsplash.com/photo-1579372786545-d24232daf58c?auto=format&fit=crop&q=80&w=250',
          description: 'Pisang tanduk balur tepung renyah dengan taburan cokelat parut kasar dan keju cheddar tebal.',
        )
      ],
    )
  ];

  List<Restaurant> get restaurants{
    return _restaurants.map((resto) {
      // Find active user bookings for this restaurant (not cancelled)
      final activeUserBookings = _bookings.where((b) => 
        b.restaurantId == resto.id && b.status != BookingStatus.dibatalkan
      ).toList();
      final activeUserBookingsCount = activeUserBookings.length;

      // Estimate baseline occupied tables
      final baselineOccupied = (resto.occupancyPercent * resto.totalTables) ~/ 100;

      // Total occupied tables
      final totalOccupied = min(resto.totalTables, baselineOccupied + activeUserBookingsCount);

      // Re-calculate the dynamic occupancy percent
      final dynamicOccupancy = ((totalOccupied / resto.totalTables) * 100).round();

      // Remaining empty tables count
      final emptyTables = max(0, resto.totalTables - totalOccupied);

      // Adjust availableTables capacity dynamically to be consistent
      Map<int, int> dynamicAvailableTables = Map<int, int>.from(resto.availableTables);
      if (activeUserBookingsCount > 0) {
        final totalAvailableFromGrid = resto.availableTables.values.fold<int>(0, (sum, val) => sum + val);
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

  // 3. User Booking history state list
  final List<Booking> _bookings = [
    Booking(
      id: 'book-h1',
      restaurantId: 'ambrosia',
      restaurantName: 'Ambrosia Hotel & Restaurant',
      restaurantAddress: 'Jalan MH Thamrin No. 5, Jakarta Pusat',
      restaurantImage: 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?auto=format&fit=crop&q=80&w=600',
      date: '2026-05-24',
      timeSlot: '19:00',
      partySize: 4,
      tableId: 'T-4A',
      preOrderedFood: [
        PreOrderedFoodItem(menuItemId: 'amb-m1', name: 'Chicken Biryani Premium', quantity: 2, price: 75000),
        PreOrderedFoodItem(menuItemId: 'amb-m5', name: 'Fresh Mango Mint Juice', quantity: 2, price: 28000)
      ],
      totalPayment: 216000,
      status: BookingStatus.selesai,
      createdAt: '2026-05-23T14:20:00Z',
      reviewId: 'rev1',
      reviewRating: 5,
      reviewComment: 'Makanannya lezat sekali! Tempatnya sangat bersih dan pelayanannya cepat.',
    ),
    Booking(
      id: 'book-h2',
      restaurantId: 'tava',
      restaurantName: 'Tava Restaurant',
      restaurantAddress: 'Jalan Iskandar Muda No.35, Jakarta Selatan',
      restaurantImage: 'https://images.unsplash.com/photo-1544025162-d76694265947?auto=format&fit=crop&q=80&w=600',
      date: '2026-05-18',
      timeSlot: '20:00',
      partySize: 2,
      tableId: 'T-2B',
      preOrderedFood: [
        PreOrderedFoodItem(menuItemId: 'tav-m1', name: 'Lamb Curry & Garlic Naan', quantity: 1, price: 110000),
        PreOrderedFoodItem(menuItemId: 'tav-m4', name: 'Kopi Kapulaga Arabika', quantity: 2, price: 35000)
      ],
      totalPayment: 180000,
      status: BookingStatus.selesai,
      createdAt: '2026-05-17T09:12:00Z',
    ),
    Booking(
      id: 'book-h3',
      restaurantId: 'haatkhola',
      restaurantName: 'Haatkhola Dine',
      restaurantAddress: 'Jalan Fatmawati No. 33, Jakarta Pusat',
      restaurantImage: 'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?auto=format&fit=crop&q=80&w=600',
      date: '2026-05-12',
      timeSlot: '13:00',
      partySize: 6,
      tableId: 'T-6B',
      preOrderedFood: [
        PreOrderedFoodItem(menuItemId: 'hat-m1', name: 'Sate Ayam Madura Legendaris', quantity: 3, price: 38000),
        PreOrderedFoodItem(menuItemId: 'hat-m3', name: 'Es Kelapa Muda Gula Aren', quantity: 4, price: 18000)
      ],
      totalPayment: 186000,
      status: BookingStatus.selesai,
      createdAt: '2026-05-11T16:45:00Z',
      reviewId: 'rev4',
      reviewRating: 4,
      reviewComment: 'Suasana restoran sangat nyaman untuk keluarga. Sate ayamnya gurih manis maknyus.',
    )
  ];

  List<Booking> get bookings => _bookings;

  // 4. Simulated application push notifications
  final List<AppNotification> _notifications = [
    AppNotification(
      id: 'notif-1',
      title: 'Reservasi Sukses Terverifikasi!',
      body: 'Booking Anda di Ambrosia Hotel & Restaurant untuk 4 orang telah sukses disetujui.',
      timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
      isRead: false,
      type: NotificationType.booking,
    ),
    AppNotification(
      id: 'notif-2',
      title: 'Rekomendasi Kuliner Akhir Pekan',
      body: 'Diskon pre-order hingga 15% di Tava Restaurant dengan hidangan Lamb Curry and Roti Naan.',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      isRead: true,
      type: NotificationType.food,
    )
  ];

  List<AppNotification> get notifications => _notifications;
  int get unreadNotificationsCount => _notifications.filter((n) => !n.isRead).length;

  // Add a new system notification helper
  void triggerNotification(String title, String body, NotificationType type) {
    _notifications.insert(
      0,
      AppNotification(
        id: 'notif-rnd-${Random().nextInt(999999)}',
        title: title,
        body: body,
        timestamp: DateTime.now(),
        isRead: false,
        type: type,
      ),
    );
    notifyListeners();
  }

  void markAllNotificationsAsRead() {
    for (int i = 0; i < _notifications.length; i++) {
      _notifications[i] = _notifications[i].copyWith(isRead: true);
    }
    notifyListeners();
  }

  // Create new dining table booking inside the list
  void createBooking({
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
  }) {
    final String bookingId = 'book-gen-${100 + _bookings.length}';
    final Booking b = Booking(
      id: bookingId,
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
      status: BookingStatus.menunggu,
      createdAt: DateTime.now().toIso8601String(),
    );
    _bookings.insert(0, b);

    // Trigger local push notification
    triggerNotification(
      'Reservasi Berhasil Diajukan',
      'Meja $tableId berhasil dipesan di $restaurantName pada tanggal $date waktu $timeSlot.',
      NotificationType.booking,
    );

    notifyListeners();
  }

  // Update specified Booking Status
  void cancelBooking(String bookingId) {
    final index = _bookings.indexWhere((b) => b.id == bookingId);
    if (index != -1) {
      _bookings[index] = _bookings[index].copyWith(status: BookingStatus.dibatalkan);
      triggerNotification(
        'Reservasi Dibatalkan',
        'Reservasi di ${_bookings[index].restaurantName} dibatalkan dengan sukses.',
        NotificationType.alert,
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

  // Submit direct new reviews/ratings to a restaurant
  // MUST match user request: user ONLY can submit review if they have completed a booking
  void handleAddReview({
    required String restaurantId,
    required String bookingId,
    required int rating,
    required String comment,
  }) {
    final reviewId = 'rev-done-${Random().nextInt(99999)}';
    final newReview = Review(
      id: reviewId,
      userName: _currentUser?.fullName ?? 'Pelanggan DineEat',
      rating: rating,
      comment: comment,
      date: DateTime.now().toString().split(' ')[0],
    );

    // Append to corresponding restaurant reviews
    final restoIndex = _restaurants.indexWhere((r) => r.id == restaurantId);
    if (restoIndex != -1) {
      final updatedReviews = List<Review>.from(_restaurants[restoIndex].reviews)..insert(0, newReview);
      final totalStars = updatedReviews.map((r) => r.rating).reduce((value, element) => value + element);
      final double newAvg = double.parse((totalStars / updatedReviews.length).toStringAsFixed(1));

      _restaurants[restoIndex] = _restaurants[restoIndex].copyWith(
        reviews: updatedReviews,
        averageRating: newAvg,
        totalReviews: updatedReviews.length,
      );
    }

    // Mark corresponding booking with review details to check-off
    if (bookingId.isNotEmpty) {
      final index = _bookings.indexWhere((b) => b.id == bookingId);
      if (index != -1) {
        _bookings[index] = _bookings[index].copyWith(
          reviewId: reviewId,
          reviewRating: rating,
          reviewComment: comment,
        );
      }
    }

    notifyListeners();
  }

  // User Authentication Simulation
  final List<User> _users = [
    User(
      id: 'user-007',
      fullName: 'Anselma Putri',
      email: 'ansel1804@gmail.com',
      isLoggedIn: true,
      profileImage: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&q=80&w=150',
      password: 'password123',
    ),
  ];

  bool loginUser(String email, String password) {
    final index = _users.indexWhere((u) => u.email.toLowerCase() == email.toLowerCase() && u.password == password);
    if (index != -1) {
      _users[index] = _users[index].copyWith(isLoggedIn: true);
      _currentUser = _users[index];
      notifyListeners();
      return true;
    }
    return false;
  }

  bool registerUser(String name, String email, String password) {
    if (_users.any((u) => u.email.toLowerCase() == email.toLowerCase())) {
      return false; // Email already registered
    }
    final newUser = User(
      id: 'user-${Random().nextInt(99999)}',
      fullName: name,
      email: email,
      isLoggedIn: true,
      profileImage: 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?auto=format&fit=crop&q=80&w=150',
      password: password,
    );
    _users.add(newUser);
    _currentUser = newUser;


    notifyListeners();
    return true;
  }

  void updateProfile({
    required String name,
    required String email,
    required String password,
    required String profileImage,
  }) {
    if (_currentUser != null) {
      final updated = _currentUser!.copyWith(
        fullName: name,
        email: email,
        password: password,
        profileImage: profileImage,
      );
      _currentUser = updated;
      
      // Also update in registered user list
      final index = _users.indexWhere((u) => u.id == _currentUser!.id);
      if (index != -1) {
        _users[index] = updated;
      }
      notifyListeners();
    }
  }


  void logout() {
    if (_currentUser != null) {
      final index = _users.indexWhere((u) => u.id == _currentUser!.id);
      if (index != -1) {
        _users[index] = _users[index].copyWith(isLoggedIn: false);
      }
    }
    _currentUser = null;
    notifyListeners();
  }
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
