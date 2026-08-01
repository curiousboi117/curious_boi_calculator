import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/calculation.dart';
import '../providers/calculator_provider.dart';
import '../providers/theme_provider.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calculation History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep_outlined),
            tooltip: 'Clear All',
            onPressed: () => _confirmClearAll(context),
          ),
        ],
      ),
      body: const SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: HistoryListWidget(),
        ),
      ),
    );
  }

  void _confirmClearAll(BuildContext context) {
    final provider = Provider.of<CalculatorProvider>(context, listen: false);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear History?'),
        content: const Text('This will delete all saved calculations permanently.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              provider.clearHistory();
              Navigator.pop(context);
            },
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }
}

class HistoryListWidget extends StatefulWidget {
  final bool embedMode;
  const HistoryListWidget({Key? key, this.embedMode = false}) : super(key: key);

  @override
  State<HistoryListWidget> createState() => _HistoryListWidgetState();
}

class _HistoryListWidgetState extends State<HistoryListWidget> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final calcProvider = Provider.of<CalculatorProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final calculations = calcProvider.searchHistory(_searchQuery);
    
    // Split pinned vs normal calculations
    final pinned = calculations.where((c) => c.isFavorite).toList();
    final unpinned = calculations.where((c) => !c.isFavorite).toList();
    final sortedCalculations = [...pinned, ...unpinned];

    return Column(
      children: [
        // Search bar
        TextField(
          controller: _searchController,
          onChanged: (val) => setState(() => _searchQuery = val),
          decoration: InputDecoration(
            hintText: 'Search calculations...',
            prefixIcon: const Icon(Icons.search_outlined),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear_outlined),
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _searchQuery = '');
                    },
                  )
                : null,
            filled: true,
            fillColor: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
        const SizedBox(height: 16.0),

        // List body
        Expanded(
          child: sortedCalculations.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.history_outlined,
                        size: 64,
                        color: theme.colorScheme.outline.withOpacity(0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _searchQuery.isNotEmpty ? 'No matches found' : 'No calculations yet',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: theme.colorScheme.outline,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: sortedCalculations.length,
                  physics: const BouncingScrollPhysics(),
                  itemBuilder: (context, index) {
                    final calc = sortedCalculations[index];
                    return _buildHistoryCard(context, calc, calcProvider, themeProvider);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildHistoryCard(
    BuildContext context,
    Calculation calc,
    CalculatorProvider provider,
    ThemeProvider themeProvider,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Card(
        margin: EdgeInsets.zero,
        elevation: 0,
        color: isDark ? const Color(0xFF1E1E22) : const Color(0xFFF3F3F7),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: calc.isFavorite
              ? BorderSide(color: theme.colorScheme.primary.withOpacity(0.4), width: 1.5)
              : BorderSide.none,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Expression & pin indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (calc.isFavorite)
                    Icon(
                      Icons.push_pin,
                      size: 14,
                      color: theme.colorScheme.primary,
                    )
                  else
                    const SizedBox.shrink(),
                  Expanded(
                    child: Text(
                      calc.expression,
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w400,
                        color: theme.colorScheme.outline,
                      ),
                      textAlign: TextAlign.end,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6.0),
              
              // Result
              Text(
                calc.result,
                style: TextStyle(
                  fontSize: 22.0,
                  fontWeight: FontWeight.bold,
                  color: themeProvider.dynamicColorEnabled
                      ? theme.colorScheme.primary
                      : (isDark ? const Color(0xFFD0BCFF) : const Color(0xFF6750A4)),
                ),
                textAlign: TextAlign.end,
              ),
              const SizedBox(height: 12.0),
              
              // Actions bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Timestamp
                  Text(
                    _formatTime(calc.timestamp),
                    style: TextStyle(
                      fontSize: 11.0,
                      color: theme.colorScheme.outline.withOpacity(0.7),
                    ),
                  ),
                  
                  // Action buttons
                  Row(
                    children: [
                      // Toggle Pin/Favorite
                      IconButton(
                        icon: Icon(
                          calc.isFavorite ? Icons.push_pin : Icons.push_pin_outlined,
                          size: 18,
                        ),
                        visualDensity: VisualDensity.compact,
                        tooltip: calc.isFavorite ? 'Unpin' : 'Pin Favorite',
                        onPressed: () {
                          provider.triggerFeedback();
                          provider.toggleFavoriteHistoryItem(calc.id);
                        },
                      ),
                      
                      // Copy Answer
                      IconButton(
                        icon: const Icon(Icons.copy_outlined, size: 18),
                        visualDensity: VisualDensity.compact,
                        tooltip: 'Copy Answer',
                        onPressed: () {
                          provider.triggerFeedback();
                          Clipboard.setData(ClipboardData(text: calc.result));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Answer copied to clipboard'),
                              duration: Duration(seconds: 1),
                            ),
                          );
                        },
                      ),
                      
                      // Reuse expression
                      IconButton(
                        icon: const Icon(Icons.settings_backup_restore_outlined, size: 18),
                        visualDensity: VisualDensity.compact,
                        tooltip: 'Load Expression',
                        onPressed: () {
                          provider.triggerFeedback();
                          provider.loadCalculation(calc);
                          if (!widget.embedMode) {
                            Navigator.pop(context);
                          }
                        },
                      ),
                      
                      // Delete item
                      IconButton(
                        icon: const Icon(Icons.delete_outline, size: 18),
                        visualDensity: VisualDensity.compact,
                        color: theme.colorScheme.error.withOpacity(0.8),
                        tooltip: 'Delete',
                        onPressed: () {
                          provider.triggerFeedback();
                          provider.deleteHistoryItem(calc.id);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final day = dateTime.day.toString().padLeft(2, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    return '$day/$month $hour:$minute';
  }
}
