import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../services/college_provider.dart';
import '../widgets/college_card.dart';
import '../widgets/search_bar_widget.dart';
import '../widgets/bottom_navigation.dart';
import '../models/college.dart';
import '../ui/widgets/app_scaffold.dart';
import '../ui/widgets/shimmer_box.dart';
import '../ui/design_system.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with AutomaticKeepAliveClientMixin<SearchScreen> {
  // Track which image URLs we've already prefetched to avoid repeated work
  final Set<String> _prefetchedUrls = <String>{};
  @override
  bool get wantKeepAlive => true;
  @override
  Widget build(BuildContext context) {
    super.build(context); // required when using AutomaticKeepAliveClientMixin
    return AppScaffold(
      title: 'Search Colleges',
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () {
          final router = GoRouter.of(context);
          if (router.canPop()) {
            router.pop();
          } else {
            context.go('/home');
          }
        },
      ),
      body: Column(
        children: [
          const SearchBarWidget(),
          Expanded(
            child: Builder(
              builder: (context) {
                final isLoading = context.select<CollegeProvider, bool>((p) => p.isLoading);
                final isRefreshing = context.select<CollegeProvider, bool>((p) => p.isRefreshing);
                final colleges = context.select<CollegeProvider, List<College>>((p) => p.colleges);
                final searchQuery = context.select<CollegeProvider, String>((p) => p.searchQuery);
                final hasMoreData = context.select<CollegeProvider, bool>((p) => p.hasMoreData);
                final isLoadingMore = context.select<CollegeProvider, bool>((p) => p.isLoadingMore);

                if ((isLoading || isRefreshing) && colleges.isEmpty) {
                  return const _SearchSkeleton();
                }

                if (colleges.isEmpty && searchQuery.isNotEmpty) {
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

                if (colleges.isEmpty) {
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
                      if (hasMoreData && !isLoadingMore) {
                        context.read<CollegeProvider>().loadMoreColleges();
                      }
                    }
                    return false;
                  },
                  child: ListView.builder(
                    itemCount: colleges.length + (hasMoreData ? 1 : 0),
                    cacheExtent: 800,
                    addAutomaticKeepAlives: false,
                    addRepaintBoundaries: true,
                    itemBuilder: (context, index) {
                      if (index == colleges.length) {
                        // Show loading indicator at the bottom
                        return isLoadingMore
                            ? const Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Center(child: CircularProgressIndicator()),
                              )
                            : const SizedBox.shrink();
                      }

                      final college = colleges[index];
                      // Prefetch thumbnail image (if any) after this frame
                      final url = college.imageUrl;
                      if (url != null && url.isNotEmpty && !_prefetchedUrls.contains(url)) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          precacheImage(CachedNetworkImageProvider(url), context)
                              .catchError((_) {
                            // Ignore prefetch failures (e.g., 404) to prevent noisy exceptions
                          });
                        });
                        _prefetchedUrls.add(url);
                      }
                      return RepaintBoundary(
                        child: Selector<CollegeProvider, bool>(
                          selector: (_, p) => p.isFavorite(college),
                          builder: (context, isFav, _) {
                            return CollegeCard(
                              college: college,
                              isFavorite: isFav,
                              onTap: () => context.go('/college/${college.id}', extra: college),
                              onFavoriteToggle: () => context.read<CollegeProvider>().toggleFavorite(college),
                              onCompare: () => context.go('/compare', extra: college),
                            );
                          },
                        ),
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
}

// ─── SKELETONS ───────────────────────────────────────────────────────────────
class _SearchSkeleton extends StatelessWidget {
  const _SearchSkeleton();
  @override
  Widget build(BuildContext context) {
    return const _SkeletonList();
  }
}

class _SkeletonList extends StatelessWidget {
  const _SkeletonList();
  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemBuilder: (_, __) => const _SkeletonCard(),
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemCount: 6,
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  const _SkeletonCard();
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTokens.outline, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.04),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: AppTokens.primary.withOpacity(.06),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          _SkeletonRow(),
          SizedBox(height: 12),
          _SkeletonChips(),
          SizedBox(height: 10),
          _SkeletonFooter(),
        ],
      ),
    );
  }
}

class _SkeletonRow extends StatelessWidget {
  const _SkeletonRow();
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        _SkeletonBox(height: 44, width: 44, radius: BorderRadius.all(Radius.circular(12))),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SkeletonBox(height: 16, width: 160, radius: BorderRadius.all(Radius.circular(4))),
              SizedBox(height: 6),
              _SkeletonBox(height: 12, width: 120, radius: BorderRadius.all(Radius.circular(4))),
            ],
          ),
        ),
        SizedBox(width: 12),
        _SkeletonBox(height: 22, width: 60, radius: BorderRadius.all(Radius.circular(999))),
      ],
    );
  }
}

class _SkeletonChips extends StatelessWidget {
  const _SkeletonChips();
  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: const [
        _SkeletonBox(height: 20, width: 70, radius: BorderRadius.all(Radius.circular(999))),
        _SkeletonBox(height: 20, width: 110, radius: BorderRadius.all(Radius.circular(999))),
      ],
    );
  }
}

class _SkeletonFooter extends StatelessWidget {
  const _SkeletonFooter();
  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Expanded(
          child: _SkeletonBox(height: 14, radius: BorderRadius.all(Radius.circular(4))),
        ),
        SizedBox(width: 12),
        _SkeletonBox(height: 36, width: 110, radius: BorderRadius.all(Radius.circular(24))),
      ],
    );
  }
}

class _SkeletonBox extends StatelessWidget {
  final double height;
  final double? width;
  final BorderRadius radius;
  const _SkeletonBox({required this.height, this.width, this.radius = const BorderRadius.all(Radius.circular(12))});
  @override
  Widget build(BuildContext context) {
    return ShimmerBox(height: height, width: width, borderRadius: radius);
  }
}