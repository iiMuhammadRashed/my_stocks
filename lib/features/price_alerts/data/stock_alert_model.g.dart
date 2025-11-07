part of 'stock_alert_model.dart';

class StockAlertModelAdapter extends TypeAdapter<StockAlertModel> {
  @override
  final int typeId = 2;

  @override
  StockAlertModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return StockAlertModel(
      symbol: fields[0] as String,
      highPrice: fields[1] as double?,
      lowPrice: fields[2] as double?,
      active: fields[3] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, StockAlertModel obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.symbol)
      ..writeByte(1)
      ..write(obj.highPrice)
      ..writeByte(2)
      ..write(obj.lowPrice)
      ..writeByte(3)
      ..write(obj.active);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StockAlertModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
