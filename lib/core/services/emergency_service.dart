import 'package:url_launcher/url_launcher.dart';
import '../models/emergency_contact.dart';
import '../constants/app_constants.dart';

class EmergencyService {
  Future<void> sendSms({
    required List<EmergencyContact> contacts,
    required String location,
  }) async {
    try {
      final recipients = contacts
          .where((c) => c.enableAutoSms)
          .toList();

      if (recipients.isEmpty) return;

      final message = AppConstants.emergencySmsTemplate
          .replaceAll('{location}', location);

      // Send SMS to each contact using URL launcher
      for (final contact in recipients) {
        final uri = Uri(
          scheme: 'sms',
          path: contact.phoneNumber,
          queryParameters: {'body': message},
        );
        
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri);
        }
      }
    } catch (e) {
      throw Exception('Failed to send SMS: $e');
    }
  }

  Future<void> makeCall(EmergencyContact contact) async {
    try {
      final uri = Uri(scheme: 'tel', path: contact.phoneNumber);
      
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        throw Exception('Cannot make phone call');
      }
    } catch (e) {
      throw Exception('Failed to make call: $e');
    }
  }

  Future<void> triggerEmergency({
    required List<EmergencyContact> contacts,
    required String location,
  }) async {
    // Send SMS to all enabled contacts
    await sendSms(contacts: contacts, location: location);

    // Call the primary contact if auto-call is enabled
    final primaryContact = contacts
        .where((c) => c.enableAutoCall)
        .toList()
      ..sort((a, b) => b.priority.compareTo(a.priority));

    if (primaryContact.isNotEmpty) {
      await makeCall(primaryContact.first);
    }
  }
}
