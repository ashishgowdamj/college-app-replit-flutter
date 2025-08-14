import 'package:flutter/material.dart';
import '../models/college.dart';

/// A single accordion section that looks like Collegedunia's compare block:
/// ┌────────────────────────────── Courses & Fees  ▾ ───────────────────────────┐
/// │  Fees                  |  ₹253,417 1st Yr Fees   |   ₹227,750 1st Yr Fees  │
/// │  Course Name           |  Bachelor of Technology…|   Bachelor of Tech…     │
/// │  Accepted Exams        |  JEE Advanced (link)    |   JEE Advanced (link)   │
/// │  Eligibility Criteria  |  10+2 with 75% + JEE…   |   10+2 with 75% + JEE…  │
/// │  Cutoff                |  171 (JEE-Advanced)     |   125 (JEE-Advanced)    │
/// │  Course Credential     |  Degree                 |   Degree                │
/// │  Mode                  |  On Campus              |   On Campus             │
/// └────────────────────────────────────────────────────────────────────────────┘
class CompareAccordion extends StatelessWidget {
  final String title;
  final List<College> colleges;
  final List<RowSpec> rows;

  const CompareAccordion({
    super.key,
    required this.title,
    required this.colleges,
    required this.rows,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final tileBg = theme.colorScheme.surfaceContainerHighest;
    final borderColor = theme.colorScheme.outlineVariant;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Theme(
        data: theme.copyWith(
          dividerColor: Colors.transparent,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          expansionTileTheme: ExpansionTileThemeData(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            collapsedShape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            backgroundColor: tileBg,
            collapsedBackgroundColor: tileBg,
            tilePadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            childrenPadding: EdgeInsets.zero,
            textColor: theme.colorScheme.onSurface,
            iconColor: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        child: ExpansionTile(
          initiallyExpanded: true,
          title: Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          children: [
            for (final r in rows) RowBlock(spec: r, colleges: colleges),
          ],
        ),
      ),
    );
  }
}

/// Row definition (label on the left + one cell per college)
class RowSpec {
  final String label;

  /// Returns plain text for each college cell (index aligned with [colleges]).
  final List<String?> Function(List<College> colleges) values;

  /// Optional: which cells should render as links (blue) and trigger [onLinkTap].
  final Set<int> linkIndices;
  final void Function(int index)? onLinkTap;

  const RowSpec({
    required this.label,
    required this.values,
    this.linkIndices = const {},
    this.onLinkTap,
  });
}

class RowBlock extends StatelessWidget {
  final RowSpec spec;
  final List<College> colleges;

  const RowBlock({super.key, required this.spec, required this.colleges});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final borderColor = theme.colorScheme.outlineVariant.withOpacity(0.6);
    final vals = spec.values(colleges);

    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: borderColor),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label column (fixed width, like screenshot)
          SizedBox(
            width: 140,
            child: Text(
              spec.label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          // Value cells (one per college)
          for (var i = 0; i < colleges.length; i++)
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(left: i == 0 ? 4 : 12),
                child: Cell(
                  text: vals.length > i ? (vals[i] ?? '—') : '—',
                  isLink: spec.linkIndices.contains(i),
                  onTap:
                      spec.onLinkTap == null ? null : () => spec.onLinkTap!(i),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class Cell extends StatelessWidget {
  final String text;
  final bool isLink;
  final VoidCallback? onTap;

  const Cell({super.key, required this.text, this.isLink = false, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = isLink
        ? theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.w600,
            decoration: TextDecoration.underline,
            decorationStyle: TextDecorationStyle.solid,
          )
        : theme.textTheme.bodyMedium;

    return GestureDetector(
      onTap: isLink ? onTap : null,
      behavior: HitTestBehavior.opaque,
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: style,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

/// Helpers your screen can use to build rows from typical College fields.
class CompareRows {
  static RowSpec fees() => RowSpec(
        label: 'Fees',
        values: (cols) => cols.map((c) {
          if (c.fees == null || c.fees!.isEmpty) return null;
          try {
            final fee = double.tryParse(c.fees!);
            if (fee == null || fee == 0) return null;
            final k = (fee / 1000).round();
            return '₹$k,000 1st Yr Fees';
          } catch (e) {
            return c.fees; // Return the raw fee string if parsing fails
          }
        }).toList(),
      );

  static RowSpec courseName(
          {String fallback = 'Bachelor of Technology [B.Tech]'}) =>
      RowSpec(
        label: 'Course Name',
        values: (cols) => List.filled(cols.length, fallback),
      );

  static RowSpec acceptedExams({
    String linkText = 'Admission Details',
    void Function(int index)? onLinkTap,
  }) {
    return RowSpec(
      label: 'Accepted Exams',
      values: (cols) => cols.map((c) {
        if (c.exams.isEmpty) return null;
        // Show first exam (you can customize to join multiple)
        return c.exams.first;
      }).toList(),
      linkIndices: {for (var i = 0; i < 10; i++) i}, // mark all as linkable
      onLinkTap: onLinkTap,
    );
  }

  static RowSpec eligibility([String text = '10+2 with 75% + JEE Advanced']) =>
      RowSpec(
          label: 'Eligibility Criteria',
          values: (cols) => List.filled(cols.length, text));

  static RowSpec cutoff(List<String?> cutoffs) =>
      RowSpec(label: 'Cutoff', values: (_) => cutoffs);

  static RowSpec credential([String text = 'Degree']) => RowSpec(
      label: 'Course Credential',
      values: (cols) => List.filled(cols.length, text));

  static RowSpec mode([String text = 'On Campus']) =>
      RowSpec(label: 'Mode', values: (cols) => List.filled(cols.length, text));
}
