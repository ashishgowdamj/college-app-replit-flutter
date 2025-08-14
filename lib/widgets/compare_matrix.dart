import 'package:flutter/material.dart';
import '../models/college.dart';

class CompareMatrix extends StatelessWidget {
  final List<College> colleges;
  const CompareMatrix({super.key, required this.colleges});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cols = colleges;

    final rows = <_MetricRow>[
      _MetricRow(
        title: 'NIRF Rank',
        accessorNum: (c) => c.nirfRank?.toDouble(),
        betterIsHigher: false,
        format: (v) => v == null ? '—' : '#${v.toInt()}',
      ),
      _MetricRow(
        title: 'Avg. Package',
        accessorNum: (c) => c.averagePackage == null
            ? null
            : double.tryParse(c.averagePackage!),
        betterIsHigher: true,
        format: (v) => v == null ? '—' : '${v.toStringAsFixed(1)} LPA',
      ),
      _MetricRow(
        title: 'Fees',
        accessorNum: (c) => c.feesAsDouble,
        betterIsHigher: false,
        format: (v) => v == null || v == 0 ? '—' : '₹${(v / 1000).round()}k',
      ),
      _MetricRow(
        title: 'Placement Rate',
        accessorNum: (c) =>
            c.placementRate == null ? null : double.tryParse(c.placementRate!),
        betterIsHigher: true,
        format: (v) => v == null ? '—' : '${v.toInt()}%',
      ),
      _MetricRow(
        title: 'Rating',
        accessorNum: (c) => c.ratingAsDouble,
        betterIsHigher: true,
        format: (v) => v == null || v == 0 ? '—' : v.toStringAsFixed(1),
      ),
    ];

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(color: theme.colorScheme.outlineVariant),
          color: theme.colorScheme.surface,
        ),
        child: Column(
          children: [
            _HeaderRow(colleges: cols),
            const Divider(height: 1),
            for (final r in rows) _MetricRowWidget(row: r, colleges: cols),
          ],
        ),
      ),
    );
  }
}

class _HeaderRow extends StatelessWidget {
  final List<College> colleges;
  const _HeaderRow({required this.colleges});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      color: theme.colorScheme.surfaceContainerHighest,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
              width: 140,
              child: Text('Metric',
                  style: TextStyle(fontWeight: FontWeight.w700))),
          for (final c in colleges)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 12),
                child: Text(
                  c.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _MetricRow {
  final String title;
  final double? Function(College) accessorNum; // null-safe numeric accessor
  final String Function(double?) format;
  final bool betterIsHigher;

  _MetricRow({
    required this.title,
    required this.accessorNum,
    required this.format,
    required this.betterIsHigher,
  });
}

class _MetricRowWidget extends StatelessWidget {
  final _MetricRow row;
  final List<College> colleges;

  const _MetricRowWidget({required this.row, required this.colleges});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Compute best value index(es)
    final values = colleges.map(row.accessorNum).toList();
    double? best;
    for (final v in values) {
      if (v == null) continue;
      if (best == null) {
        best = v;
      } else {
        best =
            row.betterIsHigher ? (v > best ? v : best) : (v < best ? v : best);
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
            bottom: BorderSide(
                color: theme.colorScheme.outlineVariant.withOpacity(0.5))),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(width: 140, child: Text(row.title)),
          for (var i = 0; i < colleges.length; i++)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 12),
                child: _Cell(
                  text: row.format(values[i]),
                  isBest:
                      (values[i] != null && best != null && values[i] == best),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Cell extends StatelessWidget {
  final String text;
  final bool isBest;
  const _Cell({required this.text, required this.isBest});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bg = isBest ? theme.colorScheme.primary.withOpacity(0.10) : null;
    final border = isBest
        ? theme.colorScheme.primary.withOpacity(0.55)
        : theme.colorScheme.outlineVariant;
    final fw = isBest ? FontWeight.w700 : FontWeight.w500;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: bg,
        border: Border.all(color: border),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(text, style: TextStyle(fontWeight: fw)),
    );
  }
}
