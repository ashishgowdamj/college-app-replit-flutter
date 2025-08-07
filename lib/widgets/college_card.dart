import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:share_plus/share_plus.dart';
import '../models/college.dart';

class CollegeCard extends StatelessWidget {
  final College college;
  final VoidCallback? onTap;
  final VoidCallback? onFavoriteToggle;
  final VoidCallback? onCompare;
  final bool isFavorite;

  const CollegeCard({
    super.key,
    required this.college,
    this.onTap,
    this.onFavoriteToggle,
    this.onCompare,
    this.isFavorite = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Compact college image
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: college.imageUrl != null
                      ? CachedNetworkImage(
                          imageUrl: college.imageUrl!,
                          width: 70,
                          height: 70,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            width: 70,
                            height: 70,
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            width: 70,
                            height: 70,
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.school_rounded,
                              size: 30,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        )
                      : Icon(
                          Icons.school_rounded,
                          size: 30,
                          color: Theme.of(context).primaryColor,
                        ),
                ),
              ),
              const SizedBox(width: 12),
              
              // Main content area
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // College name and actions row
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            college.name,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[900],
                              fontSize: 16,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Compact action buttons
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            GestureDetector(
                              onTap: onFavoriteToggle,
                              child: Icon(
                                isFavorite ? Icons.favorite : Icons.favorite_border,
                                color: isFavorite ? Colors.red : Colors.grey[400],
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () => _shareCollege(context),
                              child: Icon(
                                Icons.share_outlined,
                                color: Colors.grey[400],
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: onCompare,
                              child: Icon(
                                Icons.compare_arrows,
                                color: Colors.grey[400],
                                size: 20,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    
                    // Location and type
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 14,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            '${college.city}, ${college.state}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            college.type,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.w500,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    
                    // Key metrics in compact format - Fixed overflow
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        // Rating
                        if (college.ratingAsDouble > 0)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.star,
                                size: 14,
                                color: Colors.amber[600],
                              ),
                              const SizedBox(width: 2),
                              Text(
                                college.ratingAsDouble.toStringAsFixed(1),
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        
                        // Fees
                        if (college.fees != null)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.currency_rupee,
                                size: 14,
                                color: Colors.green[600],
                              ),
                              const SizedBox(width: 2),
                              Text(
                                '${(college.feesAsDouble / 1000).toStringAsFixed(0)}K',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.green[600],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        
                        // NIRF Rank
                        if (college.nirfRank != null)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.workspace_premium,
                                size: 14,
                                color: Colors.orange[600],
                              ),
                              const SizedBox(width: 2),
                              Text(
                                '#${college.nirfRank}',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.orange[600],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    
                    // Additional info in compact format - Fixed overflow
                    Wrap(
                      spacing: 8,
                      runSpacing: 2,
                      children: [
                        // Establishment year
                        if (college.establishedYear != null)
                          Text(
                            'Est. ${college.establishedYear}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[500],
                              fontSize: 11,
                            ),
                          ),
                        
                        // Placement rate
                        if (college.placementRate != null)
                          Text(
                            '${college.placementRate} placement',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[500],
                              fontSize: 11,
                            ),
                          ),
                        
                        // Hostel availability
                        if (college.hasHostel == true)
                          Text(
                            '🏠 Hostel',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[500],
                              fontSize: 11,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _shareCollege(BuildContext context) {
    final shareText = '''
🏫 ${college.name}
📍 ${college.city}, ${college.state}
${college.ratingAsDouble > 0 ? '⭐ ${college.ratingAsDouble.toStringAsFixed(1)}' : ''}
${college.fees != null ? '💰 ₹${college.feesAsDouble.toStringAsFixed(0)}' : ''}
${college.nirfRank != null ? '🏆 NIRF #${college.nirfRank}' : ''}
${college.placementRate != null ? '💼 ${college.placementRate} placement' : ''}

Check out this college on College Campus app!
    '''.trim();
    
    Share.share(shareText, subject: 'Check out ${college.name}');
  }
}