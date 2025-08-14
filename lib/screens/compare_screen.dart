import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../services/college_provider.dart';
import '../models/college.dart';
import '../widgets/compare_matrix_sticky.dart';
import '../widgets/compare_accordion.dart';

class CompareScreen extends StatefulWidget {
  const CompareScreen({super.key});

  @override
  State<CompareScreen> createState() => _CompareScreenState();
}

class _CompareScreenState extends State<CompareScreen> {
  final List<College> selectedColleges = [];
  final Set<String> selectedCollegeIds = <String>{};
  final TextEditingController _searchController = TextEditingController();
  List<College> _filteredColleges = [];
  bool _isSearching = false;

  // Track which sections are expanded
  final Map<String, bool> _expandedSections = {
    'College Info': true,
    'College Rating & Reviews': true,
    'Courses & Fees': true,
    'College Ranking': true,
    'College Placements': true,
    'College Facilities': true,
  };

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Navigate back to previous screen
        if (context.canPop()) {
          context.pop();
        } else {
          context.go('/home');
        }
        return false; // Prevent default back behavior
      },
      child: Scaffold(
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
          title: const Text('Compare Colleges'),
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          actions: [
            if (selectedColleges.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.clear_all),
                onPressed: _clearSelection,
                tooltip: 'Clear Selection',
              ),
          ],
        ),
        body: Consumer<CollegeProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            // Initialize filtered colleges if empty
            if (_filteredColleges.isEmpty && !_isSearching) {
              _filteredColleges = provider.colleges;
            }

            return Column(
              children: [
                // Search bar at top
                _buildSearchBar(),

                // Selection area
                _buildSelectionArea(provider),

                // Comparison area
                if (selectedColleges.isNotEmpty)
                  Expanded(
                    child: _buildComparisonArea(),
                  )
                else
                  Expanded(
                    child: _buildEmptyState(),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSelectionArea(CollegeProvider provider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Compact header
          Row(
            children: [
              Text(
                'Selected (${selectedColleges.length}/4)',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              if (selectedColleges.isNotEmpty)
                TextButton(
                  onPressed: _clearSelection,
                  child: const Text('Clear', style: TextStyle(fontSize: 12)),
                ),
            ],
          ),

          // Selected colleges chips - compact
          if (selectedColleges.isNotEmpty)
            SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: selectedColleges.length,
                itemBuilder: (context, index) {
                  final college = selectedColleges[index];
                  return Container(
                    margin: const EdgeInsets.only(right: 8),
                    child: Chip(
                      label: Text(
                        college.shortName ?? college.name,
                        style: const TextStyle(fontSize: 11),
                      ),
                      deleteIcon: const Icon(Icons.close, size: 14),
                      onDeleted: () => _removeCollege(college),
                      backgroundColor:
                          Theme.of(context).primaryColor.withOpacity(0.1),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  );
                },
              ),
            ),

          // Compact college selection - only show when searching
          if (_isSearching && selectedColleges.length < 4)
            SizedBox(
              height: 120,
              child: _filteredColleges.isEmpty
                  ? Center(
                      child: Text(
                        'No colleges found for "${_searchController.text}"',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _filteredColleges.length,
                      itemBuilder: (context, index) {
                        final college = _filteredColleges[index];
                        final isSelected =
                            selectedCollegeIds.contains(college.id.toString());

                        return SizedBox(
                          height: 40,
                          child: ListTile(
                            dense: true,
                            contentPadding:
                                const EdgeInsets.symmetric(horizontal: 8),
                            leading: CircleAvatar(
                              radius: 12,
                              backgroundColor: Theme.of(context)
                                  .primaryColor
                                  .withOpacity(0.1),
                              child: Text(
                                college.shortName?.substring(0, 1) ??
                                    college.name.substring(0, 1),
                                style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            title: Text(
                              college.name,
                              style: const TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.w500),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: IconButton(
                              icon: Icon(
                                isSelected
                                    ? Icons.check_circle
                                    : Icons.add_circle_outline,
                                color: isSelected ? Colors.green : Colors.grey,
                                size: 20,
                              ),
                              onPressed: () {
                                if (isSelected) {
                                  _removeCollege(college);
                                } else {
                                  _addCollege(college);
                                }
                              },
                            ),
                          ),
                        );
                      },
                    ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.compare_arrows,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Select Colleges to Compare',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Choose up to 4 colleges to compare their features, rankings, and details side by side.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonArea() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // College Headers (like collegedunia)
          _buildCollegeHeaders(),

          const SizedBox(height: 12),

          // Comparison Matrix - shown when 2 or more colleges are selected
          if (selectedColleges.length >= 2) ...[
            const SizedBox(height: 16),
            CompareMatrixSticky(
              colleges: selectedColleges,
              compareAgainstBest:
                  true, // set to false to compare vs first selected
            ),
          ],

          // Courses & Fees Section
          if (selectedColleges.length >= 2) ...[
            const SizedBox(height: 16),
            CompareAccordion(
              title: 'Courses & Fees',
              colleges: selectedColleges,
              rows: [
                CompareRows.fees(),
                CompareRows.courseName(),
                CompareRows.acceptedExams(
                  onLinkTap: (i) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Open Admission Details for ${selectedColleges[i].name}'),
                      ),
                    );
                  },
                ),
                CompareRows.eligibility('10+2 with 75% + JEE Advanced'),
                CompareRows.cutoff(List.generate(selectedColleges.length, (i) {
                  // Generate some sample cutoff data
                  final cutoffs = ['171 (JEE-Advanced)', '125 (JEE-Advanced)', '198 (JEE-Advanced)'];
                  return i < cutoffs.length ? cutoffs[i] : '—';
                })),
                CompareRows.credential('Degree'),
                CompareRows.mode('On Campus'),
              ],
            ),
            const SizedBox(height: 16),
          ],

          // College Info Section
          _buildCollapsibleSection(
            'College Info',
            Icons.info_outline,
            _buildCollegeInfoComparison(),
          ),

          const SizedBox(height: 12),

          // College Rating & Reviews Section
          _buildCollapsibleSection(
            'College Rating & Reviews',
            Icons.star,
            _buildRatingReviewsComparison(),
          ),

          const SizedBox(height: 12),

          // Courses & Fees Section
          _buildCollapsibleSection(
            'Courses & Fees',
            Icons.school,
            _buildCoursesFeesComparison(),
          ),

          const SizedBox(height: 12),

          // College Ranking Section
          _buildCollapsibleSection(
            'College Ranking',
            Icons.workspace_premium,
            _buildRankingComparison(),
          ),

          const SizedBox(height: 12),

          // College Placements Section
          _buildCollapsibleSection(
            'College Placements',
            Icons.work,
            _buildPlacementsComparison(),
          ),

          const SizedBox(height: 12),

          // College Facilities Section
          _buildCollapsibleSection(
            'College Facilities',
            Icons.local_offer,
            _buildFacilitiesComparison(),
          ),
        ],
      ),
    );
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase().trim();
    setState(() {
      _isSearching = query.isNotEmpty;
      if (query.isEmpty) {
        _filteredColleges = [];
      } else {
        // Filter colleges based on search query
        _filteredColleges =
            context.read<CollegeProvider>().colleges.where((college) {
          return college.name.toLowerCase().contains(query) ||
              college.shortName?.toLowerCase().contains(query) == true ||
              college.city.toLowerCase().contains(query) ||
              college.state.toLowerCase().contains(query) ||
              college.type.toLowerCase().contains(query);
        }).toList();
      }
    });
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search colleges to compare...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _isSearching = false;
                      _filteredColleges = [];
                    });
                  },
                )
              : const Icon(Icons.mic),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                BorderSide(color: Theme.of(context).primaryColor, width: 2),
          ),
          filled: true,
          fillColor: Colors.grey[50],
        ),
      ),
    );
  }

  Widget _buildCollegeCardsHeader() {
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
          Text(
            'Selected Colleges',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: selectedColleges.map((college) {
              return Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Theme.of(context).primaryColor.withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        college.shortName ?? college.name,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${college.city}, ${college.state}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCollegeHeaders() {
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
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: selectedColleges.map((college) {
            return Container(
              width: 200, // Fixed width for each college
              margin: const EdgeInsets.only(right: 16),
              child: Column(
                children: [
                  Text(
                    college.shortName ?? college.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Bachelor of Technology [B.Tech]',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Computer Science and Engineering',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildCollapsibleSection(String title, IconData icon, Widget content) {
    final isExpanded = _expandedSections[title] ?? false;

    return Container(
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
          // Collapsible header
          InkWell(
            onTap: () {
              setState(() {
                _expandedSections[title] = !isExpanded;
              });
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(12),
                  topRight: const Radius.circular(12),
                  bottomLeft:
                      isExpanded ? Radius.zero : const Radius.circular(12),
                  bottomRight:
                      isExpanded ? Radius.zero : const Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  Icon(icon, color: Theme.of(context).primaryColor),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(Icons.keyboard_arrow_down,
                        color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ),
          // Content with animation
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: isExpanded ? null : 0,
            child: isExpanded ? content : null,
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonSection(String title, IconData icon, Widget content) {
    return Container(
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
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(icon, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          content,
        ],
      ),
    );
  }

  Widget _buildCollegeInfoComparison() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildComparisonRow(
              'Estd Date',
              selectedColleges
                  .map((c) => 'Estd ${c.establishedYear?.toString() ?? 'N/A'}')
                  .toList()),
          _buildComparisonRow('Ownership',
              selectedColleges.map((c) => 'Autonomous University').toList()),
          _buildComparisonRow(
              'Approved by', selectedColleges.map((c) => 'AICTE').toList()),
          _buildComparisonRow(
              'Total Course', selectedColleges.map((c) => '5').toList()),
        ],
      ),
    );
  }

  Widget _buildRatingReviewsComparison() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildComparisonRow(
              'Reviews',
              selectedColleges
                  .map((c) => '${c.reviewCount ?? 0} Reviews')
                  .toList()),
          _buildComparisonRow(
              'Overall Rating',
              selectedColleges
                  .map((c) => '${c.ratingAsDouble.toStringAsFixed(1)}/5')
                  .toList()),
          _buildComparisonRow(
              'Academic',
              selectedColleges
                  .map((c) => '${c.ratingAsDouble.toStringAsFixed(1)}/5')
                  .toList()),
        ],
      ),
    );
  }

  Widget _buildCoursesFeesComparison() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildComparisonRow(
              'Fees',
              selectedColleges
                  .map((c) => c.fees != null
                      ? '₹${(c.feesAsDouble / 1000).toStringAsFixed(0)}K 1st Yr Fees'
                      : 'N/A')
                  .toList()),
          _buildComparisonRow(
              'Course Name',
              selectedColleges
                  .map((c) => 'Bachelor of Technology [B.Tech]')
                  .toList()),
          _buildComparisonRow('Accepted Exams',
              selectedColleges.map((c) => 'JEE Advanced').toList()),
          _buildComparisonRow(
              'Eligibility Criteria',
              selectedColleges
                  .map((c) => '10+2 with 75% + JEE Advanced')
                  .toList()),
          _buildComparisonRow(
              'Cutoff',
              selectedColleges
                  .map((c) => c.cutoffScore != null
                      ? '${c.cutoffScore} (JEE-Advanced)'
                      : 'N/A')
                  .toList()),
          _buildComparisonRow('Course Credential',
              selectedColleges.map((c) => 'Degree').toList()),
          _buildComparisonRow(
              'Mode', selectedColleges.map((c) => 'On Campus').toList()),
        ],
      ),
    );
  }

  Widget _buildRankingComparison() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildComparisonRow(
              'NIRF',
              selectedColleges
                  .map((c) => c.nirfRank != null
                      ? '#${c.nirfRank} (Overall 2024)'
                      : 'N/A')
                  .toList()),
          _buildComparisonRow(
              'NIRF Innovation',
              selectedColleges
                  .map((c) => c.nirfRank != null
                      ? '#${(c.nirfRank! + 1)} (Overall 2024)'
                      : 'N/A')
                  .toList()),
          _buildComparisonRow('Financial Express',
              selectedColleges.map((c) => '#15 (Overall 2019)').toList()),
        ],
      ),
    );
  }

  Widget _buildPlacementsComparison() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildComparisonRow(
              'Highest Package',
              selectedColleges
                  .map((c) => c.highestPackage != null
                      ? 'INR ${(double.tryParse(c.highestPackage!) ?? 0 / 10000000).toStringAsFixed(2)} Cr'
                      : 'N/A')
                  .toList()),
          _buildComparisonRow(
              'Average Package',
              selectedColleges
                  .map((c) => c.averagePackage != null
                      ? 'INR ${(double.tryParse(c.averagePackage!) ?? 0 / 100000).toStringAsFixed(2)} L'
                      : 'N/A')
                  .toList()),
          _buildComparisonRow('Company',
              selectedColleges.map((c) => 'Amazon, Cisco, Citicorp').toList()),
        ],
      ),
    );
  }

  Widget _buildBasicInfoComparison() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildComparisonRow(
              'Full Name', selectedColleges.map((c) => c.name).toList()),
          _buildComparisonRow('Location',
              selectedColleges.map((c) => '${c.city}, ${c.state}').toList()),
          _buildComparisonRow(
              'Type', selectedColleges.map((c) => c.type ?? 'N/A').toList()),
          _buildComparisonRow(
              'Established',
              selectedColleges
                  .map((c) => c.establishedYear?.toString() ?? 'N/A')
                  .toList()),
          _buildComparisonRow('Affiliation',
              selectedColleges.map((c) => c.affiliation ?? 'N/A').toList()),
        ],
      ),
    );
  }

  Widget _buildRankingsComparison() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildComparisonRow(
              'NIRF Rank',
              selectedColleges
                  .map((c) => c.nirfRank != null ? '#${c.nirfRank}' : 'N/A')
                  .toList()),
          _buildComparisonRow(
              'Overall Rank',
              selectedColleges
                  .map((c) =>
                      c.overallRank != null ? '#${c.overallRank}' : 'N/A')
                  .toList()),
          _buildComparisonRow(
              'Rating',
              selectedColleges
                  .map((c) => c.ratingAsDouble > 0
                      ? c.ratingAsDouble.toStringAsFixed(1)
                      : 'N/A')
                  .toList()),
          _buildComparisonRow(
              'Reviews',
              selectedColleges
                  .map((c) => c.reviewCount?.toString() ?? 'N/A')
                  .toList()),
        ],
      ),
    );
  }

  Widget _buildFeesComparison() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildComparisonRow(
              'Fees',
              selectedColleges
                  .map((c) => c.fees != null
                      ? '₹${(c.feesAsDouble / 1000).toStringAsFixed(0)}K'
                      : 'N/A')
                  .toList()),
          _buildComparisonRow('Period',
              selectedColleges.map((c) => c.feesPeriod ?? 'N/A').toList()),
          _buildComparisonRow(
              'Hostel Fees',
              selectedColleges
                  .map((c) => c.hostelFees != null
                      ? '₹${(double.tryParse(c.hostelFees!) ?? 0 / 1000).toStringAsFixed(0)}K'
                      : 'N/A')
                  .toList()),
        ],
      ),
    );
  }

  Widget _buildPlacementComparison() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildComparisonRow(
              'Placement Rate',
              selectedColleges
                  .map((c) =>
                      c.placementRate != null ? '${c.placementRate}%' : 'N/A')
                  .toList()),
          _buildComparisonRow(
              'Avg Package',
              selectedColleges
                  .map((c) => c.averagePackage != null
                      ? '₹${(double.tryParse(c.averagePackage!) ?? 0 / 100000).toStringAsFixed(1)} LPA'
                      : 'N/A')
                  .toList()),
          _buildComparisonRow(
              'Highest Package',
              selectedColleges
                  .map((c) => c.highestPackage != null
                      ? '₹${(double.tryParse(c.highestPackage!) ?? 0 / 100000).toStringAsFixed(1)} LPA'
                      : 'N/A')
                  .toList()),
        ],
      ),
    );
  }

  Widget _buildAdmissionComparison() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildComparisonRow(
              'Admission Process',
              selectedColleges
                  .map((c) => c.admissionProcess ?? 'N/A')
                  .toList()),
          _buildComparisonRow(
              'Cutoff Score',
              selectedColleges
                  .map((c) => c.cutoffScore?.toString() ?? 'N/A')
                  .toList()),
        ],
      ),
    );
  }

  Widget _buildFacilitiesComparison() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildComparisonRow(
              'Hostel Available',
              selectedColleges
                  .map((c) => c.hasHostel == true ? 'Yes' : 'No')
                  .toList()),
          _buildComparisonRow(
              'Website',
              selectedColleges
                  .map((c) => c.website != null ? 'Available' : 'N/A')
                  .toList()),
        ],
      ),
    );
  }

  Widget _buildComparisonRow(String label, List<String> values) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: values.asMap().entries.map((entry) {
              final index = entry.key;
              final value = entry.value;
              return Container(
                width: 200, // Fixed width to match headers
                margin: const EdgeInsets.only(right: 16),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Text(
                  value,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  DataRow _buildDataRow(String label, List<String> values) {
    return DataRow(
      cells: [
        DataCell(Text(label)),
        ...values.map((value) => DataCell(Text(value))),
      ],
    );
  }

  void _addCollege(College college) {
    if (selectedColleges.length < 4 &&
        !selectedCollegeIds.contains(college.id.toString())) {
      setState(() {
        selectedColleges.add(college);
        selectedCollegeIds.add(college.id.toString());
      });
    } else if (selectedColleges.length >= 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You can only compare up to 4 colleges at a time'),
          backgroundColor: Colors.orange,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This college is already selected'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  void _removeCollege(College college) {
    setState(() {
      selectedColleges.remove(college);
      selectedCollegeIds.remove(college.id.toString());
    });
  }

  void _clearSelection() {
    setState(() {
      selectedColleges.clear();
      selectedCollegeIds.clear();
    });
  }

  void _startComparison() {
    if (selectedColleges.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least 2 colleges to compare'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // The comparison is already visible, just scroll to it
    // You could also show a success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Comparing ${selectedColleges.length} colleges'),
        backgroundColor: Colors.green,
      ),
    );
  }
}
