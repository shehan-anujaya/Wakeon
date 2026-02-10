import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/models/emergency_contact.dart';
import '../../../../core/theme/app_theme.dart';
import '../../providers/emergency_contacts_provider.dart';

class ContactFormPage extends ConsumerStatefulWidget {
  /// If null, we're creating a new contact. Otherwise, updating.
  final EmergencyContact? contact;

  const ContactFormPage({super.key, this.contact});

  @override
  ConsumerState<ContactFormPage> createState() => _ContactFormPageState();
}

class _ContactFormPageState extends ConsumerState<ContactFormPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late bool _enableAutoSms;
  late bool _enableAutoCall;
  bool _isSubmitting = false;

  bool get isEditing => widget.contact != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.contact?.name ?? '');
    _phoneController = TextEditingController(text: widget.contact?.phoneNumber ?? '');
    _enableAutoSms = widget.contact?.enableAutoSms ?? true;
    _enableAutoCall = widget.contact?.enableAutoCall ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final notifier = ref.read(emergencyContactsProvider.notifier);
    final contacts = ref.read(emergencyContactsProvider).valueOrNull ?? [];

    if (isEditing) {
      final updated = widget.contact!.copyWith(
        name: _nameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        enableAutoSms: _enableAutoSms,
        enableAutoCall: _enableAutoCall,
      );
      await notifier.updateContact(updated);
    } else {
      final newContact = EmergencyContact(
        id: const Uuid().v4(),
        name: _nameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        enableAutoSms: _enableAutoSms,
        enableAutoCall: _enableAutoCall,
        priority: contacts.length,
      );
      await notifier.addContact(newContact);
    }

    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundBlack,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          isEditing ? 'Edit Contact' : 'New Contact',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              // Avatar preview
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppTheme.neonGreen.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      _nameController.text.isNotEmpty
                          ? _nameController.text[0].toUpperCase()
                          : '+',
                      style: GoogleFonts.outfit(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.neonGreen,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Name field
              TextFormField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                style: GoogleFonts.outfit(color: AppTheme.textPrimary),
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  labelStyle: GoogleFonts.outfit(color: AppTheme.textTertiary),
                  prefixIcon: const Icon(Icons.person_outline, color: AppTheme.textTertiary),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Name is required';
                  }
                  if (value.trim().length < 2) {
                    return 'Name must be at least 2 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Phone field
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                style: GoogleFonts.outfit(color: AppTheme.textPrimary),
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  labelStyle: GoogleFonts.outfit(color: AppTheme.textTertiary),
                  prefixIcon: const Icon(Icons.phone_outlined, color: AppTheme.textTertiary),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Phone number is required';
                  }
                  // Basic phone validation – at least 7 digits
                  final digitsOnly = value.replaceAll(RegExp(r'\D'), '');
                  if (digitsOnly.length < 7) {
                    return 'Enter a valid phone number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),

              // Settings section
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceDark,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.borderColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Notification Settings',
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SwitchListTile(
                      title: Text(
                        'Auto SMS',
                        style: GoogleFonts.outfit(color: AppTheme.textPrimary),
                      ),
                      subtitle: Text(
                        'Send an automated SMS alert when drowsiness is detected',
                        style: GoogleFonts.outfit(fontSize: 12, color: AppTheme.textTertiary),
                      ),
                      value: _enableAutoSms,
                      onChanged: (v) => setState(() => _enableAutoSms = v),
                      activeColor: AppTheme.neonGreen,
                      activeTrackColor: AppTheme.neonGreen.withOpacity(0.3),
                      contentPadding: EdgeInsets.zero,
                    ),
                    const Divider(color: AppTheme.borderColor),
                    SwitchListTile(
                      title: Text(
                        'Auto Call',
                        style: GoogleFonts.outfit(color: AppTheme.textPrimary),
                      ),
                      subtitle: Text(
                        'Initiate a call after SMS is sent',
                        style: GoogleFonts.outfit(fontSize: 12, color: AppTheme.textTertiary),
                      ),
                      value: _enableAutoCall,
                      onChanged: (v) => setState(() => _enableAutoCall = v),
                      activeColor: AppTheme.neonGreen,
                      activeTrackColor: AppTheme.neonGreen.withOpacity(0.3),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // Submit button
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: AppTheme.backgroundBlack,
                          ),
                        )
                      : Text(
                          isEditing ? 'SAVE CHANGES' : 'ADD CONTACT',
                          style: GoogleFonts.outfit(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.5,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
