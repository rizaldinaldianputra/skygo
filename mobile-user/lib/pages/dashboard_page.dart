import 'package:flutter/material.dart';
import '../session/session_manager.dart';
import 'login_page.dart';
import 'map_page.dart';
import 'order_history_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String _userName = "User";
  int _points = 0; // Coming soon

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() async {
    final name = await SessionManager().getUserId();
    setState(() {
      _userName = name ?? "User";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(),
            _buildPointsBar(),
            const SizedBox(height: 20),
            _buildMenuGrid(),
            const SizedBox(height: 20),
            _buildPromoCarousel(),
            const SizedBox(height: 20),
            _buildNewsSection(),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.discount), label: 'Promos'),
          BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: 'Orders'),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chat'),
        ],
        currentIndex: 0,
        selectedItemColor: Colors.green,
        onTap: (index) {
          if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const OrderHistoryPage()),
            );
          }
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(30),
        ),
        child: const TextField(
          decoration: InputDecoration(
            hintText: "Cari layanan, makanan, & tujuan",
            border: InputBorder.none,
            icon: Icon(Icons.search, color: Colors.grey),
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const CircleAvatar(
            backgroundColor: Colors.green,
            child: Icon(Icons.person, color: Colors.white),
          ),
          onPressed: () {
            // Profile or settings
            _showLogoutDialog();
          },
        ),
      ],
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Logout?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          TextButton(
            onPressed: () async {
              await SessionManager().clearSession();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
              );
            },
            child: const Text("Logout", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Greeting handled in AppBar or here if needed
        ],
      ),
    );
  }

  Widget _buildPointsBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0081A0), // Gopay Blue-ish
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildBalanceItem(Icons.account_balance_wallet, "Rp 50.000", "Saldo"),
          _buildBalanceItem(Icons.control_point_duplicate, "120 Pts", "Points"),
          _buildBalanceItem(Icons.history, "Riwayat", "History"),
          _buildBalanceItem(Icons.add_circle, "Top Up", "Isi Saldo"),
        ],
      ),
    );
  }

  Widget _buildBalanceItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 10),
        ),
      ],
    );
  }

  Widget _buildMenuGrid() {
    final menuItems = [
      {
        'icon': Icons.two_wheeler,
        'label': 'SkyRide',
        'type': 'MOTOR',
        'active': true,
        'color': const Color(0xFF00BFFF), // Blue
      },
      {
        'icon': Icons.directions_car,
        'label': 'SkyCar',
        'type': 'CAR',
        'active': true,
        'color': const Color(0xFF00BFFF), // Blue
      },
      {
        'icon': Icons.fastfood,
        'label': 'SkyFood',
        'type': '',
        'active': false,
        'color': Colors.red,
      },
      {
        'icon': Icons.local_shipping,
        'label': 'SkySend',
        'type': '',
        'active': false,
        'color': Colors.orange,
      },
      {
        'icon': Icons.shopping_cart,
        'label': 'SkyMart',
        'type': '',
        'active': false,
        'color': Colors.red,
      },
      {
        'icon': Icons.account_balance_wallet,
        'label': 'SkyBill',
        'type': '',
        'active': false,
        'color': Colors.blue,
      },
      {
        'icon': Icons.local_offer,
        'label': 'SkyShop',
        'type': '',
        'active': false,
        'color': Colors.pink,
      },
      {
        'icon': Icons.more_horiz,
        'label': 'Lainnya',
        'type': '',
        'active': false,
        'color': Colors.grey,
      },
    ];

    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 20,
        crossAxisSpacing: 10,
        childAspectRatio: 0.8,
      ),
      itemCount: menuItems.length,
      itemBuilder: (context, index) {
        final item = menuItems[index];
        bool isActive = item['active'] as bool;
        return InkWell(
          onTap: isActive
              ? () {
                  if (item['type'] != '') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            MapPage(vehicleType: item['type'] as String),
                      ),
                    );
                  }
                }
              : null,
          child: Opacity(
            opacity: isActive ? 1.0 : 0.4,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: (item['color'] as Color).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Icon(
                    item['icon'] as IconData,
                    color: item['color'] as Color,
                    size: 30,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  item['label'] as String,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPromoCarousel() {
    return SizedBox(
      height: 150,
      child: PageView(
        controller: PageController(viewportFraction: 0.9),
        children: [
          _buildPromoCard(Colors.blue, "Diskon 50% untuk Pengguna Baru!"),
          _buildPromoCard(Colors.orange, "Gratis Ongkir GoFood!"),
          _buildPromoCard(Colors.purple, "Cashback 20% Pakai Gopay!"),
        ],
      ),
    );
  }

  Widget _buildPromoCard(Color color, String text) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Center(
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildNewsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Berita Pilihan",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          _buildNewsItem(
            "Tips Hemat di Akhir Bulan",
            "https://via.placeholder.com/150",
          ),
          _buildNewsItem(
            "Update Fitur Terbaru SkyGo",
            "https://via.placeholder.com/150",
          ),
          _buildNewsItem(
            "Kuliner Wajib Coba Minggu Ini",
            "https://via.placeholder.com/150",
          ),
        ],
      ),
    );
  }

  Widget _buildNewsItem(String title, String imageUrl) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Row(
        children: [
          Container(
            width: 100,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10),
                bottomLeft: Radius.circular(10),
              ),
            ),
            child: const Icon(Icons.image, color: Colors.grey),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
