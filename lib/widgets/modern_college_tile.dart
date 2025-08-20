import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../models/college.dart';
import '../ui/design_system.dart';

class ModernCollegeTile extends StatelessWidget {
  final College college;
  final VoidCallback onTap;
  final bool isFavorite;
  final VoidCallback onToggleFav;

  const ModernCollegeTile({
    super.key,
    required this.college,
    required this.onTap,
    required this.isFavorite,
    required this.onToggleFav,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTokens.outline),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
            BoxShadow(
              color: AppTokens.primary.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            _AvatarBadge(text: _initials(college.name)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(college.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 4),
                  Text('${college.city}, ${college.state} • ${college.type}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _pill(context, '#${college.nirfRank ?? '—'}', Icons.emoji_events_outlined),
                      _pill(
                        context,
                        college.fees == null || college.fees!.isEmpty
                            ? '₹—/yr'
                            : '₹${(double.tryParse(college.fees!) ?? 0) / 1000}k/yr',
                        Icons.account_balance_wallet_outlined,
                      ),
                      _pill(
                        context,
                        college.averagePackage == null || college.averagePackage!.isEmpty
                            ? '— LPA'
                            : '${double.tryParse(college.averagePackage!)?.toStringAsFixed(1) ?? '—'} LPA',
                        Icons.currency_rupee_outlined,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      RatingBarIndicator(
                        rating: (college.ratingAsDouble).clamp(0, 5).toDouble(),
                        itemCount: 5,
                        itemSize: 16,
                        itemBuilder: (context, _) =>
                            Icon(Icons.star_rounded, color: cs.primary),
                      ),
                      const SizedBox(width: 8),
                      Text(college.ratingAsDouble.toStringAsFixed(1),
                          style: tt.bodySmall?.copyWith(fontWeight: FontWeight.w700)),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: onToggleFav,
              icon: Icon(
                isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                color: isFavorite ? cs.primary : cs.onSurfaceVariant,
              ),
              tooltip: isFavorite ? 'Remove from favorites' : 'Add to favorites',
            )
          ],
        ),
      ),
    );
  }

  Widget _pill(BuildContext context, String text, IconData icon) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: cs.onSurfaceVariant),
          const SizedBox(width: 6),
          Text(text, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }

  static String _initials(String name) {
    final parts = name.split(' ');
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1)).toUpperCase();
  }
}

class _AvatarBadge extends StatelessWidget {
  final String text;
  const _AvatarBadge({required this.text});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: 54,
      height: 54,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [cs.primary, cs.primaryContainer],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w900,
              color: cs.onPrimary,
            ),
      ),
    );
  }
}
