import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../home/home_screen.dart';
import '../vocabulary/topic_screen.dart';
import '../progress/progress_screen.dart';
import '../challenge/challenge_screen.dart';
import '../profile/profile_screen.dart';
import 'dart:ui';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  List<Widget> get _pages => [
    HomeScreen(onSwitchTab: (index) => setState(() => _currentIndex = index)),
    const TopicScreen(),
    const ProgressScreen(),
    const ChallengeScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, // Ép nội dung cuộn luồn xuống dưới Navbar
      body: _pages[_currentIndex],
      bottomNavigationBar: _buildCustomNavBar(),
    );
  }

  static const double _barHeight = 60; // thanh nền
  static const double _bump = 20;      // độ cao vòng cung

  static const List<_NavData> _navItems = [
    _NavData(Icons.home_filled, 'Trang chủ', Color(0xFF3366FF)),
    _NavData(Icons.menu_book, 'Học tập', Color(0xFF2FBF71)),
    _NavData(Icons.bar_chart, 'Tiến độ', Color(0xFF8B5CF6)),
    _NavData(Icons.emoji_events_outlined, 'Thử thách', Color(0xFFFF9F1C)),
    _NavData(Icons.person_outline, 'Cá nhân', Color(0xFFFF5C7A)),
  ];

  Widget _buildCustomNavBar() {
    // Bỏ SafeArea để thanh nền chạm sát đáy, phần inset được tô cùng màu nền
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return SizedBox(
      height: _barHeight + _bump + bottomInset,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final itemWidth = constraints.maxWidth / _navItems.length;

          return Stack(
            clipBehavior: Clip.none,
            children: [
              // 1. Nền: blur + vòng cung trượt mượt theo tab đang chọn
              Positioned.fill(
                child: TweenAnimationBuilder<double>(
                  tween: Tween<double>(end: _currentIndex.toDouble()),
                  duration: const Duration(milliseconds: 350),
                  curve: Curves.easeOutCubic,
                  builder: (context, pos, _) {
                    final centerX = (pos + 0.5) * itemWidth;
                    final halfWidth = itemWidth * 0.6;

                    return Stack(
                      children: [
                        // Lớp blur cắt đúng theo hình thanh nền
                        Positioned.fill(
                          child: ClipPath(
                            clipper: _NavBarClipper(
                              centerX: centerX,
                              bumpHeight: _bump,
                              halfWidth: halfWidth,
                            ),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
                              child: Container(color: Colors.transparent),
                            ),
                          ),
                        ),
                        // Lớp màu nền + bóng
                        Positioned.fill(
                          child: CustomPaint(
                            painter: _NavBarPainter(
                              centerX: centerX,
                              bumpHeight: _bump,
                              halfWidth: halfWidth,
                              color: Theme.of(context).cardColor.withValues(alpha: 0.1),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              // 2. Các tab
              Positioned(
                left: 0,
                right: 0,
                top: 0,
                height: _barHeight + _bump,
                child: Row(
                  children: List.generate(
                    _navItems.length,
                        (i) => _buildNavItem(i, itemWidth),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildNavItem(int index, double itemWidth) {
    final item = _navItems[index];
    final isSelected = _currentIndex == index;

    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: itemWidth,
        height: _barHeight + _bump,
        child: TweenAnimationBuilder<double>(
          tween: Tween<double>(end: isSelected ? 1.0 : 0.0),
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutBack, // nảy nhẹ
          builder: (context, t, _) {
            final tc = t.clamp(0.0, 1.0); // dùng cho màu (tránh vượt 0..1 do easeOutBack)
            final color = Color.lerp(AppTheme.greyColor, item.color, tc)!;

            return Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Icon: nhô lên + to ra
                Transform.translate(
                  offset: Offset(0, -12 * t),
                  child: Transform.scale(
                    scale: 1 + 0.35 * t,
                    child: Icon(item.icon, size: 26, color: color),
                  ),
                ),
                const SizedBox(height: 4),
                // Text: nhích lên + to ra theo icon
                Transform.translate(
                  offset: Offset(0, -3 * t),
                  child: Transform.scale(
                    scale: 1 + 0.2 * t,
                    child: Text(
                      item.label,
                      maxLines: 1,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        color: color,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _NavData {
  final IconData icon;
  final String label;
  final Color color; // màu riêng của từng trang
  const _NavData(this.icon, this.label, this.color);
}

// Hình dạng thanh nền, dùng chung cho cả vẽ nền và cắt vùng blur
Path _navBarPath(Size size, double centerX, double bumpHeight, double halfWidth) {
  final top = bumpHeight;
  return Path()
    ..moveTo(0, top)
    ..lineTo(centerX - halfWidth, top)
    ..cubicTo(centerX - halfWidth * 0.5, top, centerX - halfWidth * 0.5, 0, centerX, 0)
    ..cubicTo(centerX + halfWidth * 0.5, 0, centerX + halfWidth * 0.5, top, centerX + halfWidth, top)
    ..lineTo(size.width, top)
    ..lineTo(size.width, size.height)
    ..lineTo(0, size.height)
    ..close();
}

class _NavBarClipper extends CustomClipper<Path> {
  final double centerX;
  final double bumpHeight;
  final double halfWidth;

  const _NavBarClipper({
    required this.centerX,
    required this.bumpHeight,
    required this.halfWidth,
  });

  @override
  Path getClip(Size size) => _navBarPath(size, centerX, bumpHeight, halfWidth);

  @override
  bool shouldReclip(covariant _NavBarClipper old) =>
      old.centerX != centerX || old.bumpHeight != bumpHeight || old.halfWidth != halfWidth;
}

// Vẽ thanh nền có vòng cung nhô lên ở vị trí tab đang chọn
class _NavBarPainter extends CustomPainter {
  final double centerX;
  final double bumpHeight;
  final double halfWidth;
  final Color color;

  const _NavBarPainter({
    required this.centerX,
    required this.bumpHeight,
    required this.halfWidth,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final path = _navBarPath(size, centerX, bumpHeight, halfWidth);

    // Bóng đổ: chỉ vẽ bên ngoài hình thanh nền
    canvas.save();
    canvas.clipPath(
      Path.combine(
        PathOperation.difference,
        Path()..addRect(Rect.fromLTWH(-50, -50, size.width + 100, size.height + 100)),
        path,
      ),
    );
    canvas.drawPath(
      path.shift(const Offset(0, -2)),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.10)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
    );
    canvas.restore();

    // Nền (bán trong suốt để thấy lớp blur phía sau)
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _NavBarPainter old) =>
      old.centerX != centerX || old.color != color || old.bumpHeight != bumpHeight || old.halfWidth != halfWidth;
}