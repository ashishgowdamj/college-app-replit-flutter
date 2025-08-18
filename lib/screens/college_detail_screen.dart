import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shimmer/shimmer.dart';
import '../services/college_provider.dart';
import '../models/college.dart';

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
                  onPressed: () {
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.go('/home');
                    }
                  },
                ),
                title: const Text('College Details'),
              ),
              body: _buildDetailsSkeleton(context),
            );
          }

          if (provider.error != null && provider.selectedCollege == null) {
            return Scaffold(
              appBar: AppBar(
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.go('/home');
                    }
                  },
                ),
              ),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 64),
                    const SizedBox(height: 16),
                    const Text('Failed to load college details'),
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
                  onPressed: () {
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.go('/home');
                    }
                  },
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

  // Shimmer skeletons for loading state
  Widget _buildHeroImageSkeleton() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(color: Colors.grey[300]),
    );
  }

  Widget _buildDetailsSkeleton(BuildContext context) {
    final base = Colors.grey[300]!;
    final highlight = Colors.grey[100]!;
    return Shimmer.fromColors(
      baseColor: base,
      highlightColor: highlight,
      child: ListView(
        children: [
          // Hero image area
          Container(height: 280, color: base),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title line
                Container(height: 22, width: double.infinity, color: base),
                const SizedBox(height: 12),
                // Location row
                Row(
                  children: [
                    Container(width: 20, height: 20, decoration: BoxDecoration(color: base, borderRadius: BorderRadius.circular(6))),
                    const SizedBox(width: 8),
                    Expanded(child: Container(height: 16, color: base)),
                  ],
                ),
                const SizedBox(height: 16),
                // Metrics grid placeholders
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: List.generate(4, (i) => Container(
                        width: (MediaQuery.of(context).size.width - 20 * 2 - 12) / 2,
                        height: 90,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[200]!),
                        ),
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(width: 100, height: 12, color: base),
                            const SizedBox(height: 8),
                            Container(width: 60, height: 18, color: base),
                            const SizedBox(height: 6),
                            Container(width: 80, height: 10, color: base),
                          ],
                        ),
                      )),
                ),
                const SizedBox(height: 20),
                // Section blocks
                ...List.generate(3, (index) => Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(height: 16, width: 120, color: base),
                          const SizedBox(height: 12),
                          Container(height: 12, width: double.infinity, color: base),
                          const SizedBox(height: 8),
                          Container(height: 12, width: MediaQuery.of(context).size.width * 0.7, color: base),
                          const SizedBox(height: 8),
                          Container(height: 12, width: MediaQuery.of(context).size.width * 0.5, color: base),
                        ],
                      ),
                    )),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildCollegeDetails(
      BuildContext context, College college, CollegeProvider provider) {
    return CustomScrollView(
      slivers: [
        // Enhanced SliverAppBar with better design
        SliverAppBar(
          expandedHeight: 280,
          pinned: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/home');
              }
            },
          ),
          flexibleSpace: FlexibleSpaceBar(
            title: Text(
              college.shortName ?? college.name,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
                shadows: [Shadow(blurRadius: 4, color: Colors.black54)],
              ),
            ),
            background: Stack(
              fit: StackFit.expand,
              children: [
                college.imageUrl != null && college.imageUrl!.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: college.imageUrl!,
                        fit: BoxFit.cover,
                        errorWidget: (context, url, error) =>
                            _buildPlaceholderBackground(context),
                        placeholder: (context, url) => _buildHeroImageSkeleton(),
                      )
                    : _buildPlaceholderBackground(context),
                // Gradient overlay for better text readability
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.3),
                        Colors.black.withOpacity(0.7),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(
                provider.isFavorite(college)
                    ? Icons.favorite
                    : Icons.favorite_border,
                color: provider.isFavorite(college) ? Colors.red : Colors.white,
              ),
              onPressed: () => provider.toggleFavorite(college),
            ),
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: () => _shareCollege(college),
            ),
          ],
        ),

        // College header information
        SliverToBoxAdapter(
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // College name and basic info
                Text(
                  college.name,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[900],
                      ),
                ),
                const SizedBox(height: 8),

                // Location with enhanced design
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(
                        Icons.location_on,
                        size: 16,
                        color: Colors.blue[700],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${college.city}, ${college.state}',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Rating section with enhanced design
                if (college.ratingAsDouble > 0) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.amber[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.amber[200]!),
                    ),
                    child: Row(
                      children: [
                        RatingBar.builder(
                          initialRating: college.ratingAsDouble,
                          minRating: 1,
                          direction: Axis.horizontal,
                          allowHalfRating: true,
                          itemCount: 5,
                          itemSize: 24.0,
                          ignoreGestures: true,
                          onRatingUpdate: (rating) {},
                          itemBuilder: (context, index) => const Icon(
                            Icons.star,
                            color: Colors.amber,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              college.ratingAsDouble.toStringAsFixed(1),
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.amber[800],
                                  ),
                            ),
                            Text(
                              '${college.reviewCount ?? 0} reviews',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: Colors.amber[700],
                                  ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Key metrics in a grid layout
                _buildKeyMetricsGrid(context, college),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),

        // Enhanced tab bar
        SliverPersistentHeader(
          pinned: true,
          delegate: _SliverAppBarDelegate(
            TabBar(
              controller: _tabController,
              labelColor: Theme.of(context).primaryColor,
              unselectedLabelColor: Colors.grey[600],
              indicatorColor: Theme.of(context).primaryColor,
              indicatorWeight: 3,
              labelStyle: const TextStyle(fontWeight: FontWeight.w600),
              tabs: const [
                Tab(icon: Icon(Icons.info_outline), text: 'Overview'),
                Tab(icon: Icon(Icons.school), text: 'Courses'),
                Tab(icon: Icon(Icons.work), text: 'Placement'),
                Tab(icon: Icon(Icons.rate_review), text: 'Reviews'),
              ],
            ),
          ),
        ),

        // Tab content
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

  Widget _buildPlaceholderBackground(BuildContext context) {
    return Container(
      color: Theme.of(context).primaryColor,
      child: const Center(
        child: Icon(Icons.school, size: 80, color: Colors.white),
      ),
    );
  }

  Widget _buildKeyMetricsGrid(BuildContext context, College college) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.5, // Further reduced to give even more height
      children: [
        if (college.fees != null)
          _buildMetricCard(
            context,
            'Fees',
            '₹${(college.feesAsDouble / 1000).toStringAsFixed(0)}K',
            college.feesPeriod ?? 'yearly',
            Icons.currency_rupee,
            Colors.green,
          ),
        if (college.nirfRank != null)
          _buildMetricCard(
            context,
            'NIRF Rank',
            '#${college.nirfRank}',
            'National Ranking',
            Icons.workspace_premium,
            Colors.orange,
          ),
        if (college.placementRate != null)
          _buildMetricCard(
            context,
            'Placement',
            '${college.placementRate}%',
            'Placement Rate',
            Icons.work,
            Colors.blue,
          ),
        if (college.establishedYear != null)
          _buildMetricCard(
            context,
            'Established',
            '${college.establishedYear}',
            'Year Founded',
            Icons.calendar_today,
            Colors.purple,
          ),
      ],
    );
  }

  Widget _buildMetricCard(BuildContext context, String title, String value,
      String subtitle, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(10), // Further reduced padding
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16), // Further reduced icon size
              const SizedBox(width: 4), // Further reduced spacing
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: color.withOpacity(0.8),
                        fontWeight: FontWeight.w500,
                        fontSize: 11, // Smaller font size
                      ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4), // Further reduced spacing
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                  fontSize: 16, // Slightly smaller font
                ),
            overflow: TextOverflow.ellipsis,
          ),
          if (subtitle.isNotEmpty) ...[
            const SizedBox(height: 1), // Minimal spacing
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: color.withOpacity(0.7),
                    fontSize: 10, // Smaller font size
                  ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOverviewTab(BuildContext context, College college) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // About section
          if (college.description != null) ...[
            _buildSectionTitle('About', Icons.info_outline),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Text(
                college.description!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      height: 1.5,
                    ),
              ),
            ),
            const SizedBox(height: 24),
          ],

          // College details
          _buildSectionTitle('College Details', Icons.school),
          const SizedBox(height: 12),
          _buildDetailCard(context, college),
          const SizedBox(height: 24),

          // Contact information
          if (college.website != null) ...[
            _buildSectionTitle('Contact', Icons.contact_phone),
            const SizedBox(height: 12),
            _buildContactCard(context, college),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey[600], size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailCard(BuildContext context, College college) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildDetailRow('Type', college.type, Icons.category),
          if (college.establishedYear != null)
            _buildDetailRow('Established', college.establishedYear.toString(),
                Icons.calendar_today),
          if (college.affiliation != null)
            _buildDetailRow(
                'Affiliation', college.affiliation!, Icons.account_balance),
          if (college.admissionProcess != null)
            _buildDetailRow('Admission Process', college.admissionProcess!,
                Icons.how_to_reg),
          if (college.cutoffScore != null)
            _buildDetailRow(
                'Cutoff Score', college.cutoffScore.toString(), Icons.score),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactCard(BuildContext context, College college) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          if (college.website != null) ...[
            ListTile(
              leading: const Icon(Icons.web, color: Colors.blue),
              title: const Text('Website'),
              subtitle: Text(college.website!),
              trailing: const Icon(Icons.open_in_new),
              onTap: () => _launchUrl(college.website!),
            ),
            const Divider(),
          ],
          ListTile(
            leading: const Icon(Icons.location_on, color: Colors.red),
            title: const Text('Address'),
            subtitle: Text(college.location),
            trailing: const Icon(Icons.map),
            onTap: () => _openMap(college.location),
          ),
        ],
      ),
    );
  }

  Widget _buildCoursesTab(BuildContext context, College college) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Available Courses', Icons.school),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildCourseItem('Bachelor of Technology (B.Tech)', '4 Years',
                    'Engineering'),
                const Divider(),
                _buildCourseItem(
                    'Master of Technology (M.Tech)', '2 Years', 'Engineering'),
                const Divider(),
                _buildCourseItem(
                    'Bachelor of Science (B.Sc)', '3 Years', 'Science'),
                const Divider(),
                _buildCourseItem('Master of Business Administration (MBA)',
                    '2 Years', 'Management'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCourseItem(String courseName, String duration, String category) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.school, color: Colors.blue[700], size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  courseName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        duration,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.green[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.orange[50],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        category,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.orange[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlacementTab(BuildContext context, College college) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Placement Statistics', Icons.work),
          const SizedBox(height: 16),

          // Placement overview card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                if (college.placementRate != null)
                  _buildPlacementStat(
                      'Placement Rate',
                      '${college.placementRate}%',
                      Icons.trending_up,
                      Colors.green),
                if (college.averagePackage != null)
                  _buildPlacementStat(
                      'Average Package',
                      '₹${college.averagePackage} LPA',
                      Icons.currency_rupee,
                      Colors.blue),
                if (college.highestPackage != null)
                  _buildPlacementStat(
                      'Highest Package',
                      '₹${college.highestPackage} LPA',
                      Icons.emoji_events,
                      Colors.orange),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Top recruiters section
          _buildSectionTitle('Top Recruiters', Icons.business),
          const SizedBox(height: 16),
          _buildRecruitersList(),
        ],
      ),
    );
  }

  Widget _buildPlacementStat(
      String label, String value, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecruitersList() {
    final recruiters = [
      'Google',
      'Microsoft',
      'Amazon',
      'TCS',
      'Infosys',
      'Wipro',
      'HCL',
      'IBM',
      'Accenture',
      'Cognizant'
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: recruiters
            .map((recruiter) => Chip(
                  label: Text(recruiter),
                  backgroundColor: Colors.grey[100],
                  side: BorderSide(color: Colors.grey[300]!),
                ))
            .toList(),
      ),
    );
  }

  Widget _buildReviewsTab(
      BuildContext context, College college, CollegeProvider provider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Student Reviews', Icons.rate_review),
          const SizedBox(height: 16),

          // Review summary
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Overall Rating',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Text(
                              college.ratingAsDouble.toStringAsFixed(1),
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.amber,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              '/5',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        RatingBar.builder(
                          initialRating: college.ratingAsDouble,
                          minRating: 1,
                          direction: Axis.horizontal,
                          allowHalfRating: true,
                          itemCount: 5,
                          itemSize: 24.0,
                          ignoreGestures: true,
                          onRatingUpdate: (rating) {},
                          itemBuilder: (context, index) => const Icon(
                            Icons.star,
                            color: Colors.amber,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${college.reviewCount ?? 0} reviews',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Sample reviews
          _buildSampleReviews(),
        ],
      ),
    );
  }

  Widget _buildSampleReviews() {
    final sampleReviews = [
      {
        'name': 'Rahul Kumar',
        'rating': 4.5,
        'comment':
            'Great infrastructure and faculty. Placement opportunities are excellent.',
        'date': '2 months ago',
      },
      {
        'name': 'Priya Sharma',
        'rating': 4.0,
        'comment':
            'Good academic environment. The campus is beautiful and well-maintained.',
        'date': '3 months ago',
      },
      {
        'name': 'Amit Patel',
        'rating': 4.8,
        'comment':
            'Outstanding college with excellent placement records. Highly recommended!',
        'date': '1 month ago',
      },
    ];

    return Column(
      children: sampleReviews
          .map((review) => Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[200]!),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.grey[300],
                          child: Text(
                            review['name'].toString().substring(0, 1),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                review['name'].toString(),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                review['date'].toString(),
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        RatingBar.builder(
                          initialRating: review['rating'] as double,
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
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      review['comment'].toString(),
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ))
          .toList(),
    );
  }

  void _shareCollege(College college) {
    final shareText = '''
🏫 ${college.name}
📍 ${college.city}, ${college.state}
${college.ratingAsDouble > 0 ? '⭐ ${college.ratingAsDouble.toStringAsFixed(1)} (${college.reviewCount ?? 0} reviews)' : ''}
${college.fees != null ? '💰 ₹${college.feesAsDouble.toStringAsFixed(0)} ${college.feesPeriod ?? 'yearly'}' : ''}
${college.nirfRank != null ? '🏆 NIRF Rank #${college.nirfRank}' : ''}
${college.placementRate != null ? '💼 ${college.placementRate}% placement rate' : ''}

Check out this college on College Campus app!
    '''
        .trim();

    Share.share(shareText, subject: 'Check out ${college.name}');
  }

  void _launchUrl(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }

  void _openMap(String location) async {
    final url =
        'https://www.google.com/maps/search/${Uri.encodeComponent(location)}';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }
}

// Custom SliverPersistentHeaderDelegate for tab bar
class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;

  _SliverAppBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height;

  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
