import 'package:flutter/material.dart';
import 'package:mance/Providers/video_provider.dart';

class VideoSearchBar extends StatelessWidget {
  final ThemeData theme;
  final VideoProvider provider;
  final bool isDark;
  final bool isGridView;
  final VoidCallback onToggleView;

  const VideoSearchBar({
    super.key,
    required this.theme,
    required this.provider,
    required this.isDark,
    required this.isGridView,
    required this.onToggleView,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withOpacity(0.08)
                  : Colors.black.withOpacity(0.05),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: isDark ? Colors.white10 : Colors.black12,
                width: 0.5,
              ),
            ),
            child: TextField(
              onChanged: provider.searchVideos,
              style: const TextStyle(fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Search videos...',
                hintStyle: const TextStyle(fontSize: 14, color: Colors.grey),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  size: 20,
                  color: Colors.grey,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip(
                  "All",
                  provider.currentFilter == "All",
                  () => provider.filterVideos("All"),
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  "Recent",
                  provider.currentFilter == "Recent",
                  () => provider.filterVideos("Recent"),
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  "Large",
                  provider.currentFilter == "Large",
                  () => provider.filterVideos("Large"),
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  "Short",
                  provider.currentFilter == "Short",
                  () => provider.filterVideos("Short"),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 16, 0),
          child: Row(
            children: [
              Text(
                '${provider.filteredVideos.length} ITEMS',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                  color: Colors.grey,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: onToggleView,
                icon: Icon(
                  isGridView
                      ? Icons.grid_view_rounded
                      : Icons.view_list_rounded,
                  size: 20,
                ),
                color: theme.primaryColor,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.primaryColor
              : (isDark
                    ? Colors.white.withOpacity(0.05)
                    : Colors.black.withOpacity(0.05)),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? theme.primaryColor
                : (isDark ? Colors.white10 : Colors.black12),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? Colors.white
                : (isDark ? Colors.white70 : Colors.black87),
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
