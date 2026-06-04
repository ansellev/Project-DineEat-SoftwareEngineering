import 'package:flutter/material.dart';
import '../provider.dart';
import '../app_state.dart';
import '../models.dart';
import 'package:image_picker/image_picker.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _notifPush = true;
  bool _notifEmail = false;
  bool _saveHistoryOffline = true;
  bool _obscurePassword = true;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _imageController = TextEditingController();

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _imageController.text = image.path;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Foto profil lokal berhasil dipilih!'),
            backgroundColor: Color(0xFF1BAC4B),
          ));
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Gagal mengambil gambar dari galeri.'),
        backgroundColor: Colors.red,
      ));
    }
  }

  @override
  void initState() {
    super.initState();
    final state = Provider.of<AppState>(context, listen: false);
    _nameController.text = state.currentUser?.fullName ?? '';
    _emailController.text = state.currentUser?.email ?? '';
    _passwordController.text = state.currentUser?.password ?? '';
    _imageController.text = state.currentUser?.profileImage ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _imageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final user = appState.currentUser;
    final totalBookCount = appState.bookings.length;
    final completedCount = appState.bookings.filter((b) => b.status == BookingStatus.selesai).length;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Profil Pengguna', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Color(0xFF1E293B))),
        elevation: 0.5,
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // User Avatar Banner card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFEDF2F7)),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _pickImage,
                    child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 46,
                        backgroundImage: NetworkImage(user?.profileImage ?? 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&q=80&w=150'),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(color: Color(0xFF1BAC4B), shape: BoxShape.circle),
                          child: const Icon(Icons.edit_outlined, color: Colors.white, size: 14),
                        ),
                      )
                    ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    user?.fullName ?? 'Pelanggan Setia',
                    style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF1E293B), fontSize: 16),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    user?.email ?? 'mail@dineeas.com',
                    style: TextStyle(color: Colors.grey[500], fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 16),
                  
                  // Statistics
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildMetricItem('Total Reservasi', '$totalBookCount Kali'),
                      Container(height: 24, width: 1, color: Colors.grey[200]),
                      _buildMetricItem('Disetujui', '$completedCount Kunjungan'),
                    ],
                  )
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Profile Form Editor Card
            _buildSectionCard(
              title: 'PENGATURAN AKUN',
              children: [
                const SizedBox(height: 6),
                const Text('Nama Lengkap', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
                const SizedBox(height: 4),
                TextField(
                  controller: _nameController,
                  style: const TextStyle(fontSize: 12.5),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    prefixIcon: const Icon(Icons.person_outline, size: 18),
                  ),
                ),

                const SizedBox(height: 12),
                
                const Text('Alamat Email', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.indigo)),
                const SizedBox(height: 4),
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(fontSize: 12.5),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    prefixIcon: const Icon(Icons.email_outlined, size: 18),
                  ),
                ),
                const SizedBox(height: 12),

                const Text('Kata Sandi (Password)', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.indigo)),
                const SizedBox(height: 4),
                TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  style: const TextStyle(fontSize: 12.5),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    prefixIcon: const Icon(Icons.lock_outline, size: 18),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 18),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                const Text('Foto Profil', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.indigo)),
                const SizedBox(height: 6),
                InkWell(
                  onTap: _pickImage,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.grey[50],
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.photo_library_outlined, size: 18, color: Color(0xFF1BAC4B)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _imageController.text.isNotEmpty 
                                ? 'Gambar Terpilih (Lokal)' 
                                : 'Pilih Foto dari Galeri Perangkat',
                            style: const TextStyle(fontSize: 12.5, color: Colors.black87, fontWeight: FontWeight.w500),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const Icon(Icons.cloud_upload_outlined, size: 18, color: Colors.grey),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                const SizedBox(height: 14),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1BAC4B),
                    minimumSize: const Size(double.infinity, 44),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    if (_nameController.text.isNotEmpty && _emailController.text.isNotEmpty) {
                      appState.updateProfile(
                        name: _nameController.text.trim(),
                        email: _emailController.text.trim(),
                        password: _passwordController.text,
                        profileImage: _imageController.text.trim(),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Profil Anda sukses diperbarui!'),
                        backgroundColor: Color(0xFF1BAC4B),
                      ));
                      } else {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Nama dan Email tidak boleh kosong!'),
                        backgroundColor: Colors.red,
                      ));
                    }
                  },
                  child: const Text('Simpan Perubahan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.white)),
                )
              ],
            ),

            const SizedBox(height: 20),

            // Preference Options
            _buildSectionCard(
              title: 'PREFERENSI APLIKASI',
              children: [
                SwitchListTile.adaptive(
                  activeColor: const Color(0xFF1BAC4B),
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Notifikasi Aplikasi Push', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: Color(0xFF1E293B))),
                  subtitle: const Text('Kirim alarm pengingat meja 30 menit sebelum jadwal.', style: TextStyle(fontSize: 10, color: Colors.grey)),
                  value: _notifPush,
                  onChanged: (bool val) => setState(() => _notifPush = val),
                ),
                SwitchListTile.adaptive(
                  activeColor: const Color(0xFF1BAC4B),
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Email Berkala & Diskon', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: Color(0xFF1E293B))),
                  value: _notifEmail,
                  onChanged: (bool val) => setState(() => _notifEmail = val),
                ),
                SwitchListTile.adaptive(
                  activeColor: const Color(0xFF1BAC4B),
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Simpan Offline Cache', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: Color(0xFF1E293B))),
                  value: _saveHistoryOffline,
                  onChanged: (bool val) => setState(() => _saveHistoryOffline = val),
                ),
              ],
            ),

            const SizedBox(height: 24),
            
            // Logout
            TextButton(
              onPressed: () {
                appState.logout();
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Anda sukses keluar dari akun.'),
                  backgroundColor: Colors.black87,
                ));
              },
              child: const Text('Keluar dari Akun', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 13)),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricItem(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1BAC4B))),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 10, color: Colors.grey)),
      ],
    );
  }

  Widget _buildSectionCard({required String title, required List<Widget> children}) {
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
          Text(title, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }
}
