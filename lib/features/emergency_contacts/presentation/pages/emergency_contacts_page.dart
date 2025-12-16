import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';
import '../../providers/emergency_contacts_provider.dart';
import '../../../../core/models/emergency_contact.dart';
import '../../../../core/theme/app_theme.dart';

class EmergencyContactsPage extends ConsumerWidget {
  const EmergencyContactsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contacts = ref.watch(emergencyContactsProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundBlack,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 120.0),
        child: FloatingActionButton.extended(
          onPressed: () => _showAddContactDialog(context, ref),
          backgroundColor: AppTheme.neonGreen,
          foregroundColor: AppTheme.backgroundBlack,
          icon: const Icon(Icons.person_add_rounded),
          label: Text(
            'ADD CONTACT',
            style: GoogleFonts.outfit(
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.neonRed.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.emergency_share_outlined,
                        color: AppTheme.neonRed,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'EMERGENCY',
                          style: GoogleFonts.outfit(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                            letterSpacing: 1.0,
                          ),
                        ),
                        Text(
                          'Manage your guardians',
                          style: GoogleFonts.outfit(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            contacts.isEmpty
                ? SliverFillRemaining(
                    child: _buildEmptyState(context),
                  )
                : SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 8,
                          ),
                          child: _buildContactCard(
                            context,
                            ref,
                            contacts[index],
                          ),
                        );
                      },
                      childCount: contacts.length,
                    ),
                  ),

            const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.surfaceDark,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.contact_phone_outlined,
              size: 64,
              color: AppTheme.textTertiary.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No Contacts Yet',
            style: GoogleFonts.outfit(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48.0),
            child: Text(
              'Add trusted contacts who can be notified in case of emergency.',
              style: GoogleFonts.outfit(
                fontSize: 14,
                color: AppTheme.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactCard(
    BuildContext context,
    WidgetRef ref,
    EmergencyContact contact,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppTheme.borderColor,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppTheme.neonGreen.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    contact.name.isNotEmpty ? contact.name[0].toUpperCase() : '?',
                    style: GoogleFonts.outfit(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.neonGreen,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      contact.name,
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    Text(
                      contact.phoneNumber,
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        color: AppTheme.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => _showDeleteConfirmation(context, ref, contact),
                icon: const Icon(Icons.delete_outline_rounded),
                color: AppTheme.neonRed,
                style: IconButton.styleFrom(
                  backgroundColor: AppTheme.neonRed.withOpacity(0.1),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppTheme.backgroundBlack,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildToggleOption(
                    context,
                    ref,
                    contact,
                    'Auto SMS',
                    contact.enableAutoSms,
                    Icons.message_rounded,
                    (value) {
                      ref.read(emergencyContactsProvider.notifier).updateContact(
                            contact.copyWith(enableAutoSms: value),
                          );
                    },
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: _buildToggleOption(
                    context,
                    ref,
                    contact,
                    'Auto Call',
                    contact.enableAutoCall,
                    Icons.phone_rounded,
                    (value) {
                      ref.read(emergencyContactsProvider.notifier).updateContact(
                            contact.copyWith(enableAutoCall: value),
                          );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleOption(
    BuildContext context,
    WidgetRef ref,
    EmergencyContact contact,
    String label,
    bool value,
    IconData icon,
    Function(bool) onChanged,
  ) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: value ? AppTheme.surfaceLight : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: value
              ? Border.all(color: AppTheme.neonGreen.withOpacity(0.5))
              : Border.all(color: Colors.transparent),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: value ? AppTheme.neonGreen : AppTheme.textTertiary,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.outfit(
                fontSize: 13,
                fontWeight: value ? FontWeight.bold : FontWeight.w500,
                color: value ? AppTheme.textPrimary : AppTheme.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddContactDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    bool enableSms = true;
    bool enableCall = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: AppTheme.surfaceDark,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: const BorderSide(color: AppTheme.borderColor),
          ),
          title: Text(
            'New Contact',
            style: GoogleFonts.outfit(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  style: GoogleFonts.outfit(color: AppTheme.textPrimary),
                  decoration: InputDecoration(
                    labelText: 'Name',
                    prefixIcon: const Icon(Icons.person_outline_rounded),
                    labelStyle: GoogleFonts.outfit(color: AppTheme.textTertiary),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  style: GoogleFonts.outfit(color: AppTheme.textPrimary),
                  decoration: InputDecoration(
                    labelText: 'Phone Number',
                    prefixIcon: const Icon(Icons.phone_outlined),
                    labelStyle: GoogleFonts.outfit(color: AppTheme.textTertiary),
                  ),
                ),
                const SizedBox(height: 24),
                SwitchListTile(
                  title: Text(
                    'Auto SMS',
                    style: GoogleFonts.outfit(color: AppTheme.textPrimary),
                  ),
                  value: enableSms,
                  onChanged: (value) => setState(() => enableSms = value),
                  activeColor: AppTheme.neonGreen,
                  activeTrackColor: AppTheme.neonGreen.withOpacity(0.3),
                  inactiveThumbColor: AppTheme.textTertiary,
                ),
                SwitchListTile(
                  title: Text(
                    'Auto Call',
                    style: GoogleFonts.outfit(color: AppTheme.textPrimary),
                  ),
                  value: enableCall,
                  onChanged: (value) => setState(() => enableCall = value),
                  activeColor: AppTheme.neonGreen,
                  activeTrackColor: AppTheme.neonGreen.withOpacity(0.3),
                  inactiveThumbColor: AppTheme.textTertiary,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'CANCEL',
                style: GoogleFonts.outfit(
                  color: AppTheme.textTertiary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isNotEmpty &&
                    phoneController.text.isNotEmpty) {
                  final contact = ref
                      .read(emergencyContactsProvider.notifier)
                      .createNewContact(
                        name: nameController.text,
                        phoneNumber: phoneController.text,
                        enableAutoCall: enableCall,
                        enableAutoSms: enableSms,
                      );
                  
                  ref.read(emergencyContactsProvider.notifier).addContact(contact);
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.neonGreen,
                foregroundColor: AppTheme.backgroundBlack,
              ),
              child: Text(
                'ADD',
                style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    WidgetRef ref,
    EmergencyContact contact,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: AppTheme.borderColor),
        ),
        title: Text(
          'Delete Contact',
          style: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        content: Text(
          'Remove ${contact.name} from emergency contacts?',
          style: GoogleFonts.outfit(
            color: AppTheme.textSecondary,
            fontSize: 16,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'CANCEL',
              style: GoogleFonts.outfit(
                color: AppTheme.textTertiary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(emergencyContactsProvider.notifier).removeContact(contact.id);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.neonRed,
              foregroundColor: Colors.white,
            ),
            child: Text(
              'DELETE',
              style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
