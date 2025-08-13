// Avatar Provider for State Management
import 'package:flutter/foundation.dart';
import '../../domain/entities/avatar_configuration.dart';
import '../../domain/repositories/avatar_repository.dart';

enum AvatarLoadingState {
  initial,
  loading,
  loaded,
  error,
}

class AvatarProvider extends ChangeNotifier {
  final AvatarRepository _avatarRepository;

  AvatarProvider({required AvatarRepository avatarRepository})
      : _avatarRepository = avatarRepository;

  // State
  AvatarLoadingState _loadingState = AvatarLoadingState.initial;
  List<AvatarConfiguration> _configurations = [];
  AvatarConfiguration? _activeConfiguration;
  AvatarConfiguration? _selectedConfiguration;
  String? _errorMessage;
  bool _isCreating = false;
  bool _isUpdating = false;
  bool _isDeleting = false;

  // Getters
  AvatarLoadingState get loadingState => _loadingState;
  List<AvatarConfiguration> get configurations => List.unmodifiable(_configurations);
  AvatarConfiguration? get activeConfiguration => _activeConfiguration;
  AvatarConfiguration? get selectedConfiguration => _selectedConfiguration;
  String? get errorMessage => _errorMessage;
  bool get isCreating => _isCreating;
  bool get isUpdating => _isUpdating;
  bool get isDeleting => _isDeleting;
  bool get hasConfigurations => _configurations.isNotEmpty;
  bool get hasActiveConfiguration => _activeConfiguration != null;
  bool get isLoading => _loadingState == AvatarLoadingState.loading;
  bool get hasError => _loadingState == AvatarLoadingState.error;
  int get configurationCount => _configurations.length;
  
  // Expose repository for backup operations
  AvatarRepository get repository => _avatarRepository;

  // Load all configurations
  Future<void> loadConfigurations() async {
    _setLoadingState(AvatarLoadingState.loading);
    _clearError();

    try {
      final configurations = await _avatarRepository.getAllConfigurations();
      _configurations = configurations;
      
      // Find active configuration
      try {
        _activeConfiguration = configurations.firstWhere((config) => config.isActive);
      } catch (e) {
        _activeConfiguration = null;
      }

      _setLoadingState(AvatarLoadingState.loaded);
    } catch (e) {
      _setError('Failed to load configurations: $e');
      _setLoadingState(AvatarLoadingState.error);
    }
  }

  // Create new configuration
  Future<bool> createConfiguration(AvatarConfiguration configuration) async {
    _isCreating = true;
    _clearError();
    notifyListeners();

    try {
      await _avatarRepository.createConfiguration(configuration);
      _configurations.add(configuration);
      
      if (configuration.isActive) {
        await _updateActiveConfiguration(configuration);
      }
      
      _isCreating = false;
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to create configuration: $e');
      _isCreating = false;
      notifyListeners();
      return false;
    }
  }

  // Update configuration
  Future<bool> updateConfiguration(AvatarConfiguration configuration) async {
    _isUpdating = true;
    _clearError();
    notifyListeners();

    try {
      await _avatarRepository.updateConfiguration(configuration);
      
      final index = _configurations.indexWhere((c) => c.id == configuration.id);
      if (index != -1) {
        _configurations[index] = configuration;
        
        if (configuration.isActive) {
          await _updateActiveConfiguration(configuration);
        }
        
        if (_selectedConfiguration?.id == configuration.id) {
          _selectedConfiguration = configuration;
        }
      }
      
      _isUpdating = false;
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to update configuration: $e');
      _isUpdating = false;
      notifyListeners();
      return false;
    }
  }

  // Delete configuration
  Future<bool> deleteConfiguration(String id) async {
    _isDeleting = true;
    _clearError();
    notifyListeners();

    try {
      await _avatarRepository.deleteConfiguration(id);
      
      final wasActive = _activeConfiguration?.id == id;
      _configurations.removeWhere((c) => c.id == id);
      
      if (wasActive) {
        _activeConfiguration = null;
      }
      
      if (_selectedConfiguration?.id == id) {
        _selectedConfiguration = null;
      }
      
      _isDeleting = false;
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to delete configuration: $e');
      _isDeleting = false;
      notifyListeners();
      return false;
    }
  }

  // Activate configuration
  Future<bool> activateConfiguration(String id) async {
    _clearError();
    
    try {
      await _avatarRepository.activateConfiguration(id);
      
      // Update local state
      for (int i = 0; i < _configurations.length; i++) {
        if (_configurations[i].id == id) {
          _configurations[i] = _configurations[i].activate();
          _activeConfiguration = _configurations[i];
        } else {
          _configurations[i] = _configurations[i].deactivate();
        }
      }
      
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to activate configuration: $e');
      return false;
    }
  }

  // Deactivate configuration
  Future<bool> deactivateConfiguration(String id) async {
    _clearError();
    
    try {
      await _avatarRepository.deactivateConfiguration(id);
      
      final index = _configurations.indexWhere((c) => c.id == id);
      if (index != -1) {
        _configurations[index] = _configurations[index].deactivate();
        
        if (_activeConfiguration?.id == id) {
          _activeConfiguration = null;
        }
      }
      
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to deactivate configuration: $e');
      return false;
    }
  }

  // Search configurations
  Future<void> searchConfigurations(String query) async {
    if (query.isEmpty) {
      await loadConfigurations();
      return;
    }

    _setLoadingState(AvatarLoadingState.loading);
    _clearError();

    try {
      final results = await _avatarRepository.searchConfigurations(query);
      _configurations = results;
      _setLoadingState(AvatarLoadingState.loaded);
    } catch (e) {
      _setError('Failed to search configurations: $e');
      _setLoadingState(AvatarLoadingState.error);
    }
  }

  // Select configuration for editing
  void selectConfiguration(AvatarConfiguration? configuration) {
    _selectedConfiguration = configuration;
    notifyListeners();
  }

  // Clear selection
  void clearSelection() {
    _selectedConfiguration = null;
    notifyListeners();
  }

  // Get configuration by ID
  AvatarConfiguration? getConfigurationById(String id) {
    try {
      return _configurations.firstWhere((config) => config.id == id);
    } catch (e) {
      return null;
    }
  }

  // Check if name exists
  Future<bool> configurationNameExists(String name, {String? excludeId}) async {
    try {
      return await _avatarRepository.configurationNameExists(name, excludeId: excludeId);
    } catch (e) {
      return false;
    }
  }

  // Refresh data
  Future<void> refresh() async {
    await loadConfigurations();
  }

  // Clear all configurations
  Future<bool> clearAllConfigurations() async {
    _clearError();
    
    try {
      await _avatarRepository.clearAllConfigurations();
      
      // Clear local state
      _configurations.clear();
      _activeConfiguration = null;
      _selectedConfiguration = null;
      
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to clear all configurations: $e');
      return false;
    }
  }

  // Private methods
  void _setLoadingState(AvatarLoadingState state) {
    _loadingState = state;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  Future<void> _updateActiveConfiguration(AvatarConfiguration configuration) async {
    // Deactivate all other configurations
    for (int i = 0; i < _configurations.length; i++) {
      if (_configurations[i].id != configuration.id && _configurations[i].isActive) {
        _configurations[i] = _configurations[i].deactivate();
      }
    }
    _activeConfiguration = configuration;
  }

}