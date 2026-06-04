import 'package:flutter/material.dart';
import '../provider.dart';
import '../models.dart';
import '../app_state.dart';

class PaymentScreen extends StatefulWidget {
  final Restaurant restaurant;
  final String date;
  final String timeSlot;
  final int partySize;
  final String tableId;
  final List<PreOrderedFoodItem> preOrderedFood;
  final int totalPayment;
  final int subtotal;
  final int depositFee;

  const PaymentScreen({
    Key? key,
    required this.restaurant,
    required this.date,
    required this.timeSlot,
    required this.partySize,
    required this.tableId,
    required this.preOrderedFood,
    required this.totalPayment,
    required this.subtotal,
    required this.depositFee,
  }) : super(key: key);

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String _selectedPaymentMethod = 'QRIS';
  bool _isProcessing = false;

  final List<Map<String, String>> _paymentMethods = [
    {'id': 'QRIS', 'name': 'QRIS (Gopay, OVO, Dana, LinkAja)', 'icon': '📱'},
    {'id': 'BCA_VA', 'name': 'BCA Virtual Account', 'icon': '🏦'},
    {'id': 'MANDIRI_VA', 'name': 'Mandiri Virtual Account', 'icon': '🏢'},
    {'id': 'DANA', 'name': 'Dana E-Wallet', 'icon': '👛'},
    {'id': 'CREDIT_CARD', 'name': 'Kartu Kredit / Debit', 'icon': '💳'},
  ];

  String _formatCurrency(int amount) {
    return 'Rp ${amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }

  void _processPayment() {
    setState(() => _isProcessing = true);

    // Simulate Payment Gateway Network Delay
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      final appState = Provider.of<AppState>(context, listen: false);

      // Create Booking with current state
      appState.createBooking(
        restaurantId: widget.restaurant.id,
        restaurantName: widget.restaurant.name,
        restaurantImage: widget.restaurant.image,
        restaurantAddress: widget.restaurant.address,
        date: widget.date,
        timeSlot: widget.timeSlot,
        partySize: widget.partySize,
        tableId: widget.tableId,
        preOrderedFood: widget.preOrderedFood,
        totalPayment: widget.totalPayment,
      );

      setState(() => _isProcessing = false);

      // Show payment completion success dialog
      _showSuccessDialog();
    });
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext c) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Column(
            children: [
              Text('🎉', style: TextStyle(fontSize: 48)),
              SizedBox(height: 12),
              Text(
                'Pembayaran Sukses!',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Pembayaran transaksi deposit meja ${widget.tableId} di ${widget.restaurant.name} seharga ${_formatCurrency(widget.totalPayment)} telah berhasil dilakukan.',
                style: const TextStyle(fontSize: 12, color: Color(0xFF475569), height: 1.5),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Status reservasi Anda kini aktif. Silakan tunjukkan bukti transaksi di tab Riwayat saat Anda mengunjungi restoran.',
                style: TextStyle(fontSize: 10.5, color: Colors.grey[500], height: 1.4),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1BAC4B),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                ),
                onPressed: () {
                  Navigator.pop(c); // Pop dialog
                  Navigator.pop(context); // Pop PaymentScreen
                  Navigator.pop(context); // Pop DetailsScreen back to dashboard
                },
                child: const Text('Kembali ke Dashboard', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 10),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Pembayaran Reservasi', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: Color(0xFF1E293B))),
        elevation: 0.5,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1E293B)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 120, left: 16, right: 16, top: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Booking Summary Banner Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFEDF2F7)),
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(widget.restaurant.image, width: 80, height: 80, fit: BoxFit.cover),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.restaurant.name,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1E293B)),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '📍 ${widget.restaurant.address}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: Colors.grey[500], fontSize: 11, fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                _buildSummaryTag('📅 ${widget.date}'),
                                const SizedBox(width: 6),
                                _buildSummaryTag('⏰ ${widget.timeSlot}'),
                              ],
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // 2. Table Detail Summary Card
                _buildSectionCard(
                  title: 'DETAIL RESERVASI MEJA',
                  child: Column(
                    children: [
                      _buildDetailRow('Kode Meja Pilihan', widget.tableId, highlight: true),
                      const Divider(height: 14, color: Color(0xFFF1F5F9)),
                      _buildDetailRow('Kapasitas Direkomendasikan', '${widget.partySize} Kursi (Pax)'),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // 3. Pre-ordered Meals (Optional Listing)
                if (widget.preOrderedFood.isNotEmpty) ...[
                  _buildSectionCard(
                    title: 'PRE-ORDER HIDANGAN KULINER',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ...widget.preOrderedFood.map((item) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(color: const Color(0xFFEFFDF4), borderRadius: BorderRadius.circular(6)),
                                        child: Text('${item.quantity}x', style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Color(0xFF1BAC4B))),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          item.name,
                                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(_formatCurrency(item.price * item.quantity), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                              ],
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                ],

                // 4. Payment Method Picker Card
                _buildSectionCard(
                  title: 'METODE PEMBAYARAN',
                  child: Column(
                    children: _paymentMethods.map((method) {
                      final isSelected = _selectedPaymentMethod == method['id'];
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedPaymentMethod = method['id']!;
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFFEFFDF4) : const Color(0xFFF8F9FA),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: isSelected ? const Color(0xFF1BAC4B) : const Color(0xFFE2E8F0), width: isSelected ? 1.5 : 1),
                          ),
                          child: Row(
                            children: [
                              Text(method['icon']!, style: const TextStyle(fontSize: 20)),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  method['name']!,
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                    color: isSelected ? const Color(0xFF111827) : const Color(0xFF4B5563),
                                  ),
                                ),
                              ),
                              if (isSelected)
                                const Icon(Icons.check_circle, color: Color(0xFF1BAC4B), size: 18)
                              else
                                Container(
                                  width: 18,
                                  height: 18,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.grey),
                                  ),
                                )
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 18),

                // 5. Invoice Billing Breakdown Card
                _buildSectionCard(
                  title: 'RINCIAN TAGIHAN',
                  child: Column(
                    children: [
                      _buildInvoiceRow('Subtotal Sesi Pre-Order', _formatCurrency(widget.subtotal)),
                      const SizedBox(height: 8),
                      _buildInvoiceRow('Biaya Deposit Meja (Secure Lock)', _formatCurrency(widget.depositFee)),
                      const Divider(height: 20, color: Color(0xFFEDF2F7)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total Pembayaran', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1E293B))),
                          Text(_formatCurrency(widget.totalPayment), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF1BAC4B))),
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Core Bottom Sticky Bayar Button Bar Layout
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
                  BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, -4))
                ],
                border: const Border(top: BorderSide(color: Color(0xFFEDF2F7))),
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Total Tagihan:', style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 2),
                          Text(
                            _formatCurrency(widget.totalPayment),
                            style: const TextStyle(color: Color(0xFF1BAC4B), fontSize: 17, fontWeight: FontWeight.w900),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1BAC4B),
                        padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 1,
                      ),
                      onPressed: _isProcessing ? null : _processPayment,
                      child: _isProcessing
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : const Text(
                              'Bayar Sekarang',
                              style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w900),
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

  Widget _buildSummaryTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(8)),
      child: Text(text, style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: Color(0xFF475569))),
    );
  }

  Widget _buildSectionCard({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFEDF2F7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.indigo)),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool highlight = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w500)),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: highlight ? FontWeight.bold : FontWeight.w700,
            color: highlight ? const Color(0xFF1BAC4B) : const Color(0xFF1E293B),
          ),
        ),
      ],
    );
  }

  Widget _buildInvoiceRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w500)),
        Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF475569))),
      ],
    );
  }
}
