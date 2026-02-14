import 'package:flutter/material.dart';
import '../session/session_manager.dart';
import '../services/dashboard_service.dart';
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
  int _points = 0;

  final DashboardService _dashboardService = DashboardService();
  List<Map<String, dynamic>> _banners = [];
  List<Map<String, dynamic>> _promos = [];
  List<Map<String, dynamic>> _news = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadDashboardData();
  }

  void _loadUserData() async {
    final name = await SessionManager().getUserId();
    setState(() {
      _userName = name ?? "User";
    });
  }

  void _loadDashboardData() async {
    try {
      final banners = await _dashboardService.getBanners();
      final promos = await _dashboardService.getPromos();
      final news = await _dashboardService.getNews();
      if (mounted) {
        setState(() {
          _banners = banners;
          _promos = promos;
          _news = news;
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error loading dashboard data: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: RefreshIndicator(
        onRefresh: () async {
          _loadDashboardData();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              _buildHeader(),
              _buildPointsBar(),
              const SizedBox(height: 20),
              _buildMenuGrid(),
              const SizedBox(height: 20),
              _buildBannerCarousel(),
              const SizedBox(height: 20),
              _buildPromoCarousel(),
              const SizedBox(height: 20),
              _buildNewsSection(),
              const SizedBox(height: 20),
            ],
          ),
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
        children: const [],
      ),
    );
  }

  Widget _buildPointsBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0081A0),
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
        'color': const Color(0xFF00BFFF),
      },
      {
        'icon': Icons.directions_car,
        'label': 'SkyCar',
        'type': 'CAR',
        'active': true,
        'color': const Color(0xFF00BFFF),
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

  // ================== BANNER CAROUSEL (from API) ==================
  Widget _buildBannerCarousel() {
    if (_banners.isEmpty) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            "Banner",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 140,
          child: PageView.builder(
            controller: PageController(viewportFraction: 0.9),
            itemCount: _banners.length,
            itemBuilder: (context, index) {
              final banner = _banners[index];
              final imageUrl = banner['imageUrl'] as String?;
              final title = banner['title'] as String? ?? '';

              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: Colors.grey[300],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (imageUrl != null && imageUrl.isNotEmpty)
                        Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (ctx, error, stack) => Container(
                            color: Colors.blue.shade400,
                            child: Center(
                              child: Text(
                                title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        )
                      else
                        Container(
                          color: Colors.blue.shade400,
                          child: Center(
                            child: Text(
                              title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      // Overlay title
                      if (imageUrl != null && imageUrl.isNotEmpty)
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [
                                  Colors.black.withOpacity(0.6),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                            child: Text(
                              title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ================== PROMO CAROUSEL (from API) ==================
  Widget _buildPromoCarousel() {
    // Fallback to hardcoded if no promos from API
    if (_promos.isEmpty && !_isLoading) {
      return SizedBox(
        height: 150,
        child: PageView(
          controller: PageController(viewportFraction: 0.9),
          children: [
            _buildPromoCardFallback(
              Colors.blue,
              "Diskon 50% untuk Pengguna Baru!",
            ),
            _buildPromoCardFallback(Colors.orange, "Gratis Ongkir SkyFood!"),
            _buildPromoCardFallback(
              Colors.purple,
              "Cashback 20% Pakai SkyPay!",
            ),
          ],
        ),
      );
    }

    if (_promos.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            "Promo Spesial",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 150,
          child: PageView.builder(
            controller: PageController(viewportFraction: 0.9),
            itemCount: _promos.length,
            itemBuilder: (context, index) {
              final promo = _promos[index];
              final imageUrl = promo['imageUrl'] as String?;
              final title = promo['title'] as String? ?? '';
              final description = promo['description'] as String? ?? '';
              final code = promo['code'] as String? ?? '';
              final discountAmount = promo['discountAmount'];

              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  gradient: LinearGradient(
                    colors: [Colors.green.shade400, Colors.green.shade700],
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (imageUrl != null && imageUrl.isNotEmpty)
                        Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (ctx, error, stack) =>
                              const SizedBox.shrink(),
                        ),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                              Colors.black.withOpacity(0.5),
                              Colors.transparent,
                            ],
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (description.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                description,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                            if (code.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.4),
                                  ),
                                ),
                                child: Text(
                                  "Kode: $code",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPromoCardFallback(Color color, String text) {
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

  // ================== NEWS SECTION (from API) ==================
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
          if (_news.isNotEmpty)
            ..._news.map(
              (newsItem) => _buildNewsItem(
                newsItem['title'] as String? ?? 'Berita',
                newsItem['imageUrl'] as String?,
                newsItem['content'] as String?,
              ),
            )
          else ...[
            _buildNewsItemFallback("Tips Hemat di Akhir Bulan"),
            _buildNewsItemFallback("Update Fitur Terbaru SkyGo"),
            _buildNewsItemFallback("Kuliner Wajib Coba Minggu Ini"),
          ],
        ],
      ),
    );
  }

  Widget _buildNewsItem(String title, String? imageUrl, String? content) {
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
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10),
                bottomLeft: Radius.circular(10),
              ),
              child: imageUrl != null && imageUrl.isNotEmpty
                  ? Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (ctx, error, stack) =>
                          const Icon(Icons.image, color: Colors.grey),
                    )
                  : const Icon(Icons.image, color: Colors.grey),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (content != null && content.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      content,
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _buildNewsItemFallback(String title) {
    return _buildNewsItem(title, null, null);
  }
}
