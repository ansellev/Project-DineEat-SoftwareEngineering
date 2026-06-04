import 'package:flutter/material.dart';
import '../provider.dart';
import '../models.dart';
import '../app_state.dart';
import 'payment_screen.dart';
import 'dart:math';

class DetailsScreen extends StatefulWidget {
  final Restaurant restaurant;

  const DetailsScreen({Key? key, required this.restaurant}) : super(key: key);

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Meal pre-order cart map state (menuItemId -> quantity)
  final Map<String, int> _mealCart = {};

  // Form Booking parameters
  int _partySize = 4;
  String _selectedDate = '';
  String _selectedTimeSlot = '19:00';
  String _selectedTableId = 'T-4A'; // default initial selection

  final List<String> _timeSlots = [
    '12:00', '13:00', '14:00', '15:00', '16:00', '17:00', '18:00', '19:00', '20:00', '21:00', '22:00'
  ];

  // Direct Review & Rating Submit Form state
  bool _showReviewFormCompletely = false;
  int _selectedRatingStarForForm = 5;
  final TextEditingController _commentForFormController = TextEditingController();

  final List<Map<String, dynamic>> _simulatedTables = [
    {'id': 'T-2A', 'name': 'M-1', 'capacity': 2, 'isOccupied': false},
    {'id': 'T-2B', 'name': 'M-2', 'capacity': 2, 'isOccupied': false},
    {'id': 'T-4A', 'name': 'M-3', 'capacity': 4, 'isOccupied': false},
    {'id': 'T-4B', 'name': 'M-4', 'capacity': 4, 'isOccupied': false},
    {'id': 'T-4C', 'name': 'M-5', 'capacity': 4, 'isOccupied': true}, // Occupied
    {'id': 'T-6A', 'name': 'M-6', 'capacity': 6, 'isOccupied': false},
    {'id': 'T-6B', 'name': 'M-7', 'capacity': 6, 'isOccupied': false},
    {'id': 'T-8A', 'name': 'M-8', 'capacity': 8, 'isOccupied': false},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

    // Initialize date to today dynamically formatted as YYYY-MM-DD
    final now = DateTime.now();
    _selectedDate = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _tabController.dispose();
    _commentForFormController.dispose();
    super.dispose();
  }

  List<Map<String, String>> _getDateStrip() {
    final List<Map<String, String>> days = [];
    final List<String> idDays = ['Minggu', 'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu'];
    final List<String> idMonths = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];

    final now = DateTime.now();
    for (int i = 0; i < 5; i++) {
      final d = now.add(Duration(days: i));
      final String dayName = i == 0 ? 'Hari Ini' : (i == 1 ? 'Besok' : idDays[d.weekday % 7]);
      final String dayNum = d.day.toString().padLeft(2, '0');
      final String monthName = idMonths[d.month - 1];
      final String dateString = '${d.year}-${d.month.toString().padLeft(2, '0')}-${dayNum}';
      
      days.add({
        'name': dayName,
        'num': dayNum,
        'month': monthName,
        'value': dateString,
      });
    }
    return days;
  }

  Widget _buildOccupancyBadge(int pct) {
    Color bgColor = const Color(0xFFEFFDF4);
    Color textColor = const Color(0xFF1BAC4B);
    Color borderColor = const Color(0xFFD1FAE5);
    String label = 'Senggang 🍃';

    if (pct >= 80) {
      bgColor = const Color(0xFFFEF2F2);
      textColor = const Color(0xFFEF4444);
      borderColor = const Color(0xFFFEE2E2);
      label = 'Sangat Ramai 🔥';
    } else if (pct >= 55) {
      bgColor = const Color(0xFFFFFBEB);
      textColor = const Color(0xFFD97706);
      borderColor = const Color(0xFFFEF3C7);
      label = 'Cukup Ramai 👥';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor),
      ),
      child: Text(
        label,
        style: TextStyle(color: textColor, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }

  int _calculateSubtotal() {
    int sub = 0;
    _mealCart.forEach((itemId, quantity) {
      final item = widget.restaurant.menu.firstWhere((m) => m.id == itemId);
      sub += item.price * quantity;
    });
    return sub;
  }

  int _calculateTotalCartItemsCount() {
    int count = 0;
    _mealCart.forEach((_, q) => count += q);
    return count;
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    
    // Find the reactive state version of this restaurant to get live reviews
    final liveResto = appState.restaurants.firstWhere((r) => r.id == widget.restaurant.id, orElse: () => widget.restaurant);
    
    // Check if the user has compiled and completed at least one booking for security review locks
    final hasCompletedBooking = appState.bookings.any(
      (b) => b.restaurantId == widget.restaurant.id && b.status == BookingStatus.selesai
    );

    // Calculate dynamic table counts based on custom mock tables and active user bookings
    final int total = liveResto.totalTables;
    final int emptyCount = liveResto.emptyTablesCount ?? (liveResto.totalTables - (liveResto.occupancyPercent * liveResto.totalTables / 100).round());
    final int occupiedCount = total - emptyCount;

    // Find active user bookings for this restaurant and slot
    final userBookings = appState.bookings.where(
      (b) => b.restaurantId == liveResto.id &&
             b.status != BookingStatus.dibatalkan &&
             b.date == _selectedDate &&
             b.timeSlot == _selectedTimeSlot
    ).toList();
    final List<Map<String, dynamic>> simulatedTables = [];
    for (int i = 0; i < total; i++) {
      int capacity = 4;
      if (i < total * 0.3) {
        capacity = 2; // 30% are 2 Pax
      } else if (i < total * 0.7) {
        capacity = 4; // 40% are 4 Pax
      } else if (i < total * 0.9) {
        capacity = 6; // 20% are 6 Pax
      } else {
        capacity = 8; // 10% are 8 Pax
      }

      final String tabId = 'T-$capacity${String.fromCharCode(65 + (i % 5))}-${i + 1}';
      final String tabName = 'M-${i + 1}';

      simulatedTables.add({
        'id': tabId,
        'name': tabName,
        'capacity': capacity,
        'isOccupied': false,
      });
    }

    int currentOccupiedCount = 0;

    // 1st pass: set user bookings as occupied
    for (var tab in simulatedTables) {
      final String tabId = tab['id'] as String;
      final isBooked = userBookings.any((b) => b.tableId == tabId);
      if (isBooked) {
        tab['isOccupied'] = true;
        currentOccupiedCount++;
      }
    }

    // 2nd pass: distribute occupied tables deterministically
    final int targetOccupied = min(total, occupiedCount);
    for (int i = 0; i < total && currentOccupiedCount < targetOccupied; i++) {
      final int idx = (i * 7) % total;
      if (simulatedTables[idx]['isOccupied'] == false) {
        simulatedTables[idx]['isOccupied'] = true;
        currentOccupiedCount++;
      }
    }
     // Ensure _selectedTableId is valid and not occupied
    bool selectedIsValid = simulatedTables.any((t) => t['id'] == _selectedTableId && t['isOccupied'] == false);
    if (!selectedIsValid) {
      final firstMatchingEmpty = simulatedTables.firstWhere(
        (t) => (t['isOccupied'] == false) && (t['capacity'] as int) >= _partySize,
        orElse: () => simulatedTables.firstWhere(
          (t) => t['isOccupied'] == false,
          orElse: () => simulatedTables.first,
        ),
      );
      _selectedTableId = firstMatchingEmpty['id'] as String;
    }
    // Calculate dynamic table counts
    int emptyTablesCountSimulated = 0;
    int occupiedTablesCountSimulated = 0;
    for (final tab in simulatedTables) {
      if (tab['isOccupied'] as bool) {
        occupiedTablesCountSimulated++;
      } else {
        emptyTablesCountSimulated++;
      }
    }
    final int dynamicOccupancyPercent =
    total > 0
        ? ((occupiedTablesCountSimulated / total) * 100).round()
        : 0;
        
    final List<Map<String, dynamic>> _simulatedTables = simulatedTables;

    int subtotal = _calculateSubtotal();
    int reservationFee = 50000;
    int totalPrice = subtotal + reservationFee;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(liveResto.name, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: Colors.black)),
        elevation: 0.5,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Highlight Banner 
                Image.network(
                  liveResto.image,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),

                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Restaurant title description & quick stats
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              liveResto.name,
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF1E293B)),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(color: const Color(0xFFEFFDF4), borderRadius: BorderRadius.circular(10)),
                            child: Text(liveResto.category, style: const TextStyle(color: Color(0xFF1BAC4B), fontSize: 11, fontWeight: FontWeight.bold)),
                          )
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.location_on, size: 14, color: Colors.grey[500]),
                          const SizedBox(width: 4),
                          Expanded(child: Text(liveResto.address, style: TextStyle(color: Colors.grey[600], fontSize: 12, fontWeight: FontWeight.w500))),
                        ],
                      ),
                      const SizedBox(height: 12),
                      
                      // Contact phone and rating metrics
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8F9FA),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFEDF2F7)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('📞 Telp: ${liveResto.phone}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF475569))),
                            Row(
                              children: [
                                const Icon(Icons.star, color: Colors.amber, size: 13),
                                const SizedBox(width: 2),
                                Text(
                                  liveResto.averageRating.toStringAsFixed(1),
                                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF1BAC4B)),
                                ),
                                Text(
                                  ' (${liveResto.reviews.length} Ulasan)',
                                  style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: Colors.grey),
                                )
                              ],
                            )
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(liveResto.description ?? 'Restoran fine-dining dengan masakan khas terlezat.', style: TextStyle(color: Colors.grey[600], fontSize: 12, height: 1.5)),
                      
                      const SizedBox(height: 24),
                      const Divider(),
                      const SizedBox(height: 12),

                       // DYNAMIC RESERVATION FORM LABELS & CONTROLS
                      Row(
                        children: [
                          const Icon(Icons.people, size: 14, color: Color(0xFF1BAC4B)),
                          const SizedBox(width: 4),
                          const Text(
                            'PILIH JUMLAH TAMU:',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Color(0xFF64748B)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [2, 4, 6, 8].map((size) {
                          final isSel = _partySize == size;
                          return Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _partySize = size;
                                });
                              },
                              child: Container(
                                margin: const EdgeInsets.symmetric(horizontal: 4),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  color: isSel ? const Color(0xFF1BAC4B) : const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: isSel ? const Color(0xFF1BAC4B) : Colors.transparent),
                                ),
                                child: Center(
                                  child: Text(
                                    '$size Orang',
                                    style: TextStyle(
                                      color: isSel ? Colors.white : const Color(0xFF475569),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),
                       Row(
                        children: [
                          const Icon(Icons.calendar_month, size: 14, color: Color(0xFF1BAC4B)),
                          const SizedBox(width: 4),
                          const Text(
                            'PILIH TANGGAL KUNJUNGAN:',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Color(0xFF64748B)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 80,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          itemCount: _getDateStrip().length,
                          itemBuilder: (context, idx) {
                            final day = _getDateStrip()[idx];
                            final isSel = _selectedDate == day['value'];
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedDate = day['value']!;
                                });
                              },
                              child: Container(
                                width: 75,
                                margin: const EdgeInsets.only(right: 8),
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: isSel ? const Color(0xFF1BAC4B) : const Color(0xFFF8F9FA),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: isSel ? const Color(0xFF1BAC4B) : const Color(0xFFE2E8F0)),
                                  boxShadow: isSel
                                      ? [BoxShadow(color: const Color(0xFF1BAC4B).withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 3))]
                                      : null,
                                ),
                                                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      day['name']!,
                                      style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                        color: isSel ? Colors.white.withOpacity(0.8) : Colors.grey[500],
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      day['num']!,
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: isSel ? Colors.white : const Color(0xFF1E293B),
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      day['month']!,
                                      style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                        color: isSel ? Colors.white.withOpacity(0.8) : Colors.grey[500],
                                      ),
                                      ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const Icon(Icons.access_time, size: 14, color: Color(0xFF1BAC4B)),
                          const SizedBox(width: 4),
                          const Text(
                            'PILIH WAKTU KEDATANGAN:',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Color(0xFF64748B)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 44,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          itemCount: _timeSlots.length,
                          itemBuilder: (context, idx) {
                            final slot = _timeSlots[idx];
                            final isSel = _selectedTimeSlot == slot;
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedTimeSlot = slot;
                                });
                              },
                              child: Container(
                                margin: const EdgeInsets.only(right: 8),
                                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                                decoration: BoxDecoration(
                                  color: isSel ? const Color(0xFF1BAC4B) : const Color(0xFFF8F9FA),
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(color: isSel ? const Color(0xFF1BAC4B) : const Color(0xFFE2E8F0)),
                                ),
                                child: Center(
                                  child: Text(
                                    slot,
                                    style: TextStyle(
                                      color: isSel ? Colors.white : const Color(0xFF475569),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Divider(),
                      const SizedBox(height: 12),
                      // LIVE RESTAURANT OCCUPANCY & TABLES STATUS SECTION
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Tingkat Keramaian & Meja',
                                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Ketersediaan meja pada $_selectedDate ($_selectedTimeSlot)',
                                      style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: Colors.grey),
                                    ),
                                  ],
                                ),
                                // Badge for occupancy level
                                _buildOccupancyBadge(dynamicOccupancyPercent),
                              ],
                            ),
                            const SizedBox(height: 12),
                            // Progress / Gauge Bar Visualizer
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'KEPADATAN RESTORAN',
                                      style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.grey),
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          '$dynamicOccupancyPercent% Terisi',
                                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                                        ),
                                        const SizedBox(width: 6),
                                        const Text('|', style: TextStyle(color: Colors.grey, fontSize: 10)),
                                        const SizedBox(width: 6),
                                        Text(
                                          '🟢 $emptyTablesCountSimulated Meja Kosong',
                                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF1BAC4B)),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                                const SizedBox(height: 8),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: LinearProgressIndicator(
                                    value: dynamicOccupancyPercent / 100.0,
                                    backgroundColor: const Color(0xFFF1F5F9),
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      dynamicOccupancyPercent >= 80 ? Colors.red : (dynamicOccupancyPercent >= 55 ? Colors.amber : const Color(0xFF1BAC4B))
                                    ),
                                    minHeight: 8,
                                  ),
                                ),
                                if (dynamicOccupancyPercent >= 80) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    '⚠️ Antrean terdeteksi. Estimasi waktu tunggu masuk: ${liveResto.estimatedWaitMinutes} menit.',
                                    style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.red),
                                  ),
                                  ]
                              ],
                            )
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Divider(),
                      const SizedBox(height: 12),

                      // Core requirements: TABLE SELECTION DECORATING MAP 2D GRIDS (WHITE BACKGROUND & BLACK WRITINGS)
                      const Text(
                        'DENAH LETAK MEJA & KETERSEDIAAN:',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Color(0xFF64748B)),
                      ),
                      const SizedBox(height: 12),
                      
                      // Dynamic Table Map Grid (Polished visual mockup on White container + rich dark typography markers)
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 3))
                          ],
                        ),
                        child: Column(
                          children: [
                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 4,
                                crossAxisSpacing: 8,
                                mainAxisSpacing: 8,
                                childAspectRatio: 1.1,
                              ),
                              itemCount: _simulatedTables.length,
                              itemBuilder: (context, idx) {
                                final tab = _simulatedTables[idx];
                                final tabId = tab['id'] as String;
                                final isSelected = _selectedTableId == tabId;
                                final isBookedByUser = appState.bookings.any(
                                  (b) => b.restaurantId == widget.restaurant.id &&
                                         b.tableId == tabId &&
                                         b.status != BookingStatus.dibatalkan &&
                                         b.date == _selectedDate &&
                                         b.timeSlot == _selectedTimeSlot
                                );
                                final isOcc = (tab['isOccupied'] as bool) || isBookedByUser;

                                Color borderColor = const Color(0xFFE2E8F0);
                                Color bgColor = const Color(0xFFF8F9FA);
                                Color textPrimaryColor = const Color(0xFF1E293B);

                                if (isOcc) {
                                  borderColor = const Color(0xFFFEE2E2);
                                  bgColor = const Color(0xFFFEF2F2);
                                  textPrimaryColor = const Color(0xFFEF4444);
                                } else if (isSelected) {
                                  borderColor = const Color(0xFF1BAC4B);
                                  bgColor = const Color(0xFFECFDF5);
                                  textPrimaryColor = const Color(0xFF1BAC4B);
                                }

                                return GestureDetector(
                                  onTap: isOcc ? null : () {
                                    setState(() {
                                      _selectedTableId = tabId;
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: bgColor,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(color: borderColor, width: isSelected ? 1.8 : 1),
                                    ),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment: CrossAxisAlignment.stretch,
                                      children: [
                                        Text(tab['id'], style: TextStyle(fontSize: 8, fontWeight: FontWeight.normal, color: Colors.grey[400])),
                                        Text(
                                          tab['name'],
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Colors.black),
                                        ),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text('${tab['capacity']}p', style: TextStyle(fontSize: 8, fontWeight: FontWeight.w600, color: Colors.grey[500])),
                                            Container(
                                              width: 5,
                                              height: 5,
                                              decoration: BoxDecoration(
                                                color: isOcc ? const Color(0xFFEF4444) : const Color(0xFF10B981),
                                                shape: BoxShape.circle,
                                              ),
                                            )
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 12),
                            // Key Markers
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Row(
                                  children: [
                                    Container(width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xFF10B981), shape: BoxShape.circle)),
                                    const SizedBox(width: 4),
                                    Text('Kosong ($emptyTablesCountSimulated)', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF475569))),
                                  ],
                                ),
                                const SizedBox(width: 20),
                                Row(
                                  children: [
                                    Container(width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xFFEF4444), shape: BoxShape.circle)),
                                    const SizedBox(width: 4),
                                    Text('Terisi ($occupiedTablesCountSimulated)', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF475569))),
                                  ],
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      const Divider(),
                      const SizedBox(height: 12),

                      // Quick pre-order Menu section
                      const Text(
                        'PRE-ORDER MENU MAKANAN (OPSIONAL):',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Color(0xFF64748B)),
                      ),
                      const SizedBox(height: 12),
                      
                      // List of food items
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: liveResto.menu.length,
                        itemBuilder: (context, idx) {
                          final item = liveResto.menu[idx];
                          final qty = _mealCart[item.id] ?? 0;
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8F9FA),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: const Color(0xFFEDF2F7)),
                            ),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(item.image, width: 64, height: 64, fit: BoxFit.cover),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black)),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Rp ${item.price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
                                        style: const TextStyle(color: Color(0xFF1BAC4B), fontSize: 11, fontWeight: FontWeight.w900),
                                      ),
                                    ],
                                  ),
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.remove_circle_outline, color: Colors.grey, size: 22),
                                      onPressed: qty == 0 ? null : () {
                                        setState(() {
                                          if (qty == 1) {
                                            _mealCart.remove(item.id);
                                          } else {
                                            _mealCart[item.id] = qty - 1;
                                          }
                                        });
                                      },
                                    ),
                                    Text('$qty', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                    IconButton(
                                      icon: const Icon(Icons.add_circle, color: Color(0xFF1BAC4B), size: 22),
                                      onPressed: () {
                                        setState(() {
                                          _mealCart[item.id] = qty + 1;
                                        });
                                      },
                                    ),
                                  ],
                                )
                              ],
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 24),
                      const Divider(),
                      const SizedBox(height: 12),

                      // Reviews List Section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'ULASAN KULINER (${liveResto.reviews.length})',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Color(0xFF64748B)),
                          ),
                          Row(
                            children: [
                              const Icon(Icons.star, color: Colors.amber, size: 14),
                              const SizedBox(width: 2),
                              Text(liveResto.averageRating.toStringAsFixed(1), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                            ],
                          )
                        ],
                      ),
                      const SizedBox(height: 10),
                      
                      // Actual culinary reviews listing
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: liveResto.reviews.length,
                        itemBuilder: (context, idx) {
                          final r = liveResto.reviews[idx];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(color: const Color(0xFFF8F9FA), borderRadius: BorderRadius.circular(16)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(r.userName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Color(0xFF1E293B))),
                                    Row(
                                      children: List.generate(5, (starIdx) => Icon(
                                        Icons.star,
                                        size: 10,
                                        color: starIdx < r.rating ? Colors.amber : Colors.grey[300],
                                      )),
                                    )
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(r.comment, style: TextStyle(fontSize: 11, color: Colors.grey[700], height: 1.4)),
                                const SizedBox(height: 4),
                                Text(r.date, style: TextStyle(fontSize: 8.5, color: Colors.grey[400], fontWeight: FontWeight.bold)),
                              ],
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 16),
                      
                      // SECURITY LOCK RULE FOR FORM SUBMISSIONS ENFORCED HERE:
                      if (hasCompletedBooking) ...[
                        if (!_showReviewFormCompletely)
                          GestureDetector(
                            onTap: () => setState(() => _showReviewFormCompletely = true),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFECFDF5),
                                border: Border.all(color: const Color(0xFFA7F3D0)),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              alignment: Alignment.center,
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('📝 Tulis Ulasan & Rating Baru', style: TextStyle(color: Color(0xFF047857), fontWeight: FontWeight.bold, fontSize: 11.5)),
                                ],
                              ),
                            ),
                          )
                        else
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8F9FA),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Beri Rating Ulasan:', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Colors.grey)),
                                const SizedBox(height: 8),
                                Row(
                                  children: List.generate(5, (sIdx) {
                                    final currentS = sIdx + 1;
                                    return GestureDetector(
                                      onTap: () => setState(() => _selectedRatingStarForForm = currentS),
                                      child: Padding(
                                        padding: const EdgeInsets.only(right: 8.0),
                                        child: Icon(
                                          Icons.star,
                                          size: 24,
                                          color: currentS <= _selectedRatingStarForForm ? Colors.amber : Colors.grey[300],
                                        ),
                                      ),
                                    );
                                  }),
                                ),
                                const SizedBox(height: 12),
                                const Text('Komentar Kuliner:', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Colors.grey)),
                                const SizedBox(height: 6),
                                TextField(
                                  controller: _commentForFormController,
                                  maxLines: 3,
                                  style: const TextStyle(fontSize: 12),
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                    hintText: 'Bagikan rasa makanan, layanan, dan suasana restoran...',
                                    hintStyle: const TextStyle(fontSize: 11.5),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    TextButton(
                                      onPressed: () => setState(() {
                                        _showReviewFormCompletely = false;
                                        _commentForFormController.clear();
                                      }),
                                      child: const Text('Batal', style: TextStyle(color: Colors.grey)),
                                    ),
                                    const SizedBox(width: 8),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF1BAC4B),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                      ),
                                      onPressed: () {
                                        if (_commentForFormController.text.isNotEmpty) {
                                          appState.handleAddReview(
                                            restaurantId: widget.restaurant.id,
                                            bookingId: '', // Direct detail review
                                            rating: _selectedRatingStarForForm,
                                            comment: _commentForFormController.text,
                                          );
                                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                            content: Text('Terima kasih! Ulasan Anda sukses diunggah.'),
                                            backgroundColor: Color(0xFF1BAC4B),
                                          ));
                                          setState(() {
                                            _showReviewFormCompletely = false;
                                            _commentForFormController.clear();
                                            _selectedRatingStarForForm = 5;
                                          });
                                        }
                                      },
                                      child: const Text('Kirim Ulasan', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
                                    )
                                  ],
                                )
                              ],
                            ),
                          )
                      ] else ...[
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Column(
                            children: [
                              const Text('🔒', style: TextStyle(fontSize: 22)),
                              const SizedBox(height: 4),
                              const Text(
                                'Ulasan Hanya Untuk Kunjungan Terverifikasi',
                                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Anda hanya dapat memberikan rating & ulasan jika Anda sudah menyelesaikan pemesanan meja di restoran ini (status booking selesai).',
                                style: TextStyle(fontSize: 9.5, color: Colors.grey[500], height: 1.4),
                                textAlign: TextAlign.center,
                              )
                            ],
                          ),
                        )
                      ],
                    ],
                  ),
                )
              ],
            ),
          ),

          // Bottom sticky summary layout for booking orders
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 15, offset: const Offset(0, -5))
                ],
                border: const Border(top: BorderSide(color: Color(0xFFF1F5F9))),
              ),
              child: SafeArea(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text('Porsi Meja: ', style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
                            Text('$_partySize Pax', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: Colors.black)),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Rp ${totalPrice.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
                          style: const TextStyle(color: Color(0xFF1BAC4B), fontSize: 16, fontWeight: FontWeight.w900),
                        ),
                        const Text('Keamanan deposit terhitung', style: TextStyle(fontSize: 8.5, color: Colors.grey, fontWeight: FontWeight.w500)),
                      ],
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1BAC4B),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 1.5,
                      ),
                      onPressed: () {
                        // Gather Preordered cart
                        final List<PreOrderedFoodItem> foods = [];
                        _mealCart.forEach((itemId, q) {
                          final orig = widget.restaurant.menu.firstWhere((element) => element.id == itemId);
                          foods.add(PreOrderedFoodItem(menuItemId: itemId, name: orig.name, quantity: q, price: orig.price));
                        });

                        // Create transaction booking record
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PaymentScreen(
                              restaurant: widget.restaurant,
                          date: _selectedDate,
                          timeSlot: _selectedTimeSlot,
                          partySize: _partySize,
                          tableId: _selectedTableId,
                          preOrderedFood: foods,
                          totalPayment: totalPrice,
                          subtotal: subtotal,
                            depositFee: reservationFee,
                            ),
                          ),
                        );

                        // Popup notification confirmation dialog
                    
                      },
                      child: const Row(
                        children: [
                          Icon(Icons.check_circle_outline, color: Colors.white, size: 16),
                          SizedBox(width: 6),
                          Text('Reservasi Sekarang', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w900)),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  void _showSuccessReservationDialog(BuildContext context, String table, String name) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext c) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Column(
            children: [
              Text('🎉', style: TextStyle(fontSize: 36)),
              SizedBox(height: 8),
              Text('Reservasi Sukses!', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900), textAlign: TextAlign.center),
            ],
          ),
          content: Text(
            'Selamat! Meja $table telah sukses dipesan untuk Anda di $name. Anda dapat memantau pesanan di tab Riwayat.',
            style: const TextStyle(fontSize: 11.5, color: Color(0xFF475569), height: 1.4),
            textAlign: TextAlign.center,
          ),
          actions: [
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1BAC4B),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                ),
                onPressed: () {
                  Navigator.pop(c); // Pop dialog
                  Navigator.pop(context); // Back to main
                },
                child: const Text('Ke Dashboard', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 8),
          ],
        );
      },
    );
  }
}
