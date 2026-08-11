import 'package:flutter/material.dart';
import 'package:grofery_user/config/constant.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

class BusinessDetailsBottomSheet extends StatefulWidget {
  const BusinessDetailsBottomSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: const BusinessDetailsBottomSheet(),
      ),
    );
  }

  @override
  State<BusinessDetailsBottomSheet> createState() =>
      _BusinessDetailsBottomSheetState();
}

class _BusinessDetailsBottomSheetState
    extends State<BusinessDetailsBottomSheet> {
  int _selectedOption = 1; // 0 for GST, 1 for NO GST
  bool _confirmed = false;
  final TextEditingController _gstController = TextEditingController();

  @override
  void dispose() {
    _gstController.dispose();
    super.dispose();
  }

  bool get _isNextEnabled {
    if (!_confirmed) return false;
    if (_selectedOption == 0 && _gstController.text.trim().isEmpty) {
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = isDarkMode(context);
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(width: 24), // to balance the close button
                const Text(
                  'Select your business type',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(TablerIcons.x),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildOptionCard(
              index: 0,
              title: 'I have GST or FSSAI',
              subtitle: 'For registered businesses',
              icon: TablerIcons.shield_check_filled,
              iconColor: Colors.green,
              isDark: isDark,
              primaryColor: Colors.green,
              showTextField: _selectedOption == 0,
            ),
            const SizedBox(height: 16),
            _buildOptionCard(
              index: 1,
              title: "I don't have GST or FSSAI",
              subtitle: 'For non-registered businesses',
              icon: TablerIcons.alert_circle_filled,
              iconColor: Colors.green,
              isDark: isDark,
              primaryColor: Colors.green,
              extraContent: Row(
                children: [
                  Icon(TablerIcons.check, color: Colors.green, size: 16),
                  const SizedBox(width: 4),
                  const Expanded(
                    child: Text(
                      'Easy onboarding (no documents required)',
                      style: TextStyle(color: Colors.green, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Checkbox(
                  value: _confirmed,
                  onChanged: (val) {
                    setState(() {
                      _confirmed = val ?? false;
                    });
                  },
                  activeColor: Colors.green,
                  side: BorderSide(
                    color: _confirmed ? Colors.green : Colors.grey,
                    width: 1.5,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: Text(
                      'I confirm that this account is intended for business use only, not for personal or consumer use',
                      style: TextStyle(
                        fontSize: 13,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isNextEnabled
                    ? () {
                        // TODO: Call API to save Business Details
                        // String? gstNumber = _selectedOption == 0 ? _gstController.text.trim() : null;
                        Navigator.pop(context);
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isNextEnabled
                      ? Colors.green
                      : Colors.green.withValues(alpha: 0.3),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Next',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionCard({
    required int index,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required bool isDark,
    required Color primaryColor,
    Widget? extraContent,
    bool showTextField = false,
  }) {
    bool isSelected = _selectedOption == index;
    Color borderColor =
        isSelected ? iconColor : Theme.of(context).colorScheme.outlineVariant;
    Color bgColor = isSelected
        ? iconColor.withValues(alpha: isDark ? 0.2 : 0.05)
        : Theme.of(context).colorScheme.surface;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedOption = index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bgColor,
          border: Border.all(color: borderColor, width: 1.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, color: iconColor),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontSize: 13,
                        ),
                      ),
                      if (extraContent != null) ...[
                        const SizedBox(height: 8),
                        extraContent,
                      ]
                    ],
                  ),
                ),
                Icon(
                  isSelected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                  color: isSelected ? iconColor : Colors.grey.shade400,
                ),
              ],
            ),
            if (showTextField) ...[
              const SizedBox(height: 16),
              TextField(
                controller: _gstController,
                onChanged: (val) {
                  setState(() {}); // trigger rebuild to enable/disable Next button
                },
                decoration: InputDecoration(
                  hintText: 'Enter your 15-digit GST Number',
                  hintStyle: const TextStyle(fontSize: 14),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surface,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.outlineVariant),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: primaryColor, width: 2),
                  ),
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
