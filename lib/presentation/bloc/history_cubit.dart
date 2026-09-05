import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/models/calculation_entry.dart';

/// History list management cubit
class HistoryCubit extends Cubit<HistoryState> {
  HistoryCubit() : super(const HistoryState()) {
    loadHistory();
  }
  
  Future<void> loadHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getStringList('history') ?? [];
      final entries = historyJson
          .map((json) => CalculationEntry.fromJsonString(json))
          .toList();
      emit(HistoryState(entries: entries));
    } catch (_) {
      emit(const HistoryState());
    }
  }
  
  Future<void> addEntry(CalculationEntry entry) async {
    final newEntries = [entry, ...state.entries];
    emit(state.copyWith(entries: newEntries));
    await _save(newEntries);
  }
  
  Future<void> deleteEntry(String id) async {
    final newEntries = state.entries.where((e) => e.id != id).toList();
    emit(state.copyWith(entries: newEntries));
    await _save(newEntries);
  }
  
  Future<void> toggleFavorite(String id) async {
    final newEntries = state.entries.map((e) {
      if (e.id == id) {
        return e.copyWith(isFavorite: !e.isFavorite);
      }
      return e;
    }).toList();
    emit(state.copyWith(entries: newEntries));
    await _save(newEntries);
  }
  
  Future<void> clearAll() async {
    emit(const HistoryState());
    await _save([]);
  }
  
  List<CalculationEntry> get filteredEntries {
    if (state.searchQuery.isEmpty) return state.entries;
    final query = state.searchQuery.toLowerCase();
    return state.entries.where((e) {
      return e.expression.toLowerCase().contains(query) ||
             e.result.toLowerCase().contains(query) ||
             e.mode.toLowerCase().contains(query);
    }).toList();
  }
  
  void setSearchQuery(String query) {
    emit(state.copyWith(searchQuery: query));
  }
  
  void setShowFavoritesOnly(bool value) {
    emit(state.copyWith(showFavoritesOnly: value));
  }
  
  Future<void> _save(List<CalculationEntry> entries) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = entries.map((e) => e.toJsonString()).toList();
      if (jsonList.length > 500) {
        jsonList.removeRange(500, jsonList.length);
      }
      await prefs.setStringList('history', jsonList);
    } catch (_) {}
  }
}

/// History state
class HistoryState {
  final List<CalculationEntry> entries;
  final String searchQuery;
  final bool showFavoritesOnly;
  
  const HistoryState({
    this.entries = const [],
    this.searchQuery = '',
    this.showFavoritesOnly = false,
  });
  
  HistoryState copyWith({
    List<CalculationEntry>? entries,
    String? searchQuery,
    bool? showFavoritesOnly,
  }) {
    return HistoryState(
      entries: entries ?? this.entries,
      searchQuery: searchQuery ?? this.searchQuery,
      showFavoritesOnly: showFavoritesOnly ?? this.showFavoritesOnly,
    );
  }
  
  bool get isEmpty => entries.isEmpty;
  int get count => entries.length;
  
  List<CalculationEntry> get favoriteEntries =>
      entries.where((e) => e.isFavorite).toList();
}
