import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';

import '../services/college_provider.dart';
import '../services/profile_provider.dart';
import '../widgets/modern_college_tile.dart';
import '../widgets/quick_filters_bar.dart';
import '../widgets/bottom_navigation.dart';
import '../widgets/course_customization_drawer.dart';
import '../data/goal_catalog.dart';

/// Sticky header delegate used for Search bar and Filters bar
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
  ) {
    return Material(
      elevation: shrinkOffset > 0 ? 2 : 0,
      child: SizedBox.expand(
        child: child,
      ),
    );
  }
  @override
  bool shouldRebuild(covariant _StickyHeaderDelegate old) =>
      min != old.min || max != old.max || child != old.child;
}

/// Goal-driven hero and quick actions (top-level widget)
class _GoalHeroSection extends StatelessWidget {
  final String goal;
  final String location;
  const _GoalHeroSection({required this.goal, required this.location});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final hasGoal = goal.isNotEmpty;
    final specializations = GoalCatalog.specializations[goal] ?? const <String>[];
    final places = GoalCatalog.topPlaces[goal] ?? const <String>[];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header / CTA
          Container(
            decoration: BoxDecoration(
              color: cs.primaryContainer.withOpacity(0.3),
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: cs.primary,
                  foregroundColor: cs.onPrimary,
                  child: Icon(GoalCatalog.goalIcon(goal), size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        hasGoal ? '$goal Colleges' : 'Choose your goal',
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        hasGoal
                            ? (location.isEmpty ? 'Across India' : 'in $location')
                            : 'Set your preferred course and location',
                        style: TextStyle(color: Colors.grey[700], fontSize: 12.5),
                      ),
                    ],
                  ),
                ),
                TextButton.icon(
                  onPressed: () => context.push('/select-goal'),
                  icon: const Icon(Icons.edit, size: 18),
                  label: Text(hasGoal ? 'Edit' : 'Set'),
                  style: TextButton.styleFrom(foregroundColor: cs.primary),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Specializations chips
          if (hasGoal && specializations.isNotEmpty) ...[
            const Text('Top Specializations', style: TextStyle(fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final spec in specializations.take(10))
                  ActionChip(
                    label: Text(spec),
                    onPressed: () {
                      context.read<CollegeProvider>().updateSearchQuery('$goal $spec');
                      context.go('/search');
                    },
                  ),
              ],
            ),

            const SizedBox(height: 12),
          ],

          // Top places row
          if (hasGoal && places.isNotEmpty) ...[
            const Text('Top Locations', style: TextStyle(fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (final p in places)
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ChoiceChip(
                        label: Text(p),
                        selected: false,
                        onSelected: (_) async {
                          final cp = context.read<CollegeProvider>();
                          cp.updateFilters(state: p, courseType: null, minFees: null, maxFees: null);
                          await cp.fetchColleges(refresh: true);
                          context.go('/search');
                        },
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 8),
          ],
        ],
      ),
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
        color: Colors.white, // solid for readability
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
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
                        // Clear the search field and trigger search with empty query
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
    print('=== HomeScreen initState called ===');

    // Add scroll controller listener
    _scrollController.addListener(_onScrollForPagination);

    // Load initial data after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print('Post-frame callback - Loading initial data...');
      _loadInitialData();
    });
  }

  void _loadInitialData() {
    print('=== _loadInitialData() called ===');
    try {
      if (!mounted) {
        print('Widget not mounted, skipping data load');
        return;
      }

      final provider = context.read<CollegeProvider>();
      print(
          'CollegeProvider state - isLoading: ${provider.isLoading}, error: ${provider.error}');
      print('Current colleges count: ${provider.colleges.length}');

      // If we already have data, no need to fetch again
      if (provider.colleges.isNotEmpty) {
        print(
            'Colleges already loaded (${provider.colleges.length}), skipping fetch');
        return;
      }

      // If already loading, don't trigger another load
      if (provider.isLoading) {
        print('Already loading colleges, skipping duplicate request');
        return;
      }

      print('Initiating colleges fetch...');
      final startTime = DateTime.now();

      provider.fetchColleges(refresh: true).then((_) {
        final duration = DateTime.now().difference(startTime);
        print('Colleges fetch completed in ${duration.inMilliseconds}ms');

        if (!mounted) {
          print('Widget disposed, not updating state');
          return;
        }

        print('Updating UI with ${provider.colleges.length} colleges');
        setState(() {
          // Trigger a rebuild
        });
      }).catchError((error, stackTrace) {
        print('Error fetching colleges: $error');
        print('Stack trace: $stackTrace');

        if (mounted) {
          setState(() {
            // Update UI to show error state
          });
        }
      });
    } catch (e, stackTrace) {
      print('Unexpected error in _loadInitialData: $e');
      print('Stack trace: $stackTrace');
    } finally {
      print('=== _loadInitialData() completed ===');
    }
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

  // Shimmer skeleton placeholder for a college tile
  Widget _buildSkeletonTile(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image placeholder
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(width: 12),
            // Text lines
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(height: 16, width: double.infinity, color: Colors.white),
                  const SizedBox(height: 8),
                  Container(height: 14, width: MediaQuery.of(context).size.width * 0.5, color: Colors.white),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(child: Container(height: 12, color: Colors.white)),
                      const SizedBox(width: 8),
                      Container(width: 60, height: 24, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12))),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Safe read: returns null if ProfileProvider isn't registered
  ProfileProvider? _tryReadProfileProvider(BuildContext context) {
    try {
      return Provider.of<ProfileProvider>(context, listen: false);
    } catch (_) {
      return null;
    }
  }

  // Drawer header that works even if ProfileProvider isn't available yet
  Widget _drawerHeader(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final pp = _tryReadProfileProvider(context);
    final name = (pp?.profile.name ?? '').trim();
    final email = (pp?.profile.email ?? '').trim();
    final initials = (name.isEmpty
            ? 'CC'
            : name.split(RegExp(r'\s+')).take(2).map((e) => e[0]).join())
        .toUpperCase();

    return DrawerHeader(
      decoration: BoxDecoration(
        color: cs.primary,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.pop(context);
          // If you haven't added /profile route, comment next line.
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
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                alignment: Alignment.center,
                child: Text(
                  initials,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: cs.primary,
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
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      email.isEmpty ? 'you@email.com' : email,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style:
                          const TextStyle(color: Colors.white70, fontSize: 12),
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
  }

  @override
  Widget build(BuildContext context) {
    print('=== HomeScreen build() called ===');
    final theme = Theme.of(context);
    final provider = context.watch<CollegeProvider>();
    final colleges = provider.colleges;
    final cs = theme.colorScheme;
    final profile = context.watch<ProfileProvider>().profile;

    // Debug print provider state
    print(
        'Provider state - isLoading: ${provider.isLoading}, error: ${provider.error}');
    print('Colleges count: ${colleges.length}');
    if (provider.error != null) {
      print('Error details: ${provider.error}');
    }

    // Show skeletons on initial load
    if (provider.isLoading && provider.colleges.isEmpty) {
      print('Showing skeleton placeholders (initial load)');
      return Scaffold(
        body: ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          itemCount: 6,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) => _buildSkeletonTile(context),
        ),
      );
    }

    // Show error message if there's an error
    if (provider.error != null && provider.colleges.isEmpty) {
      print('Showing error message: ${provider.error}');
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error: ${provider.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  print('Retry button pressed');
                  provider.fetchColleges(refresh: true);
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    // If no colleges but no error, try to load data
    if (colleges.isEmpty) {
      print('No colleges found, triggering load');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadInitialData();
      });
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      // Drawer → SliverAppBar will show default hamburger automatically
      drawer: const Drawer(child: CourseCustomizationDrawer()),

      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // 1) Solid, high-contrast AppBar (pinned)
          SliverAppBar(
            pinned: true,
            elevation: 0,
            backgroundColor: cs.primary,
            foregroundColor: cs.onPrimary,
            title: const Text(
              'Campus Connect',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
            centerTitle: false,
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
          ),

          // 2) Sticky Search header (pinned under the app bar)
          SliverPersistentHeader(
            pinned: true,
            delegate: _StickyHeaderDelegate(
              min: 76,
              max: 76,
              child: Container(
                color: cs.surface,
                child: Material(
                  color: Colors.transparent,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
                    child: _SearchField(
                      controller: _searchController,
                      onChanged: (q) async {
                        try {
                          await provider.updateSearchQuery(q);
                        } catch (e, stackTrace) {
                          print('Error updating search query: $e');
                          print('Stack trace: $stackTrace');
                          // Optionally show an error to the user
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text('Search error: ${e.toString()}')),
                          );
                        }
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),

          // 3) Sticky Quick Filters (pinned under search)
          SliverPersistentHeader(
            pinned: true,
            delegate: _StickyHeaderDelegate(
              min: 56,
              max: 56,
              child: Container(
                color: cs.surface,
                child: Material(
                  color: Colors.transparent,
                  child: QuickFiltersBar(
                    onFilter: (query) {
                      // QuickFiltersBar passes a simple string like 'IIT' or 'Delhi'
                      print('Quick filter selected: $query');

                      // If cleared or 'All', clear filters
                      if (query.isEmpty || query == 'All') {
                        provider.clearFilters();
                        provider.fetchColleges(refresh: true);
                        return;
                      }

                      // Map chip to either course type or location query
                      String? state;
                      String? courseType;
                      String? locationQuery;

                      const knownTypes = {'IIT', 'NIT', 'IIIT', 'Private'};
                      if (knownTypes.contains(query)) {
                        courseType = query;
                      } else {
                        // Treat anything else as a free-text location (city/area)
                        locationQuery = query;
                        state = null; // do not over-constrain by state here
                      }

                      provider.updateFilters(
                        state: state,
                        courseType: courseType,
                        minFees: null,
                        maxFees: null,
                        locationQuery: locationQuery,
                      );
                      provider.fetchColleges(refresh: true);
                    },
                  ),
                ),
              ),
            ),
          ),

          // 4) Goal-driven hero and quick actions
          SliverToBoxAdapter(
            child: _GoalHeroSection(
              goal: profile.preferredCourse,
              location: profile.preferredState,
            ),
          ),

          // Inline refresh indicator when updating results but existing list is shown
          if (provider.isRefreshing && colleges.isNotEmpty)
            const SliverToBoxAdapter(
              child: SizedBox(
                height: 3,
                child: LinearProgressIndicator(minHeight: 3),
              ),
            ),

          // Loading (first load) — show skeletons
          if (provider.isLoading && colleges.isEmpty)
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              sliver: SliverList.separated(
                itemCount: 6,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, _) => _buildSkeletonTile(context),
              ),
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
                    // pagination skeletons
                    return Column(
                      children: [
                        _buildSkeletonTile(context),
                        const SizedBox(height: 12),
                        _buildSkeletonTile(context),
                        const SizedBox(height: 12),
                        _buildSkeletonTile(context),
                      ],
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
        backgroundColor: cs.primary,
        foregroundColor: Colors.white,
        child: const Icon(Icons.psychology),
      ),
      bottomNavigationBar: const BottomNavigation(currentRoute: '/home'),
    );
  }
}
