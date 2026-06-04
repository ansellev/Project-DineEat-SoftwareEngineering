import 'package:flutter/material.dart';
import '../provider.dart';
import '../models.dart';
import '../app_state.dart';
import 'details_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String _activeFilter = 'Semua';

  final List<String> _filters = ['Semua', 'Menunggu', 'Selesai', 'Dibatalkan'];

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final allBookings = appState.bookings;

    // Filter bookings on state status
    final filteredBookings = allBookings.filter((b) {
      if (_activeFilter == 'Semua') return true;
      if (_activeFilter == 'Menunggu') return b.status == BookingStatus.menunggu || b.status == BookingStatus.pengingatDikirim;
      if (_activeFilter == 'Selesai') return b.status == BookingStatus.selesai;
      if (_activeFilter == 'Dibatalkan') return b.status == BookingStatus.dibatalkan;
      return true;
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Riwayat Booking Meja', style: TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF1E293B), fontSize: 16)),
        backgroundColor: Colors.white,
        elevation: 0.5,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          // Filter Chips Row
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: _filters.map((filter) {
                final isSelected = _activeFilter == filter;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _activeFilter = filter;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF1BAC4B) : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      filter,
                      style: TextStyle(
                        color: isSelected ? Colors.white : const Color(0xFF475569),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // Lists builder
          Expanded(
            child: filteredBookings.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.bookmark_border_sharp, size: 48, color: Colors.grey),
                        const SizedBox(height: 12),
                        Text('Tidak ada riwayat booking', style: TextStyle(color: Colors.grey[500], fontSize: 13, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text('Reservasi meja restoran Anda akan tercatat di sini.', style: TextStyle(color: Colors.grey[400], fontSize: 11)),
                      ],
                    ),
                  )
                : ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredBookings.length,
                    itemBuilder: (context, idx) {
                      final b = filteredBookings[idx];
                      return _buildBookingCard(context, b, appState);
                    },
                  ),
          )
        ],
      ),
    );
  }

  Widget _buildBookingCard(BuildContext context, Booking b, AppState appState) {
    Color statusBg = const Color(0xFFFEF3C7);
    Color statusText = const Color(0xFFD97706);
    String statusLabel = 'Menunggu';

    if (b.status == BookingStatus.selesai) {
      statusBg = const Color(0xFFECFDF5);
      statusText = const Color(0xFF059669);
      statusLabel = 'Selesai';
    } else if (b.status == BookingStatus.dibatalkan) {
      statusBg = const Color(0xFFFEF2F2);
      statusText = const Color(0xFFDC2626);
      statusLabel = 'Dibatalkan';
    } else if (b.status == BookingStatus.pengingatDikirim) {
      statusBg = const Color(0xFFEFF6FF);
      statusText = const Color(0xFF2563EB);
      statusLabel = 'Pengingat Aktif';
    }

    final hasBeenReviewed = b.reviewId != null && b.reviewId!.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFEDF2F7)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header of card (Image & status)
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(b.restaurantImage, width: 48, height: 48, fit: BoxFit.cover),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () {
                          final matchedRestaurant = appState.restaurants.where((r) => r.id == b.restaurantId);
                          if (matchedRestaurant.isNotEmpty) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => DetailsScreen(restaurant: matchedRestaurant.first),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Detail restoran tidak ditemukan.'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                        child: Text(
                          b.restaurantName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: Color(0xFF1BAC4B),
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(Icons.location_on_sharp, size: 10, color: Colors.grey[400]),
                          const SizedBox(width: 2),
                          Expanded(
                            child: Text(
                              b.restaurantAddress,
                              style: TextStyle(color: Colors.grey[500], fontSize: 10, overflow: TextOverflow.ellipsis),
                              maxLines: 1,
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: statusBg, borderRadius: BorderRadius.circular(8)),
                  child: Text(
                    statusLabel,
                    style: TextStyle(color: statusText, fontSize: 9, fontWeight: FontWeight.bold),
                  ),
                )
              ],
            ),
          ),
          const Divider(height: 1),

          // Booking Specific details
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildCompactInfo('Tanggal', b.date, Icons.calendar_today_outlined),
                _buildCompactInfo('Jam', b.timeSlot, Icons.access_time),
                _buildCompactInfo('No. Meja', b.tableId, Icons.table_bar_outlined),
                _buildCompactInfo('Pax', '${b.partySize} Orang', Icons.people_outline_sharp),
              ],
            ),
          ),

          // List custom foods
          if (b.preOrderedFood.isNotEmpty) ...[
            Container(
              color: const Color(0xFFF8FAFC),
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Preordered Foods:', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.grey)),
                  const SizedBox(height: 6),
                  ...b.preOrderedFood.map((food) => Padding(
                        padding: const EdgeInsets.only(bottom: 4.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('${food.name} (x${food.quantity})', style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: Color(0xFF475569))),
                            Text(
                              'Rp ${(food.price * food.quantity).toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
                              style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                            )
                          ],
                        ),
                      )),
                ],
              ),
            ),
            const Divider(height: 1),
          ],

          // Footer containing total payments & contextual buttons
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Total Pembayaran', style: TextStyle(fontSize: 9, color: Colors.grey, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 2),
                    Text(
                      'Rp ${b.totalPayment.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Color(0xFF1BAC4B)),
                    )
                  ],
                ),
                
                // Contextual buttons matching React application
                if (b.status == BookingStatus.menunggu || b.status == BookingStatus.pengingatDikirim) ...[
                  Row(
                    children: [
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFFEF4444)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        ),
                        onPressed: () => _showCancelBookingConfirmation(context, b.id, appState),
                        child: const Text('Batal', style: TextStyle(color: Color(0xFFEF4444), fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 6),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1BAC4B),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        ),
                        onPressed: () {
                          appState.updateBookingStatus(b.id, BookingStatus.pengingatDikirim);
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                            content: Text('🔔 Pengingat reservasi dikirim! SMS & WhatsApp aktif.'),
                            backgroundColor: Color(0xFF1BAC4B),
                          ));
                        },
                        child: const Text('Kirim Pengingat', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
                      )
                    ],
                  )
                ] else if (b.status == BookingStatus.selesai) ...[
                  Row(
                    children: [
                      if (hasBeenReviewed)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(10)),
                          child: const Row(
                            children: [
                              Icon(Icons.star, color: Colors.amber, size: 12),
                              SizedBox(width: 4),
                              Text('Sudah Diulas', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF475569))),
                            ],
                          ),
                        )
                      else
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1BAC4B),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          ),
                          onPressed: () => _showAddReviewDialog(context, b, appState),
                          child: const Text('✍️ Ulas Sekarang', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
                        ),
                      const SizedBox(width: 6),
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFF1BAC4B)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        ),
                        onPressed: () {
                          // Reorder logic (auto-generate new reservation)
                          appState.createBooking(
                            restaurantId: b.restaurantId,
                            restaurantName: b.restaurantName,
                            restaurantImage: b.restaurantImage,
                            restaurantAddress: b.restaurantAddress,
                            date: '2026-06-04', // Next day
                            timeSlot: b.timeSlot,
                            partySize: b.partySize,
                            tableId: b.tableId,
                            preOrderedFood: b.preOrderedFood,
                            totalPayment: b.totalPayment,
                          );
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                            content: Text('Re-booking restoran berhasil diajukan untuk besok!'),
                            backgroundColor: Color(0xFF1BAC4B),
                          ));
                        },
                        child: const Text('Pesan Lagi', style: TextStyle(color: Color(0xFF1BAC4B), fontSize: 10, fontWeight: FontWeight.bold)),
                      )
                    ],
                  )
                ] else if (b.status == BookingStatus.dibatalkan) ...[
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF1BAC4B)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () {
                      appState.createBooking(
                        restaurantId: b.restaurantId,
                        restaurantName: b.restaurantName,
                        restaurantImage: b.restaurantImage,
                        restaurantAddress: b.restaurantAddress,
                        date: '2026-06-04',
                        timeSlot: b.timeSlot,
                        partySize: b.partySize,
                        tableId: b.tableId,
                        preOrderedFood: b.preOrderedFood,
                        totalPayment: b.totalPayment,
                      );
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Re-booking restoran berhasil diajukan!'),
                        backgroundColor: Color(0xFF1BAC4B),
                      ));
                    },
                    child: const Text('Pesan Lagi', style: TextStyle(color: Color(0xFF1BAC4B), fontSize: 10, fontWeight: FontWeight.bold)),
                  )
                ]
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildCompactInfo(String title, String val, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 9, color: Colors.grey),
            const SizedBox(width: 2),
            Text(title, style: const TextStyle(fontSize: 8.5, color: Colors.grey, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 2),
        Text(val, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF1E293B))),
      ],
    );
  }

  void _showCancelBookingConfirmation(BuildContext context, String bId, AppState state) {
    showDialog(
      context: context,
      builder: (BuildContext dContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Batal Reservasi?', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900)),
          content: const Text('Apakah Anda yakin ingin membatalkan pesanan meja makan malam ini? Deposit akan dikembalikan dalam limitasi syarat dan ketentuan.', style: TextStyle(fontSize: 11.5)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dContext),
              child: const Text('Tutup', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () {
                state.cancelBooking(bId);
                Navigator.pop(dContext);
              },
              child: const Text('Batalkan', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  // Floating material review dialog on completed dining bookings
  void _showAddReviewDialog(BuildContext context, Booking b, AppState state) {
    int localRating = 5;
    final textController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext dContext) {
        return StatefulBuilder(
          builder: (context, setLocalDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              title: Column(
                children: [
                  const Text('Beri Ulasan Kuliner', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 4),
                  Text('Penilaian Anda untuk ${b.restaurantName}', style: const TextStyle(fontSize: 10, color: Colors.grey), textAlign: TextAlign.center),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Clickable Stars Rating inside popover
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (idx) {
                        final starVal = idx + 1;
                        return GestureDetector(
                          onTap: () {
                            setLocalDialogState(() {
                              localRating = starVal;
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4.0),
                            child: Icon(
                              Icons.star,
                              size: 28,
                              color: starVal <= localRating ? Colors.amber : Colors.grey[300],
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: textController,
                      maxLines: 3,
                      style: const TextStyle(fontSize: 11.5),
                      decoration: InputDecoration(
                        hintText: 'Tulis rasa masakan, kenyamanan meja, dan keramahan pelayan di sini...',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    )
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dContext),
                  child: const Text('Batal', style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1BAC4B),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () {
                    final comment = textController.text.isNotEmpty ? textController.text : 'Pelayanan yang fantastis!';
                    // Dispatch
                    state.handleAddReview(
                      restaurantId: b.restaurantId,
                      bookingId: b.id,
                      rating: localRating,
                      comment: comment,
                    );
                    Navigator.pop(dContext);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Ulasan Anda telah sukses diunggah ke restoran!'),
                      backgroundColor: Color(0xFF1BAC4B),
                    ));
                  },
                  child: const Text('Kirim Ulasan', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
                )
              ],
            );
          },
        );
      },
    );
  }
}
