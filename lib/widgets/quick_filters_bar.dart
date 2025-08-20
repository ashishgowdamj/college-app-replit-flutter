import 'package:flutter/material.dart';

typedef OnFilter = void Function(String query);

class QuickFiltersBar extends StatefulWidget {
  final OnFilter onFilter;
  const QuickFiltersBar({super.key, required this.onFilter});

  @override
  State<QuickFiltersBar> createState() => _QuickFiltersBarState();
}

class _QuickFiltersBarState extends State<QuickFiltersBar> {
  String _active = 'All';

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final chips = <String>[
      'All', 'IIT', 'NIT', 'IIIT', 'Private', 'Delhi', 'Karnataka', 'Maharashtra'
    ];

    return Container(
      height: 56,
      color: cs.surface,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        scrollDirection: Axis.horizontal,
        itemBuilder: (_, i) => ChoiceChip(
          label: Text(chips[i]),
          selected: _active == chips[i],
          onSelected: (_) {
            setState(() => _active = chips[i]);
            // naive filter: just pass chip as query text to provider.setQuery
            widget.onFilter(_active == 'All' ? '' : chips[i]);
          },
        ),
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemCount: chips.length,
      ),
    );
  }
}
