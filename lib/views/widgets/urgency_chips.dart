import 'package:flutter/material.dart';

class UrgencyChips extends StatelessWidget {
  final String selectedUrgency;
  final ValueChanged<String> onSelected;

  const UrgencyChips({
    super.key,
    required this.selectedUrgency,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final urgencies = ['Low', 'Medium', 'High'];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: urgencies.map((urgency) {
        final isSelected = selectedUrgency == urgency;
        Color activeColor;
        Color glowColor;

        switch (urgency) {
          case 'High':
            activeColor = const Color(0xFFEF4444); // Neon Coral Red
            glowColor = const Color(0x33EF4444);
            break;
          case 'Medium':
            activeColor = const Color(0xFFF59E0B); // Amber Orange
            glowColor = const Color(0x33F59E0B);
            break;
          case 'Low':
          default:
            activeColor = const Color(0xFF10B981); // Emerald Green
            glowColor = const Color(0x3310B981);
            break;
        }

        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: GestureDetector(
              onTap: () => onSelected(urgency),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                decoration: BoxDecoration(
                  color: isSelected ? activeColor : const Color(0x11FFFFFF),
                  borderRadius: BorderRadius.circular(12.0),
                  border: Border.all(
                    color: isSelected ? activeColor : const Color(0x22FFFFFF),
                    width: 1.5,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: glowColor,
                            blurRadius: 8.0,
                            offset: const Offset(0, 4),
                          )
                        ]
                      : [],
                ),
                child: Center(
                  child: Text(
                    urgency,
                    style: TextStyle(
                      fontFamily: 'Outfit',
                      color: isSelected ? Colors.white : Colors.white60,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      fontSize: 14.0,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
