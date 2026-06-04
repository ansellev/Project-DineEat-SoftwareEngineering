import 'package:flutter/material.dart';
import '../provider.dart';
import '../app_state.dart';
import '../models.dart';
import 'details_screen.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback onNavigateToBookings;

  const HomeScreen({Key? key, required this.onNavigateToBookings}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _searchQuery = '';
  String _selectedCategory = 'Semua';

  final List<String> _categories = [
    'Semua',
    'Nusantara',
    'Asian Modern',
    'Indo-Western & Grill',
    'Japanese',
    'Western',
    'Indian & Turkish'
  ];

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final user = appState.currentUser;
    final allResto = appState.restaurants;

    // Filter restaurants by search and categories
    final filteredRestos = allResto.filter((r) {
      final matchesSearch = r.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          r.address.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          r.category.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCat = _selectedCategory == 'Semua' ||
          r.category.toLowerCase().contains(_selectedCategory.toLowerCase());
      return matchesSearch && matchesCat;
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Selamat Datang, 👋',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        user?.fullName ?? 'Pelanggan Setia',
                        style: const TextStyle(
                          color: Color(0xFF1E293B),
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                  Stack(
                    children: [
                      IconButton(
                        onPressed: () => _showNotificationsDialog(context),
                        icon: const Icon(Icons.notifications_none_outlined, size: 28, color: Color(0xFF1E293B)),
                      ),
                      if (appState.unreadNotificationsCount > 0)
                        Positioned(
                          right: 8,
                          top: 8,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Color(0xFF1BAC4B),
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              '${appState.unreadNotificationsCount}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Hero Search card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1BAC4B), Color(0xFF158C3A)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Pesan Meja Resto Istimewa',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Hindari antrean panjang & pesan makanan favorit Anda sebelum tiba di tempat.',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: TextField(
                        onChanged: (val) {
                          setState(() {
                            _searchQuery = val;
                          });
                        },
                        decoration: InputDecoration(
                          hintText: 'Cari kuliner, nama restoran, atau menu...',
                          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13, fontWeight: FontWeight.w500),
                          prefixIcon: const Icon(Icons.search, color: Color(0xFF1BAC4B)),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Horizontal Category Chips
              const Text(
                'Kategori Restoran',
                style: TextStyle(
                  color: Color(0xFF1E293B),
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 40,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    final cat = _categories[index];
                    final isSelected = _selectedCategory == cat;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedCategory = cat;
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFF1BAC4B) : Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isSelected ? Colors.transparent : const Color(0xFFE2E8F0),
                            width: 1.2,
                          ),
                        ),
                        child: Text(
                          cat,
                          style: TextStyle(
                            color: isSelected ? Colors.white : const Color(0xFF475569),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 24),

              // Restaurant List Title
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Restorasi Pilihan Terbaik (${filteredRestos.length})',
                    style: const TextStyle(
                      color: Color(0xFF1E293B),
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  if (_searchQuery.isNotEmpty || _selectedCategory != 'Semua')
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _searchQuery = '';
                          _selectedCategory = 'Semua';
                        });
                      },
                      child: const Text(
                        'Reset Filter',
                        style: TextStyle(
                          color: Color(0xFF1BAC4B),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),

              // Restaurant Listing Builder
              if (filteredRestos.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Column(
                    children: [
                      const Icon(Icons.restaurant_menu_outlined, size: 48, color: Colors.grey),
                      const SizedBox(height: 12),
                      Text(
                        'Tidak ada restoran ditemukan',
                        style: TextStyle(color: Colors.grey[500], fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Coba cari kata kunci lainnya atau ubah filter kategori.',
                        style: TextStyle(color: Colors.grey[400], fontSize: 11),
                        textAlign: TextAlign.center,
                      )
                    ],
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filteredRestos.length,
                  itemBuilder: (context, index) {
                    final r = filteredRestos[index];
                    return _buildRestaurantCard(context, r);
                  },
                ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRestaurantCard(BuildContext context, Restaurant r) {
    final isCrowded = r.occupancyPercent >= 80;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailsScreen(restaurant: r),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 3),
            )
          ],
          border: Border.all(color: const Color(0xFFEDF2F7), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Restaurant Hero Banner image
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  child: Image.network(
                    r.image,
                    height: 160,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star, color: Color(0xFFFFB000), size: 14),
                        const SizedBox(width: 4),
                        Text(
                          r.averageRating.toStringAsFixed(1),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          ' (${r.totalReviews})',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      r.category,
                      style: const TextStyle(
                        color: Color(0xFF1BAC4B),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                )
              ],
            ),

            // Content Body
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          r.name,
                          style: const TextStyle(
                            color: Color(0xFF1E293B),
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        r.priceRange,
                        style: const TextStyle(
                          color: Color(0xFF1BAC4B),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 12, color: Colors.indigo[300]),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          r.address,
                          style: TextStyle(color: Colors.grey[500], fontSize: 11.5, fontWeight: FontWeight.w500),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${r.distance} km',
                        style: TextStyle(color: Colors.green[600], fontSize: 11, fontWeight: FontWeight.bold),
                      )
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Occupancy meter & Estimated Waiting indicators
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                 Row(
                                  children: [
                                Text(
                                  'Keterisian Meja',
                                  style: TextStyle(color: Colors.grey[500], fontSize: 10, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(width: 4),
                                    Text(
                                      '• ${r.emptyTablesCount ?? (r.totalTables - (r.occupancyPercent * r.totalTables / 100).round())} Kosong',
                                      style: const TextStyle(color: Color(0xFF1BAC4B), fontSize: 10, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),

                                Text(
                                  '${r.occupancyPercent}%',
                                  style: TextStyle(
                                    color: isCrowded ? Colors.red[600] : const Color(0xFF1BAC4B),
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: LinearProgressIndicator(
                                value: r.occupancyPercent / 100,
                                minHeight: 6,
                                backgroundColor: const Color(0xFFEDF2F7),
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  isCrowded ? const Color(0xFFEF4444) : const Color(0xFF1BAC4B),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 24),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Estimasi Antrean',
                            style: TextStyle(color: Colors.grey[500], fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            r.estimatedWaitMinutes == 0 ? 'Langsung Masuk' : '${r.estimatedWaitMinutes} Menit',
                            style: TextStyle(
                              color: r.estimatedWaitMinutes == 0 ? const Color(0xFF1BAC4B) : Colors.amber[800],
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      )
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showNotificationsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        final state = Provider.of<AppState>(context, listen: true);
        final notifs = state.notifications;

        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Notifikasi',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
              ),
              if (state.unreadNotificationsCount > 0)
                TextButton(
                  onPressed: () {
                    state.markAllNotificationsAsRead();
                  },
                  child: const Text('Baca Semua', style: TextStyle(color: Color(0xFF1BAC4B), fontSize: 11, fontWeight: FontWeight.bold)),
                )
            ],
          ),
          content: notifs.isEmpty
              ? Container(
                  height: 120,
                  alignment: Alignment.center,
                  child: Text('Belum ada notifikasi baru', style: TextStyle(color: Colors.grey[400], fontSize: 12)),
                )
              : SizedBox(
                  width: double.maxFinite,
                  height: 300,
                  child: ListView.builder(
                    itemCount: notifs.length,
                    itemBuilder: (context, idx) {
                      final n = notifs[idx];
                      return Container(
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                        decoration: BoxDecoration(
                        border: Border(bottom: BorderSide(color: Colors.grey[100]!)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: n.isRead ? Colors.grey[100] : const Color(0xFFEFFDF4),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                n.type == NotificationType.booking ? Icons.calendar_today : Icons.restaurant_menu,
                                color: n.isRead ? Colors.grey[500] : const Color(0xFF1BAC4B),
                                size: 14,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    n.title,
                                    style: TextStyle(
                                      color: n.isRead ? const Color(0xFF475569) : Colors.black,
                                      fontSize: 11,
                                      fontWeight: n.isRead ? FontWeight.w600 : FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    n.body,
                                    style: TextStyle(color: Colors.grey[500], fontSize: 10),
                                  ),
                                ],
                              ),
                            ),
                            if (!n.isRead)
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF1BAC4B),
                                  shape: BoxShape.circle,
                                ),
                              )
                          ],
                        ),
                      );
                    },
                  ),
                ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Tutup', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
            )
          ],
        );
      },
    );
  }
}
