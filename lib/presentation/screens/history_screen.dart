import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';

import '../../core/theme/color_tokens.dart';
import '../bloc/calculator_cubit.dart';
import '../bloc/history_cubit.dart';
import '../../domain/models/calculation_entry.dart';

/// Full history view with search and filter
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _showFavoritesOnly = false;
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? ColorTokens.darkBackground : ColorTokens.lightBackground,
      appBar: AppBar(
        title: Text(
          'History',
          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            onPressed: _showFavoritesOnly ? null : () {
              setState(() => _showFavoritesOnly = !_showFavoritesOnly);
            },
            icon: Icon(
              _showFavoritesOnly ? Icons.star : Icons.star_border,
              color: _showFavoritesOnly ? ColorTokens.accentYellow : null,
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'clear':
                  _showClearDialog();
                  break;
                case 'export_all':
                  _exportAll();
                  break;
              }
            },
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: 'export_all',
                child: Text('Export All'),
              ),
              const PopupMenuItem(
                value: 'clear',
                child: Text('Clear All', style: TextStyle(color: ColorTokens.error)),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: InputDecoration(
                hintText: 'Search calculations...',
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                        icon: const Icon(Icons.clear, size: 20),
                      )
                    : null,
                filled: true,
                fillColor: isDark ? ColorTokens.darkSurface : ColorTokens.lightSurface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
              ),
            ),
          ),
          
          // History list
          Expanded(
            child: BlocBuilder<HistoryCubit, HistoryState>(
              builder: (context, state) {
                final entries = _getFilteredEntries(state);
                
                if (entries.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.history_rounded,
                          size: 64,
                          color: (isDark ? ColorTokens.darkOnSurface : ColorTokens.lightOnSurface)
                              .withOpacity(0.3),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isNotEmpty
                              ? 'No matching calculations'
                              : 'No history yet',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            color: (isDark ? ColorTokens.darkOnSurface : ColorTokens.lightOnSurface)
                                .withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                  );
                }
                
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: entries.length,
                  itemBuilder: (context, index) {
                    final entry = entries[index];
                    return _buildHistoryItem(context, entry, isDark);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
  
  List<CalculationEntry> _getFilteredEntries(HistoryState state) {
    var entries = state.entries;
    
    if (_showFavoritesOnly) {
      entries = entries.where((e) => e.isFavorite).toList();
    }
    
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      entries = entries.where((e) {
        return e.expression.toLowerCase().contains(query) ||
               e.result.toLowerCase().contains(query);
      }).toList();
    }
    
    return entries;
  }
  
  Widget _buildHistoryItem(BuildContext context, CalculationEntry entry, bool isDark) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: isDark ? ColorTokens.darkSurface : ColorTokens.lightSurface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          context.read<CalculatorCubit>().recallHistory(entry);
          Navigator.pop(context);
        },
        onLongPress: () => _showEntryOptions(context, entry),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      entry.expression,
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 14,
                        color: (isDark ? ColorTokens.darkOnSurface : ColorTokens.lightOnSurface)
                            .withOpacity(0.7),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      context.read<HistoryCubit>().toggleFavorite(entry.id);
                    },
                    icon: Icon(
                      entry.isFavorite ? Icons.star : Icons.star_border,
                      size: 18,
                      color: entry.isFavorite
                          ? ColorTokens.accentYellow
                          : (isDark ? ColorTokens.darkOnSurface : ColorTokens.lightOnSurface)
                              .withOpacity(0.4),
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '= ${entry.result}',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: isDark ? ColorTokens.darkOnBackground : ColorTokens.lightOnBackground,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    entry.mode,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: ColorTokens.electricCyan,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _formatTimestamp(entry.timestamp),
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: (isDark ? ColorTokens.darkOnSurface : ColorTokens.lightOnSurface)
                          .withOpacity(0.4),
                    ),
                  ),
                  const Spacer(),
                  // Copy button
                  IconButton(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: entry.result));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Result copied to clipboard'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                    icon: const Icon(Icons.copy, size: 16),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 8),
                  // Share button
                  IconButton(
                    onPressed: () => _shareEntry(entry),
                    icon: const Icon(Icons.share, size: 16),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  void _showEntryOptions(BuildContext context, CalculationEntry entry) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.copy),
              title: const Text('Copy Result'),
              onTap: () {
                Clipboard.setData(ClipboardData(text: entry.result));
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.content_copy),
              title: const Text('Copy Expression'),
              onTap: () {
                Clipboard.setData(ClipboardData(text: '${entry.expression} = ${entry.result}'));
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Share'),
              onTap: () {
                Navigator.pop(context);
                _shareEntry(entry);
              },
            ),
            ListTile(
              leading: Icon(
                entry.isFavorite ? Icons.star_border : Icons.star,
                color: entry.isFavorite ? ColorTokens.error : null,
              ),
              title: Text(entry.isFavorite ? 'Remove from Favorites' : 'Add to Favorites'),
              onTap: () {
                context.read<HistoryCubit>().toggleFavorite(entry.id);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: ColorTokens.error),
              title: const Text('Delete', style: TextStyle(color: ColorTokens.error)),
              onTap: () {
                context.read<HistoryCubit>().deleteEntry(entry.id);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
  
  void _shareEntry(CalculationEntry entry) {
    // ignore: deprecated_member_use
    Share.share(
      '${entry.expression} = ${entry.result}\n— CalcPro Studio',
    );
  }
  
  void _exportAll() {
    final entries = context.read<HistoryCubit>().state.entries;
    final buffer = StringBuffer();
    buffer.writeln('CalcPro Studio - Calculation History');
    buffer.writeln('=' * 50);
    buffer.writeln();
    
    for (final entry in entries) {
      buffer.writeln('${entry.expression} = ${entry.result}');
      buffer.writeln('  Mode: ${entry.mode} | ${_formatTimestamp(entry.timestamp)}');
      buffer.writeln();
    }
    
    // ignore: deprecated_member_use
    Share.share(buffer.toString());
  }
  
  void _showClearDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear History'),
        content: const Text('Are you sure you want to clear all history? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<HistoryCubit>().clearAll();
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: ColorTokens.error),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
  
  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final entryDate = DateTime(timestamp.year, timestamp.month, timestamp.day);
    
    if (entryDate == today) {
      return 'Today ${DateFormat('HH:mm').format(timestamp)}';
    } else if (entryDate == today.subtract(const Duration(days: 1))) {
      return 'Yesterday ${DateFormat('HH:mm').format(timestamp)}';
    } else {
      return DateFormat('MMM d, HH:mm').format(timestamp);
    }
  }
}
