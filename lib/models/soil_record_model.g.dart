// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'soil_record_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SoilRecordAdapter extends TypeAdapter<SoilRecord> {
  @override
  final int typeId = 1;

  @override
  SoilRecord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SoilRecord(
      id: fields[0] as String,
      userId: fields[1] as String,
      timestamp: fields[2] as DateTime,
      nitrogen: fields[3] as double,
      phosphorus: fields[4] as double,
      potassium: fields[5] as double,
      phLevel: fields[6] as double,
      moisture: fields[7] as double,
      locationName: fields[8] as String?,
      latitude: fields[9] as double?,
      longitude: fields[10] as double?,
      cropType: fields[11] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, SoilRecord obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.timestamp)
      ..writeByte(3)
      ..write(obj.nitrogen)
      ..writeByte(4)
      ..write(obj.phosphorus)
      ..writeByte(5)
      ..write(obj.potassium)
      ..writeByte(6)
      ..write(obj.phLevel)
      ..writeByte(7)
      ..write(obj.moisture)
      ..writeByte(8)
      ..write(obj.locationName)
      ..writeByte(9)
      ..write(obj.latitude)
      ..writeByte(10)
      ..write(obj.longitude)
      ..writeByte(11)
      ..write(obj.cropType);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SoilRecordAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
