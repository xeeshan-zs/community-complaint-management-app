import 'package:flutter/material.dart';

class CustomDropdown extends StatelessWidget {
  final String label;
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  final IconData leadingIcon;

  const CustomDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    required this.leadingIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Outfit',
            color: Colors.white70,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: const Color(0x0AFFFFFF),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0x1BFFFFFF), width: 1.5),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white54),
              isExpanded: true,
              dropdownColor: const Color(0xFF1E1E22),
              style: const TextStyle(
                fontFamily: 'Outfit',
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
              items: items.map((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Row(
                    children: [
                      Icon(
                        _getIconForDropdownItem(item) ?? leadingIcon,
                        size: 18,
                        color: Colors.white70,
                      ),
                      const SizedBox(width: 10),
                      Text(item),
                    ],
                  ),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  IconData? _getIconForDropdownItem(String item) {
    switch (item) {
      case 'Water Leakage':
        return Icons.water_drop_rounded;
      case 'Electricity Failure':
        return Icons.bolt_rounded;
      case 'Garbage Collection':
        return Icons.delete_outline_rounded;
      case 'Security Issue':
        return Icons.security_rounded;
      case 'Street Light Damage':
        return Icons.lightbulb_outline_rounded;
      case 'General':
      case 'All':
        return Icons.category_rounded;
      case 'Low':
        return Icons.check_circle_outline_rounded;
      case 'Medium':
        return Icons.help_outline_rounded;
      case 'High':
        return Icons.error_outline_rounded;
      case 'Pending':
        return Icons.hourglass_empty_rounded;
      case 'Resolved':
        return Icons.task_alt_rounded;
      default:
        return null;
    }
  }
}
