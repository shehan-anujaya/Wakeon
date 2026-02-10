import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../../core/models/emergency_contact.dart';
import '../../../core/services/emergency_service.dart';

final emergencyServiceProvider = Provider<EmergencyService>((ref) {
  return EmergencyService();
});

class EmergencyContactsRepository {
  static const String _boxName = 'emergency_contacts';
  Box<EmergencyContact>? _box;

  Future<Box<EmergencyContact>> _getBox() async {
    _box ??= await Hive.openBox<EmergencyContact>(_boxName);
    return _box!;
  }

  Future<List<EmergencyContact>> getAll() async {
    final box = await _getBox();
    return box.values.toList()..sort((a, b) => a.priority.compareTo(b.priority));
  }

  Future<EmergencyContact?> getById(String id) async {
    final box = await _getBox();
    return box.get(id);
  }

  Future<void> add(EmergencyContact contact) async {
    final box = await _getBox();
    await box.put(contact.id, contact);
  }

  Future<void> update(EmergencyContact contact) async {
    final box = await _getBox();
    await box.put(contact.id, contact);
  }

  Future<void> delete(String id) async {
    final box = await _getBox();
    await box.delete(id);
  }
}

final emergencyContactsRepositoryProvider =
    Provider<EmergencyContactsRepository>((ref) {
  return EmergencyContactsRepository();
});

final emergencyContactsProvider = StateNotifierProvider<
    EmergencyContactsNotifier, AsyncValue<List<EmergencyContact>>>((ref) {
  final repository = ref.watch(emergencyContactsRepositoryProvider);
  return EmergencyContactsNotifier(repository);
});

class EmergencyContactsNotifier
    extends StateNotifier<AsyncValue<List<EmergencyContact>>> {
  final EmergencyContactsRepository _repository;

  EmergencyContactsNotifier(this._repository)
      : super(const AsyncValue.loading()) {
    _loadContacts();
  }

  Future<void> _loadContacts() async {
    try {
      final contacts = await _repository.getAll();
      state = AsyncValue.data(contacts);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    await _loadContacts();
  }

  Future<void> addContact(EmergencyContact contact) async {
    try {
      await _repository.add(contact);
      state = state.whenData((contacts) => [...contacts, contact]
        ..sort((a, b) => a.priority.compareTo(b.priority)));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateContact(EmergencyContact contact) async {
    try {
      await _repository.update(contact);
      state = state.whenData((contacts) => [
            for (final c in contacts)
              if (c.id == contact.id) contact else c
          ]);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> removeContact(String id) async {
    try {
      await _repository.delete(id);
      state = state.whenData(
          (contacts) => contacts.where((c) => c.id != id).toList());
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  EmergencyContact createNewContact({
    required String name,
    required String phoneNumber,
    bool enableAutoCall = false,
    bool enableAutoSms = true,
  }) {
    final currentList = state.valueOrNull ?? [];
    return EmergencyContact(
      id: const Uuid().v4(),
      name: name,
      phoneNumber: phoneNumber,
      enableAutoCall: enableAutoCall,
      enableAutoSms: enableAutoSms,
      priority: currentList.length,
    );
  }
}
