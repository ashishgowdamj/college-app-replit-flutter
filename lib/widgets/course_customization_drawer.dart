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
              gradient: LinearGradient(
                colors: [cs.primary, cs.primaryContainer],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
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
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          _InfoPill(
                            icon: GoalCatalog.goalIcon(profile.preferredCourse),
                            label: profile.preferredCourse.isEmpty ? 'Select Goal' : profile.preferredCourse,
                          ),
                          _InfoPill(
                            icon: Icons.place,
                            label: profile.preferredState.isEmpty ? 'Choose Location' : profile.preferredState,
                          ),
                        ],
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
                // Course search
                const SizedBox(height: 6),
                Text('Browse Categories', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                TextField(
                  controller: _courseSearch,
                  decoration: InputDecoration(
                    hintText: 'Search Courses by Name',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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

                // Categories list
                ...GoalCatalog.defaultGoals.map((g) => _CategoryTile(
                      title: g,
                      icon: GoalCatalog.goalIcon(g),
                      onTap: () async {
                        // Navigate to Search prefilled with this goal as query (do not change saved goal here)
                        context.read<CollegeProvider>().updateSearchQuery(g);
                        context.go('/search');
                      },
                    )),

                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                  title: const Text('All Courses', style: TextStyle(fontWeight: FontWeight.w700, color: Colors.blue)),
                  trailing: const Icon(Icons.chevron_right, color: Colors.blue),
                  onTap: () => context.go('/search'),
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

class _CategoryTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;
  const _CategoryTile({required this.title, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        trailing: const Icon(Icons.add),
        onTap: onTap,
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

class _InfoPill extends StatelessWidget {
  final IconData icon;
  final String label;
  const _InfoPill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white70, size: 14),
          const SizedBox(width: 6),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 150),
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white70, fontSize: 12.5),
            ),
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
