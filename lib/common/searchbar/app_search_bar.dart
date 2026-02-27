import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../core/utils/platform_helper.dart';

/// Reusable SearchBar with built-in debouncing to avoid API spam.
/// Resolves cleanly to CupertinoSearchTextField on iOS, and decorated TextField on Android.
class AppSearchBar extends StatefulWidget {
  final String hintText;
  final String? staticPrefix;
  final List<String>? animatedHints;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;
  final Duration debounceDuration;
  final bool autofocus;

  const AppSearchBar({
    Key? key,
    this.hintText = 'Search...',
    this.staticPrefix,
    this.animatedHints,
    this.onChanged,
    this.onClear,
    this.debounceDuration = const Duration(milliseconds: 500),
    this.autofocus = false,
  }) : super(key: key);

  @override
  State<AppSearchBar> createState() => _AppSearchBarState();
}

class _AppSearchBarState extends State<AppSearchBar> {
  Timer? _debounceTimer;
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  bool _isTypingActive = false;
  int _currentHintIndex = 0;
  String _currentHintText = '';

  @override
  void initState() {
    super.initState();
    _currentHintText = widget.hintText;

    if (widget.animatedHints != null && widget.animatedHints!.isNotEmpty) {
      _startTypewriter();
    }

    _focusNode.addListener(() {
      if (_focusNode.hasFocus || _controller.text.isNotEmpty) {
        setState(() {
          _currentHintText = widget.hintText;
        });
      }
    });

    _controller.addListener(() {
      if (_focusNode.hasFocus || _controller.text.isNotEmpty) {
        setState(() {
          _currentHintText = widget.hintText;
        });
      }
      // Rebuild to show/hide suffixIcon correctly based on text emptiness
      setState(() {});
    });
  }

  void _startTypewriter() async {
    _isTypingActive = true;
    while (_isTypingActive && mounted) {
      if (_focusNode.hasFocus || _controller.text.isNotEmpty) {
        await Future.delayed(const Duration(milliseconds: 200));
        continue;
      }

      final hints = widget.animatedHints!;
      if (_currentHintIndex >= hints.length) {
        _currentHintIndex = 0;
      }

      String target = hints[_currentHintIndex];
      // Type forward
      for (int i = 0; i <= target.length; i++) {
        if (!mounted ||
            !_isTypingActive ||
            _focusNode.hasFocus ||
            _controller.text.isNotEmpty)
          break;
        setState(() {
          _currentHintText =
              (widget.staticPrefix ?? '') + target.substring(0, i);
        });
        await Future.delayed(const Duration(milliseconds: 50));
      }

      if (!mounted ||
          !_isTypingActive ||
          _focusNode.hasFocus ||
          _controller.text.isNotEmpty)
        continue;

      // Wait at the end
      await Future.delayed(const Duration(milliseconds: 2000));

      if (!mounted ||
          !_isTypingActive ||
          _focusNode.hasFocus ||
          _controller.text.isNotEmpty)
        continue;

      // Delete backward
      for (int i = target.length; i >= 0; i--) {
        if (!mounted ||
            !_isTypingActive ||
            _focusNode.hasFocus ||
            _controller.text.isNotEmpty)
          break;
        setState(() {
          _currentHintText =
              (widget.staticPrefix ?? '') + target.substring(0, i);
        });
        await Future.delayed(const Duration(milliseconds: 30));
      }

      if (!mounted || !_isTypingActive) break;
      if (!_focusNode.hasFocus && _controller.text.isEmpty) {
        _currentHintIndex = (_currentHintIndex + 1) % hints.length;
      }
    }
  }

  void _onSearchChanged(String query) {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();

    _debounceTimer = Timer(widget.debounceDuration, () {
      if (widget.onChanged != null) {
        widget.onChanged!(query);
      }
    });

    if (query.isEmpty && widget.onClear != null) {
      widget.onClear!();
    }
  }

  @override
  void dispose() {
    _isTypingActive = false;
    _debounceTimer?.cancel();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (PlatformHelper.isIOS) {
      return CupertinoSearchTextField(
        controller: _controller,
        focusNode: _focusNode,
        placeholder: _currentHintText.isEmpty
            ? (widget.animatedHints?.first ?? widget.hintText)
            : _currentHintText,
        autofocus: widget.autofocus,
        onChanged: _onSearchChanged,
        onSubmitted: widget.onChanged,
        style: TextStyle(color: theme.textTheme.bodyLarge?.color),
      );
    } else {
      return TextField(
        controller: _controller,
        focusNode: _focusNode,
        autofocus: widget.autofocus,
        onChanged: _onSearchChanged,
        decoration: InputDecoration(
          hintText: _currentHintText.isEmpty
              ? '\u200B'
              : _currentHintText, // Zero-width space to keep height steady
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _controller.clear();
                    _onSearchChanged('');
                    FocusScope.of(context).unfocus();
                  },
                )
              : null,
          filled: true,
          fillColor: theme.colorScheme.surface,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 0,
            horizontal: 16,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
        ),
      );
    }
  }
}
