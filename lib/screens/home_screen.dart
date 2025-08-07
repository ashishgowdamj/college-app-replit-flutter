import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../services/college_provider.dart';
import '../models/college.dart';
import '../widgets/college_card.dart';
import '../widgets/search_bar_widget.dart';
import '../widgets/bottom_navigation.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CollegeProvider>().fetchColleges(refresh: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/app_logo.png',
              height: 48,
              width: 48,
            ),
            const SizedBox(width: 12),
            const Text(
              'College Campus',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // TODO: Implement notifications
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: Theme.of(context).primaryColor,
            child: const SearchBarWidget(),
          ),
          
          // Quick filters section
          _buildQuickFilters(),
          
          // Statistics section
          _buildStatistics(),
          
          Expanded(
            child: Consumer<CollegeProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading && provider.colleges.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Loading colleges...'),
                      ],
                    ),
                  );
                }

                if (provider.error != null && provider.colleges.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Failed to load colleges',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          provider.error!,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => provider.fetchColleges(),
                          child: const Text('Retry'),
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
                          Icons.school_outlined,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No colleges found',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Try adjusting your search filters',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => provider.fetchColleges(),
                  child: ListView.builder(
                    itemCount: provider.colleges.length + (provider.isLoading ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index >= provider.colleges.length) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }

                      final college = provider.colleges[index];
                      return CollegeCard(
                        college: college,
                        isFavorite: provider.isFavorite(college),
                        onTap: () => context.go('/college/${college.id}'),
                        onFavoriteToggle: () => provider.toggleFavorite(college),
                        onCompare: () => _addToComparison(context, college),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: const BottomNavigation(currentRoute: '/home'),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/predictor'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        child: const Icon(Icons.psychology),
      ),
    );
  }

  Widget _buildQuickFilters() {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildFilterChip('All', Icons.all_inclusive, null),
          _buildFilterChip('IITs', Icons.school, 'IIT'),
          _buildFilterChip('Medical', Icons.medical_services, 'Medical'),
          _buildFilterChip('Management', Icons.business, 'Management'),
          _buildFilterChip('Government', Icons.account_balance, 'Government'),
          _buildFilterChip('Private', Icons.business_center, 'Private'),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, IconData icon, String? filterValue) {
    return Consumer<CollegeProvider>(
      builder: (context, provider, child) {
        final isSelected = provider.currentFilters['type'] == filterValue;
        
        return Container(
          margin: const EdgeInsets.only(right: 8),
          child: FilterChip(
            label: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 16),
                const SizedBox(width: 4),
                Text(label),
              ],
            ),
            selected: isSelected,
            onSelected: (selected) {
              if (selected) {
                provider.setFilter('type', filterValue);
              } else {
                provider.clearFilter('type');
              }
              provider.fetchColleges(refresh: true);
            },
            backgroundColor: Colors.grey[100],
            selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
            checkmarkColor: Theme.of(context).primaryColor,
          ),
        );
      },
    );
  }

  void _addToComparison(BuildContext context, College college) {
    // Navigate to compare screen and add the college
    context.go('/compare');
    // You could also pass the college data through a provider or route parameters
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${college.shortName ?? college.name} added to comparison'),
        backgroundColor: Colors.green,
        action: SnackBarAction(
          label: 'View',
          onPressed: () => context.go('/compare'),
        ),
      ),
    );
  }

  Widget _buildStatistics() {
    return Consumer<CollegeProvider>(
      builder: (context, provider, child) {
        if (provider.colleges.isEmpty) return const SizedBox.shrink();
        
        final totalColleges = provider.colleges.length;
        final avgRating = provider.colleges
            .where((c) => c.ratingAsDouble > 0)
            .map((c) => c.ratingAsDouble)
            .reduce((a, b) => a + b) / provider.colleges.where((c) => c.ratingAsDouble > 0).length;
        
        return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Total Colleges',
                  totalColleges.toString(),
                  Icons.school,
                  Colors.blue,
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.grey[300],
              ),
              Expanded(
                child: _buildStatItem(
                  'Avg Rating',
                  avgRating.isNaN ? 'N/A' : avgRating.toStringAsFixed(1),
                  Icons.star,
                  Colors.amber,
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.grey[300],
              ),
              Expanded(
                child: _buildStatItem(
                  'Top Ranked',
                  provider.colleges.where((c) => c.nirfRank != null && c.nirfRank! <= 10).length.toString(),
                  Icons.workspace_premium,
                  Colors.orange,
                ),
              ),
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