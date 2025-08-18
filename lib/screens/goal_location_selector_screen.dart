import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../data/goal_catalog.dart';
import '../services/profile_provider.dart';

class GoalLocationSelectorScreen extends StatefulWidget {
  const GoalLocationSelectorScreen({super.key});

  @override
  State<GoalLocationSelectorScreen> createState() => _GoalLocationSelectorScreenState();
}

class _GoalLocationSelectorScreenState extends State<GoalLocationSelectorScreen> with TickerProviderStateMixin {
  late final TabController _tab;
  final TextEditingController _courseSearch = TextEditingController();
  final TextEditingController _citySearch = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    _courseSearch.dispose();
    _citySearch.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pp = context.watch<ProfileProvider>();
    final profile = pp.profile;

    return Scaffold(
      appBar: AppBar(
        title: Text('You have selected ${profile.preferredCourse.isEmpty ? '—' : profile.preferredCourse} in ${profile.preferredState.isEmpty ? '—' : profile.preferredState}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              final router = GoRouter.of(context);
              if (router.canPop()) {
                router.pop();
              } else {
                context.go('/home');
              }
            },
          )
        ],
        bottom: TabBar(
          controller: _tab,
          tabs: const [
            Tab(text: 'Goals'),
            Tab(text: 'City/State'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tab,
        children: [
          _GoalsTab(controller: _courseSearch),
          _CitiesTab(controller: _citySearch),
        ],
      ),
    );
  }
}

class _GoalsTab extends StatelessWidget {
  final TextEditingController controller;
  const _GoalsTab({required this.controller});

  @override
  Widget build(BuildContext context) {
    final pp = context.read<ProfileProvider>();

    const goals = GoalCatalog.defaultGoals;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Search for preferred course',
            prefixIcon: Icon(Icons.search),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final g in goals)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  icon: Icon(GoalCatalog.goalIcon(g)),
                  label: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(g, style: const TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ),
                  onPressed: () async {
                    await pp.save(pp.profile.copyWith(preferredCourse: g));
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Goal set to $g')));
                    }
                  },
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _CitiesTab extends StatelessWidget {
  final TextEditingController controller;
  const _CitiesTab({required this.controller});

  @override
  Widget build(BuildContext context) {
    const cities = ['New Delhi', 'Mumbai', 'Chennai', 'Kolkata', 'Hyderabad', 'Bangalore'];
    final pp = context.read<ProfileProvider>();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Add places you are planning for',
            prefixIcon: Icon(Icons.search),
          ),
        ),
        const SizedBox(height: 10),
        for (final city in cities)
          Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: ListTile(
              leading: const Icon(Icons.location_city),
              title: Text(city, style: const TextStyle(fontWeight: FontWeight.w700)),
              trailing: const Icon(Icons.chevron_right),
              onTap: () async {
                await pp.save(pp.profile.copyWith(preferredState: city));
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Location set to $city')));
                }
              },
            ),
          ),
      ],
    );
  }
}
