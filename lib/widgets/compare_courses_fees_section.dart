import 'package:flutter/material.dart';
import '../models/college.dart';

class CompareCoursesFeesSection extends StatelessWidget {
  final College a;
  final College b;
  final VoidCallback? onEditLeft;
  final VoidCallback? onEditRight;
  const CompareCoursesFeesSection({super.key, required this.a, required this.b, this.onEditLeft, this.onEditRight});

  @override
  Widget build(BuildContext context) {
    final labelStyle = TextStyle(
      fontSize: 14,
      color: Colors.grey[700],
      fontWeight: FontWeight.w600,
    );
    const valueStyle = TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
    );
    final linkStyle = TextStyle(
      fontSize: 14,
      color: Theme.of(context).colorScheme.primary,
      fontWeight: FontWeight.w600,
      decoration: TextDecoration.underline,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Top headers with college names and edit icons (visual only)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              Expanded(child: _collegeHeader(a, context, onEditLeft)),
              const SizedBox(width: 12),
              Expanded(child: _collegeHeader(b, context, onEditRight)),
            ],
          ),
        ),
        const SizedBox(height: 4),
        // Courses & Fees expandable section
        _SectionContainer(
          title: 'Courses & Fees',
          child: Column(
            children: [
              _LabeledRow(label: 'Fees', labelStyle: labelStyle),
              _ValuesRow(
                left: a.fees != null
                    ? '₹${(a.feesAsDouble).toStringAsFixed(0)} 1st Yr Fees'
                    : '—',
                right: b.fees != null
                    ? '₹${(b.feesAsDouble).toStringAsFixed(0)} 1st Yr Fees'
                    : '—',
                valueStyle: valueStyle,
              ),
              const Divider(height: 24),

              _LabeledRow(label: 'Course Name', labelStyle: labelStyle),
              _ValuesRow(
                left: 'Bachelor of Technology [B.Tech]',
                right: 'Bachelor of Technology [B.Tech]',
                valueStyle: valueStyle,
              ),
              const Divider(height: 24),

              _LabeledRow(label: 'Accepted Exams', labelStyle: labelStyle),
              _ValuesRow(
                left: 'JEE Advanced\n18 May 25',
                right: 'JEE Advanced\n18 May 25',
                valueStyle: valueStyle,
                maxLines: 3,
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: Center(
                      child: GestureDetector(
                        onTap: () {},
                        child: Text('Admission Details', style: linkStyle),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Center(
                      child: GestureDetector(
                        onTap: () {},
                        child: Text('Admission Details', style: linkStyle),
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),

              _LabeledRow(label: 'Eligibility Criteria', labelStyle: labelStyle),
              _ValuesRow(
                left: '10+2 with 75% + JEE Advanced',
                right: '10+2 with 75% + JEE Advanced',
                valueStyle: valueStyle,
                maxLines: 2,
              ),
              const Divider(height: 24),

              _LabeledRow(label: 'Cutoff', labelStyle: labelStyle),
              _ValuesRow(
                left: a.cutoffScore != null
                    ? '${a.cutoffScore} (JEE-Advanced)'
                    : '—',
                right: b.cutoffScore != null
                    ? '${b.cutoffScore} (JEE-Advanced)'
                    : '—',
                valueStyle: valueStyle,
              ),
              const Divider(height: 24),

              _LabeledRow(label: 'Course Credential', labelStyle: labelStyle),
              _ValuesRow(
                left: 'Degree',
                right: 'Degree',
                valueStyle: valueStyle,
              ),
              const Divider(height: 24),

              _LabeledRow(label: 'Mode', labelStyle: labelStyle),
              _ValuesRow(
                left: 'On Campus',
                right: 'On Campus',
                valueStyle: valueStyle,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // College Ranking
        _SectionContainer(
          title: 'College Ranking',
          child: Column(
            children: [
              _LabeledRow(label: 'Overall Rank', labelStyle: labelStyle),
              _ValuesRow(
                left: a.overallRank != null ? '#${a.overallRank}' : '—',
                right: b.overallRank != null ? '#${b.overallRank}' : '—',
                valueStyle: valueStyle,
              ),
              const Divider(height: 24),

              _LabeledRow(label: 'NIRF Rank', labelStyle: labelStyle),
              _ValuesRow(
                left: a.nirfRank != null ? '#${a.nirfRank}' : '—',
                right: b.nirfRank != null ? '#${b.nirfRank}' : '—',
                valueStyle: valueStyle,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // College Info
        _SectionContainer(
          title: 'College Info',
          child: Column(
            children: [
              _LabeledRow(label: 'Established', labelStyle: labelStyle),
              _ValuesRow(
                left: a.establishedYear?.toString() ?? '—',
                right: b.establishedYear?.toString() ?? '—',
                valueStyle: valueStyle,
              ),
              const Divider(height: 24),

              _LabeledRow(label: 'Type', labelStyle: labelStyle),
              _ValuesRow(
                left: a.type,
                right: b.type,
                valueStyle: valueStyle,
              ),
              const Divider(height: 24),

              _LabeledRow(label: 'Affiliation', labelStyle: labelStyle),
              _ValuesRow(
                left: a.affiliation ?? '—',
                right: b.affiliation ?? '—',
                valueStyle: valueStyle,
                maxLines: 3,
              ),
              const Divider(height: 24),

              _LabeledRow(label: 'Location', labelStyle: labelStyle),
              _ValuesRow(
                left: '${a.city}, ${a.state}',
                right: '${b.city}, ${b.state}',
                valueStyle: valueStyle,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // College Rating & Reviews
        _SectionContainer(
          title: 'College Rating & Reviews',
          child: Column(
            children: [
              _LabeledRow(label: 'Rating', labelStyle: labelStyle),
              _ValuesRow(
                left: a.rating != null && a.rating!.isNotEmpty ? '${a.rating}/5' : '—',
                right: b.rating != null && b.rating!.isNotEmpty ? '${b.rating}/5' : '—',
                valueStyle: valueStyle,
              ),
              const Divider(height: 24),

              _LabeledRow(label: 'Review Count', labelStyle: labelStyle),
              _ValuesRow(
                left: a.reviewCount != null ? '${a.reviewCount} reviews' : '—',
                right: b.reviewCount != null ? '${b.reviewCount} reviews' : '—',
                valueStyle: valueStyle,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // College Placements
        _SectionContainer(
          title: 'College Placements',
          child: Column(
            children: [
              _LabeledRow(label: 'Placement Rate', labelStyle: labelStyle),
              _ValuesRow(
                left: a.placementRate ?? '—',
                right: b.placementRate ?? '—',
                valueStyle: valueStyle,
              ),
              const Divider(height: 24),

              _LabeledRow(label: 'Average Package', labelStyle: labelStyle),
              _ValuesRow(
                left: a.averagePackage ?? '—',
                right: b.averagePackage ?? '—',
                valueStyle: valueStyle,
              ),
              const Divider(height: 24),

              _LabeledRow(label: 'Highest Package', labelStyle: labelStyle),
              _ValuesRow(
                left: a.highestPackage ?? '—',
                right: b.highestPackage ?? '—',
                valueStyle: valueStyle,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // College Facilities
        _SectionContainer(
          title: 'College Facilities',
          child: Column(
            children: [
              _LabeledRow(label: 'Hostel', labelStyle: labelStyle),
              _ValuesRow(
                left: a.hasHostel == true ? 'Available' : 'Not Available',
                right: b.hasHostel == true ? 'Available' : 'Not Available',
                valueStyle: valueStyle,
              ),
              const Divider(height: 24),

              _LabeledRow(label: 'Hostel Fees', labelStyle: labelStyle),
              _ValuesRow(
                left: (a.hostelFees != null && a.hostelFees!.isNotEmpty) ? '₹${a.hostelFees}' : '—',
                right: (b.hostelFees != null && b.hostelFees!.isNotEmpty) ? '₹${b.hostelFees}' : '—',
                valueStyle: valueStyle,
              ),
              const Divider(height: 24),

              _LabeledRow(label: 'Website', labelStyle: labelStyle),
              _ValuesRow(
                left: a.website ?? '—',
                right: b.website ?? '—',
                valueStyle: valueStyle,
                maxLines: 2,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _collegeHeader(College c, BuildContext context, VoidCallback? onEdit) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                c.shortName ?? c.name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            IconButton(
              icon: Icon(Icons.edit, size: 18, color: Colors.orange[700]),
              splashRadius: 16,
              tooltip: 'Change college',
              onPressed: onEdit,
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Bachelor of Technology\n[B.Tech]',
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[800],
            height: 1.25,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        Text(
          'Computer Science and\nEngineering',
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[800],
            height: 1.25,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class _SectionContainer extends StatefulWidget {
  final String title;
  final Widget child;
  const _SectionContainer({required this.title, required this.child});

  @override
  State<_SectionContainer> createState() => _SectionContainerState();
}

class _SectionContainerState extends State<_SectionContainer> {
  bool _expanded = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    turns: _expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(Icons.keyboard_arrow_down),
                  ),
                ],
              ),
            ),
          ),
          if (_expanded)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: widget.child,
            ),
        ],
      ),
    );
  }
}

class _LabeledRow extends StatelessWidget {
  final String label;
  final TextStyle labelStyle;
  const _LabeledRow({required this.label, required this.labelStyle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 6, bottom: 10),
      child: Center(
        child: Text(label, style: labelStyle),
      ),
    );
  }
}

class _ValuesRow extends StatelessWidget {
  final String left;
  final String right;
  final TextStyle valueStyle;
  final int maxLines;
  const _ValuesRow({
    required this.left,
    required this.right,
    required this.valueStyle,
    this.maxLines = 2,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Center(
            child: Text(
              left,
              style: valueStyle,
              textAlign: TextAlign.center,
              maxLines: maxLines,
              softWrap: true,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Center(
            child: Text(
              right,
              style: valueStyle,
              textAlign: TextAlign.center,
              maxLines: maxLines,
              softWrap: true,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ],
    );
  }
}
