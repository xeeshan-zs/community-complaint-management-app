import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/complaint.dart';
import '../../providers/complaint_provider.dart';
import '../widgets/complaint_card.dart';
import '../widgets/complaint_form.dart';
import '../widgets/stats_card.dart';
import '../widgets/custom_dropdown.dart';
import '../widgets/snackbar_helper.dart';
import '../../services/firebase_service.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F11), // Midnight Black backdrop
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Adaptive Layout: Centered Phone Shell on Desktop
            final isDesktop = constraints.maxWidth > 550;
            
            if (isDesktop) {
              return Center(
                child: Container(
                  width: 410,
                  height: 820,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: const Color(0xFF121214), // Phone body
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(color: Colors.white12, width: 6),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 30,
                        spreadRadius: 5,
                      )
                    ],
                  ),
                  child: const PhoneBody(),
                ),
              );
            }
            
            return const PhoneBody();
          },
        ),
      ),
    );
  }
}

class PhoneBody extends StatelessWidget {
  const PhoneBody({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ComplaintProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFF121214), // Obsidian dark screen
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'SOCIETY CONNECT',
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => _showSyncSettings(context, provider),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: provider.isOfflineMode
                          ? const Color(0xFF10B981).withOpacity(0.1)
                          : const Color(0xFF6366F1).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: provider.isOfflineMode
                            ? const Color(0xFF10B981).withOpacity(0.3)
                            : const Color(0xFF6366F1).withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      provider.isOfflineMode ? 'SANDBOX' : 'LIVE',
                      style: TextStyle(
                        fontFamily: 'Outfit',
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: provider.isOfflineMode
                            ? const Color(0xFF10B981)
                            : const Color(0xFF6366F1),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const Text(
              'Smart Complaint Portal',
              style: TextStyle(
                fontFamily: 'Outfit',
                fontSize: 11,
                color: Colors.white38,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              provider.isOfflineMode ? Icons.cloud_off_rounded : Icons.cloud_done_rounded,
              color: provider.isOfflineMode ? Colors.white38 : const Color(0xFF6366F1),
              size: 20,
            ),
            tooltip: provider.isOfflineMode ? 'Offline Sandbox Mode' : 'Cloud Sync Active',
            onPressed: () => _showSyncSettings(context, provider),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openAddSheet(context),
        backgroundColor: const Color(0xFF6366F1), // Glowing Indigo
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add_rounded, size: 28),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stats Dashboard Card Grid
            const SizedBox(height: 8),
            const StatsGrid(),
            const SizedBox(height: 18),
            
            // Dropdown Filters Row (Roll Number 459 - Filter using Dropdown)
            const Text(
              'Filters & Sorting',
              style: TextStyle(
                fontFamily: 'Outfit',
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 8),
            const DropdownFilterRow(),
            const SizedBox(height: 14),

            // Active Filters Clear Button (Only show if filtering is active)
            if (provider.selectedType != 'All' ||
                provider.selectedUrgency != 'All' ||
                provider.selectedStatus != 'All')
              Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Showing ${provider.filteredComplaints.length} of ${provider.allComplaints.length} complaints',
                      style: const TextStyle(
                        fontFamily: 'Outfit',
                        fontSize: 11,
                        color: Colors.white38,
                      ),
                    ),
                    GestureDetector(
                      onTap: provider.clearFilters,
                      child: const Row(
                        children: [
                          Icon(Icons.close_rounded, size: 12, color: Color(0xFF6366F1)),
                          SizedBox(width: 4),
                          Text(
                            'Clear Active Filters',
                            style: TextStyle(
                              fontFamily: 'Outfit',
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF6366F1),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

            // Scrollable List area
            Expanded(
              child: _buildListContent(context, provider),
            ),
          ],
        ),
      ),
    );
  }

  // Handle Edge Cases for Screen States
  Widget _buildListContent(BuildContext context, ComplaintProvider provider) {
    if (provider.isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
        ),
      );
    }

    if (provider.allComplaints.isEmpty) {
      // Edge Case: Absolute Zero Complaints in Database
      return Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 100,
                width: 100,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.02),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.spa_rounded,
                  size: 48,
                  color: Colors.white12,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Prinstine Community',
                style: TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white60,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'No complaints have been reported yet.\nEnjoy the tranquility!',
                style: TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 12,
                  color: Colors.white24,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => _openAddSheet(context),
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('SUBMIT FIRST COMPLAINT'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              )
            ],
          ),
        ),
      );
    }

    if (provider.filteredComplaints.isEmpty) {
      // Edge Case: Filtering yielded zero matches
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.filter_list_off_rounded,
              size: 40,
              color: Colors.white24,
            ),
            const SizedBox(height: 16),
            const Text(
              'No matches found',
              style: TextStyle(
                fontFamily: 'Outfit',
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.white54,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Try clearing filters to review full records.',
              style: TextStyle(
                fontFamily: 'Outfit',
                fontSize: 12,
                color: Colors.white30,
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: provider.clearFilters,
              child: const Text(
                'RESET FILTERS',
                style: TextStyle(
                  fontFamily: 'Outfit',
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF6366F1),
                ),
              ),
            )
          ],
        ),
      );
    }

    // Default: Display scrollable stream list
    return ListView.builder(
      itemCount: provider.filteredComplaints.length,
      padding: const EdgeInsets.only(bottom: 80),
      physics: const BouncingScrollPhysics(),
      itemBuilder: (context, index) {
        final complaint = provider.filteredComplaints[index];
        return Dismissible(
          key: Key(complaint.id),
          direction: DismissDirection.horizontal,
          background: _buildSwipeBackground(context, true),
          secondaryBackground: _buildSwipeBackground(context, false),
          confirmDismiss: (direction) => _confirmSwipeDelete(context, provider, complaint),
          child: ComplaintCard(complaint: complaint),
        );
      },
    );
  }

  Widget _buildSwipeBackground(BuildContext context, bool isLeft) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      decoration: BoxDecoration(
        color: const Color(0xFFEF4444),
        borderRadius: BorderRadius.circular(16.0),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      alignment: isLeft ? Alignment.centerLeft : Alignment.centerRight,
      child: const Icon(
        Icons.delete_sweep_rounded,
        color: Colors.white,
        size: 28,
      ),
    );
  }

  Future<bool?> _confirmSwipeDelete(
      BuildContext context, ComplaintProvider provider, Complaint complaint) async {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E22),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Delete Complaint?',
          style: TextStyle(fontFamily: 'Outfit', color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Swiping deletes this record permanently. Proceed?',
          style: TextStyle(fontFamily: 'Outfit', color: Colors.white70, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('CANCEL', style: TextStyle(fontFamily: 'Outfit', color: Colors.white54)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx, true);
              final success = await provider.deleteComplaint(complaint.id);
              if (ctx.mounted) {
                if (success) {
                  SnackbarHelper.showSuccess(context, 'Complaint deleted.');
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

  void _openAddSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1E1E22),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
      ),
      builder: (context) => const ComplaintForm(),
    );
  }

  void _showSyncSettings(BuildContext context, ComplaintProvider provider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E22),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final isOffline = provider.isOfflineMode;
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Database Connection',
                        style: TextStyle(
                          fontFamily: 'Outfit',
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, color: Colors.white38),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isOffline
                          ? const Color(0xFF10B981).withOpacity(0.05)
                          : const Color(0xFF6366F1).withOpacity(0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isOffline
                            ? const Color(0xFF10B981).withOpacity(0.15)
                            : const Color(0xFF6366F1).withOpacity(0.15),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isOffline
                                ? const Color(0xFF10B981).withOpacity(0.1)
                                : const Color(0xFF6366F1).withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isOffline ? Icons.bolt_rounded : Icons.cloud_done_rounded,
                            color: isOffline ? const Color(0xFF10B981) : const Color(0xFF6366F1),
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isOffline ? 'Offline Sandbox Mode' : 'Cloud Sync Active',
                                style: const TextStyle(
                                  fontFamily: 'Outfit',
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                isOffline
                                    ? 'Running with local mock data. 100% stable, zero setup required.'
                                    : 'Connected to Firebase Firestore. Syncing complaints in real-time.',
                                style: TextStyle(
                                  fontFamily: 'Outfit',
                                  fontSize: 12,
                                  color: Colors.white.withOpacity(0.5),
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Connection Toggle',
                    style: TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.white60,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SwitchListTile(
                    value: !isOffline,
                    onChanged: (bool value) async {
                      if (!value) {
                        provider.setForceOffline(true);
                        setModalState(() {});
                        SnackbarHelper.showSuccess(context, 'Switched to Offline Sandbox Mode.');
                      } else {
                        provider.setForceOffline(false);
                        setModalState(() {});
                        if (!FirebaseService.instance.isFirebaseInitialized) {
                          SnackbarHelper.showWarning(context, 'Connecting to Cloud Firestore...');
                        }
                        // Give it a brief delay to connect
                        await Future.delayed(const Duration(milliseconds: 1000));
                        if (provider.hasFirebaseError) {
                          // Revert back
                          provider.setForceOffline(true);
                          setModalState(() {});
                          if (context.mounted) {
                            showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                backgroundColor: const Color(0xFF1E1E22),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                title: const Text(
                                  'Connection Denied',
                                  style: TextStyle(fontFamily: 'Outfit', color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                                content: const Text(
                                  'Cloud Firestore returned permission denied.\n\nReason: Cloud Firestore API is not enabled in Firebase Console yet.\n\nReverting safely to Offline Sandbox Mode.',
                                  style: TextStyle(fontFamily: 'Outfit', color: Colors.white70, fontSize: 13, height: 1.4),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx),
                                    child: const Text('OK', style: TextStyle(fontFamily: 'Outfit', color: Color(0xFF6366F1))),
                                  ),
                                ],
                              ),
                            );
                          }
                        } else {
                          if (context.mounted) {
                            SnackbarHelper.showSuccess(context, 'Successfully synced with Cloud Firestore!');
                          }
                        }
                      }
                    },
                    title: const Text(
                      'Enable Cloud Sync',
                      style: TextStyle(
                        fontFamily: 'Outfit',
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                    subtitle: Text(
                      'Sync database changes live with Firebase servers.',
                      style: TextStyle(
                        fontFamily: 'Outfit',
                        fontSize: 11,
                        color: Colors.white.withOpacity(0.4),
                      ),
                    ),
                    activeColor: const Color(0xFF6366F1),
                    activeTrackColor: const Color(0xFF6366F1).withOpacity(0.4),
                    inactiveThumbColor: Colors.white30,
                    inactiveTrackColor: Colors.white10,
                    contentPadding: EdgeInsets.zero,
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

// Top level aggregated calculations view cards
class StatsGrid extends StatelessWidget {
  const StatsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ComplaintProvider>(context);
    final avgDays = provider.avgExpectedResolutionDays;

    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 2,
      childAspectRatio: 1.65,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        StatsCard(
          title: 'TOTAL CASES',
          value: provider.totalComplaintsCount.toString(),
          icon: Icons.assignment_rounded,
          accentColor: const Color(0xFF6366F1), // Glowing indigo
        ),
        StatsCard(
          title: 'CRITICAL HIGHS',
          value: provider.highUrgencyCount.toString(),
          icon: Icons.error_rounded,
          accentColor: const Color(0xFFEF4444), // Neon coral red
        ),
        StatsCard(
          title: 'RESOLVED CASES',
          value: provider.resolvedCount.toString(),
          icon: Icons.task_alt_rounded,
          accentColor: const Color(0xFF10B981), // Emerald green
        ),
        StatsCard(
          title: 'AVG DURATION',
          value: '${avgDays.toStringAsFixed(1)} ${avgDays == 1.0 ? "Day" : "Days"}',
          icon: Icons.hourglass_bottom_rounded,
          accentColor: const Color(0xFFF59E0B), // Amber orange
        ),
      ],
    );
  }
}

// Dropdown filter component implementation
class DropdownFilterRow extends StatelessWidget {
  const DropdownFilterRow({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ComplaintProvider>(context);

    final List<String> types = [
      'All',
      'Water Leakage',
      'Electricity Failure',
      'Garbage Collection',
      'Security Issue',
      'Street Light Damage'
    ];

    final List<String> urgencies = ['All', 'Low', 'Medium', 'High'];
    final List<String> statuses = ['All', 'Pending', 'Resolved'];

    return Row(
      children: [
        // Type Filter
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Type',
                style: TextStyle(fontFamily: 'Outfit', fontSize: 10, color: Colors.white38),
              ),
              const SizedBox(height: 4),
              _buildThemedDropdownContainer(
                DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: provider.selectedType,
                    icon: const Icon(Icons.arrow_drop_down, color: Colors.white54, size: 16),
                    isExpanded: true,
                    dropdownColor: const Color(0xFF1E1E22),
                    style: const TextStyle(fontFamily: 'Outfit', color: Colors.white, fontSize: 12),
                    items: types.map((String item) {
                      return DropdownMenuItem<String>(
                        value: item,
                        child: Text(
                          item,
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) provider.setFilterType(val);
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 6),

        // Urgency Filter
        Expanded(
          flex: 1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Urgency',
                style: TextStyle(fontFamily: 'Outfit', fontSize: 10, color: Colors.white38),
              ),
              const SizedBox(height: 4),
              _buildThemedDropdownContainer(
                DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: provider.selectedUrgency,
                    icon: const Icon(Icons.arrow_drop_down, color: Colors.white54, size: 16),
                    isExpanded: true,
                    dropdownColor: const Color(0xFF1E1E22),
                    style: const TextStyle(fontFamily: 'Outfit', color: Colors.white, fontSize: 12),
                    items: urgencies.map((String item) {
                      return DropdownMenuItem<String>(
                        value: item,
                        child: Text(item),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) provider.setFilterUrgency(val);
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 6),

        // Status Filter
        Expanded(
          flex: 1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Status',
                style: TextStyle(fontFamily: 'Outfit', fontSize: 10, color: Colors.white38),
              ),
              const SizedBox(height: 4),
              _buildThemedDropdownContainer(
                DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: provider.selectedStatus,
                    icon: const Icon(Icons.arrow_drop_down, color: Colors.white54, size: 16),
                    isExpanded: true,
                    dropdownColor: const Color(0xFF1E1E22),
                    style: const TextStyle(fontFamily: 'Outfit', color: Colors.white, fontSize: 12),
                    items: statuses.map((String item) {
                      return DropdownMenuItem<String>(
                        value: item,
                        child: Text(item),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) provider.setFilterStatus(val);
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildThemedDropdownContainer(Widget child) {
    return Container(
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: const Color(0x06FFFFFF),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0x0EFFFFFF), width: 1.5),
      ),
      child: child,
    );
  }
}
