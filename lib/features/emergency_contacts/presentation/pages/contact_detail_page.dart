import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/models/emergency_contact.dart';
import '../../../../core/theme/app_theme.dart';
import '../../providers/emergency_contacts_provider.dart';
import 'contact_form_page.dart';

class ContactDetailPage extends ConsumerWidget {
  final String contactId;

  const ContactDetailPage({super.key, required this.contactId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contactsAsync = ref.watch(emergencyContactsProvider);

    return contactsAsync.when(
      loading: () => Scaffold(
        backgroundColor: AppTheme.backgroundBlack,
        appBar: AppBar(backgroundColor: Colors.transparent),
        body: const Center(
          child: CircularProgressIndicator(color: AppTheme.neonGreen),
        ),
      ),
      error: (e, _) => Scaffold(
        backgroundColor: AppTheme.backgroundBlack,
        appBar: AppBar(backgroundColor: Colors.transparent),
        body: Center(
          child: Text('Error: $e', style: const TextStyle(color: AppTheme.neonRed)),
        ),
      ),
      data: (contacts) {
        final contact = contacts.firstWhere(
          (c) => c.id == contactId,
          orElse: () => EmergencyContact(
            id: '',
            name: 'Not Found',
            phoneNumber: '',
            enableAutoCall: false,
            enableAutoSms: false,
            priority: 0,
          ),
        );

        if (contact.id.isEmpty) {
          return Scaffold(
            backgroundColor: AppTheme.backgroundBlack,
            appBar: AppBar(backgroundColor: Colors.transparent),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.person_off_outlined, size: 64, color: AppTheme.textTertiary),
                  const SizedBox(height: 16),
                  Text(
                    'Contact not found',
                    style: GoogleFonts.outfit(fontSize: 18, color: AppTheme.textPrimary),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Go Back'),
                  ),
                ],
              ),
            ),
          );
        }

        return _buildDetailView(context, ref, contact);
      },
    );
  }

  Widget _buildDetailView(BuildContext context, WidgetRef ref, EmergencyContact contact) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundBlack,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          'Contact Details',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ContactFormPage(contact: contact),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppTheme.neonRed),
            onPressed: () => _confirmDelete(context, ref, contact),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Avatar
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppTheme.neonGreen.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  contact.name.isNotEmpty ? contact.name[0].toUpperCase() : '?',
                  style: GoogleFonts.outfit(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.neonGreen,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Name
            Text(
              contact.name,
              style: GoogleFonts.outfit(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              contact.phoneNumber,
              style: GoogleFonts.outfit(
                fontSize: 16,
                color: AppTheme.textTertiary,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.surfaceDark,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Priority #${contact.priority + 1}',
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Quick actions
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildQuickAction(
                  context,
                  icon: Icons.phone_rounded,
                  label: 'Call',
                  color: AppTheme.neonGreen,
                  onTap: () => _launchPhone(contact.phoneNumber),
                ),
                const SizedBox(width: 24),
                _buildQuickAction(
                  context,
                  icon: Icons.message_rounded,
                  label: 'SMS',
                  color: Colors.blueAccent,
                  onTap: () => _launchSms(contact.phoneNumber),
                ),
              ],
            ),
            const SizedBox(height: 40),

            // Settings card
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
                    'Emergency Settings',
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildSettingTile(
                    'Auto SMS',
                    'Send automated alert on detection',
                    Icons.message_outlined,
                    contact.enableAutoSms,
                    (value) {
                      ref.read(emergencyContactsProvider.notifier).updateContact(
                            contact.copyWith(enableAutoSms: value),
                          );
                    },
                  ),
                  const Divider(color: AppTheme.borderColor, height: 24),
                  _buildSettingTile(
                    'Auto Call',
                    'Initiate call after SMS is sent',
                    Icons.phone_outlined,
                    contact.enableAutoCall,
                    (value) {
                      ref.read(emergencyContactsProvider.notifier).updateContact(
                            contact.copyWith(enableAutoCall: value),
                          );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAction(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.outfit(
              color: AppTheme.textSecondary,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingTile(
    String title,
    String subtitle,
    IconData icon,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppTheme.surfaceLight,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppTheme.textSecondary, size: 20),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.outfit(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              Text(
                subtitle,
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  color: AppTheme.textTertiary,
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: AppTheme.neonGreen,
          activeTrackColor: AppTheme.neonGreen.withOpacity(0.3),
        ),
      ],
    );
  }

  Future<void> _launchPhone(String phoneNumber) async {
    final uri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _launchSms(String phoneNumber) async {
    final uri = Uri(scheme: 'sms', path: phoneNumber);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, EmergencyContact contact) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surfaceDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Delete Contact',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        content: Text(
          'Are you sure you want to remove ${contact.name} from your emergency contacts?',
          style: GoogleFonts.outfit(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: GoogleFonts.outfit(color: AppTheme.textTertiary)),
          ),
          TextButton(
            onPressed: () {
              ref.read(emergencyContactsProvider.notifier).removeContact(contact.id);
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: Text('Delete', style: GoogleFonts.outfit(color: AppTheme.neonRed)),
          ),
        ],
      ),
    );
  }
}
