// Personality Selection Screen
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../domain/entities/personality.dart';
import '../widgets/personality_card.dart';
import '../theme/colors.dart';

class PersonalitySelectionScreen extends StatefulWidget {
  final Personality? initialPersonality;
  final Function(Personality?)? onPersonalitySelected;
  final bool showAppBar;

  const PersonalitySelectionScreen({
    super.key,
    this.initialPersonality,
    this.onPersonalitySelected,
    this.showAppBar = true,
  });

  @override
  State<PersonalitySelectionScreen> createState() => _PersonalitySelectionScreenState();
}

class _PersonalitySelectionScreenState extends State<PersonalitySelectionScreen>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  Personality? _selectedPersonality;
  List<Personality> _filteredPersonalities = [];
  bool _isGridView = true;
  String _searchQuery = '';
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Vietnamese translations for personality names and descriptions
  final Map<PersonalityType, Map<String, String>> _vietnameseTranslations = {
    PersonalityType.happy: {
      'name': 'Vui vẻ',
      'description': 'Tính cách vui vẻ và lạc quan với giọng điệu tích cực',
    },
    PersonalityType.romantic: {
      'name': 'Lãng mạn',
      'description': 'Ấm áp và tình cảm với giọng điệu dịu dàng, yêu thương',
    },
    PersonalityType.funny: {
      'name': 'Hài hước',
      'description': 'Vui tươi và hài hước với cách tiếp cận nhẹ nhàng',
    },
    PersonalityType.professional: {
      'name': 'Chuyên nghiệp',
      'description': 'Trang trọng và nghiệp vụ với lời nói rõ ràng, mạch lạc',
    },
    PersonalityType.casual: {
      'name': 'Thân thiện',
      'description': 'Thư giãn và thân mật với giọng điệu trò chuyện thoải mái',
    },
    PersonalityType.energetic: {
      'name': 'Năng động',
      'description': 'Tràn đầy năng lượng và nhiệt tình với cách trình bày sinh động',
    },
    PersonalityType.calm: {
      'name': 'Bình tĩnh',
      'description': 'Thanh bình và nhẹ nhàng với giọng điệu ổn định, yên tĩnh',
    },
    PersonalityType.mysterious: {
      'name': 'Bí ẩn',
      'description': 'Hấp dẫn và bí ẩn với giọng điệu tinh tế, quyến rũ',
    },
  };

  @override
  void initState() {
    super.initState();
    _selectedPersonality = widget.initialPersonality;
    _filteredPersonalities = Personality.allPersonalities;
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    
    _animationController.forward();
    
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase().trim();
      _filterPersonalities();
    });
  }

  void _filterPersonalities() {
    if (_searchQuery.isEmpty) {
      _filteredPersonalities = Personality.allPersonalities;
    } else {
      _filteredPersonalities = Personality.allPersonalities.where((personality) {
        final englishName = personality.displayName.toLowerCase();
        final englishDescription = personality.description.toLowerCase();
        final vietnameseName = _getVietnameseName(personality.type).toLowerCase();
        final vietnameseDescription = _getVietnameseDescription(personality.type).toLowerCase();
        
        return englishName.contains(_searchQuery) ||
               englishDescription.contains(_searchQuery) ||
               vietnameseName.contains(_searchQuery) ||
               vietnameseDescription.contains(_searchQuery);
      }).toList();
    }
  }

  String _getVietnameseName(PersonalityType type) {
    return _vietnameseTranslations[type]?['name'] ?? '';
  }

  String _getVietnameseDescription(PersonalityType type) {
    return _vietnameseTranslations[type]?['description'] ?? '';
  }

  void _onPersonalityTap(Personality personality) {
    setState(() {
      _selectedPersonality = _selectedPersonality == personality ? null : personality;
    });
    
    // Haptic feedback
    if (_selectedPersonality != null) {
      // Light impact feedback for selection
      HapticFeedback.lightImpact();
    }
    
    widget.onPersonalitySelected?.call(_selectedPersonality);
  }

  void _toggleViewMode() {
    setState(() {
      _isGridView = !_isGridView;
    });
  }

  void _clearSearch() {
    _searchController.clear();
    _searchFocusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Scaffold(
      appBar: widget.showAppBar
          ? AppBar(
              title: const Text('Chọn tính cách'),
              elevation: 0,
              actions: [
                IconButton(
                  icon: Icon(_isGridView ? Icons.list : Icons.grid_view),
                  onPressed: _toggleViewMode,
                  tooltip: _isGridView ? 'Chế độ danh sách' : 'Chế độ lưới',
                ),
                if (_selectedPersonality != null)
                  IconButton(
                    icon: const Icon(Icons.check),
                    onPressed: () {
                      Navigator.of(context).pop(_selectedPersonality);
                    },
                    tooltip: 'Xác nhận',
                  ),
              ],
            )
          : null,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            // Search Bar
            Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(28),
              ),
              child: TextField(
                controller: _searchController,
                focusNode: _searchFocusNode,
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm tính cách...',
                  prefixIcon: Icon(
                    Icons.search,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: Icon(
                            Icons.clear,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          onPressed: _clearSearch,
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                ),
              ),
            ),

            // Results count and view toggle
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  if (_searchQuery.isNotEmpty)
                    Text(
                      '${_filteredPersonalities.length} kết quả',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  const Spacer(),
                  
                  // View toggle buttons
                  Container(
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Grid view button
                        InkWell(
                          onTap: () => setState(() => _isGridView = true),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(8),
                            bottomLeft: Radius.circular(8),
                          ),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: _isGridView
                                  ? colorScheme.primary
                                  : Colors.transparent,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(8),
                                bottomLeft: Radius.circular(8),
                              ),
                            ),
                            child: Icon(
                              Icons.grid_view,
                              size: 20,
                              color: _isGridView
                                  ? colorScheme.onPrimary
                                  : colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                        
                        // List view button
                        InkWell(
                          onTap: () => setState(() => _isGridView = false),
                          borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(8),
                            bottomRight: Radius.circular(8),
                          ),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: !_isGridView
                                  ? colorScheme.primary
                                  : Colors.transparent,
                              borderRadius: const BorderRadius.only(
                                topRight: Radius.circular(8),
                                bottomRight: Radius.circular(8),
                              ),
                            ),
                            child: Icon(
                              Icons.view_list,
                              size: 20,
                              color: !_isGridView
                                  ? colorScheme.onPrimary
                                  : colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Selected personality preview
            if (_selectedPersonality != null)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.getPersonalityColor(_selectedPersonality!.type.name).withOpacity(0.15),
                      AppColors.getPersonalityColor(_selectedPersonality!.type.name).withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.getPersonalityColor(_selectedPersonality!.type.name),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.getPersonalityColor(_selectedPersonality!.type.name).withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.getPersonalityColor(_selectedPersonality!.type.name).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.check_circle,
                        color: AppColors.getPersonalityColor(_selectedPersonality!.type.name),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Đã chọn: ${_selectedPersonality!.displayName}',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.getPersonalityColor(_selectedPersonality!.type.name),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _getVietnameseDescription(_selectedPersonality!.type),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => setState(() => _selectedPersonality = null),
                      icon: Icon(
                        Icons.close,
                        color: AppColors.getPersonalityColor(_selectedPersonality!.type.name),
                      ),
                      tooltip: 'Bỏ chọn',
                    ),
                  ],
                ),
              ),

            // Personality list/grid
            Expanded(
              child: _filteredPersonalities.isEmpty
                  ? _buildEmptyState()
                  : _isGridView
                      ? _buildGridView()
                      : _buildListView(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            'Không tìm thấy tính cách',
            style: theme.textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Thử từ khóa khác',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: _clearSearch,
            child: const Text('Xóa tìm kiếm'),
          ),
        ],
      ),
    );
  }

  Widget _buildGridView() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        padding: const EdgeInsets.only(bottom: 16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.75, // Làm cho các ô cao hơn một chút
          crossAxisSpacing: 8,     // Giảm khoảng cách giữa các cột
          mainAxisSpacing: 8,      // Giảm khoảng cách giữa các hàng
        ),
        itemCount: _filteredPersonalities.length,
        itemBuilder: (context, index) {
          final personality = _filteredPersonalities[index];
          return CompactPersonalityCard(
            personality: personality,
            isSelected: _selectedPersonality == personality,
            onTap: () => _onPersonalityTap(personality),
          );
        },
      ),
    );
  }

  Widget _buildListView() {
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 16),
      itemCount: _filteredPersonalities.length,
      itemBuilder: (context, index) {
        final personality = _filteredPersonalities[index];
        return PersonalityListItem(
          personality: personality,
          isSelected: _selectedPersonality == personality,
          onTap: () => _onPersonalityTap(personality),
        );
      },
    );
  }
}

// Standalone personality selection dialog
class PersonalitySelectionDialog extends StatelessWidget {
  final Personality? initialPersonality;
  final String title;

  const PersonalitySelectionDialog({
    super.key,
    this.initialPersonality,
    this.title = 'Chọn tính cách',
  });

  static Future<Personality?> show(
    BuildContext context, {
    Personality? initialPersonality,
    String title = 'Chọn tính cách',
  }) {
    return showDialog<Personality?>(
      context: context,
      builder: (context) => PersonalitySelectionDialog(
        initialPersonality: initialPersonality,
        title: title,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      child: SizedBox(
        width: double.maxFinite,
        height: MediaQuery.of(context).size.height * 0.8,
        child: Column(
          children: [
            // Dialog Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            
            // Personality Selection Content
            Expanded(
              child: PersonalitySelectionScreen(
                initialPersonality: initialPersonality,
                showAppBar: false,
                onPersonalitySelected: (personality) {
                  Navigator.of(context).pop(personality);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}