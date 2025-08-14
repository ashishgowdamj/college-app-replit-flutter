import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../services/college_provider.dart';
import '../widgets/modern_college_tile.dart';
import '../widgets/quick_filters_bar.dart';

// Sticky header delegate for the quick filters bar
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
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) => child;

  @override
  bool shouldRebuild(covariant _StickyHeaderDelegate oldDelegate) {
    return min != oldDelegate.min || max != oldDelegate.max || child != oldDelegate.child;
  }
}

class _HeaderGradient extends StatelessWidget {
  final Widget child;

  const _HeaderGradient({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withOpacity(0.9),
          ],
        ),
      ),
      child: child,
    );
  }
}

class _SearchField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _SearchField({
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: const TextStyle(fontSize: 16),
        decoration: InputDecoration(
          hintText: 'Search colleges...',
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close, color: Colors.grey),
                  onPressed: () {
                    controller.clear();
                    onChanged('');
                  },
                )
              : null,
        ),
      ),
    );
  }
}

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
    // Load initial data
    Future.microtask(() => context.read<CollegeProvider>().fetchColleges());
    
    // Set up scroll listener for pagination
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
  

  
  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent * 0.9) {
      final provider = context.read<CollegeProvider>();
      if (!provider.isLoading && provider.hasMoreData) {
        // Load next page
        provider.fetchColleges();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CollegeProvider>();
    final colleges = provider.colleges;
    final isLoading = provider.isLoading;
    final error = provider.error;
    final hasMoreData = provider.hasMoreData;

    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverAppBar(
            pinned: true,
            floating: false,
            stretch: true,
            expandedHeight: 180,
            backgroundColor: Colors.transparent,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [StretchMode.fadeTitle, StretchMode.blurBackground],
              background: _HeaderGradient(
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Brand row
                        Row(
                          children: [
                            Icon(Icons.school_rounded,
                                size: 26, color: Theme.of(context).colorScheme.onPrimary),
                            const SizedBox(width: 8),
                            Text(
                              'College Compare',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: Theme.of(context).colorScheme.onPrimary,
                                    fontWeight: FontWeight.w800,
                                  ),
                            ),
                            const Spacer(),
                            IconButton(
                              onPressed: () => context.push('/compare'),
                              icon: Icon(Icons.compare_arrows_rounded,
                                  color: Theme.of(context).colorScheme.onPrimary),
                              tooltip: 'Compare Colleges',
                            ),
                            IconButton(
                              onPressed: () => context.push('/favorites'),
                              icon: Icon(Icons.favorite_outline_rounded,
                                  color: Theme.of(context).colorScheme.onPrimary),
                              tooltip: 'Favorites',
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Search field
                        _SearchField(
                          controller: _searchController,
                          onChanged: (query) {
                            provider.updateSearchQuery(query);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              titlePadding: const EdgeInsetsDirectional.only(start: 16, bottom: 14),
              title: const SizedBox.shrink(),
            ),
          ),

          // Quick filters
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
                    } else if (['IIT', 'NIT', 'IIIT', 'Private'].contains(filter)) {
                      provider.setFilter('type', filter);
                    } else {
                      provider.setFilter('state', filter);
                    }
                  },
                ),
              ),
            ),
          ),

          // Loading indicator
          if (isLoading && colleges.isEmpty)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            )
          // Error message
          else if (error != null)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Error: $error'),
                    const SizedBox(height: 16),
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
              child: Center(child: Text('No colleges found')),
            )
          // College list
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              sliver: SliverList.separated(
                itemCount: colleges.length + (hasMoreData ? 1 : 0),
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  if (index >= colleges.length) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }
                  
                  final college = colleges[index];
                  return TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOut,
                    tween: Tween(begin: 0.9, end: 1),
                    builder: (ctx, scale, child) => Transform.scale(scale: scale, child: child!),
                    child: ModernCollegeTile(
                      college: college,
                      isFavorite: provider.isFavorite(college),
                      onToggleFav: () {
                        // Toggle favorite status
                        provider.toggleFavorite(college);
                      },
                      onTap: () {
                        context.push('/college/${college.id}');
                      },
                    ),
                  );
                },
              ),
            ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/predictor'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        child: const Icon(Icons.psychology),
      ),
    );
  }

  Widget _buildStatistics() {
    return Consumer<CollegeProvider>(
      builder: (context, provider, _) {
        if (provider.colleges.isEmpty) return const SizedBox.shrink();
        
        final totalColleges = provider.colleges.length;
        final ratings = provider.colleges
            .map((c) => c.rating != null ? double.tryParse(c.rating.toString()) ?? 0.0 : 0.0)
            .where((r) => r > 0)
            .toList();
            
        final avgRating = ratings.isEmpty 
            ? 0.0 
            : ratings.reduce((a, b) => a + b) / ratings.length;
            
        return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(
            children: [
              _buildStatItem('Total Colleges', totalColleges.toString(), Icons.school, Colors.blue),
              _buildStatItem('Average Rating', avgRating.toStringAsFixed(1), Icons.star, Colors.amber),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}