import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import '../services/college_provider.dart';
import '../widgets/college_card.dart';
import '../widgets/search_bar_widget.dart';
import '../widgets/bottom_navigation.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/');
            }
          },
        ),
        title: const Text(
          'Search Colleges',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SearchBarWidget(),
          Expanded(
            child: Consumer<CollegeProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading && provider.colleges.isEmpty) {
                  // Initial shimmer skeletons mimicking CollegeCard layout
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    itemCount: 6,
                    itemBuilder: (context, index) => _buildSearchSkeletonTile(context),
                  );
                }

                if (provider.colleges.isEmpty && provider.searchQuery.isNotEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No results found',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Try different keywords or adjust filters',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                if (provider.colleges.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Search for colleges',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Use the search bar above to find colleges',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return NotificationListener<ScrollNotification>(
                  onNotification: (ScrollNotification scrollInfo) {
                    if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
                      if (provider.hasMoreData && !provider.isLoadingMore) {
                        provider.loadMoreColleges();
                      }
                    }
                    return false;
                  },
                  child: ListView.builder(
                    itemCount: provider.colleges.length + (provider.hasMoreData ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == provider.colleges.length) {
                        // Show loading indicator at the bottom
                        return provider.isLoadingMore
                            ? Padding(
                                padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                                child: Column(
                                  children: [
                                    _buildSearchSkeletonTile(context),
                                    const SizedBox(height: 12),
                                    _buildSearchSkeletonTile(context),
                                    const SizedBox(height: 12),
                                    _buildSearchSkeletonTile(context),
                                  ],
                                ),
                              )
                            : const SizedBox.shrink();
                      }
                      
                      final college = provider.colleges[index];
                      return CollegeCard(
                        college: college,
                        isFavorite: provider.isFavorite(college),
                        onTap: () => context.go('/college/${college.id}'),
                        onFavoriteToggle: () => provider.toggleFavorite(college),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: const BottomNavigation(currentRoute: '/search'),
    );
  }

  Widget _buildSearchSkeletonTile(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final base = isDark ? Colors.grey[800]! : Colors.grey[300]!;
    final highlight = isDark ? Colors.grey[700]! : Colors.grey[100]!;
    return Shimmer.fromColors(
      baseColor: base,
      highlightColor: highlight,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.04),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row mirrors CollegeCard
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // App badge placeholder 44x44 with r=12
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: base,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                const SizedBox(width: 12),
                // Title + location
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(height: 20, width: double.infinity, color: base),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          // location icon circle 16
                          Container(width: 16, height: 16, decoration: const BoxDecoration(shape: BoxShape.circle), color: base),
                          const SizedBox(width: 4),
                          Expanded(child: Container(height: 12, color: base)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // Right cluster: rank pill, rating, fees
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      height: 22,
                      decoration: BoxDecoration(
                        color: base,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 28),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(width: 18, height: 18, decoration: const BoxDecoration(shape: BoxShape.circle), color: base),
                        const SizedBox(width: 6),
                        Container(height: 12, width: 28, color: base),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(height: 14, width: 80, color: base),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Tags row chips
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Container(
                  height: 28,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: base,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                Container(
                  height: 28,
                  width: 90,
                  decoration: BoxDecoration(
                    color: base,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Footer row: hints and buttons
            Row(
              children: [
                Expanded(
                  child: Wrap(
                    spacing: 16,
                    children: [
                      Container(height: 12, width: 110, color: base),
                      Container(height: 12, width: 120, color: base),
                      Container(height: 12, width: 100, color: base),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // Compare button
                Container(
                  height: 40,
                  width: 110,
                  decoration: BoxDecoration(
                    color: base,
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                const SizedBox(width: 8),
                // Icons
                Container(width: 24, height: 24, decoration: const BoxDecoration(shape: BoxShape.circle), color: base),
                const SizedBox(width: 8),
                Container(width: 24, height: 24, decoration: const BoxDecoration(shape: BoxShape.circle), color: base),
              ],
            ),
          ],
        ),
      ),
    );
  }
}