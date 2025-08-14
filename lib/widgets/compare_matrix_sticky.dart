import 'package:flutter/material.dart';
import '../models/college.dart';

/// Sticky‑header comparison matrix with:
/// - Header row pinned
/// - Horizontal scroll for many columns
/// - Diff badges vs. BEST value (configurable)
/// - Null-safe rendering with em dashes
class CompareMatrixSticky extends StatefulWidget {
  final List<College> colleges;

  /// If true, diffs compare each column vs. BEST value.
  /// If false, diffs compare vs. the FIRST selected college.
  final bool compareAgainstBest;

  const CompareMatrixSticky({
    super.key,
    required this.colleges,
    this.compareAgainstBest = true,
  });

  @override
  State<CompareMatrixSticky> createState() => _CompareMatrixStickyState();
}

class _CompareMatrixStickyState extends State<CompareMatrixSticky> {
  final ScrollController _h = ScrollController();
  final ScrollController _v = ScrollController();

  @override
  void dispose() {
    _h.dispose();
    _v.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cols = widget.colleges;

    final rows = <_MetricRow>[
      _MetricRow(
        title: 'NIRF Rank',
        accessor: (c) => c.nirfRank?.toDouble(),
        betterIsHigher: false,
        format: (v) => v == null ? '—' : '#${v.toInt()}',
      ),
      _MetricRow(
        title: 'Avg. Package',
        accessor: (c) => c.averagePackage == null
            ? null
            : double.tryParse(c.averagePackage!),
        betterIsHigher: true,
        format: (v) => v == null ? '—' : '${v.toStringAsFixed(1)} LPA',
      ),
      _MetricRow(
        title: 'Fees',
        accessor: (c) => c.feesAsDouble,
        betterIsHigher: false,
        format: (v) => v == null || v == 0 ? '—' : '₹${(v / 1000).round()}k',
      ),
      _MetricRow(
        title: 'Placement Rate',
        accessor: (c) =>
            c.placementRate == null ? null : double.tryParse(c.placementRate!),
        betterIsHigher: true,
        format: (v) => v == null ? '—' : '${v.toInt()}%',
      ),
      _MetricRow(
        title: 'Rating',
        accessor: (c) => c.ratingAsDouble,
        betterIsHigher: true,
        format: (v) => v == null || v == 0 ? '—' : v.toStringAsFixed(1),
      ),
    ];

    // Precompute best and base vectors
    final valuesByRow = [
      for (final r in rows) cols.map(r.accessor).toList(growable: false)
    ];
    final bestByRow = [
      for (var ri = 0; ri < rows.length; ri++)
        _best(valuesByRow[ri], rows[ri].betterIsHigher)
    ];
    final baseIndex = widget.compareAgainstBest ? null : 0; // first column

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          border: Border.all(color: theme.colorScheme.outlineVariant),
        ),
        child: Column(
          children: [
            // Sticky header bar (not inside vertical scroll)
            _HeaderBar(
              colleges: cols,
              h: _h,
            ),
            const Divider(height: 1),
            // Scrollable body
            SizedBox(
              height: 380, // adjust if you want taller
              child: Scrollbar(
                controller: _v,
                thumbVisibility: true,
                child: SingleChildScrollView(
                  controller: _v,
                  child: Column(
                    children: [
                      for (var ri = 0; ri < rows.length; ri++)
                        _MetricRowWidget(
                          row: rows[ri],
                          values: valuesByRow[ri],
                          best: bestByRow[ri],
                          base: baseIndex ?? bestByRow[ri].index,
                          compareAgainstBest: widget.compareAgainstBest,
                          h: _h,
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderBar extends StatelessWidget {
  final List<College> colleges;
  final ScrollController h;
  const _HeaderBar({required this.colleges, required this.h});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      color: theme.colorScheme.surfaceContainerHighest,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            width: 140,
            child: Text(
              'Metric',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          // Horizontal scrollable name headers
          Expanded(
            child: SingleChildScrollView(
              controller: h,
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (final c in colleges)
                    SizedBox(
                      width: 220,
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
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricRow {
  final String title;
  final double? Function(College) accessor;
  final String Function(double?) format;
  final bool betterIsHigher;

  _MetricRow({
    required this.title,
    required this.accessor,
    required this.format,
    required this.betterIsHigher,
  });
}

class _BestInfo {
  final int? index;
  final double? value;
  const _BestInfo(this.index, this.value);
}

_BestInfo _best(List<double?> vals, bool higher) {
  int? idx;
  double? best;
  for (var i = 0; i < vals.length; i++) {
    final v = vals[i];
    if (v == null) continue;
    if (best == null) {
      idx = i;
      best = v;
    } else {
      final better = higher ? v > best : v < best;
      if (better) {
        idx = i;
        best = v;
      }
    }
  }
  return _BestInfo(idx, best);
}

class _MetricRowWidget extends StatelessWidget {
  final _MetricRow row;
  final List<double?> values;
  final _BestInfo best;
  final int? base; // index of baseline column
  final bool compareAgainstBest;
  final ScrollController h;

  const _MetricRowWidget({
    required this.row,
    required this.values,
    required this.best,
    required this.base,
    required this.compareAgainstBest,
    required this.h,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final borderColor = theme.colorScheme.outlineVariant.withOpacity(0.5);

    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: borderColor)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(width: 140, child: Text(row.title)),
          // Horizontal scrollable cells
          Expanded(
            child: SingleChildScrollView(
              controller: h,
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (var i = 0; i < values.length; i++)
                    _Cell(
                      width: 220,
                      text: row.format(values[i]),
                      isBest: (values[i] != null &&
                          best.value != null &&
                          values[i] == best.value),
                      betterIsHigher: row.betterIsHigher,
                      diff: _diff(values, i, base, row.betterIsHigher),
                      compareAgainstBest: compareAgainstBest,
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  double? _diff(List<double?> vals, int i, int? base, bool higher) {
    if (vals[i] == null) return null;
    if (base == null || base < 0 || base >= vals.length) return null;
    final b = vals[base];
    if (b == null) return null;
    // Note: for rank/fee (lower is better), we still show signed delta (negative is better)
    return vals[i]! - b;
  }
}

class _Cell extends StatelessWidget {
  final String text;
  final bool isBest;
  final bool betterIsHigher;
  final double? diff;
  final bool compareAgainstBest;
  final double width;

  const _Cell({
    required this.text,
    required this.isBest,
    required this.betterIsHigher,
    required this.diff,
    required this.compareAgainstBest,
    this.width = 220,
  });

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
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      margin: const EdgeInsets.only(left: 12, top: 8, bottom: 8),
      decoration: BoxDecoration(
        color: bg,
        border: Border.all(color: border),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(child: Text(text, style: TextStyle(fontWeight: fw))),
          const SizedBox(width: 8),
          _DiffBadge(
            diff: diff,
            betterIsHigher: betterIsHigher,
            compareAgainstBest: compareAgainstBest,
          ),
        ],
      ),
    );
  }
}

class _DiffBadge extends StatelessWidget {
  final double? diff;
  final bool betterIsHigher;
  final bool compareAgainstBest;

  const _DiffBadge({
    required this.diff,
    required this.betterIsHigher,
    required this.compareAgainstBest,
  });

  @override
  Widget build(BuildContext context) {
    if (diff == null || diff!.abs() < 1e-6) return const SizedBox.shrink();

    // For higher-is-better metrics:
    //   positive diff = worse vs base/best, negative = better
    // For lower-is-better metrics:
    //   positive diff = better, negative = worse
    final isBetter = betterIsHigher ? (diff! < 0) : (diff! > 0);
    final arrow = isBetter ? '▲' : '▼';
    final color = isBetter
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.error;

    // Format number compactly
    String fmt(double v) {
      final a = v.abs();
      if (a >= 1000 && a % 1000 < 1e-6) {
        return '${(v / 1000).toStringAsFixed(0)}k';
      }
      if (a >= 100) return v.toStringAsFixed(0);
      if (a >= 10) return v.toStringAsFixed(1);
      return v.toStringAsFixed(2);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        '$arrow ${fmt(diff!)}',
        style: TextStyle(
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
