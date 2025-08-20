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

class _CourseCustomizationDrawerState extends State<CourseCustomizationDrawer> {
  // Track expanded categories (multiple expansion allowed)
  final Set<String> _expanded = <String>{};
  bool _allCoursesExpanded = false;

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
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => context.push('/select-goal'),
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
                // Selected goals box under the header
                _SelectedGoalsBox(profile: profile),
                const SizedBox(height: 12),

                // Section header
                const SizedBox(height: 6),
                Text('Browse Categories', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: 12),

                // Categories list (expand/collapse)
                ...GoalCatalog.defaultGoals.map((g) {
                  final expanded = _expanded.contains(g);
                  return _CategoryExpandable(
                    title: g,
                    icon: GoalCatalog.goalIcon(g),
                    expanded: expanded,
                    onToggle: () {
                      setState(() {
                        if (expanded) {
                          _expanded.remove(g);
                        } else {
                          _expanded.add(g);
                        }
                      });
                    },
                    onNavigateTopCities: () {
                      // Prefill query with goal and go to search
                      context.read<CollegeProvider>().updateSearchQuery(g);
                      Navigator.of(context).pop();
                      context.go('/search');
                    },
                    onNavigateStreams: () {
                      // Prefill query with "<goal> streams" and go to search
                      context.read<CollegeProvider>().updateSearchQuery('$g streams');
                      Navigator.of(context).pop();
                      context.go('/search');
                    },
                    onNavigatePredictor: () {
                      Navigator.of(context).pop();
                      context.go('/predictor');
                    },
                  );
                }),

                // All Courses expandable dropdown
                Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                        title: const Text('All Courses', style: TextStyle(fontWeight: FontWeight.w700, color: Colors.blue)),
                        trailing: Icon(_allCoursesExpanded ? Icons.remove : Icons.add, color: Colors.blue),
                        onTap: () => setState(() => _allCoursesExpanded = !_allCoursesExpanded),
                      ),
                      if (_allCoursesExpanded) const Divider(height: 1),
                      if (_allCoursesExpanded)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              for (final c in GoalCatalog.otherCourses)
                                ActionChip(
                                  label: Text(c, style: const TextStyle(fontWeight: FontWeight.w600)),
                                  onPressed: () {
                                    context.read<CollegeProvider>().updateSearchQuery(c);
                                    Navigator.of(context).pop();
                                    context.go('/search');
                                  },
                                ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),
                Text('Helpful For Your Career', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                _ToolsGrid(onNavigate: (route) {
                  if (route == '/predictor') {
                    context.go('/predictor');
                  } else if (route == '/search') context.go('/search');
                  else {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Coming soon')));
                  }
                }),

                const SizedBox(height: 12),
                Text('Other Popular Links', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                ...[
                  _LinkTile(title: 'News', onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('News coming soon')))),
                  _LinkTile(title: 'Admissions 2025', onTap: () => context.go('/search')),
                  _LinkTile(title: 'Top Courses', onTap: () => context.go('/search')),
                  _LinkTile(title: 'Institutes', onTap: () => context.go('/home')),
                  _LinkTile(title: 'Top Universities & Colleges', onTap: () => context.go('/search')),
                  _LinkTile(title: 'Exams', onTap: () => context.go('/search')),
                  _LinkTile(title: 'Rate Us', onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Thanks for supporting!')))),
                  _LinkTile(title: 'Logout', onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Logout not implemented')))),
                ],
                const SizedBox(height: 16),
                Center(
                  child: Text('App Version 1.0.0', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
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

class _CategoryExpandable extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool expanded;
  final VoidCallback onToggle;
  final VoidCallback onNavigateTopCities;
  final VoidCallback onNavigateStreams;
  final VoidCallback onNavigatePredictor;

  const _CategoryExpandable({
    required this.title,
    required this.icon,
    required this.expanded,
    required this.onToggle,
    required this.onNavigateTopCities,
    required this.onNavigateStreams,
    required this.onNavigatePredictor,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = Colors.grey[300]!;
    final primary = Theme.of(context).colorScheme.primary;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          ListTile(
            leading: Icon(icon, color: primary),
            title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
            trailing: Icon(expanded ? Icons.remove : Icons.add),
            onTap: onToggle,
          ),
          if (expanded) const Divider(height: 1),
          if (expanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
              child: Column(
                children: [
                  _SubLink(
                    title: 'Top Cities & States',
                    onTap: onNavigateTopCities,
                  ),
                  _SubLink(
                    title: 'Browse By $title Streams',
                    onTap: onNavigateStreams,
                  ),
                  _SubLink(
                    title: 'College Predictor',
                    onTap: onNavigatePredictor,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _SubLink extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  const _SubLink({required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        child: Row(
          children: [
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
}

 

class _ToolsGrid extends StatelessWidget {
  final void Function(String route) onNavigate;
  const _ToolsGrid({required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    final tiles = <_ToolItem>[
      const _ToolItem('Course Finder', Icons.search_rounded, '/search'),
      const _ToolItem('College Predictor', Icons.psychology, '/predictor'),
      const _ToolItem('Education Loan', Icons.account_balance, '/loans'),
      const _ToolItem('Ask a Question', Icons.chat_bubble_outline, '/ask'),
      const _ToolItem('Test Series', Icons.menu_book_outlined, '/tests'),
      const _ToolItem('Practice Questions', Icons.quiz_outlined, '/practice'),
      const _ToolItem('Read College Reviews', Icons.home_work_outlined, '/reviews'),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        // Responsive columns based on available width inside the Drawer
        final w = constraints.maxWidth;
        int cols;
        if (w < 240) {
          cols = 2;
        } else if (w < 340) {
          cols = 3;
        } else {
          cols = 4;
        }
        return GridView.builder(
          itemCount: tiles.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: cols,
            childAspectRatio: 1.05,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemBuilder: (context, i) {
            final t = tiles[i];
            return InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => onNavigate(t.route),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(t.icon, color: Theme.of(context).colorScheme.primary, size: 22),
                    const SizedBox(height: 8),
                    Text(
                      t.title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _SelectedGoalsBox extends StatelessWidget {
  final UserProfile profile;
  const _SelectedGoalsBox({required this.profile});

  @override
  Widget build(BuildContext context) {
    final titleStyle = const TextStyle(color: Colors.white, fontWeight: FontWeight.w800);
    final pillText = const TextStyle(color: Colors.white, fontWeight: FontWeight.w700);
    return InkWell(
      onTap: () => context.push('/select-goal'),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF1F2937), // dark slate
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Selected Goals', style: titleStyle),
                const Spacer(),
                Icon(Icons.edit, color: Colors.white70, size: 18),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _pill(icon: GoalCatalog.goalIcon(profile.preferredCourse),
                    label: profile.preferredCourse.isEmpty ? 'Select Goal' : profile.preferredCourse,
                    textStyle: pillText,
                    bg: Colors.white.withOpacity(0.08),
                    iconColor: Colors.white70),
                _pill(icon: Icons.place,
                    label: profile.preferredState.isEmpty ? 'Choose Location' : profile.preferredState,
                    textStyle: pillText,
                    bg: Colors.white.withOpacity(0.08),
                    iconColor: Colors.white70),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _pill({required IconData icon, required String label, required TextStyle textStyle, required Color bg, required Color iconColor}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white24)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: iconColor, size: 14),
          const SizedBox(width: 6),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 180),
            child: Text(label, style: textStyle, maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }
}

class _ToolItem {
  final String title;
  final IconData icon;
  final String route;
  const _ToolItem(this.title, this.icon, this.route);
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

class _GoalPickerSheet extends StatefulWidget {
  final UserProfile profile;
  const _GoalPickerSheet({required this.profile});

  @override
  State<_GoalPickerSheet> createState() => _GoalPickerSheetState();
}

class _GoalPickerSheetState extends State<_GoalPickerSheet> {
  late String _goal = widget.profile.preferredCourse.isEmpty ? GoalCatalog.defaultGoals.first : widget.profile.preferredCourse;
  late String _location = widget.profile.preferredState;

  final _locations = const ['Bangalore', 'Mumbai', 'Delhi', 'Chennai', 'Pune', 'Hyderabad'];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text('Customize Goal & Location', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  )
                ],
              ),
              const SizedBox(height: 6),
              const Text('Select Goal', style: TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final g in GoalCatalog.defaultGoals)
                    ChoiceChip(
                      label: Text(g),
                      selected: _goal == g,
                      onSelected: (_) => setState(() => _goal = g),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              const Text('Preferred Location', style: TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final city in _locations)
                    ChoiceChip(
                      label: Text(city),
                      selected: _location == city,
                      onSelected: (_) => setState(() => _location = city),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context, widget.profile.copyWith(preferredCourse: _goal, preferredState: _location));
                  },
                  child: const Text('Save'),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
