import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../data/goal_catalog.dart';
import '../services/profile_provider.dart';
import '../models/user_profile.dart';
import '../services/college_provider.dart';

class CourseCustomizationDrawer extends StatefulWidget {
  const CourseCustomizationDrawer({super.key});

  @override
  State<CourseCustomizationDrawer> createState() => _CourseCustomizationDrawerState();
}

class _SelectedGoalsCard extends StatelessWidget {
  final String goal;
  final String location;
  const _SelectedGoalsCard({required this.goal, required this.location});

  @override
  Widget build(BuildContext context) {
    final hasGoal = goal.isNotEmpty;
    final hasLocation = location.isNotEmpty;
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => context.push('/select-goal'),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF111827),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Selected Goals',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.35),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Icon(GoalCatalog.goalIcon(goal), color: Colors.white70, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            hasGoal ? goal : 'Select Goal',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.35),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.place, color: Colors.white70, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            hasLocation ? location : 'Choose Location',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class _CourseCustomizationDrawerState extends State<CourseCustomizationDrawer> {
  final TextEditingController _courseSearch = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final pp = context.watch<ProfileProvider>();
    final profile = pp.profile;

    return SafeArea(
      child: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cs.primary,
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.white,
                  child: Text(
                    (profile.name.isEmpty ? 'CC' : profile.name.split(RegExp(r'\s+')).take(2).map((e) => e[0]).join()).toUpperCase(),
                    style: TextStyle(color: cs.primary, fontWeight: FontWeight.w900),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        profile.name.isEmpty ? "Ashish's Dashboard" : "${profile.name.split(' ').first}'s Dashboard",
                        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => context.push('/profile'),
                  icon: const Icon(Icons.edit, color: Colors.white),
                  tooltip: 'Customize Goal & Location',
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              children: [
                _SelectedGoalsCard(
                  goal: profile.preferredCourse,
                  location: profile.preferredState,
                ),
                const SizedBox(height: 12),

                // Course search field
                Text(
                  'Browse Categories',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _courseSearch,
                  decoration: InputDecoration(
                    hintText: 'Search Courses by Name',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    isDense: true,
                  ),
                  onSubmitted: (q) {
                    final query = q.trim();
                    if (query.isEmpty) return;
                    context.read<CollegeProvider>().updateSearchQuery(query);
                    context.go('/search');
                  },
                ),
                const SizedBox(height: 12),

                // Expandable categories
                ...GoalCatalog.defaultGoals.map((g) => _CategorySection(goal: g)),

                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                  title: const Text('All Courses',
                      style: TextStyle(fontWeight: FontWeight.w700, color: Colors.blue)),
                  trailing: const Icon(Icons.chevron_right, color: Colors.blue),
                  onTap: () => context.go('/search'),
                ),

                const SizedBox(height: 12),
                Text(
                  'Other Popular Links',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                ...[
                  _LinkTile(
                      title: 'News',
                      onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('News coming soon')))),
                  _LinkTile(
                      title: 'Admissions 2025',
                      onTap: () => context.go('/search')),
                  _LinkTile(
                      title: 'Top Courses', onTap: () => context.go('/search')),
                  _LinkTile(title: 'Institutes', onTap: () => context.go('/home')),
                  _LinkTile(
                      title: 'Top Universities & Colleges',
                      onTap: () => context.go('/search')),
                  _LinkTile(title: 'Exams', onTap: () => context.go('/search')),
                  _LinkTile(
                      title: 'Rate Us',
                      onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Thanks for supporting!')))),
                  _LinkTile(
                      title: 'Logout',
                      onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Logout not implemented')))),
                ],
                const SizedBox(height: 16),
                Center(
                  child: Text('App Version 1.0.0',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CategorySection extends StatefulWidget {
  final String goal;
  const _CategorySection({required this.goal});

  @override
  State<_CategorySection> createState() => _CategorySectionState();
}

class _CategorySectionState extends State<_CategorySection> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: false,
          onExpansionChanged: (v) => setState(() => _expanded = v),
          leading: Icon(GoalCatalog.goalIcon(widget.goal), color: cs.primary),
          title:
              Text(widget.goal, style: const TextStyle(fontWeight: FontWeight.w700)),
          trailing: Icon(_expanded ? Icons.remove : Icons.add, color: Colors.grey[800]),
          childrenPadding: const EdgeInsets.only(left: 16, right: 8, bottom: 8),
          children: [
            _ActionRow(
              title: 'Top Cities & States',
              onTap: () {
                context.read<CollegeProvider>().updateSearchQuery(widget.goal);
                context.go('/search');
              },
            ),
            _ActionRow(
              title: 'Browse By ${widget.goal} Streams',
              onTap: () {
                final hint = GoalCatalog.specializations[widget.goal] ?? const <String>[];
                final first = hint.isNotEmpty ? ' ${hint.first}' : '';
                context
                    .read<CollegeProvider>()
                    .updateSearchQuery('${widget.goal}$first');
                context.go('/search');
              },
            ),
            _ActionRow(
              title: 'College Predictor',
              onTap: () => context.go('/predictor'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  const _ActionRow({required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
      dense: true,
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}

class _LinkTile extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  const _LinkTile({required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
