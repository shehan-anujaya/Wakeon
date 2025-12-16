import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../core/models/emergency_contact.dart';
import '../../../core/services/emergency_service.dart';

final emergencyServiceProvider = Provider<EmergencyService>((ref) {
  return EmergencyService();
});

final emergencyContactsProvider = StateNotifierProvider<EmergencyContactsNotifier, List<EmergencyContact>>((ref) {
  return EmergencyContactsNotifier();
});

class EmergencyContactsNotifier extends StateNotifier<List<EmergencyContact>> {
  EmergencyContactsNotifier() : super([]);

  void addContact(EmergencyContact contact) {
    state = [...state, contact];
  }

  void updateContact(EmergencyContact contact) {
    state = [
      for (final c in state)
        if (c.id == contact.id) contact else c
    ];
  }

  void removeContact(String id) {
    state = state.where((c) => c.id != id).toList();
  }

  EmergencyContact createNewContact({
    required String name,
    required String phoneNumber,
    bool enableAutoCall = false,
    bool enableAutoSms = true,
  }) {
    return EmergencyContact(
      id: const Uuid().v4(),
      name: name,
      phoneNumber: phoneNumber,
      enableAutoCall: enableAutoCall,
      enableAutoSms: enableAutoSms,
      priority: state.length,
    );
  }
}
