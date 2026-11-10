import 'dart:convert';
import 'dart:ui';

import 'package:base_project/utils/app_build_methods.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

// ─────────────────────────────────────────────────────────────────────────────
// LoggerStackTrace
// ─────────────────────────────────────────────────────────────────────────────

/// Parses a [StackTrace] into its constituent components for structured logging.
///
/// Extracts the current function name, its caller, file name, line number,
/// and column number from the raw stack trace string.
class LoggerStackTrace {
  const LoggerStackTrace._({
    required this.functionName,
    required this.callerFunctionName,
    required this.fileName,
    required this.lineNumber,
    required this.columnNumber,
  });

  /// Constructs a [LoggerStackTrace] by parsing the given [StackTrace].
  factory LoggerStackTrace.from(StackTrace trace) {
    final frames = trace.toString().split('\n');
    final functionName = _getFunctionNameFromFrame(frames[0]);
    final callerFunctionName = _getFunctionNameFromFrame(frames[1]);
    final fileInfo = _getFileInfoFromFrame(frames[0]);

    return LoggerStackTrace._(
      functionName: functionName,
      callerFunctionName: callerFunctionName,
      fileName: fileInfo[0],
      lineNumber: int.parse(fileInfo[1]),
      columnNumber: int.parse(fileInfo[2].replaceFirst(')', '')),
    );
  }

  /// The name of the function where the trace was captured.
  final String functionName;

  /// The name of the function that called [functionName].
  final String callerFunctionName;

  /// The source file name (e.g. `my_widget.dart`).
  final String fileName;

  /// The line number within [fileName].
  final int lineNumber;

  /// The column number within [fileName].
  final int columnNumber;

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  static List<String> _getFileInfoFromFrame(String trace) {
    final indexOfFileName = trace.indexOf(RegExp('[A-Za-z]+.dart'));
    final fileInfo = trace.substring(indexOfFileName);
    return fileInfo.split(':');
  }

  static String _getFunctionNameFromFrame(String trace) {
    final indexOfWhiteSpace = trace.indexOf(' ');
    final subStr = trace.substring(indexOfWhiteSpace);
    final indexOfFunction = subStr.indexOf(RegExp('[A-Za-z0-9]'));
    final funcSubStr = subStr.substring(indexOfFunction);
    return funcSubStr.substring(0, funcSubStr.indexOf(' '));
  }

  @override
  String toString() =>
      '('
      'functionName: $functionName, '
      'callerFunctionName: $callerFunctionName, '
      'fileName: $fileName, '
      'lineNumber: $lineNumber, '
      'columnNumber: $columnNumber)';
}

// ─────────────────────────────────────────────────────────────────────────────
// Log section color tags
// ─────────────────────────────────────────────────────────────────────────────

const String _kTagRequest = '\x01';
const String _kTagResponse = '\x02';
const String _kTagError = '\x03';
const String _kTagSystem = '\x04';
const String _kTagDivider = '\x05';
const String _kRequestStartTimeKey = '@request_start_time';
const String _kRequestStopwatchKey = '@request_stopwatch';
final RegExp _flutterLogPrefix = RegExp(
  r'^\s*[VDIWEF]/flutter(?:\s*\(\s*\d+\s*\))?:\s?',
  multiLine: true,
);

String _cleanCopiedLog(String value) =>
    value.replaceAll(_flutterLogPrefix, '');

/// Maps each tag to its display [Color].
const Map<String, Color> _kLogColors = {
  _kTagRequest: Color(0xFFFFB300), // vibrant amber gold
  _kTagResponse: Color(0xFF00E676), // vibrant emerald green
  _kTagError: Color(0xFFFF5252), // bright coral red
  _kTagSystem: Color(0xFF40C4FF), // bright sky blue
  _kTagDivider: Color(0xFF424242), // dim grey
};

// ─────────────────────────────────────────────────────────────────────────────
// ─────────────────────────────────────────────────────────────────────────────
// Structured Log Data Model
// ─────────────────────────────────────────────────────────────────────────────

enum LogCategory { api, system }

enum ApiLogSubtype { request, response, error }

enum LogFilterMode { api, system, all }

/// Structured data model representing a single log entry.
class AppLogEntry {
  final String id;
  final LogCategory category;
  final ApiLogSubtype? apiSubtype;
  final String method;
  final String url;
  final int? statusCode;
  final int? durationMs;
  final DateTime? startTime;
  final DateTime? endTime;
  final String summaryTitle;
  final String Function()? _formattedContentBuilder;
  final String? _directContent;
  String? _cachedFormattedContent;
  final DateTime timestamp;
  bool isExpanded;

  AppLogEntry({
    required this.id,
    required this.category,
    this.apiSubtype,
    this.method = '',
    this.url = '',
    this.statusCode,
    this.durationMs,
    this.startTime,
    this.endTime,
    required this.summaryTitle,
    String Function()? formattedContentBuilder,
    String? formattedContent,
    required this.timestamp,
    this.isExpanded = false,
  }) : _formattedContentBuilder = formattedContentBuilder,
       _directContent = formattedContent;

  /// Lazy getter that evaluates formatted content on demand.
  String get formattedContent {
    if (_cachedFormattedContent != null) return _cachedFormattedContent!;
    final direct = _directContent;
    if (direct != null) {
      _cachedFormattedContent = direct;
      return direct;
    }
    final builder = _formattedContentBuilder;
    if (builder != null) {
      final built = builder();
      _cachedFormattedContent = built;
      return built;
    }
    return '';
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// AppStackInterceptor
// ─────────────────────────────────────────────────────────────────────────────

/// A Dio [Interceptor] that logs outgoing requests, incoming responses, and
/// errors in a structured, human-readable format.
class AppStackInterceptor extends Interceptor {
  /// Callback invoked when a structured [AppLogEntry] is captured.
  final ValueChanged<AppLogEntry>? onLogEntry;

  /// Optional callback invoked for every log line produced by this interceptor.
  final ValueChanged<String>? onDisplayLog;

  /// Whether to print formatted logs to the debug console. Defaults to `true`.
  final bool logToConsole;

  AppStackInterceptor({
    this.onLogEntry,
    this.onDisplayLog,
    this.logToConsole = true,
  }) : super();

  String _currentTag = _kTagSystem;

  // ---------------------------------------------------------------------------
  // Interceptor overrides
  // ---------------------------------------------------------------------------

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final startTime = DateTime.now();
    options.extra[_kRequestStartTimeKey] = startTime;
    options.extra[_kRequestStopwatchKey] = Stopwatch()..start();
    try {
      final entry = AppLogEntry(
        id: '${startTime.microsecondsSinceEpoch}_req',
        category: LogCategory.api,
        apiSubtype: ApiLogSubtype.request,
        method: options.method,
        url: options.uri.toString(),
        startTime: startTime,
        summaryTitle: _formatEndpointPath(options.uri),
        formattedContentBuilder: () =>
            _formatRequest(options, startTime: startTime),
        timestamp: startTime,
      );
      onLogEntry?.call(entry);

      _currentTag = _kTagRequest;
      _emitDivider();
      _displayLog(_header('⬆  REQUEST'));
      _displayRequestOption(options);
      _emitDivider();
    } on Exception catch (e) {
      debugPrint('AppStackInterceptor.onRequest error: $e');
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final endTime = DateTime.now();
    final startTime =
        response.requestOptions.extra[_kRequestStartTimeKey] as DateTime?;
    final stopwatch =
        response.requestOptions.extra[_kRequestStopwatchKey] as Stopwatch?;
    stopwatch?.stop();
    final durationMs =
        stopwatch?.elapsedMilliseconds ??
        (startTime != null
            ? endTime.difference(startTime).inMilliseconds
            : null);

    try {
      final entry = AppLogEntry(
        id: '${endTime.microsecondsSinceEpoch}_res',
        category: LogCategory.api,
        apiSubtype: ApiLogSubtype.response,
        method: response.requestOptions.method,
        url: response.realUri.toString(),
        statusCode: response.statusCode,
        durationMs: durationMs,
        startTime: startTime,
        endTime: endTime,
        summaryTitle: _formatEndpointPath(response.realUri),
        formattedContentBuilder: () =>
            _formatResponse(response, startTime: startTime, endTime: endTime),
        timestamp: endTime,
      );
      onLogEntry?.call(entry);

      _currentTag = _kTagResponse;
      _emitDivider();
      final timeStr = durationMs != null ? ' ($durationMs ms)' : '';
      _displayLog(_header('⬇  RESPONSE$timeStr'));
      _displayResponse(
        response,
        startTime: startTime,
        endTime: endTime,
        durationMs: durationMs,
      );
      _emitDivider();
    } on Exception catch (e) {
      debugPrint('AppStackInterceptor.onResponse error: $e');
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final endTime = DateTime.now();
    final startTime =
        err.requestOptions.extra[_kRequestStartTimeKey] as DateTime?;
    final stopwatch =
        err.requestOptions.extra[_kRequestStopwatchKey] as Stopwatch?;
    stopwatch?.stop();
    final durationMs =
        stopwatch?.elapsedMilliseconds ??
        (startTime != null
            ? endTime.difference(startTime).inMilliseconds
            : null);

    try {
      final entry = AppLogEntry(
        id: '${endTime.microsecondsSinceEpoch}_err',
        category: LogCategory.api,
        apiSubtype: ApiLogSubtype.error,
        method: err.requestOptions.method,
        url: err.requestOptions.uri.toString(),
        statusCode: err.response?.statusCode,
        durationMs: durationMs,
        startTime: startTime,
        endTime: endTime,
        summaryTitle: _formatEndpointPath(err.requestOptions.uri),
        formattedContentBuilder: () =>
            _formatError(err, startTime: startTime, endTime: endTime),
        timestamp: endTime,
      );
      onLogEntry?.call(entry);

      _currentTag = _kTagError;
      _emitDivider();
      final timeStr = durationMs != null ? ' ($durationMs ms)' : '';
      _displayLog(_header('✖  ERROR$timeStr'));
      _displayRequestOption(err.requestOptions);
      if (startTime != null) {
        _displayLog('  Start    : ${_formatTime(startTime)}');
      }
      _displayLog('  End      : ${_formatTime(endTime)}');
      if (durationMs != null) {
        _displayLog('  Time     : ${durationMs}ms');
      }
      if (err.message != null && err.message!.isNotEmpty) {
        _displayLog('');
        _displayLog('  Message  : ${err.message}');
      }
      if (err.response != null) {
        _displayLog('');
        _displayResponse(
          err.response!,
          startTime: startTime,
          endTime: endTime,
          durationMs: durationMs,
        );
      }
      _emitDivider();
    } on Exception catch (e) {
      debugPrint('AppStackInterceptor.onError error: $e');
    }
    handler.next(err);
  }

  // ---------------------------------------------------------------------------
  // Content formatting helpers
  // ---------------------------------------------------------------------------

  String _formatRequest(RequestOptions options, {DateTime? startTime}) {
    final sb = StringBuffer();
    sb.writeln('  Method   : ${options.method}');
    sb.writeln('  URL      : ${options.uri}');
    if (startTime != null) {
      sb.writeln('  Start    : ${_formatTime(startTime)}');
    }
    sb.writeln('');
    sb.writeln('  Headers  :');
    sb.writeln(_indentBlock(_prettyJson(options.headers)));

    final data = options.data;
    if (data != null) {
      sb.writeln('');
      if (data is FormData) {
        sb.writeln(
          '  Body     : [FormData — ${data.fields.length} field(s), '
          '${data.files.length} file(s)]',
        );
      } else if (data is Map) {
        sb.writeln('  Body     :');
        sb.writeln(_indentBlock(_prettyJson(data)));
      } else {
        sb.writeln('  Body     : $data');
      }
    }
    return sb.toString();
  }

  String _formatResponse(
    Response<dynamic> response, {
    DateTime? startTime,
    DateTime? endTime,
  }) {
    final sb = StringBuffer();
    sb.writeln('  Method   : ${response.requestOptions.method}');
    sb.writeln('  URL      : ${response.realUri}');
    sb.writeln('  Status   : ${response.statusCode}');
    if (startTime != null) {
      sb.writeln('  Start    : ${_formatTime(startTime)}');
    }
    if (endTime != null) {
      sb.writeln('  End      : ${_formatTime(endTime)}');
    }
    sb.writeln('');

    final body = response.data;
    if (body is Map || body is List) {
      sb.writeln('  Response :');
      sb.writeln(_indentBlock(_prettyJson(body)));
    } else {
      sb.writeln('  Response : $body');
    }
    return sb.toString();
  }

  String _formatError(
    DioException err, {
    DateTime? startTime,
    DateTime? endTime,
  }) {
    final sb = StringBuffer();
    sb.writeln('  Method   : ${err.requestOptions.method}');
    sb.writeln('  URL      : ${err.requestOptions.uri}');
    if (err.response?.statusCode != null) {
      sb.writeln('  Status   : ${err.response?.statusCode}');
    }
    if (startTime != null) {
      sb.writeln('  Start    : ${_formatTime(startTime)}');
    }
    if (endTime != null) {
      sb.writeln('  End      : ${_formatTime(endTime)}');
    }
    if (err.message != null && err.message!.isNotEmpty) {
      sb.writeln('');
      sb.writeln('  Message  : ${err.message}');
    }
    if (err.response != null) {
      sb.writeln('');
      sb.writeln(
        _formatResponse(err.response!, startTime: startTime, endTime: endTime),
      );
    }
    return sb.toString();
  }

  // ---------------------------------------------------------------------------
  // Legacy Display Helpers
  // ---------------------------------------------------------------------------

  void _displayRequestOption(RequestOptions options) {
    _displayLog('');
    _displayLog('  Method   : ${options.method}');
    _displayLog('  URL      : ${options.uri}');
    _displayLog('');
    _displayLog('  Headers  :');
    _displayLog(_indentBlock(_prettyJson(options.headers)));

    final data = options.data;
    if (data != null) {
      _displayLog('');
      if (data is FormData) {
        _displayLog(
          '  Body     : [FormData — ${data.fields.length} field(s), '
          '${data.files.length} file(s)]',
        );
      } else if (data is Map) {
        _displayLog('  Body     :');
        _displayLog(_indentBlock(_prettyJson(data)));
      } else {
        _displayLog('  Body     : $data');
      }
    }
  }

  void _displayResponse(
    Response<dynamic> response, {
    DateTime? startTime,
    DateTime? endTime,
    int? durationMs,
  }) {
    _displayLog('');
    _displayLog('  Method   : ${response.requestOptions.method}');
    _displayLog('  URL      : ${response.realUri}');
    _displayLog('  Status   : ${response.statusCode}');
    if (startTime != null) {
      _displayLog('  Start    : ${_formatTime(startTime)}');
    }
    if (endTime != null) {
      _displayLog('  End      : ${_formatTime(endTime)}');
    }
    if (durationMs != null) {
      _displayLog('  Time     : ${durationMs}ms');
    }
    _displayLog('');

    final body = response.data;
    if (body is Map || body is List) {
      _displayLog('  Response :');
      _displayLog(_indentBlock(_prettyJson(body)));
    } else {
      _displayLog('  Response : $body');
    }
  }

  void _emitDivider() {
    final saved = _currentTag;
    _currentTag = _kTagDivider;
    _displayLog('─' * 48);
    _currentTag = saved;
  }

  void _displayLog(String val) => onDisplayLog?.call('$_currentTag$val');

  static String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    final s = dt.second.toString().padLeft(2, '0');
    final ms = dt.millisecond.toString().padLeft(3, '0');
    return '$h:$m:$s.$ms';
  }

  static String _header(String title) {
    const width = 44;
    final pad = ((width - title.length - 2) / 2).floor();
    final line = '═' * pad;
    return '$line $title $line';
  }

  static String _indentBlock(String block) {
    return block.split('\n').map((l) => '    $l').join('\n');
  }

  static String _formatEndpointPath(Uri uri) {
    final path = uri.path;
    if (path.isEmpty) return uri.toString();
    if (uri.hasQuery) {
      return '$path?${uri.query}';
    }
    return path;
  }

  static String _prettyJson(dynamic value) {
    try {
      const encoder = JsonEncoder.withIndent('  ');
      final str = encoder.convert(value);
      if (str.length > 15000) {
        return '${str.substring(0, 15000)}\n... [Truncated — ${str.length - 15000} chars omitted]';
      }
      return str;
    } catch (_) {
      final str = value.toString();
      if (str.length > 15000) {
        return '${str.substring(0, 15000)}\n... [Truncated]';
      }
      return str;
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// AppStackInterceptorBuilder
// ─────────────────────────────────────────────────────────────────────────────

/// A widget that overlays a draggable, toggleable log viewer on top of its
/// [child] with glassmorphism, log filtering, and expandable request/response cards.
class AppStackInterceptorBuilder extends StatefulWidget {
  /// Flag to enable/disable system log tracking and UI elements. Defaults to `false`.
  static bool enableSystemLogs = false;

  static final ValueNotifier<List<AppLogEntry>> _logEntriesNotifier =
      ValueNotifier<List<AppLogEntry>>([]);

  /// Appends [value] (tagged as a system entry) to the shared log buffer.
  static set log(String value) {
    if (!enableSystemLogs) return;
    final trimmed = value.trim();
    final firstLine = trimmed
        .split('\n')
        .firstWhere((l) => l.trim().isNotEmpty, orElse: () => 'System Log');

    final entry = AppLogEntry(
      id: '${DateTime.now().microsecondsSinceEpoch}_sys',
      category: LogCategory.system,
      summaryTitle: firstLine,
      formattedContent: value,
      timestamp: DateTime.now(),
      isExpanded: false,
    );
    addLogEntry(entry);
  }

  /// The singleton [AppStackInterceptor] pre-wired to this widget's log buffer.
  static AppStackInterceptor appStackInterceptor = AppStackInterceptor(
    onLogEntry: addLogEntry,
  );

  /// Adds a new [AppLogEntry] to the shared notifier (retains all log history).
  static void addLogEntry(AppLogEntry entry) {
    if (entry.category == LogCategory.system && !enableSystemLogs) return;
    _logEntriesNotifier.value = [..._logEntriesNotifier.value, entry];
  }

  /// The widget rendered beneath the log overlay.
  final Widget child;

  /// Option to enable system log section & features. Defaults to `false`.
  final bool showSystemLogs;

  /// Creates an [AppStackInterceptorBuilder].
  const AppStackInterceptorBuilder({
    super.key,
    required this.child,
    this.showSystemLogs = false,
  });

  @override
  State<AppStackInterceptorBuilder> createState() =>
      _AppStackInterceptorBuilderState();
}

class _AppStackInterceptorBuilderState
    extends State<AppStackInterceptorBuilder> {
  final _scrollController = ScrollController();
  final _isExpandedNotifier = ValueNotifier<bool>(false);
  final _filterModeNotifier = ValueNotifier<LogFilterMode>(LogFilterMode.api);
  final _searchController = TextEditingController();
  final _searchQueryNotifier = ValueNotifier<String>('');

  @override
  void initState() {
    super.initState();
    if (widget.showSystemLogs) {
      AppStackInterceptorBuilder.enableSystemLogs = true;
    }
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    if (_searchQueryNotifier.value != _searchController.text) {
      _searchQueryNotifier.value = _searchController.text;
    }
  }

  Offset _offSet = Offset.zero;
  bool _isInitialized = false;
  bool _isDragging = false;
  static const double _kButtonWidth = 56.0;
  static const double _kButtonHeight = 34.0;

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _scrollController.dispose();
    _isExpandedNotifier.dispose();
    _filterModeNotifier.dispose();
    _searchController.dispose();
    _searchQueryNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    final safeTop = mediaQuery.padding.top + 10;
    final safeBottom =
        screenHeight - mediaQuery.padding.bottom - _kButtonHeight - 10;

    if (!_isInitialized) {
      _offSet = Offset(screenWidth - _kButtonWidth, safeTop + 60);
      _isInitialized = true;
    }

    return Material(
      child: Stack(
        children: [
          // ── Main content ────────────────────────────────────────────────
          widget.child,

          // ── Log overlay panel with glass background ─────────────────────
          Positioned.fill(
            child: ValueListenableBuilder<bool>(
              valueListenable: _isExpandedNotifier,
              builder: (context, isExpanded, _) {
                if (!isExpanded) return const SizedBox.shrink();
                return Overlay(
                  initialEntries: [
                    OverlayEntry(builder: (context) => _buildLogPanel()),
                  ],
                );
              },
            ),
          ),

          // ── Draggable toggle button docking to screen edge ──────────────
          ValueListenableBuilder<bool>(
            valueListenable: _isExpandedNotifier,
            builder: (context, isExpanded, _) {
              if (isExpanded) return const SizedBox.shrink();

              final isLeft = _offSet.dx < (screenWidth / 2);

              return AnimatedPositioned(
                duration: _isDragging
                    ? Duration.zero
                    : const Duration(milliseconds: 250),
                curve: Curves.easeOutCubic,
                left: _isDragging
                    ? _offSet.dx.clamp(0.0, screenWidth - _kButtonWidth)
                    : (isLeft ? 0.0 : screenWidth - _kButtonWidth),
                top: _offSet.dy.clamp(safeTop, safeBottom),
                child: GestureDetector(
                  onTap: _onTapExpand,
                  onPanStart: (_) {
                    setState(() => _isDragging = true);
                  },
                  onPanUpdate: (details) {
                    setState(() {
                      final newX = (_offSet.dx + details.delta.dx).clamp(
                        0.0,
                        screenWidth - _kButtonWidth,
                      );
                      final newY = (_offSet.dy + details.delta.dy).clamp(
                        safeTop,
                        safeBottom,
                      );
                      _offSet = Offset(newX, newY);
                    });
                  },
                  onPanEnd: (_) {
                    setState(() {
                      _isDragging = false;
                      final snapLeft =
                          _offSet.dx + (_kButtonWidth / 2) < (screenWidth / 2);
                      final snapX = snapLeft
                          ? 0.0
                          : (screenWidth - _kButtonWidth);
                      final snapY = _offSet.dy.clamp(safeTop, safeBottom);
                      _offSet = Offset(snapX, snapY);
                    });
                  },
                  child: _buildToggleButton(context, isLeft: isLeft),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Glass Log Panel
  // ---------------------------------------------------------------------------

  Widget _buildLogPanel() {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      behavior: HitTestBehavior.translucent,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          color: const Color(0xFF0D0D0D).withValues(alpha: 0.75),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SafeArea(
            left: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildLogToolbar(),
                _buildSearchBar(),
                _buildFilterBar(),
                _buildLegend(),
                const Divider(
                  color: Color(0xFF2A2A2A),
                  height: 1,
                  thickness: 1,
                ),
                Expanded(child: _buildLogBody()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Compact real-time search bar for filtering endpoints, status codes, and methods.
  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withValues(alpha: 0.07),
            width: 1,
          ),
        ),
      ),
      child: Container(
        height: 32,
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.15),
            width: 0.8,
          ),
        ),
        child: Row(
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: Icon(
                Icons.search_rounded,
                size: 15,
                color: Color(0xFF888888),
              ),
            ),
            Expanded(
              child: TextField(
                controller: _searchController,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontFamily: 'monospace',
                ),
                cursorColor: Colors.white70,
                textInputAction: TextInputAction.search,
                onSubmitted: (_) => FocusScope.of(context).unfocus(),
                decoration: const InputDecoration(
                  hintText: 'Search endpoint, status, method, payload...',
                  hintStyle: TextStyle(
                    color: Color(0xFF666666),
                    fontSize: 11,
                    fontFamily: 'monospace',
                  ),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 8),
                ),
              ),
            ),
            ValueListenableBuilder<String>(
              valueListenable: _searchQueryNotifier,
              builder: (context, query, _) {
                if (query.isEmpty) return const SizedBox.shrink();
                return InkWell(
                  onTap: () {
                    _searchController.clear();
                    FocusScope.of(context).unfocus();
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Icon(
                      Icons.clear_rounded,
                      size: 14,
                      color: Color(0xFF888888),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Top toolbar with Clear-All, Fold/Unfold-All, Copy-All, and Close actions.
  Widget _buildLogToolbar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          const Text(
            '  NETWORK LOG',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
              fontFamily: 'monospace',
            ),
          ),
          const Spacer(),
          TextButton(
            onPressed: _toggleExpandAll,
            style: _toolbarButtonStyle(),
            child: const Text('Toggle Fold'),
          ),
          TextButton(
            onPressed: () =>
                AppStackInterceptorBuilder._logEntriesNotifier.value = [],
            style: _toolbarButtonStyle(),
            child: const Text('Clear All'),
          ),
          TextButton(
            onPressed: _copyFilteredToClipboard,
            style: _toolbarButtonStyle(),
            child: const Text('Copy All'),
          ),
          const SizedBox(width: 4),
          InkWell(
            onTap: _onTapExpand,
            borderRadius: BorderRadius.circular(16),
            child: const Padding(
              padding: EdgeInsets.all(6.0),
              child: Icon(Icons.close_rounded, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  /// Segmented filter selector to switch between API Logs (default), System Logs, or All.
  Widget _buildFilterBar() {
    if (!AppStackInterceptorBuilder.enableSystemLogs) {
      return const SizedBox.shrink();
    }
    return ValueListenableBuilder<LogFilterMode>(
      valueListenable: _filterModeNotifier,
      builder: (context, currentMode, _) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
          color: Colors.white.withValues(alpha: 0.04),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                const Text(
                  'FILTER: ',
                  style: TextStyle(
                    color: Color(0xFF757575),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                  ),
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: 'API LOGS',
                  mode: LogFilterMode.api,
                  isSelected: currentMode == LogFilterMode.api,
                ),
                const SizedBox(width: 6),
                _buildFilterChip(
                  label: 'SYSTEM LOGS',
                  mode: LogFilterMode.system,
                  isSelected: currentMode == LogFilterMode.system,
                ),
                const SizedBox(width: 6),
                _buildFilterChip(
                  label: 'ALL',
                  mode: LogFilterMode.all,
                  isSelected: currentMode == LogFilterMode.all,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFilterChip({
    required String label,
    required LogFilterMode mode,
    required bool isSelected,
  }) {
    return InkWell(
      onTap: () => _filterModeNotifier.value = mode,
      borderRadius: BorderRadius.circular(4),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).primaryColor.withValues(alpha: 0.3)
              : const Color(0xFF222222),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).primaryColor
                : const Color(0xFF333333),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFF9E9E9E),
            fontSize: 10,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            fontFamily: 'monospace',
          ),
        ),
      ),
    );
  }

  /// Color-coded legend row.
  Widget _buildLegend() {
    final showSystem = AppStackInterceptorBuilder.enableSystemLogs;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 6.0),
      color: Colors.white.withValues(alpha: 0.03),
      child: Wrap(
        spacing: 18,
        runSpacing: 4,
        children: [
          _LegendDot(color: _kLogColors[_kTagRequest]!, label: 'REQUEST'),
          _LegendDot(color: _kLogColors[_kTagResponse]!, label: 'RESPONSE'),
          _LegendDot(color: _kLogColors[_kTagError]!, label: 'ERROR'),
          if (showSystem)
            _LegendDot(color: _kLogColors[_kTagSystem]!, label: 'SYSTEM'),
        ],
      ),
    );
  }

  int _displayLimit = 50;

  /// Main log list showing cards for filtered entries with paginated windowing.
  Widget _buildLogBody() {
    return ValueListenableBuilder<List<AppLogEntry>>(
      valueListenable: AppStackInterceptorBuilder._logEntriesNotifier,
      builder: (context, allEntries, _) {
        return ValueListenableBuilder<LogFilterMode>(
          valueListenable: _filterModeNotifier,
          builder: (context, filterMode, _) {
            return ValueListenableBuilder<String>(
              valueListenable: _searchQueryNotifier,
              builder: (context, query, _) {
                final trimmedQuery = query.trim().toLowerCase();

                final isSearching = trimmedQuery.isNotEmpty;

                final visibleEntries = allEntries.where((e) {
                  // Category filter
                  if (filterMode == LogFilterMode.api &&
                      e.category != LogCategory.api) {
                    return false;
                  }
                  if (filterMode == LogFilterMode.system &&
                      e.category != LogCategory.system) {
                    return false;
                  }

                  // Search query filter
                  if (isSearching) {
                    final matchTitle = e.summaryTitle.toLowerCase().contains(
                      trimmedQuery,
                    );
                    final matchUrl = e.url.toLowerCase().contains(trimmedQuery);
                    final matchMethod = e.method.toLowerCase().contains(
                      trimmedQuery,
                    );
                    final matchStatus =
                        e.statusCode != null &&
                        e.statusCode.toString().contains(trimmedQuery);
                    final matchSubtype =
                        e.apiSubtype != null &&
                        e.apiSubtype!.name.toLowerCase().contains(trimmedQuery);
                    final matchContent =
                        (matchTitle ||
                            matchUrl ||
                            matchMethod ||
                            matchStatus ||
                            matchSubtype)
                        ? true
                        : e.formattedContent.toLowerCase().contains(
                            trimmedQuery,
                          );

                    if (!matchContent) {
                      return false;
                    }
                  }

                  return true;
                }).toList();

                if (visibleEntries.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 36.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          isSearching
                              ? '— No logs matching "$query" —'
                              : '— No logs found for selected filter —',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Color(0xFF555555),
                            fontSize: 12,
                            fontFamily: 'monospace',
                            letterSpacing: 0.5,
                          ),
                        ),
                        if (isSearching) ...[
                          const SizedBox(height: 10),
                          InkWell(
                            onTap: () {
                              _searchController.clear();
                              FocusScope.of(context).unfocus();
                            },
                            child: const Text(
                              'Clear Search',
                              style: TextStyle(
                                color: Color(0xFF82B1FF),
                                fontSize: 11,
                                fontFamily: 'monospace',
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                }

                final totalCount = visibleEntries.length;
                // If searching, show up to 100 results immediately so older matching logs aren't hidden
                final currentLimit = isSearching
                    ? (_displayLimit < 100 ? 100 : _displayLimit)
                    : _displayLimit;
                final hasMore = totalCount > currentLimit;
                final currentBatch = hasMore
                    ? visibleEntries.sublist(totalCount - currentLimit)
                    : visibleEntries;

                return Column(
                  children: [
                    if (hasMore)
                      InkWell(
                        onTap: () {
                          setState(() {
                            _displayLimit += 50;
                          });
                        },
                        child: Container(
                          width: double.infinity,
                          margin: const EdgeInsets.symmetric(
                            horizontal: 8.0,
                            vertical: 4.0,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: Colors.white24,
                              width: 0.8,
                            ),
                          ),
                          child: Text(
                            'LOAD OLDER LOGS (${totalCount - currentLimit} MORE)',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'monospace',
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                      ),
                    Expanded(
                      child: ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(8.0),
                        keyboardDismissBehavior:
                            ScrollViewKeyboardDismissBehavior.onDrag,
                        addAutomaticKeepAlives: false,
                        addRepaintBoundaries: true,
                        scrollCacheExtent:
                            const ScrollCacheExtent.pixels(200.0),
                        itemCount: currentBatch.length,
                        itemBuilder: (context, index) {
                          final entry = currentBatch[index];
                          return _LogEntryCard(
                            key: ValueKey(entry.id),
                            entry: entry,
                            onToggleExpand: () {
                              setState(() {
                                entry.isExpanded = !entry.isExpanded;
                              });
                            },
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildToggleButton(BuildContext context, {required bool isLeft}) {
    final primaryColor = Theme.of(context).primaryColor;

    return ValueListenableBuilder<List<AppLogEntry>>(
      valueListenable: AppStackInterceptorBuilder._logEntriesNotifier,
      builder: (context, entries, _) {
        final count = entries.length;
        final countText = count > 99 ? '99+' : '$count';

        return AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: _isDragging ? 1.0 : 0.7,
          child: Container(
            width: _kButtonWidth,
            height: _kButtonHeight,
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E).withValues(alpha: 0.85),
              borderRadius: isLeft
                  ? const BorderRadius.only(
                      topRight: Radius.circular(17),
                      bottomRight: Radius.circular(17),
                    )
                  : const BorderRadius.only(
                      topLeft: Radius.circular(17),
                      bottomLeft: Radius.circular(17),
                    ),
              border: Border.all(
                color: primaryColor.withValues(alpha: 0.6),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.35),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.terminal_rounded,
                  color: Colors.white.withValues(alpha: 0.9),
                  size: 15,
                ),
                if (count > 0) ...[
                  const SizedBox(width: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4.5,
                      vertical: 1.5,
                    ),
                    decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      countText,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Private Actions & Helpers
  // ---------------------------------------------------------------------------

  ButtonStyle _toolbarButtonStyle() => TextButton.styleFrom(
    foregroundColor: Colors.white,
    textStyle: const TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.bold,
      letterSpacing: 0.5,
    ),
  );

  void _toggleExpandAll() {
    final entries = AppStackInterceptorBuilder._logEntriesNotifier.value;
    if (entries.isEmpty) return;
    final hasFolded = entries.any((e) => !e.isExpanded);
    setState(() {
      for (final e in entries) {
        e.isExpanded = hasFolded;
      }
    });
  }

  Future<void> _copyFilteredToClipboard() async {
    final filterMode = _filterModeNotifier.value;
    final query = _searchQueryNotifier.value.trim().toLowerCase();
    final entries = AppStackInterceptorBuilder._logEntriesNotifier.value.where((
      e,
    ) {
      if (filterMode == LogFilterMode.api && e.category != LogCategory.api) {
        return false;
      }
      if (filterMode == LogFilterMode.system &&
          e.category != LogCategory.system) {
        return false;
      }
      if (query.isNotEmpty) {
        final matchTitle = e.summaryTitle.toLowerCase().contains(query);
        final matchUrl = e.url.toLowerCase().contains(query);
        final matchMethod = e.method.toLowerCase().contains(query);
        final matchStatus =
            e.statusCode != null && e.statusCode.toString().contains(query);
        final matchSubtype =
            e.apiSubtype != null &&
            e.apiSubtype!.name.toLowerCase().contains(query);
        final matchContent =
            (matchTitle ||
                matchUrl ||
                matchMethod ||
                matchStatus ||
                matchSubtype)
            ? true
            : e.formattedContent.toLowerCase().contains(query);
        if (!matchContent) {
          return false;
        }
      }
      return true;
    }).toList();

    if (entries.isEmpty) {
      showToast('No logs to copy');
      return;
    }

    final buffer = StringBuffer();
    for (final e in entries) {
      buffer.writeln('=== ${e.summaryTitle} ===');
      buffer.writeln(_cleanCopiedLog(e.formattedContent));
      buffer.writeln('');
    }

    await Clipboard.setData(ClipboardData(text: buffer.toString()));
    showToast('Copied all visible logs to clipboard');
  }

  void _onTapExpand() {
    FocusScope.of(context).unfocus();
    _isExpandedNotifier.value = !_isExpandedNotifier.value;
    if (_isExpandedNotifier.value) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!_scrollController.hasClients) {
          return;
        }
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      });
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Foldable Log Entry Card Widget
// ─────────────────────────────────────────────────────────────────────────────

class _LogEntryCard extends StatelessWidget {
  final AppLogEntry entry;
  final VoidCallback onToggleExpand;

  const _LogEntryCard({
    super.key,
    required this.entry,
    required this.onToggleExpand,
  });

  @override
  Widget build(BuildContext context) {
    final color = _getEntryColor(entry);
    final isSystem = entry.category == LogCategory.system;

    return Container(
      margin: const EdgeInsets.only(bottom: 8.0),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.4), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Card Header (Folded summary title + copy & fold buttons) ──────
          InkWell(
            onTap: isSystem ? null : onToggleExpand,
            borderRadius: BorderRadius.circular(6),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 10.0,
                vertical: 8.0,
              ),
              child: Row(
                children: [
                  // Status code + timer badge
                  _buildBadge(color),
                  const SizedBox(width: 8),

                  // URL / Title text / System message
                  Expanded(
                    child: Text(
                      isSystem ? entry.formattedContent : entry.summaryTitle,
                      maxLines: isSystem ? null : (entry.isExpanded ? 3 : 1),
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xDDFFFFFF),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),

                  // Copy button for single request/response/system log
                  InkWell(
                    onTap: () => _copySingleEntry(entry),
                    borderRadius: BorderRadius.circular(16),
                    child: const Padding(
                      padding: EdgeInsets.all(6.0),
                      child: Icon(
                        Icons.copy_rounded,
                        size: 16,
                        color: Color(0xFF9E9E9E),
                      ),
                    ),
                  ),

                  // Fold/unfold chevron button (API logs only)
                  if (!isSystem)
                    Icon(
                      entry.isExpanded
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      color: const Color(0xFF757575),
                      size: 20,
                    ),
                ],
              ),
            ),
          ),

          // ── Expanded Body (API logs only when expanded) ─────────────────────
          if (!isSystem && entry.isExpanded) ...[
            Divider(color: Colors.white.withValues(alpha: 0.1), height: 1),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.35),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(6),
                  bottomRight: Radius.circular(6),
                ),
              ),
              child: SelectableText(
                entry.formattedContent,
                style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontFamily: 'monospace',
                  height: 1.45,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBadge(Color color) {
    if (entry.category == LogCategory.system) {
      return _badgeContainer(
        color: color,
        child: Text(
          'SYSTEM',
          style: TextStyle(
            color: color,
            fontSize: 9,
            fontWeight: FontWeight.bold,
            fontFamily: 'monospace',
          ),
        ),
      );
    }

    if (entry.apiSubtype == ApiLogSubtype.request) {
      return _badgeContainer(
        color: color,
        child: Text(
          'REQUEST',
          style: TextStyle(
            color: color,
            fontSize: 9,
            fontWeight: FontWeight.bold,
            fontFamily: 'monospace',
          ),
        ),
      );
    }

    final hasStatus = entry.statusCode != null;
    final hasDuration = entry.durationMs != null;

    if (!hasStatus && !hasDuration) {
      return _badgeContainer(
        color: color,
        child: Text(
          entry.apiSubtype == ApiLogSubtype.response ? 'RESPONSE' : 'ERROR',
          style: TextStyle(
            color: color,
            fontSize: 9,
            fontWeight: FontWeight.bold,
            fontFamily: 'monospace',
          ),
        ),
      );
    }

    return _badgeContainer(
      color: color,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (hasStatus)
            Text(
              '${entry.statusCode}',
              style: TextStyle(
                color: color,
                fontSize: 9,
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace',
              ),
            ),
          if (hasStatus && hasDuration) const SizedBox(width: 5),
          if (hasDuration) ...[
            Icon(Icons.timer_outlined, size: 10, color: color),
            const SizedBox(width: 2.5),
            Text(
              '${entry.durationMs}ms',
              style: TextStyle(
                color: color,
                fontSize: 9,
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace',
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _badgeContainer({required Color color, required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color, width: 0.8),
      ),
      child: child,
    );
  }

  Color _getEntryColor(AppLogEntry entry) {
    if (entry.category == LogCategory.system) return _kLogColors[_kTagSystem]!;
    switch (entry.apiSubtype) {
      case ApiLogSubtype.request:
        return _kLogColors[_kTagRequest]!;
      case ApiLogSubtype.response:
        if (entry.statusCode != null && entry.statusCode! >= 400) {
          return _kLogColors[_kTagError]!;
        }
        return _kLogColors[_kTagResponse]!;
      case ApiLogSubtype.error:
      default:
        return _kLogColors[_kTagError]!;
    }
  }

  Future<void> _copySingleEntry(AppLogEntry entry) async {
    final textToCopy =
        '=== ${entry.summaryTitle} ===\n${_cleanCopiedLog(entry.formattedContent)}';
    await Clipboard.setData(ClipboardData(text: textToCopy));
    final label = entry.category == LogCategory.system
        ? 'System log'
        : (entry.apiSubtype == ApiLogSubtype.request
              ? 'Request log'
              : 'Response log');
    showToast('$label copied to clipboard');
  }

}

// ─────────────────────────────────────────────────────────────────────────────
// _LegendDot  (private helper widget)
// ─────────────────────────────────────────────────────────────────────────────

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
            boxShadow: [
              BoxShadow(color: color.withValues(alpha: 0.5), blurRadius: 4),
            ],
          ),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 10,
            fontWeight: FontWeight.bold,
            fontFamily: 'monospace',
            letterSpacing: 0.8,
          ),
        ),
      ],
    );
  }
}
