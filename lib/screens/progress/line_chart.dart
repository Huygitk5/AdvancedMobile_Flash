import 'package:flutter/material.dart';
import '../../core/l10n.dart';
import '../../core/theme.dart';
import 'chart_data.dart';

/// Biểu đồ đường "Số từ đã học": có trục tung (số từ), lưới ngang, nhãn mốc thời gian dưới trục hoành,
/// và chạm / kéo ngón tay để xem giá trị chính xác tại một mốc.
class WordsLineChart extends StatefulWidget {
  final List<ChartPoint> points;
  final double height;

  const WordsLineChart({super.key, required this.points, this.height = 210});

  @override
  State<WordsLineChart> createState() => _WordsLineChartState();
}

class _WordsLineChartState extends State<WordsLineChart> {
  int? _selected;

  @override
  void didUpdateWidget(covariant WordsLineChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.points != widget.points) _selected = null;
  }

  void _select(Offset local, double width) {
    final geometry = ChartGeometry(widget.points.length, Size(width, widget.height));
    final index = geometry.nearestIndex(local.dx);
    if (index != _selected) setState(() => _selected = index);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (d) => _select(d.localPosition, width),
          onHorizontalDragUpdate: (d) => _select(d.localPosition, width),
          child: SizedBox(
            height: widget.height,
            width: double.infinity,
            child: CustomPaint(
              painter: LineChartPainter(
                points: widget.points,
                selected: _selected,
                axisColor: AppTheme.greyColor,
                gridColor: isDark ? Colors.white12 : const Color(0xFFE8ECF4),
                tooltipColor: isDark ? const Color(0xFF334155) : const Color(0xFF1E293B),
                wordsUnit: tr('từ'),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Toạ độ vùng vẽ của biểu đồ, dùng chung cho vẽ và cho việc tìm điểm gần ngón tay nhất.
class ChartGeometry {
  static const double leftPad = 34; // chỗ cho nhãn trục tung
  static const double rightPad = 10;
  static const double topPad = 26; // chỗ cho tooltip
  static const double bottomPad = 26; // chỗ cho nhãn trục hoành

  final int count;
  final Size size;

  const ChartGeometry(this.count, this.size);

  double get plotWidth => size.width - leftPad - rightPad;
  double get plotHeight => size.height - topPad - bottomPad;

  double xAt(int i) => count <= 1 ? leftPad + plotWidth / 2 : leftPad + plotWidth * i / (count - 1);

  double yAt(int value, int top) => topPad + plotHeight * (1 - (top == 0 ? 0 : value / top));

  int nearestIndex(double dx) {
    if (count <= 1) return 0;
    final ratio = ((dx - leftPad) / plotWidth).clamp(0.0, 1.0);
    return (ratio * (count - 1)).round();
  }
}

class LineChartPainter extends CustomPainter {
  final List<ChartPoint> points;
  final int? selected;
  final Color axisColor;
  final Color gridColor;
  final Color tooltipColor;
  final String wordsUnit;

  LineChartPainter({
    required this.points,
    required this.selected,
    required this.axisColor,
    required this.gridColor,
    required this.tooltipColor,
    required this.wordsUnit,
  });

  TextPainter _text(String text, double fontSize, Color color, {FontWeight weight = FontWeight.normal}) {
    return TextPainter(
      text: TextSpan(text: text, style: TextStyle(fontSize: fontSize, color: color, fontWeight: weight)),
      textDirection: TextDirection.ltr,
    )..layout();
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;
    final geo = ChartGeometry(points.length, size);
    final maxValue = points.fold<int>(0, (m, p) => p.value > m ? p.value : m);
    final scale = yAxisScale(maxValue);

    // Trục tung: 5 vạch (0 .. top) với số từ ở bên trái
    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1;
    for (var i = 0; i <= 4; i++) {
      final value = scale.step * i;
      final y = geo.yAt(value, scale.top);
      canvas.drawLine(Offset(ChartGeometry.leftPad, y), Offset(size.width - ChartGeometry.rightPad, y), gridPaint);
      final tp = _text('$value', 10, axisColor);
      tp.paint(canvas, Offset(ChartGeometry.leftPad - 6 - tp.width, y - tp.height / 2));
    }

    final offsets = [for (var i = 0; i < points.length; i++) Offset(geo.xAt(i), geo.yAt(points[i].value, scale.top))];

    // Đường + vùng tô gradient
    if (offsets.length >= 2) {
      final line = Path()..moveTo(offsets.first.dx, offsets.first.dy);
      for (var i = 1; i < offsets.length; i++) {
        line.lineTo(offsets[i].dx, offsets[i].dy);
      }
      final bottom = geo.yAt(0, scale.top);
      final fill = Path.from(line)
        ..lineTo(offsets.last.dx, bottom)
        ..lineTo(offsets.first.dx, bottom)
        ..close();
      canvas.drawPath(
        fill,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppTheme.primaryColor.withValues(alpha: 0.28), AppTheme.primaryColor.withValues(alpha: 0.0)],
          ).createShader(Rect.fromLTRB(0, ChartGeometry.topPad, size.width, bottom)),
      );
      canvas.drawPath(
        line,
        Paint()
          ..color = AppTheme.primaryColor
          ..strokeWidth = 3
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round,
      );
    }

    // Chấm tròn: ít điểm thì chấm hết, nhiều điểm chỉ chấm các điểm có dữ liệu và điểm đang chọn
    final dot = Paint()..color = AppTheme.primaryColor;
    final dotBg = Paint()..color = Colors.white;
    final showAllDots = points.length <= 14;
    for (var i = 0; i < offsets.length; i++) {
      final isSelected = i == selected;
      if (!showAllDots && !isSelected && points[i].value == 0) continue;
      if (!showAllDots && !isSelected) {
        canvas.drawCircle(offsets[i], 2.5, dot);
        continue;
      }
      canvas.drawCircle(offsets[i], isSelected ? 6.5 : 5, dotBg);
      canvas.drawCircle(offsets[i], isSelected ? 4.5 : 3, dot);
    }

    // Số liệu ngay trên các chấm khi biểu đồ thưa (<= 8 điểm) và chưa chọn điểm nào
    if (points.length <= 8 && selected == null) {
      for (var i = 0; i < offsets.length; i++) {
        if (points[i].value == 0) continue;
        final tp = _text('${points[i].value}', 10, axisColor, weight: FontWeight.w600);
        tp.paint(canvas, Offset(offsets[i].dx - tp.width / 2, offsets[i].dy - tp.height - 8));
      }
    }

    // Nhãn trục hoành: chọn bước để các nhãn không đè lên nhau
    final maxLabels = (geo.plotWidth / 46).floor().clamp(2, 12);
    final step = (points.length / maxLabels).ceil().clamp(1, 1 << 30);
    for (var i = 0; i < points.length; i += step) {
      final tp = _text(points[i].label, 10, axisColor);
      var x = offsets[i].dx - tp.width / 2;
      x = x.clamp(0.0, size.width - tp.width);
      tp.paint(canvas, Offset(x, size.height - ChartGeometry.bottomPad + 8));
    }

    // Tooltip của điểm đang chọn
    final sel = selected;
    if (sel != null && sel >= 0 && sel < points.length) {
      final p = points[sel];
      final o = offsets[sel];
      canvas.drawLine(
        Offset(o.dx, ChartGeometry.topPad),
        Offset(o.dx, geo.yAt(0, scale.top)),
        Paint()
          ..color = AppTheme.primaryColor.withValues(alpha: 0.35)
          ..strokeWidth = 1,
      );
      final title = _text(p.when, 10, Colors.white70);
      final value = _text('${p.value} $wordsUnit', 12, Colors.white, weight: FontWeight.bold);
      final w = (title.width > value.width ? title.width : value.width) + 16;
      final h = title.height + value.height + 12;
      var left = o.dx - w / 2;
      left = left.clamp(2.0, size.width - w - 2);
      var top = o.dy - h - 10;
      if (top < 0) top = o.dy + 12;
      final rect = RRect.fromRectAndRadius(Rect.fromLTWH(left, top, w, h), const Radius.circular(8));
      canvas.drawRRect(rect, Paint()..color = tooltipColor);
      title.paint(canvas, Offset(left + 8, top + 5));
      value.paint(canvas, Offset(left + 8, top + 5 + title.height + 2));
    }
  }

  @override
  bool shouldRepaint(covariant LineChartPainter old) =>
      old.points != points || old.selected != selected || old.gridColor != gridColor || old.wordsUnit != wordsUnit;
}
