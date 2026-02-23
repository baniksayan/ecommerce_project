import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../core/utils/platform_helper.dart';

/// Reusable SearchBar with built-in debouncing to avoid API spam.
/// Resolves cleanly to CupertinoSearchTextField on iOS, and decorated TextField on Android.
class AppSearchBar extends StatefulWidget {
  final String hintText;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;
  final Duration debounceDuration;
  final bool autofocus;

  const AppSearchBar({
    Key? key,
    this.hintText = 'Search...',
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
    _debounceTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (PlatformHelper.isIOS) {
      return CupertinoSearchTextField(
        controller: _controller,
        placeholder: widget.hintText,
        autofocus: widget.autofocus,
        onChanged: _onSearchChanged,
        onSubmitted: widget.onChanged,
        style: TextStyle(color: theme.textTheme.bodyLarge?.color),
      );
    } else {
      return TextField(
        controller: _controller,
        autofocus: widget.autofocus,
        onChanged: _onSearchChanged,
        decoration: InputDecoration(
          hintText: widget.hintText,
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
