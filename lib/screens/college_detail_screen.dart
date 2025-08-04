import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import '../services/college_provider.dart';
import '../models/college.dart';
import '../models/review.dart';

class CollegeDetailScreen extends StatefulWidget {
  final String collegeId;

  const CollegeDetailScreen({
    super.key,
    required this.collegeId,
  });

  @override
  State<CollegeDetailScreen> createState() => _CollegeDetailScreenState();
}

class _CollegeDetailScreenState extends State<CollegeDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final collegeId = int.tryParse(widget.collegeId);
      if (collegeId != null) {
        context.read<CollegeProvider>().fetchCollegeDetails(collegeId);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<CollegeProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return Scaffold(
              appBar: AppBar(
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => context.go('/'),
                ),
              ),
              body: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Loading college details...'),
                  ],
                ),
              ),
            );
          }

          if (provider.error != null && provider.selectedCollege == null) {
            return Scaffold(
              appBar: AppBar(
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => context.go('/'),
                ),
              ),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 64),
                    const SizedBox(height: 16),
                    Text('Failed to load college details'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        final collegeId = int.tryParse(widget.collegeId);
                        if (collegeId != null) {
                          provider.fetchCollegeDetails(collegeId);
                        }
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          final college = provider.selectedCollege;
          if (college == null) {
            return Scaffold(
              appBar: AppBar(
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => context.go('/'),
                ),
              ),
              body: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64),
                    SizedBox(height: 16),
                    Text('College not found'),
                  ],
                ),
              ),
            );
          }
          return _buildCollegeDetails(context, college, provider);
        },
      ),
    );
  }

  Widget _buildCollegeDetails(BuildContext context, College college, CollegeProvider provider) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 250,
          pinned: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => context.go('/'),
          ),
          flexibleSpace: FlexibleSpaceBar(
            title: Text(
              college.shortName ?? college.name,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                shadows: [Shadow(blurRadius: 4, color: Colors.black54)],
              ),
            ),
            background: college.imageUrl != null && college.imageUrl!.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: college.imageUrl!,
                    fit: BoxFit.cover,
                    errorWidget: (context, url, error) => Container(
                      color: Theme.of(context).primaryColor,
                      child: const Icon(Icons.school, size: 80, color: Colors.white),
                    ),
                    placeholder: (context, url) => Container(
                      color: Colors.grey[200],
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  )
                : Container(
                    color: Theme.of(context).primaryColor,
                    child: const Icon(Icons.school, size: 80, color: Colors.white),
                  ),
          ),
          actions: [
            IconButton(
              icon: Icon(
                provider.isFavorite(college) ? Icons.favorite : Icons.favorite_border,
                color: provider.isFavorite(college) ? Colors.red : Colors.white,
              ),
              onPressed: () => provider.toggleFavorite(college),
            ),
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: () => Share.share(
                'Check out ${college.name} - ${college.location}',
              ),
            ),
          ],
        ),
        SliverToBoxAdapter(
          child: Column(
            children: [
              // College basic info
              Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      college.name,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          '${college.city}, ${college.state}',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (college.ratingAsDouble > 0) ...[
                                              Row(
                          children: [
                            RatingBar.builder(
                              initialRating: college.ratingAsDouble,
                              minRating: 1,
                              direction: Axis.horizontal,
                              allowHalfRating: true,
                              itemCount: 5,
                              itemSize: 20.0,
                              ignoreGestures: true,
                              onRatingUpdate: (rating) {},
                              itemBuilder: (context, index) => const Icon(
                                Icons.star,
                                color: Colors.amber,
                              ),
                            ),
                          const SizedBox(width: 8),
                          Text(
                            '${college.ratingAsDouble.toStringAsFixed(1)} (${college.reviewCount ?? 0} reviews)',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],
                    // Quick stats
                    Row(
                      children: [
                        if (college.fees != null)
                          Expanded(
                            child: _buildStatCard(
                              context,
                              'Fees',
                              '₹${college.feesAsDouble.toStringAsFixed(0)}',
                              college.feesPeriod ?? 'yearly',
                              Icons.currency_rupee,
                            ),
                          ),
                        if (college.fees != null && college.nirfRank != null)
                          const SizedBox(width: 12),
                        if (college.nirfRank != null)
                          Expanded(
                            child: _buildStatCard(
                              context,
                              'NIRF Rank',
                              '#${college.nirfRank}',
                              '',
                              Icons.emoji_events,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              // Tab bar
              TabBar(
                controller: _tabController,
                labelColor: Theme.of(context).primaryColor,
                unselectedLabelColor: Colors.grey[600],
                indicatorColor: Theme.of(context).primaryColor,
                tabs: const [
                  Tab(text: 'Overview'),
                  Tab(text: 'Courses'),
                  Tab(text: 'Placement'),
                  Tab(text: 'Reviews'),
                ],
              ),
            ],
          ),
        ),
        SliverFillRemaining(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildOverviewTab(context, college),
              _buildCoursesTab(context, college),
              _buildPlacementTab(context, college),
              _buildReviewsTab(context, college, provider),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value, 
                       String subtitle, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Icon(icon, color: Theme.of(context).primaryColor),
          const SizedBox(height: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          if (subtitle.isNotEmpty)
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildOverviewTab(BuildContext context, College college) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (college.description != null) ...[
            Text(
              'About',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(college.description!),
            const SizedBox(height: 16),
          ],
          // College details
          _buildDetailRow('Type', college.type),
          if (college.establishedYear != null)
            _buildDetailRow('Established', college.establishedYear.toString()),
          if (college.affiliation != null)
            _buildDetailRow('Affiliation', college.affiliation!),
          if (college.admissionProcess != null)
            _buildDetailRow('Admission Process', college.admissionProcess!),
          if (college.website != null) ...[
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _launchUrl(college.website!),
              icon: const Icon(Icons.web),
              label: const Text('Visit Website'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCoursesTab(BuildContext context, College college) {
    return const Center(
      child: Text('Courses information coming soon...'),
    );
  }

  Widget _buildPlacementTab(BuildContext context, College college) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Placement Statistics',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          if (college.placementRate != null)
            _buildDetailRow('Placement Rate', '${college.placementRate}%'),
          if (college.averagePackage != null)
            _buildDetailRow('Average Package', '₹${college.averagePackage} LPA'),
          if (college.highestPackage != null)
            _buildDetailRow('Highest Package', '₹${college.highestPackage} LPA'),
        ],
      ),
    );
  }

  Widget _buildReviewsTab(BuildContext context, College college, CollegeProvider provider) {
    if (provider.selectedCollegeReviews.isEmpty) {
      return const Center(
        child: Text('No reviews yet. Be the first to review!'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: provider.selectedCollegeReviews.length,
      itemBuilder: (context, index) {
        final review = provider.selectedCollegeReviews[index];
        return _buildReviewCard(context, review);
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewCard(BuildContext context, Review review) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    review.studentName ?? 'Anonymous',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (review.verified == true)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Verified',
                      style: TextStyle(
                        color: Colors.green[700],
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            RatingBar.builder(
              initialRating: review.ratingAsDouble,
              minRating: 1,
              direction: Axis.horizontal,
              allowHalfRating: true,
              itemCount: 5,
              itemSize: 16.0,
              ignoreGestures: true,
              onRatingUpdate: (rating) {},
              itemBuilder: (context, index) => const Icon(
                Icons.star,
                color: Colors.amber,
              ),
            ),
            if (review.title != null) ...[
              const SizedBox(height: 8),
              Text(
                review.title!,
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ],
            if (review.content != null) ...[
              const SizedBox(height: 8),
              Text(review.content!),
            ],
            const SizedBox(height: 8),
            Row(
              children: [
                if (review.course != null)
                  Text(
                    review.course!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                if (review.course != null && review.graduationYear != null)
                  Text(
                    ' • ',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                if (review.graduationYear != null)
                  Text(
                    'Class of ${review.graduationYear}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}