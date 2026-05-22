import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../models/complaint.dart';
import '../../providers/complaint_provider.dart';
import 'urgency_chips.dart';
import 'custom_dropdown.dart';
import 'snackbar_helper.dart';

class ComplaintForm extends StatefulWidget {
  final Complaint? initialComplaint;
  final VoidCallback? onSuccess;

  const ComplaintForm({
    super.key,
    this.initialComplaint,
    this.onSuccess,
  });

  @override
  State<ComplaintForm> createState() => _ComplaintFormState();
}

class _ComplaintFormState extends State<ComplaintForm> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _nameController;
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  
  late String _selectedType;
  late String _selectedUrgency;
  late double _resolutionDays;

  final List<String> _complaintTypes = [
    'Water Leakage',
    'Electricity Failure',
    'Garbage Collection',
    'Security Issue',
    'Street Light Damage'
  ];

  @override
  void initState() {
    super.initState();
    final c = widget.initialComplaint;
    
    // DRY initialization: populate if edit, set default if new
    _nameController = TextEditingController(text: c?.residentName ?? '');
    _titleController = TextEditingController(text: c?.title ?? '');
    _descriptionController = TextEditingController(text: c?.description ?? '');
    
    _selectedType = c != null && _complaintTypes.contains(c.type)
        ? c.type
        : _complaintTypes.first;
    _selectedUrgency = c?.urgency ?? 'Low';
    _resolutionDays = (c?.resolutionDays ?? 3).toDouble();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final provider = Provider.of<ComplaintProvider>(context, listen: false);
    final isEditing = widget.initialComplaint != null;
    
    final id = widget.initialComplaint?.id ?? const Uuid().v4();
    final newComplaint = Complaint(
      id: id,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      residentName: _nameController.text.trim(),
      type: _selectedType,
      urgency: _selectedUrgency,
      resolutionDays: _resolutionDays.toInt(),
      status: widget.initialComplaint?.status ?? 'Pending',
      createdAt: widget.initialComplaint?.createdAt ?? DateTime.now(),
    );

    bool success;
    if (isEditing) {
      success = await provider.updateComplaint(newComplaint);
    } else {
      success = await provider.addComplaint(newComplaint);
    }

    if (mounted) {
      if (success) {
        SnackbarHelper.showSuccess(
          context,
          isEditing ? 'Complaint updated successfully!' : 'Complaint submitted successfully!',
        );
        Navigator.pop(context); // Close sheet
        if (widget.onSuccess != null) widget.onSuccess!();
      } else {
        SnackbarHelper.showError(
          context,
          provider.errorMessage ?? 'Submission failed. Please try again.',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ComplaintProvider>(context);
    final isEditing = widget.initialComplaint != null;

    return SingleChildScrollView(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isEditing ? 'Edit Complaint' : 'File a New Complaint',
                  style: const TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                if (isEditing)
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white60),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            
            // Resident Name
            TextFormField(
              controller: _nameController,
              decoration: _buildInputDecoration('Resident Name', Icons.person_outline_rounded),
              style: const TextStyle(color: Colors.white, fontFamily: 'Outfit'),
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return 'Please enter your name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Title
            TextFormField(
              controller: _titleController,
              decoration: _buildInputDecoration('Complaint Title', Icons.title_rounded),
              style: const TextStyle(color: Colors.white, fontFamily: 'Outfit'),
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return 'Please enter a title';
                }
                if (val.trim().length < 5) {
                  return 'Title must be at least 5 characters long';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Description
            TextFormField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: _buildInputDecoration('Detailed Description', Icons.description_outlined),
              style: const TextStyle(color: Colors.white, fontFamily: 'Outfit'),
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return 'Please describe the issue in detail';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Complaint Type Dropdown (DRY Reused Widget)
            CustomDropdown(
              label: 'Select Complaint Type',
              value: _selectedType,
              items: _complaintTypes,
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    _selectedType = val;
                  });
                }
              },
              leadingIcon: Icons.category_rounded,
            ),
            const SizedBox(height: 20),

            // Urgency choice chips
            const Text(
              'Urgency level',
              style: TextStyle(
                fontFamily: 'Outfit',
                color: Colors.white70,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            UrgencyChips(
              selectedUrgency: _selectedUrgency,
              onSelected: (val) {
                setState(() {
                  _selectedUrgency = val;
                });
              },
            ),
            const SizedBox(height: 20),

            // Expected Resolution Days (Slider)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Expected Resolution',
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '${_resolutionDays.toInt()} ${_resolutionDays.toInt() == 1 ? "Day" : "Days"}',
                  style: const TextStyle(
                    fontFamily: 'Outfit',
                    color: Color(0xFF6366F1), // Glowing Indigo
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: const Color(0xFF6366F1),
                inactiveTrackColor: Colors.white12,
                thumbColor: Colors.white,
                overlayColor: const Color(0x296366F1),
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8.5),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 18),
              ),
              child: Slider(
                value: _resolutionDays,
                min: 1,
                max: 14,
                divisions: 13,
                onChanged: (val) {
                  setState(() {
                    _resolutionDays = val;
                  });
                },
              ),
            ),
            const SizedBox(height: 24),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: provider.isSubmitting ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: const Color(0x336366F1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 6,
                  shadowColor: const Color(0x886366F1),
                ),
                child: provider.isSubmitting
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        isEditing ? 'Save Changes' : 'Submit Complaint',
                        style: const TextStyle(
                          fontFamily: 'Outfit',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String labelText, IconData prefixIcon) {
    return InputDecoration(
      labelText: labelText,
      labelStyle: const TextStyle(color: Colors.white54, fontFamily: 'Outfit'),
      prefixIcon: Icon(prefixIcon, color: Colors.white38, size: 20),
      filled: true,
      fillColor: const Color(0x0AFFFFFF),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0x1BFFFFFF), width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF6366F1), width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFEF4444), width: 2),
      ),
      errorStyle: const TextStyle(fontFamily: 'Outfit', color: Color(0xFFEF4444)),
    );
  }
}
