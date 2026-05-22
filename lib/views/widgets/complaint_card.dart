import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/complaint.dart';
import '../../providers/complaint_provider.dart';
import 'complaint_form.dart';
import 'snackbar_helper.dart';

class ComplaintCard extends StatelessWidget {
  final Complaint complaint;

  const ComplaintCard({super.key, required this.complaint});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ComplaintProvider>(context, listen: false);
    final formattedDate =
        DateFormat('MMM dd, yyyy - hh:mm a').format(complaint.createdAt);

    // Dynamic Urgency Color mapping
    Color urgencyColor;
    Color urgencyBgColor;
    switch (complaint.urgency) {
      case 'High':
        urgencyColor = const Color(0xFFEF4444); // Red
        urgencyBgColor = const Color(0x22EF4444);
        break;
      case 'Medium':
        urgencyColor = const Color(0xFFF59E0B); // Amber
        urgencyBgColor = const Color(0x22F59E0B);
        break;
      case 'Low':
      default:
        urgencyColor = const Color(0xFF10B981); // Emerald
        urgencyBgColor = const Color(0x2210B981);
        break;
    }

    final isResolved = complaint.status == 'Resolved';

    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      decoration: BoxDecoration(
        color: const Color(0x06FFFFFF),
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
          color: isResolved
              ? const Color(0x1110B981) // Emerald border if resolved
              : const Color(0x11FFFFFF),
          width: 1.5,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        type: MaterialType.transparency,
        child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          collapsedTextColor: Colors.white,
          textColor: Colors.white,
          iconColor: Colors.white70,
          collapsedIconColor: Colors.white38,
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isResolved
                  ? const Color(0x1A10B981)
                  : const Color(0x0AFFFFFF),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isResolved
                  ? Icons.task_alt_rounded
                  : _getIconForType(complaint.type),
              color: isResolved ? const Color(0xFF10B981) : Colors.white70,
              size: 20,
            ),
          ),
          title: Text(
            complaint.title,
            style: TextStyle(
              fontFamily: 'Outfit',
              fontWeight: FontWeight.bold,
              fontSize: 15.0,
              decoration: isResolved ? TextDecoration.lineThrough : null,
              color: isResolved ? Colors.white38 : Colors.white,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    'by ${complaint.residentName}',
                    style: const TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 12,
                      color: Colors.white38,
                    ),
                  ),
                  const Spacer(),
                  // Urgency Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: urgencyBgColor,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      complaint.urgency,
                      style: TextStyle(
                        fontFamily: 'Outfit',
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: urgencyColor,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0, top: 4.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(color: Colors.white10),
                  const SizedBox(height: 8),
                  
                  // Description
                  const Text(
                    'Description',
                    style: TextStyle(
                      fontFamily: 'Outfit',
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: Colors.white38,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    complaint.description,
                    style: TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.8),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Expected Resolution and Date Info
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Filed On',
                            style: TextStyle(
                              fontFamily: 'Outfit',
                              fontSize: 10,
                              color: Colors.white38,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            formattedDate,
                            style: const TextStyle(
                              fontFamily: 'Outfit',
                              fontSize: 12,
                              color: Colors.white60,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text(
                            'Expected Resolution',
                            style: TextStyle(
                              fontFamily: 'Outfit',
                              fontSize: 10,
                              color: Colors.white38,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${complaint.resolutionDays} ${complaint.resolutionDays == 1 ? "Day" : "Days"}',
                            style: const TextStyle(
                              fontFamily: 'Outfit',
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF6366F1),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(color: Colors.white10),
                  const SizedBox(height: 8),

                  // Operations Actions (Edit, Delete, Resolve Toggle)
                  Row(
                    children: [
                      // Toggle Status
                      ElevatedButton.icon(
                        onPressed: () => provider.toggleComplaintStatus(complaint),
                        icon: Icon(
                          isResolved ? Icons.undo_rounded : Icons.check_rounded,
                          size: 16,
                        ),
                        label: Text(isResolved ? 'Mark Pending' : 'Mark Resolved'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isResolved
                              ? Colors.white12
                              : const Color(0x1A10B981),
                          foregroundColor: isResolved ? Colors.white70 : const Color(0xFF10B981),
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(
                              color: isResolved ? Colors.transparent : const Color(0x3310B981),
                            ),
                          ),
                        ),
                      ),
                      const Spacer(),

                      // Edit Button (DRY Reused sheet)
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, color: Colors.white54, size: 20),
                        tooltip: 'Edit Complaint',
                        onPressed: () => _openEditSheet(context),
                      ),

                      // Delete Button
                      IconButton(
                        icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFEF4444), size: 20),
                        tooltip: 'Delete Complaint',
                        onPressed: () => _confirmDelete(context, provider),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
    );
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'Water Leakage':
        return Icons.water_drop_rounded;
      case 'Electricity Failure':
        return Icons.bolt_rounded;
      case 'Garbage Collection':
        return Icons.delete_outline_rounded;
      case 'Security Issue':
        return Icons.security_rounded;
      case 'Street Light Damage':
      default:
        return Icons.lightbulb_outline_rounded;
    }
  }

  void _openEditSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1E1E22),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
      ),
      builder: (context) => ComplaintForm(initialComplaint: complaint),
    );
  }

  void _confirmDelete(BuildContext context, ComplaintProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E22),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Delete Complaint?',
          style: TextStyle(fontFamily: 'Outfit', color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Are you sure you want to permanently delete this complaint from Firestore? This action is irreversible.',
          style: TextStyle(fontFamily: 'Outfit', color: Colors.white70, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('CANCEL', style: TextStyle(fontFamily: 'Outfit', color: Colors.white54)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final success = await provider.deleteComplaint(complaint.id);
              if (ctx.mounted) {
                if (success) {
                  SnackbarHelper.showSuccess(context, 'Complaint deleted successfully.');
                } else {
                  SnackbarHelper.showError(context, provider.errorMessage ?? 'Deletion failed.');
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('DELETE', style: TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
