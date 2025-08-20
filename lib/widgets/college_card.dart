import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:share_plus/share_plus.dart';
import '../models/college.dart';
import '../ui/design_system.dart';

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
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return RepaintBoundary(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppTokens.outline, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(.04),
                blurRadius: 24,
                offset: const Offset(0, 12),
                spreadRadius: 0,
              ),
              BoxShadow(
                color: AppTokens.primary.withOpacity(.08),
                blurRadius: 16,
                offset: const Offset(0, 6),
                spreadRadius: 0,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─── TOP ROW ────────────────────────────────────────────────
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _AppBadge(imageUrl: college.imageUrl),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          college.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: tt.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.place_rounded,
                              size: 16,
                              color: cs.onSurfaceVariant,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                '${college.city}, ${college.state}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: tt.bodySmall?.copyWith(
                                  color: cs.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (college.nirfRank != null) const SizedBox(height: 2),
                      if (college.nirfRank != null)
                        _RankPill(text: '#${college.nirfRank}'),
                      if (college.nirfRank != null) const SizedBox(height: 6),
                      if (college.ratingAsDouble > 0)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.star_rate_rounded,
                              size: 18,
                              color: Colors.orange.shade600,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              college.ratingAsDouble.toStringAsFixed(1),
                              style: tt.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      const SizedBox(height: 8),
                      if (college.fees != null)
                        Text(
                          '₹${_feeShort(college.feesAsDouble)}/year',
                          style: tt.bodyMedium?.copyWith(
                            color: cs.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // ─── TAGS ROW ────────────────────────────────────────────────
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _Chip(text: college.type),
                  if (college.establishedYear != null)
                    _Chip(text: 'Est. ${college.establishedYear}', tone: _ChipTone.soft),
                ],
              ),
              const SizedBox(height: 10),
              // (Courses line removed — your College model has no `courses`)
              // ─── FOOTER ────────────────────────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: Wrap(
                      spacing: 16,
                      children: [
                        if (college.placementRate != null)
                          const _FooterHint(text: 'Top Placements'),
                        const _FooterHint(text: 'Research Excellence'),
                        if (college.hasHostel == true)
                          const _FooterHint(text: 'Hostel Available'),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: cs.primary,
                      foregroundColor: cs.onPrimary,
                      elevation: 2,
                      shadowColor: cs.primary.withOpacity(0.4),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    icon: const Icon(Icons.compare_arrows_rounded, size: 18),
                    label: const Text(
                      'Compare',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.3,
                      ),
                    ),
                    onPressed: onCompare,
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite ? Colors.red : cs.onSurfaceVariant,
                    ),
                    onPressed: onFavoriteToggle,
                  ),
                  IconButton(
                    icon: Icon(Icons.share_outlined, color: cs.onSurfaceVariant),
                    onPressed: () => _shareCollege(context),
                  ),
                ],
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
    '''
        .trim();

    Share.share(shareText, subject: 'Check out ${college.name}');
  }

  String _feeShort(double fee) {
    final lpa = fee / 100000.0;
    if (lpa >= 1) return '${lpa.toStringAsFixed(lpa >= 10 ? 0 : 1)}L';
    final k = fee / 1000.0;
    return '${k.toStringAsFixed(k >= 100 ? 0 : 1)}K';
  }
}

// ─── SMALL WIDGETS ──────────────────────────────────────────────────────────

class _AppBadge extends StatelessWidget {
  final String? imageUrl;
  const _AppBadge({this.imageUrl});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: LinearGradient(
          colors: [cs.primary, cs.primary.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: cs.primary.withOpacity(0.25),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: imageUrl != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(
                imageUrl: imageUrl!,
                fit: BoxFit.cover,
                width: 48,
                height: 48,
                memCacheWidth: 96,
                memCacheHeight: 96,
                fadeInDuration: const Duration(milliseconds: 100),
                fadeOutDuration: const Duration(milliseconds: 100),
                filterQuality: FilterQuality.medium,
                placeholder: (context, url) => Container(
                  color: cs.primary.withOpacity(0.2),
                  child: Icon(Icons.school_rounded, color: cs.onPrimary.withOpacity(0.7), size: 24),
                ),
                errorWidget: (_, __, ___) =>
                    Icon(Icons.school_rounded, color: cs.onPrimary, size: 24),
              ),
            )
          : Icon(Icons.school_rounded, color: cs.onPrimary, size: 24),
    );
  }
}

class _RankPill extends StatelessWidget {
  final String text;
  const _RankPill({required this.text});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF10B981), // Green
            const Color(0xFF059669), // Darker green
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(999),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF10B981).withOpacity(0.3),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: 13,
          letterSpacing: -0.3,
        ),
      ),
    );
  }
}

enum _ChipTone { solid, soft }

class _Chip extends StatelessWidget {
  final String text;
  final _ChipTone tone;
  const _Chip({required this.text, this.tone = _ChipTone.solid});
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final bg = tone == _ChipTone.solid
        ? cs.primary.withOpacity(.12)
        : cs.primary.withOpacity(.08);
    final border = cs.primary.withOpacity(.25);
    final fg = cs.primary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: border),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: fg,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _FooterHint extends StatelessWidget {
  final String text;
  const _FooterHint({required this.text});
  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
    );
  }
}
