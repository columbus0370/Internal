import 'package:shared_preferences/shared_preferences.dart';

class PreferenceService {
  static const String _lastHomeTeamKey = 'last_home_team';
  static const String _lastAwayTeamKey = 'last_away_team';
  static const String _favoriteTeamsKey = 'favorite_teams';

  static late SharedPreferences _prefs;
  static bool _initialized = false;

  /// Initialize SharedPreferences. Call this once on app startup.
  static Future<void> init() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      _initialized = true;
    } catch (e) {
      print('Failed to initialize SharedPreferences: $e');
      _initialized = false;
      // Gracefully degrade: app continues but caching is disabled
    }
  }

  /// Check if SharedPreferences is initialized and ready.
  static bool get isInitialized => _initialized;

  /// Save the last selected home team name.
  static Future<void> setLastHomeTeam(String teamName) async {
    if (!_initialized) return;
    try {
      await _prefs.setString(_lastHomeTeamKey, teamName);
    } catch (e) {
      print('Failed to save last home team: $e');
    }
  }

  /// Save the last selected away team name.
  static Future<void> setLastAwayTeam(String teamName) async {
    if (!_initialized) return;
    try {
      await _prefs.setString(_lastAwayTeamKey, teamName);
    } catch (e) {
      print('Failed to save last away team: $e');
    }
  }

  /// Get the last selected home team name. Returns null if not set.
  static String? getLastHomeTeam() {
    if (!_initialized) return null;
    try {
      return _prefs.getString(_lastHomeTeamKey);
    } catch (e) {
      print('Failed to get last home team: $e');
      return null;
    }
  }

  /// Get the last selected away team name. Returns null if not set.
  static String? getLastAwayTeam() {
    if (!_initialized) return null;
    try {
      return _prefs.getString(_lastAwayTeamKey);
    } catch (e) {
      print('Failed to get last away team: $e');
      return null;
    }
  }

  /// Add a team to favorites list.
  static Future<void> addFavoriteTeam(String teamName) async {
    if (!_initialized) return;
    try {
      final favorites = _prefs.getStringList(_favoriteTeamsKey) ?? [];
      if (!favorites.contains(teamName)) {
        favorites.add(teamName);
        await _prefs.setStringList(_favoriteTeamsKey, favorites);
      }
    } catch (e) {
      print('Failed to add favorite team: $e');
    }
  }

  /// Remove a team from favorites list.
  static Future<void> removeFavoriteTeam(String teamName) async {
    if (!_initialized) return;
    try {
      final favorites = _prefs.getStringList(_favoriteTeamsKey) ?? [];
      favorites.remove(teamName);
      await _prefs.setStringList(_favoriteTeamsKey, favorites);
    } catch (e) {
      print('Failed to remove favorite team: $e');
    }
  }

  /// Get all favorite teams.
  static List<String> getFavoriteTeams() {
    if (!_initialized) return [];
    try {
      return _prefs.getStringList(_favoriteTeamsKey) ?? [];
    } catch (e) {
      print('Failed to get favorite teams: $e');
      return [];
    }
  }

  /// Check if a team is in favorites.
  static bool isFavoriteTeam(String teamName) {
    if (!_initialized) return false;
    try {
      final favorites = _prefs.getStringList(_favoriteTeamsKey) ?? [];
      return favorites.contains(teamName);
    } catch (e) {
      print('Failed to check favorite team: $e');
      return false;
    }
  }

  /// Clear all preferences.
  static Future<void> clearAll() async {
    if (!_initialized) return;
    try {
      await _prefs.clear();
    } catch (e) {
      print('Failed to clear preferences: $e');
    }
  }
}
