import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/calculation.dart';
import '../services/calculator_engine.dart';
import '../utils/constants.dart';

class CalculatorProvider extends ChangeNotifier {
  final SharedPreferences _prefs;

  String _expression = '';
  String _previewResult = '';
  String _result = '';
  double _memoryValue = 0.0;
  List<Calculation> _history = [];
  bool _isScientific = false;

  CalculatorProvider(this._prefs) {
    _loadData();
  }

  // Getters
  String get expression => _expression;
  String get previewResult => _previewResult;
  String get result => _result;
  double get memoryValue => _memoryValue;
  List<Calculation> get history => _history;
  bool get isScientific => _isScientific;

  void _loadData() {
    // Load Memory
    _memoryValue = _prefs.getDouble(AppConstants.keyMemoryValue) ?? 0.0;

    // Load History
    final historyJsonList = _prefs.getStringList(AppConstants.keyHistoryList);
    if (historyJsonList != null) {
      _history = historyJsonList.map((str) {
        return Calculation.fromJson(json.decode(str) as Map<String, dynamic>);
      }).toList();
    }
    notifyListeners();
  }

  // Load configuration details for formatting from the app context
  int _precision = AppConstants.defaultPrecision;
  bool _useSeparator = AppConstants.defaultThousandsSeparator;

  void updateFormatSettings(int precision, bool useSeparator) {
    _precision = precision;
    _useSeparator = useSeparator;
    // Re-evaluate live preview with new settings
    _updatePreview();
  }

  // Set scientific mode toggle
  void toggleScientific() {
    _isScientific = !_isScientific;
    notifyListeners();
  }

  void triggerFeedback() {
  // Placeholder for future haptic/sound feedback.
  }

  // Append character/string to current expression
  void append(String value) {
    // If there was a final result showing and user types a number, clear it
    if (_result.isNotEmpty && RegExp(r'[0-9.πe(]').hasMatch(value)) {
      _expression = '';
      _result = '';
    } else if (_result.isNotEmpty) {
      // If there was a result and user types an operator, carry over the result as expression
      _expression = _result;
      _result = '';
    }

    _expression = CalculatorEngine.append(_expression, value);
    _updatePreview();
    notifyListeners();
  }

  // Delete last character
  void backspace() {
    if (_result.isNotEmpty) {
      // If final result is showing, backspace acts as clearing it but keeping expression
      _result = '';
      _updatePreview();
      notifyListeners();
      return;
    }

    _expression = CalculatorEngine.backspace(_expression);
    _updatePreview();
    notifyListeners();
  }

  // Clear expression
  void clear() {
    _expression = '';
    _previewResult = '';
    _result = '';
    notifyListeners();
  }

  // Toggle plus/minus sign
  void toggleSign() {
    if (_result.isNotEmpty) {
      _expression = _result;
      _result = '';
    }
    _expression = CalculatorEngine.toggleSign(_expression);
    _updatePreview();
    notifyListeners();
  }

  // Updates the live preview text in real-time
  void _updatePreview() {
    if (_expression.isEmpty) {
      _previewResult = '';
      return;
    }

    try {
      final double eval = CalculatorEngine.evaluate(_expression);
      if (eval.isNaN || eval.isInfinite) {
        _previewResult = '';
      } else {
        _previewResult = CalculatorEngine.formatResult(
          eval,
          precision: _precision,
          useSeparator: _useSeparator,
        );
      }
    } catch (_) {
      // Incomplete expressions during typing don't update preview
      _previewResult = '';
    }
  }

  // Evaluate final result
  void evaluate() {
    if (_expression.isEmpty) return;

    try {
      final double rawResult = CalculatorEngine.evaluate(_expression);
      
      final formattedResult = CalculatorEngine.formatResult(
        rawResult,
        precision: _precision,
        useSeparator: _useSeparator,
      );

      _result = formattedResult;

      // Add to History
      final calculation = Calculation(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        expression: _expression,
        result: formattedResult,
        timestamp: DateTime.now(),
      );

      _history.insert(0, calculation);
      _saveHistory();
      
      _previewResult = '';
      notifyListeners();
    } catch (e) {
      _result = 'Error';
      _previewResult = e.toString().replaceFirst('FormatException: ', '');
      notifyListeners();
    }
  }

  // Load a historic calculation back into display
  void loadCalculation(Calculation calc) {
    _expression = calc.expression;
    _result = calc.result;
    _previewResult = '';
    notifyListeners();
  }

  // Append a historic result or calculation component to current expression
  void appendToExpression(String value) {
    if (_result.isNotEmpty) {
      _expression = _result;
      _result = '';
    }
    _expression = CalculatorEngine.append(_expression, value);
    _updatePreview();
    notifyListeners();
  }

  // -------------------------------------------------------------
  // Memory Functions
  // -------------------------------------------------------------
  
  // Memory Clear (MC)
  void memoryClear() {
    _memoryValue = 0.0;
    _prefs.setDouble(AppConstants.keyMemoryValue, 0.0);
    notifyListeners();
  }

  // Memory Recall (MR)
  void memoryRecall() {
    final formattedMem = CalculatorEngine.formatResult(
      _memoryValue,
      precision: _precision,
      useSeparator: false, // Don't include commas when inserting into expression
    );
    append(formattedMem);
  }

  // Memory Add (M+)
  void memoryAdd() {
    double valueToApply = 0.0;
    try {
      if (_result.isNotEmpty) {
        valueToApply = CalculatorEngine.evaluate(_result);
      } else if (_expression.isNotEmpty) {
        valueToApply = CalculatorEngine.evaluate(_expression);
      }
    } catch (_) {}

    _memoryValue += valueToApply;
    _prefs.setDouble(AppConstants.keyMemoryValue, _memoryValue);
    notifyListeners();
  }

  // Memory Subtract (M-)
  void memorySubtract() {
    double valueToApply = 0.0;
    try {
      if (_result.isNotEmpty) {
        valueToApply = CalculatorEngine.evaluate(_result);
      } else if (_expression.isNotEmpty) {
        valueToApply = CalculatorEngine.evaluate(_expression);
      }
    } catch (_) {}

    _memoryValue -= valueToApply;
    _prefs.setDouble(AppConstants.keyMemoryValue, _memoryValue);
    notifyListeners();
  }

  // Memory Store (MS)
  void memoryStore() {
    double valueToStore = 0.0;
    try {
      if (_result.isNotEmpty) {
        valueToStore = CalculatorEngine.evaluate(_result);
      } else if (_expression.isNotEmpty) {
        valueToStore = CalculatorEngine.evaluate(_expression);
      }
    } catch (_) {}

    _memoryValue = valueToStore;
    _prefs.setDouble(AppConstants.keyMemoryValue, _memoryValue);
    notifyListeners();
  }

  // -------------------------------------------------------------
  // History Operations
  // -------------------------------------------------------------

  Future<void> _saveHistory() async {
    final historyJsonList = _history.map((calc) => json.encode(calc.toJson())).toList();
    await _prefs.setStringList(AppConstants.keyHistoryList, historyJsonList);
  }

  Future<void> deleteHistoryItem(String id) async {
    _history.removeWhere((calc) => calc.id == id);
    await _saveHistory();
    notifyListeners();
  }

  Future<void> clearHistory() async {
    _history.clear();
    await _saveHistory();
    notifyListeners();
  }

  Future<void> toggleFavoriteHistoryItem(String id) async {
    final idx = _history.indexWhere((calc) => calc.id == id);
    if (idx != -1) {
      _history[idx] = _history[idx].copyWith(isFavorite: !_history[idx].isFavorite);
      await _saveHistory();
      notifyListeners();
    }
  }

  // Filter history based on search query
  List<Calculation> searchHistory(String query) {
    if (query.isEmpty) return _history;
    final lowerQuery = query.toLowerCase();
    return _history.where((calc) {
      return calc.expression.toLowerCase().contains(lowerQuery) ||
             calc.result.toLowerCase().contains(lowerQuery);
    }).toList();
  }
}
