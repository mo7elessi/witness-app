import 'package:hive/hive.dart';

class DurationAdapter extends TypeAdapter<Duration> {
  @override
  final int typeId = 2;

  @override
  Duration read(BinaryReader reader) {
    // TODO: implement read
    return const Duration();
  }

  @override
  void write(BinaryWriter writer, Duration obj) {
    // TODO: implement write
  }
}
