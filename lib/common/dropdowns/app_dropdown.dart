import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../core/utils/platform_helper.dart';

/// Reusable Dropdown component resolving to Material on Android
/// and launching a CupertinoPicker action sheet on iOS natively.
class AppDropdown<T> extends StatelessWidget {
  final String label;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final bool isExpand;
  final String? errorText;

  const AppDropdown({
    super.key,
    required this.label,
    required this.items,
    this.value,
    this.onChanged,
    this.isExpand = true,
    this.errorText,
  });

  void _showIOSPicker(BuildContext context) {
    if (onChanged == null) return;

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    int selectedIndex = items.indexWhere((item) => item.value == value);
    if (selectedIndex == -1) selectedIndex = 0; // Default if not found

    showCupertinoModalPopup(
      context: context,
      builder: (_) => Container(
        height: 250,
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        child: Column(
          children: [
            // Toolbar
            Container(
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF2C2C2C)
                    : const Color(0xFFF9F9F9),
                border: Border(
                  bottom: BorderSide(color: theme.dividerColor, width: 0.5),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    child: const Text('Cancel'),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  CupertinoButton(
                    child: const Text(
                      'Done',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    onPressed: () {
                      onChanged!(items[selectedIndex].value);
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
            // Picker
            Expanded(
              child: CupertinoPicker(
                backgroundColor: isDark
                    ? const Color(0xFF1E1E1E)
                    : Colors.white,
                itemExtent: 32.0,
                scrollController: FixedExtentScrollController(
                  initialItem: selectedIndex,
                ),
                onSelectedItemChanged: (index) {
                  selectedIndex = index;
                },
                children: items.map((item) {
                  return Center(
                    child: DefaultTextStyle(
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black,
                        fontSize: 16,
                      ),
                      child: item
                          .child, // Assume the DropdownMenuItem child is primarily a Text widget
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDisabled = onChanged == null;

    if (PlatformHelper.isIOS) {
      // iOS Implementation using a decorated container simulating a button
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: isDisabled ? null : () => _showIOSPicker(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: isDisabled
                    ? theme.disabledColor.withValues(alpha: 0.1)
                    : theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: errorText != null
                      ? theme.colorScheme.error
                      : theme.dividerColor,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Find current selected text or show label
                  value == null
                      ? Text(label, style: TextStyle(color: theme.hintColor))
                      : items
                            .firstWhere(
                              (element) => element.value == value,
                              orElse: () => items.first, // Fallback
                            )
                            .child,
                  Icon(
                    CupertinoIcons.chevron_down,
                    color: isDisabled
                        ? theme.disabledColor
                        : theme.iconTheme.color,
                    size: 16,
                  ),
                ],
              ),
            ),
          ),
          if (errorText != null)
            Padding(
              padding: const EdgeInsets.only(top: 4, left: 16),
              child: Text(
                errorText!,
                style: TextStyle(color: theme.colorScheme.error, fontSize: 12),
              ),
            ),
        ],
      );
    } else {
      // Android Implementation using Material DropdownButtonFormField
      return DropdownButtonFormField<T>(
        initialValue: value,
        decoration: InputDecoration(
          labelText: label,
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: theme.primaryColor, width: 2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: theme.dividerColor),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: theme.colorScheme.error),
          ),
          errorText: errorText,
          filled: true,
          fillColor: theme.colorScheme.surface,
        ),
        isExpanded: isExpand,
        icon: const Icon(Icons.arrow_drop_down),
        items: items,
        onChanged: onChanged,
      );
    }
  }
}
