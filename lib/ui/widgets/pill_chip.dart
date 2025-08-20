import 'package:flutter/material.dart';
import '../design_system.dart';

class PillChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback? onTap;
  final IconData? leadingIcon;
  final Color? color;

  const PillChip({
    super.key,
    required this.label,
    this.selected = false,
    this.onTap,
    this.leadingIcon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final bg = selected ? (color ?? cs.primary).withOpacity(0.12) : AppTokens.surface;
    final border = selected ? (color ?? cs.primary) : Colors.grey.withOpacity(0.25);
    final fg = selected ? (color ?? cs.primary) : AppTokens.textPrimary;

    return Material(
      color: bg,
      shape: RoundedRectangleBorder(
        borderRadius: AppTokens.rPill,
        side: BorderSide(color: border, width: 1),
      ),
      child: InkWell(
        borderRadius: AppTokens.rPill,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (leadingIcon != null) ...[
                Icon(leadingIcon, size: 16, color: fg),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: fg,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.2,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
