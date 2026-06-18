import 'dart:math' as math;
import 'package:flutter/material.dart';

class SellerStatsKpi {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final String? subtitle;

  const SellerStatsKpi({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.subtitle,
  });
}

class SellerStatsDonutSlice {
  final String label;
  final double value;
  final Color color;

  const SellerStatsDonutSlice({
    required this.label,
    required this.value,
    required this.color,
  });
}

class SellerStatsDashboard extends StatelessWidget {
  final String activityTitle;
  final String activitySubtitle;
  final List<double> activityPoints;
  final List<SellerStatsKpi> kpis;
  final String donutTitle;
  final String donutCenterValue;
  final String donutCenterLabel;
  final List<SellerStatsDonutSlice> donutSlices;

  const SellerStatsDashboard({
    super.key,
    required this.activityTitle,
    required this.activitySubtitle,
    required this.activityPoints,
    required this.kpis,
    required this.donutTitle,
    required this.donutCenterValue,
    required this.donutCenterLabel,
    required this.donutSlices,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ActivityChartCard(
          title: activityTitle,
          subtitle: activitySubtitle,
          points: activityPoints,
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 2.6,
          ),
          itemCount: kpis.length,
          itemBuilder: (context, index) => _KpiCard(kpi: kpis[index]),
        ),
        const SizedBox(height: 16),
        _DonutCard(
          title: donutTitle,
          centerValue: donutCenterValue,
          centerLabel: donutCenterLabel,
          slices: donutSlices,
        ),
      ],
    );
  }
}

class _ActivityChartCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<double> points;

  const _ActivityChartCard({
    required this.title,
    required this.subtitle,
    required this.points,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Icon(Icons.calendar_today_outlined,
                  size: 18, color: Colors.grey.shade500),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Max ${points.isEmpty ? 0 : points.reduce(math.max).round()}',
                style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
              ),
              Text(
                '${points.length} annonces',
                style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 140,
            width: double.infinity,
            child: CustomPaint(
              painter: _AreaLineChartPainter(
                points: points,
                lineColor: const Color(0xFFF8BF13),
                fillColor: const Color(0xFFF8BF13).withOpacity(0.22),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(
              points.length.clamp(1, 8),
              (i) => Text(
                '${i + 1}',
                style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _KpiCard extends StatelessWidget {
  final SellerStatsKpi kpi;

  const _KpiCard({required this.kpi});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: kpi.color.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          Icon(kpi.icon, color: kpi.color, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  kpi.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  kpi.value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DonutCard extends StatelessWidget {
  final String title;
  final String centerValue;
  final String centerLabel;
  final List<SellerStatsDonutSlice> slices;

  const _DonutCard({
    required this.title,
    required this.centerValue,
    required this.centerLabel,
    required this.slices,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 180,
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: CustomPaint(
                    painter: _SemiDonutPainter(slices: slices),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 36),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              centerValue,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              centerLabel,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: slices.map((s) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: s.color,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                s.label,
                                style: const TextStyle(fontSize: 11),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AreaLineChartPainter extends CustomPainter {
  final List<double> points;
  final Color lineColor;
  final Color fillColor;

  _AreaLineChartPainter({
    required this.points,
    required this.lineColor,
    required this.fillColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;
    final data = points.length == 1 ? [points.first, points.first] : points;
    final maxVal = data.reduce(math.max);
    final minVal = data.reduce(math.min);
    final range = (maxVal - minVal).abs() < 1 ? 1.0 : (maxVal - minVal);

    final dx = size.width / (data.length - 1);
    final path = Path();
    final fillPath = Path();

    for (var i = 0; i < data.length; i++) {
      final x = i * dx;
      final y = size.height - ((data[i] - minVal) / range) * (size.height - 16) - 8;
      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }
    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    canvas.drawPath(fillPath, Paint()..color = fillColor);
    canvas.drawPath(
      path,
      Paint()
        ..color = lineColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    for (var i = 0; i < data.length; i++) {
      final x = i * dx;
      final y = size.height - ((data[i] - minVal) / range) * (size.height - 16) - 8;
      canvas.drawCircle(Offset(x, y), 4, Paint()..color = lineColor);
      canvas.drawCircle(Offset(x, y), 2, Paint()..color = Colors.white);
    }
  }

  @override
  bool shouldRepaint(covariant _AreaLineChartPainter oldDelegate) {
    return oldDelegate.points != points;
  }
}

class _SemiDonutPainter extends CustomPainter {
  final List<SellerStatsDonutSlice> slices;

  _SemiDonutPainter({required this.slices});

  @override
  void paint(Canvas canvas, Size size) {
    final total = slices.fold<double>(0, (s, e) => s + e.value);
    if (total <= 0) return;

    final center = Offset(size.width / 2, size.height * 0.82);
    final radius = math.min(size.width, size.height) * 0.42;
    const stroke = 22.0;
    var start = math.pi;

    for (final slice in slices) {
      if (slice.value <= 0) continue;
      final sweep = (slice.value / total) * math.pi;
      final paint = Paint()
        ..color = slice.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.butt;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        start,
        sweep,
        false,
        paint,
      );
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _SemiDonutPainter oldDelegate) {
    return oldDelegate.slices != slices;
  }
}
