import 'package:flutter/material.dart';

/// Advanced search bar with filtering and sorting capabilities for configuration management
class ConfigurationSearchBar extends StatefulWidget {
  final String searchQuery;
  final ValueChanged<String> onSearchChanged;
  final ConfigurationSortBy sortBy;
  final ValueChanged<ConfigurationSortBy> onSortChanged;
  final bool sortAscending;
  final ValueChanged<bool> onSortOrderChanged;
  final Set<ConfigurationFilter> activeFilters;
  final ValueChanged<Set<ConfigurationFilter>> onFiltersChanged;
  final VoidCallback? onClearAll;
  final bool showFilters;

  const ConfigurationSearchBar({
    super.key,
    required this.searchQuery,
    required this.onSearchChanged,
    required this.sortBy,
    required this.onSortChanged,
    required this.sortAscending,
    required this.onSortOrderChanged,
    required this.activeFilters,
    required this.onFiltersChanged,
    this.onClearAll,
    this.showFilters = true,
  });

  @override
  State<ConfigurationSearchBar> createState() => _ConfigurationSearchBarState();
}

class _ConfigurationSearchBarState extends State<ConfigurationSearchBar>
    with SingleTickerProviderStateMixin {
  late TextEditingController _searchController;
  late AnimationController _filterAnimationController;
  late Animation<double> _filterAnimation;
  bool _showFilters = false;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.searchQuery);
    _filterAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _filterAnimation = CurvedAnimation(
      parent: _filterAnimationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _filterAnimationController.dispose();
    super.dispose();
  }

  void _toggleFilters() {
    setState(() {
      _showFilters = !_showFilters;
      if (_showFilters) {
        _filterAnimationController.forward();
      } else {
        _filterAnimationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      margin: EdgeInsets.zero,
      child: Column(
        children: [
          // Search bar and sort controls
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // Search field
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Tìm kiếm cấu hình...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: widget.searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              widget.onSearchChanged('');
                            },
                          )
                        : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    onChanged: widget.onSearchChanged,
                  ),
                ),
                
                const SizedBox(width: 8),
                
                // Sort button
                PopupMenuButton<ConfigurationSortBy>(
                  icon: Icon(
                    widget.sortAscending 
                      ? Icons.sort_by_alpha 
                      : Icons.sort_by_alpha,
                  ),
                  tooltip: 'Sắp xếp',
                  onSelected: widget.onSortChanged,
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: ConfigurationSortBy.name,
                      child: ListTile(
                        leading: const Icon(Icons.sort_by_alpha),
                        title: const Text('Tên'),
                        trailing: widget.sortBy == ConfigurationSortBy.name
                          ? Icon(
                              widget.sortAscending 
                                ? Icons.arrow_upward 
                                : Icons.arrow_downward
                            )
                          : null,
                      ),
                    ),
                    PopupMenuItem(
                      value: ConfigurationSortBy.dateCreated,
                      child: ListTile(
                        leading: const Icon(Icons.access_time),
                        title: const Text('Ngày tạo'),
                        trailing: widget.sortBy == ConfigurationSortBy.dateCreated
                          ? Icon(
                              widget.sortAscending 
                                ? Icons.arrow_upward 
                                : Icons.arrow_downward
                            )
                          : null,
                      ),
                    ),
                    PopupMenuItem(
                      value: ConfigurationSortBy.lastUsed,
                      child: ListTile(
                        leading: const Icon(Icons.history),
                        title: const Text('Lần dùng cuối'),
                        trailing: widget.sortBy == ConfigurationSortBy.lastUsed
                          ? Icon(
                              widget.sortAscending 
                                ? Icons.arrow_upward 
                                : Icons.arrow_downward
                            )
                          : null,
                      ),
                    ),
                    PopupMenuItem(
                      value: ConfigurationSortBy.usageCount,
                      child: ListTile(
                        leading: const Icon(Icons.trending_up),
                        title: const Text('Lượt sử dụng'),
                        trailing: widget.sortBy == ConfigurationSortBy.usageCount
                          ? Icon(
                              widget.sortAscending 
                                ? Icons.arrow_upward 
                                : Icons.arrow_downward
                            )
                          : null,
                      ),
                    ),
                    const PopupMenuDivider(),
                    PopupMenuItem(
                      value: widget.sortBy,
                      child: ListTile(
                        leading: Icon(
                          widget.sortAscending 
                            ? Icons.arrow_downward 
                            : Icons.arrow_upward
                        ),
                        title: Text(
                          widget.sortAscending 
                            ? 'Đảo ngược thứ tự' 
                            : 'Đảo ngược thứ tự'
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          widget.onSortOrderChanged(!widget.sortAscending);
                        },
                      ),
                    ),
                  ],
                ),
                
                // Filter toggle
                if (widget.showFilters) ...[
                  const SizedBox(width: 8),
                  IconButton(
                    icon: Icon(
                      _showFilters ? Icons.filter_list : Icons.filter_list_outlined,
                      color: widget.activeFilters.isNotEmpty 
                        ? theme.colorScheme.primary 
                        : null,
                    ),
                    tooltip: 'Bộ lọc',
                    onPressed: _toggleFilters,
                  ),
                ],
                
                // Clear all
                if (widget.onClearAll != null && 
                    (widget.searchQuery.isNotEmpty || widget.activeFilters.isNotEmpty)) ...[
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.clear_all),
                    tooltip: 'Xóa tất cả bộ lọc',
                    onPressed: widget.onClearAll,
                  ),
                ],
              ],
            ),
          ),
          
          // Filter options
          if (widget.showFilters)
            SizeTransition(
              sizeFactor: _filterAnimation,
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Divider(),
                    Text(
                      'Bộ lọc',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    // Filter chips
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: ConfigurationFilter.values.map((filter) {
                        final isActive = widget.activeFilters.contains(filter);
                        return FilterChip(
                          label: Text(_getFilterLabel(filter)),
                          selected: isActive,
                          onSelected: (selected) {
                            final newFilters = Set<ConfigurationFilter>.from(widget.activeFilters);
                            if (selected) {
                              newFilters.add(filter);
                            } else {
                              newFilters.remove(filter);
                            }
                            widget.onFiltersChanged(newFilters);
                          },
                          avatar: Icon(
                            _getFilterIcon(filter),
                            size: 18,
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _getFilterLabel(ConfigurationFilter filter) {
    switch (filter) {
      case ConfigurationFilter.favorites:
        return 'Yêu thích';
      case ConfigurationFilter.recentlyUsed:
        return 'Dùng gần đây';
      case ConfigurationFilter.mostUsed:
        return 'Dùng nhiều nhất';
      case ConfigurationFilter.hasVoice:
        return 'Có giọng nói';
      case ConfigurationFilter.activeOnly:
        return 'Đang hoạt động';
      case ConfigurationFilter.createdThisWeek:
        return 'Tạo tuần này';
      case ConfigurationFilter.neverUsed:
        return 'Chưa dùng';
    }
  }

  IconData _getFilterIcon(ConfigurationFilter filter) {
    switch (filter) {
      case ConfigurationFilter.favorites:
        return Icons.favorite;
      case ConfigurationFilter.recentlyUsed:
        return Icons.schedule;
      case ConfigurationFilter.mostUsed:
        return Icons.trending_up;
      case ConfigurationFilter.hasVoice:
        return Icons.record_voice_over;
      case ConfigurationFilter.activeOnly:
        return Icons.radio_button_checked;
      case ConfigurationFilter.createdThisWeek:
        return Icons.today;
      case ConfigurationFilter.neverUsed:
        return Icons.new_label;
    }
  }
}

/// Sort options for configurations
enum ConfigurationSortBy {
  name,
  dateCreated,
  lastUsed,
  usageCount,
}

/// Filter options for configurations
enum ConfigurationFilter {
  favorites,
  recentlyUsed,
  mostUsed,
  hasVoice,
  activeOnly,
  createdThisWeek,
  neverUsed,
}

/// Quick search suggestions widget
class SearchSuggestions extends StatelessWidget {
  final List<String> suggestions;
  final ValueChanged<String> onSuggestionSelected;

  const SearchSuggestions({
    super.key,
    required this.suggestions,
    required this.onSuggestionSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (suggestions.isEmpty) return const SizedBox.shrink();
    
    return Card(
      margin: const EdgeInsets.only(top: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(
              'Gợi ý tìm kiếm',
              style: Theme.of(context).textTheme.labelMedium,
            ),
          ),
          ...suggestions.take(5).map((suggestion) => ListTile(
            dense: true,
            leading: const Icon(Icons.search, size: 20),
            title: Text(suggestion),
            onTap: () => onSuggestionSelected(suggestion),
          )),
        ],
      ),
    );
  }
}

/// Search statistics widget
class SearchStatistics extends StatelessWidget {
  final int totalResults;
  final int filteredResults;
  final Duration searchDuration;

  const SearchStatistics({
    super.key,
    required this.totalResults,
    required this.filteredResults,
    required this.searchDuration,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            size: 16,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 8),
          Text(
            'Tìm thấy $filteredResults/$totalResults kết quả '
            '(${searchDuration.inMilliseconds}ms)',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}