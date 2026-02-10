import 'package:hive/hive.dart';

/// Custom Hive adapter for Duration type since Hive doesn't support it natively
class DurationAdapter extends TypeAdapter<Duration> {
  @override
  final int typeId = 11; // Use a unique typeId not used by other adapters

  @override
  Duration read(BinaryReader reader) {
    final microseconds = reader.readInt();
    return Duration(microseconds: microseconds);
  }

  @override
  void write(BinaryWriter writer, Duration obj) {
    writer.writeInt(obj.inMicroseconds);
  }
}
