import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../core/utils/platform_helper.dart';

/// A reusable Dropdown component that adapts per platform:
///
/// - **Android / other**: Material 3 [DropdownMenu] with [DropdownMenuEntry]
///   — the "Exposed Dropdown Menu" pattern from the M3 spec.
/// - **iOS**: Native-feel [CupertinoPicker] presented in a modal sheet.
///
/// ### Migration note
/// The Android side no longer uses [DropdownMenuItem]. Supply your options as
/// [DropdownMenuEntry] objects via [entries]. The helper [AppDropdown.fromItems]
/// factory converts a legacy [List<DropdownMenuItem<T>>] automatically.
class AppDropdown<T> extends StatefulWidget {
  /// Floating label shown inside / above the field.
  final String label;

  /// Currently selected value (controlled).
  final T? value;

  /// The selectable options.
  final List<DropdownMenuEntry<T>> entries;

  /// Called when the user picks a new value. Pass `null` to disable.
  final ValueChanged<T?>? onChanged;

  /// When `true` (default) the field stretches to fill its parent width.
  final bool isExpand;

  /// Red helper text rendered below the field for validation errors.
  final String? errorText;

  /// Optional grey helper text rendered below the field (ignored when
  /// [errorText] is set, matching M3 behaviour).
  final String? helperText;

  const AppDropdown({
    super.key,
    required this.label,
    required this.entries,
    this.value,
    this.onChanged,
    this.isExpand = true,
    this.errorText,
    this.helperText,
  });

  /// Convenience constructor that converts a legacy
  /// `List<DropdownMenuItem<T>>` so callers don't need to be updated at once.
  factory AppDropdown.fromItems({
    Key? key,
    required String label,
    required List<DropdownMenuItem<T>> items,
    T? value,
    ValueChanged<T?>? onChanged,
    bool isExpand = true,
    String? errorText,
    String? helperText,
  }) {
    final entries = items
        .map(
          (item) => DropdownMenuEntry<T>(
            value: item.value as T,
            label: _extractLabel(item.child),
            enabled: item.enabled,
          ),
        )
        .toList();

    return AppDropdown<T>(
      key: key,
      label: label,
      entries: entries,
      value: value,
      onChanged: onChanged,
      isExpand: isExpand,
      errorText: errorText,
      helperText: helperText,
    );
  }

  /// Best-effort label extractor for legacy [DropdownMenuItem] children.
  static String _extractLabel(Widget child) {
    if (child is Text) return child.data ?? '';
    if (child is DefaultTextStyle) return _extractLabel(child.child);
    return '';
  }

  @override
  State<AppDropdown<T>> createState() => _AppDropdownState<T>();
}

class _AppDropdownState<T> extends State<AppDropdown<T>> {
  // ── iOS picker state ────────────────────────────────────────────────────────
  late int _iosSelectedIndex;

  @override
  void initState() {
    super.initState();
    _syncIosIndex();
  }

  @override
  void didUpdateWidget(AppDropdown<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value ||
        oldWidget.entries != widget.entries) {
      _syncIosIndex();
    }
  }

  void _syncIosIndex() {
    final idx =
        widget.entries.indexWhere((e) => e.value == widget.value);
    _iosSelectedIndex = idx == -1 ? 0 : idx;
  }

  // ── iOS bottom-sheet picker ─────────────────────────────────────────────────
  void _showIOSPicker(BuildContext context) {
    if (widget.onChanged == null || widget.entries.isEmpty) return;

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    int tempIndex = _iosSelectedIndex;

    showCupertinoModalPopup<void>(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setSheetState) => Container(
          height: 260,
          color: isDark ? const Color(0xFF1C1C1E) : CupertinoColors.white,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Toolbar ────────────────────────────────────────────────────
              Container(
                height: 44,
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF2C2C2E)
                      : const Color(0xFFF2F2F7),
                  border: Border(
                    bottom: BorderSide(
                      color: isDark
                          ? const Color(0xFF3A3A3C)
                          : const Color(0xFFC6C6C8),
                      width: 0.5,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CupertinoButton(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          color: isDark
                              ? CupertinoColors.systemBlue
                              : CupertinoColors.systemBlue,
                        ),
                      ),
                      onPressed: () => Navigator.of(ctx).pop(),
                    ),
                    CupertinoButton(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      onPressed: () {
                        widget.onChanged!(
                          widget.entries[tempIndex].value,
                        );
                        setState(() => _iosSelectedIndex = tempIndex);
                        Navigator.of(ctx).pop();
                      },
                      child: Text(
                        'Done',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? CupertinoColors.systemBlue
                              : CupertinoColors.systemBlue,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Picker wheel ───────────────────────────────────────────────
              Expanded(
                child: CupertinoPicker(
                  backgroundColor:
                      isDark ? const Color(0xFF1C1C1E) : CupertinoColors.white,
                  itemExtent: 36,
                  scrollController:
                      FixedExtentScrollController(initialItem: tempIndex),
                  onSelectedItemChanged: (i) => tempIndex = i,
                  children: widget.entries.map((entry) {
                    return Center(
                      child: Text(
                        entry.label,
                        style: TextStyle(
                          fontSize: 16,
                          color: entry.enabled
                              ? (isDark ? CupertinoColors.white : CupertinoColors.black)
                              : (isDark
                                  ? CupertinoColors.systemGrey
                                  : CupertinoColors.systemGrey),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Build ───────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return PlatformHelper.isIOS
        ? _buildIOS(context)
        : _buildMaterial3(context);
  }

  // ── iOS widget ──────────────────────────────────────────────────────────────
  Widget _buildIOS(BuildContext context) {
    final theme = Theme.of(context);
    final isDisabled = widget.onChanged == null;
    final hasValue = widget.value != null;

    final selectedLabel = hasValue
        ? widget.entries
              .where((e) => e.value == widget.value)
              .map((e) => e.label)
              .firstOrNull
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: isDisabled ? null : () => _showIOSPicker(context),
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: isDisabled
                  ? theme.disabledColor.withValues(alpha: 0.08)
                  : theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: widget.errorText != null
                    ? theme.colorScheme.error
                    : (isDisabled
                        ? theme.disabledColor
                        : theme.dividerColor),
                width: widget.errorText != null ? 1.5 : 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    selectedLabel ?? widget.label,
                    style: TextStyle(
                      fontSize: 16,
                      color: selectedLabel == null
                          ? theme.hintColor
                          : (isDisabled
                              ? theme.disabledColor
                              : theme.textTheme.bodyLarge?.color),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  CupertinoIcons.chevron_up_chevron_down,
                  size: 14,
                  color: isDisabled
                      ? theme.disabledColor
                      : theme.iconTheme.color?.withValues(alpha: 0.6),
                ),
              ],
            ),
          ),
        ),

        // Error / helper text
        if (widget.errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 5, left: 16),
            child: Text(
              widget.errorText!,
              style: TextStyle(
                color: theme.colorScheme.error,
                fontSize: 12,
              ),
            ),
          )
        else if (widget.helperText != null)
          Padding(
            padding: const EdgeInsets.only(top: 5, left: 16),
            child: Text(
              widget.helperText!,
              style: TextStyle(
                color: theme.hintColor,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }

  // ── Material 3 widget ───────────────────────────────────────────────────────
  Widget _buildMaterial3(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // M3 DropdownMenu is self-sizing; wrap in LayoutBuilder to honour
    // isExpand without forcing a fixed width at definition time.
    return LayoutBuilder(
      builder: (context, constraints) {
        return DropdownMenu<T>(
          // Width: full parent when isExpand, otherwise intrinsic.
          width: widget.isExpand ? constraints.maxWidth : null,

          // Anchor field decoration
          label: Text(widget.label),
          errorText: widget.errorText,
          helperText:
              widget.errorText == null ? widget.helperText : null,

          // State
          enabled: widget.onChanged != null,
          initialSelection: widget.value,

          
          onSelected: widget.onChanged,

          dropdownMenuEntries: widget.entries,

          menuHeight: 260,

          trailingIcon: const Icon(Icons.arrow_drop_down),
          selectedTrailingIcon: const Icon(Icons.arrow_drop_up),

          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: colorScheme.surfaceContainerHighest,

            labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
            floatingLabelStyle:
                TextStyle(color: colorScheme.primary),

            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(4),
                topRight: const Radius.circular(4),
              ),
              borderSide: BorderSide(
                color: colorScheme.onSurfaceVariant,
                width: 0,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(4),
                topRight: const Radius.circular(4),
              ),
              borderSide: BorderSide(
                color: colorScheme.primary,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: BorderSide(
                color: colorScheme.error,
                width: 2,
              ),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),

          menuStyle: MenuStyle(
            elevation: const WidgetStatePropertyAll(3),
            shape: WidgetStatePropertyAll(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            backgroundColor:
                WidgetStatePropertyAll(colorScheme.surfaceContainer),
            surfaceTintColor:
                WidgetStatePropertyAll(colorScheme.surfaceTint),
          ),
        );
      },
    );
  }
}