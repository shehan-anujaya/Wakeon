import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'emergency_contact.g.dart';

@HiveType(typeId: 2)
class EmergencyContact extends Equatable {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String name;
  
  @HiveField(2)
  final String phoneNumber;
  
  @HiveField(3)
  final bool enableAutoCall;
  
  @HiveField(4)
  final bool enableAutoSms;
  
  @HiveField(5)
  final int priority;

  const EmergencyContact({
    required this.id,
    required this.name,
    required this.phoneNumber,
    this.enableAutoCall = false,
    this.enableAutoSms = true,
    this.priority = 0,
  });

  EmergencyContact copyWith({
    String? id,
    String? name,
    String? phoneNumber,
    bool? enableAutoCall,
    bool? enableAutoSms,
    int? priority,
  }) {
    return EmergencyContact(
      id: id ?? this.id,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      enableAutoCall: enableAutoCall ?? this.enableAutoCall,
      enableAutoSms: enableAutoSms ?? this.enableAutoSms,
      priority: priority ?? this.priority,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        phoneNumber,
        enableAutoCall,
        enableAutoSms,
        priority,
      ];
}
