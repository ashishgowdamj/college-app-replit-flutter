import 'package:flutter/material.dart';
import '../models/college.dart';

class CompareCompactTable extends StatelessWidget {
  final List<College> colleges; // expect 2
  final double? textScale; // Optional external scale override
  const CompareCompactTable({super.key, required this.colleges, this.textScale}) : assert(colleges.length >= 2);

  @override
  Widget build(BuildContext context) {
    final c1 = colleges[0];
    final c2 = colleges[1];

    final rows = _buildRows(context, c1, c2);

    // Prioritize readability: no downscaling. Let text wrap within screen width.
    final table = _TableContent(rows: rows, textScale: textScale);
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: table,
        ),
      ),
    );
  }

  List<_RowData> _buildRows(BuildContext context, College a, College b) {
    String fees(College c) => c.fees != null
        ? '₹${(c.feesAsDouble / 1000).toStringAsFixed(0)}K'
        : '—';
    String cityState(College c) => '${c.city}, ${c.state}';
    String rank(College c) => c.nirfRank != null ? '#${c.nirfRank}' : '—';
    String rating(College c) => c.ratingAsDouble > 0
        ? '${c.ratingAsDouble.toStringAsFixed(1)}/5 (${c.reviewCount ?? 0})'
        : '—';
    String type(College c) => c.type.isNotEmpty ? c.type : '—';
    String estd(College c) => c.establishedYear?.toString() ?? '—';
    String hostel(College c) => c.hostelFees != null
        ? '₹${(((double.tryParse(c.hostelFees!) ?? 0) / 1000)).toStringAsFixed(0)}K'
        : '—';
    String avgPkg(College c) => c.averagePackage != null
        ? '₹${(double.tryParse(c.averagePackage!) ?? 0).toStringAsFixed(0)}'
        : '—';
    String highPkg(College c) => c.highestPackage != null
        ? '₹${(double.tryParse(c.highestPackage!) ?? 0).toStringAsFixed(0)}'
        : '—';

    return [
      _RowData('College', a.shortName ?? a.name, b.shortName ?? b.name,
          isHeader: true),
      _RowData('Location', cityState(a), cityState(b)),
      _RowData('Type', type(a), type(b)),
      _RowData('Established', estd(a), estd(b)),
      _RowData('NIRF Rank', rank(a), rank(b)),
      _RowData('Overall Rating', rating(a), rating(b)),
      _RowData('Tuition (1st yr)', fees(a), fees(b)),
      _RowData('Hostel Fees (yr)', hostel(a), hostel(b)),
      _RowData('Avg Package', avgPkg(a), avgPkg(b)),
      _RowData('Highest Package', highPkg(a), highPkg(b)),
    ];
  }
}

class _TableContent extends StatelessWidget {
  final List<_RowData> rows;
  final double? textScale;
  const _TableContent({required this.rows, this.textScale});

  @override
  Widget build(BuildContext context) {
    final scale = (textScale ?? MediaQuery.textScaleFactorOf(context)).clamp(1.0, 2.5);
    final labelStyle = TextStyle(fontSize: 18 * scale, color: Colors.grey[800], fontWeight: FontWeight.w700);
    final valueStyle = TextStyle(fontSize: 20 * scale, fontWeight: FontWeight.w700, height: 1.2);
    final headerStyle = TextStyle(fontSize: 22 * scale, fontWeight: FontWeight.w800, height: 1.2);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(width: 170), // label col space
            Expanded(
              child: Center(child: Text('College A', style: labelStyle)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Center(child: Text('College B', style: labelStyle)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...rows.map((r) {
          final isHeader = r.isHeader;
          return Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.grey.withOpacity(0.15)),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 170,
                  child: Text(r.label, style: labelStyle),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      r.a,
                      style: isHeader ? headerStyle : valueStyle,
                      maxLines: 4,
                      softWrap: true,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Center(
                    child: Text(
                      r.b,
                      style: isHeader ? headerStyle : valueStyle,
                      maxLines: 4,
                      softWrap: true,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}

class _RowData {
  final String label;
  final String a;
  final String b;
  final bool isHeader;
  _RowData(this.label, this.a, this.b, {this.isHeader = false});
}
