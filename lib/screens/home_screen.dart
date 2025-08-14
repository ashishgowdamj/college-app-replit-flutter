import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../services/college_provider.dart';
import '../services/profile_provider.dart'; // ✅ profile provider
import '../widgets/modern_college_tile.dart';
import '../widgets/quick_filters_bar.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// Sticky header for the filters bar
class _StickyHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double min;
  final double max;
  final Widget child;

  const _StickyHeaderDelegate({
    required this.min,
    required this.max,
    required this.child,
  });

  @override
  double get minExtent => min;

  @override
  double get maxExtent => max;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) =>
      child;

  @override
  bool shouldRebuild(covariant _StickyHeaderDelegate old) =>
      min != old.min || max != old.max || child != old.child;
}

/// Gradient background for the header
class _HeaderGradient extends StatelessWidget {
  final Widget child;
  const _HeaderGradient({required this.child});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [cs.primary, cs.primaryContainer],
        ),
      ),
      child: child,
    );
  }
}

/// Search field with live clear “x”
class _SearchField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  const _SearchField({required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ValueListenableBuilder<TextEditingValue>(
        valueListenable: controller,
        builder: (_, value, __) {
          final hasText = value.text.isNotEmpty;
          return TextField(
            controller: controller,
            onChanged: onChanged,
            style: const TextStyle(fontSize: 16),
            decoration: InputDecoration(
              hintText: 'Search colleges...',
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              suffixIcon: hasText
                  ? IconButton(
                      icon: const Icon(Icons.close, color: Colors.grey),
                      onPressed: () {
                        controller.clear();
                        onChanged('');
                      },
                    )
                  : null,
            ),
          );
        },
      ),
    );
  }
}

/// ─────────────────────────────────────────────────────────────────────────────
/// HomeScreen
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // initial load
    Future.microtask(() => context.read<CollegeProvider>().fetchColleges());
    _scrollController.addListener(_onScrollForPagination);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScrollForPagination() {
    final provider = context.read<CollegeProvider>();
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent * 0.9 &&
        !provider.isLoading &&
        provider.hasMoreData) {
      provider.fetchColleges();
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CollegeProvider>();
    final colleges = provider.colleges;

    return Scaffold(
      // Drawer present → SliverAppBar shows default hamburger automatically.
      drawer: Drawer(
        child: Column(
          children: [
            // ── Profile-aware header (tap to open /profile)
            Consumer<ProfileProvider>(
              builder: (context, pp, _) {
                final name = (pp.profile.name).trim();
                final email = (pp.profile.email).trim();
                final initials = (name.isEmpty
                        ? 'CC'
                        : name
                            .split(RegExp(r'\s+'))
                            .take(2)
                            .map((e) => e.isNotEmpty ? e[0] : '')
                            .join())
                    .toUpperCase();

                return DrawerHeader(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).colorScheme.primary,
                        Theme.of(context).colorScheme.primaryContainer,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/profile');
                    },
                    child: Align(
                      alignment: Alignment.bottomLeft,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [
                                  Theme.of(context).colorScheme.onPrimary,
                                  Colors.white,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              initials,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    fontWeight: FontWeight.w900,
                                  ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name.isEmpty ? 'Your Name' : name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w800,
                                      ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  email.isEmpty ? 'you@email.com' : email,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.chevron_right, color: Colors.white),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),

            // ── Drawer items
            ListTile(
              leading: const Icon(Icons.home_rounded),
              title: const Text('Home'),
              onTap: () {
                Navigator.pop(context);
                context.go('/home');
              },
            ),
            ListTile(
              leading: const Icon(Icons.person_rounded),
              title: const Text('Profile'),
              onTap: () {
                Navigator.pop(context);
                context.push('/profile');
              },
            ),
            ListTile(
              leading: const Icon(Icons.search_rounded),
              title: const Text('Search Colleges'),
              onTap: () {
                Navigator.pop(context);
                context.push('/search');
              },
            ),
            ListTile(
              leading: const Icon(Icons.favorite_rounded),
              title: const Text('Favorites'),
              onTap: () {
                Navigator.pop(context);
                context.push('/favorites');
              },
            ),
            ListTile(
              leading: const Icon(Icons.compare_arrows_rounded),
              title: const Text('Compare Colleges'),
              onTap: () {
                Navigator.pop(context);
                context.push('/compare');
              },
            ),
            const Spacer(),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Campus Connect v1.0.0',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
          ],
        ),
      ),

      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          /// SliverAppBar shows the DEFAULT hamburger (we didn’t disable it).
          SliverAppBar(
            pinned: true,
            stretch: true,
            expandedHeight: 180,
            elevation: 0,
            backgroundColor: Colors.transparent,
            foregroundColor:
                Theme.of(context).colorScheme.onPrimary, // title/action color
            title: const Text(
              'Campus Connect',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
            actions: [
              IconButton(
                tooltip: 'Compare Colleges',
                onPressed: () => context.push('/compare'),
                icon: const Icon(Icons.compare_arrows_rounded),
              ),
              IconButton(
                tooltip: 'Favorites',
                onPressed: () => context.push('/favorites'),
                icon: const Icon(Icons.favorite_outline_rounded),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: _HeaderGradient(
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                        16, 56, 16, 20), // space below toolbar
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        _SearchField(
                          controller: _searchController,
                          onChanged: (q) => provider.updateSearchQuery(q),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Sticky quick filters
          SliverPersistentHeader(
            pinned: true,
            delegate: _StickyHeaderDelegate(
              min: 56,
              max: 56,
              child: Material(
                color: Theme.of(context).colorScheme.surface,
                elevation: 2,
                child: QuickFiltersBar(
                  onFilter: (filter) {
                    if (filter == 'All') {
                      provider.clearFilter('type');
                      provider.clearFilter('state');
                    } else if (['IIT', 'NIT', 'IIIT', 'Private']
                        .contains(filter)) {
                      provider.setFilter('type', filter);
                    } else {
                      provider.setFilter('state', filter);
                    }
                  },
                ),
              ),
            ),
          ),

          // Loading (first load)
          if (provider.isLoading && colleges.isEmpty)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(child: CircularProgressIndicator()),
            )
          // Error (first load)
          else if (provider.error != null && colleges.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Error: ${provider.error}'),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () => provider.fetchColleges(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            )
          // Empty state
          else if (colleges.isEmpty)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(child: Text('No colleges found')),
            )
          // List + pagination row
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              sliver: SliverList.separated(
                itemCount: colleges.length + (provider.hasMoreData ? 1 : 0),
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  if (index >= colleges.length) {
                    // pagination loader
                    return const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  final college = colleges[index];
                  return TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOut,
                    tween: Tween(begin: 0.9, end: 1),
                    builder: (ctx, scale, child) =>
                        Transform.scale(scale: scale, child: child!),
                    child: ModernCollegeTile(
                      college: college,
                      isFavorite: provider.isFavorite(college),
                      onToggleFav: () => provider.toggleFavorite(college),
                      onTap: () => context.push('/college/${college.id}'),
                    ),
                  );
                },
              ),
            ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/predictor'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        child: const Icon(Icons.psychology),
      ),
    );
  }
}
