part of 'stock_model.dart';

class StockModelAdapter extends TypeAdapter<StockModel> {
  @override
  final int typeId = 1;

  @override
  StockModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return StockModel(
      symbol: fields[0] as String,
      name: fields[1] as String,
      exchange: fields[2] as String,
      micCode: fields[3] as String,
      currency: fields[4] as String,
      open: fields[5] as double,
      high: fields[6] as double,
      low: fields[7] as double,
      close: fields[8] as double,
      previousClose: fields[9] as double,
      change: fields[10] as double,
      percentChange: fields[11] as double,
      isMarketOpen: fields[12] as bool,
      volume: fields[13] as double,
      averageVolume: fields[14] as double,
      datetime: fields[15] as String,
      fiftyTwoWeekHigh: fields[16] as String?,
      fiftyTwoWeekLow: fields[17] as String?,
      marketCap: fields[18] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, StockModel obj) {
    writer
      ..writeByte(19)
      ..writeByte(0)
      ..write(obj.symbol)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.exchange)
      ..writeByte(3)
      ..write(obj.micCode)
      ..writeByte(4)
      ..write(obj.currency)
      ..writeByte(5)
      ..write(obj.open)
      ..writeByte(6)
      ..write(obj.high)
      ..writeByte(7)
      ..write(obj.low)
      ..writeByte(8)
      ..write(obj.close)
      ..writeByte(9)
      ..write(obj.previousClose)
      ..writeByte(10)
      ..write(obj.change)
      ..writeByte(11)
      ..write(obj.percentChange)
      ..writeByte(12)
      ..write(obj.isMarketOpen)
      ..writeByte(13)
      ..write(obj.volume)
      ..writeByte(14)
      ..write(obj.averageVolume)
      ..writeByte(15)
      ..write(obj.datetime)
      ..writeByte(16)
      ..write(obj.fiftyTwoWeekHigh)
      ..writeByte(17)
      ..write(obj.fiftyTwoWeekLow)
      ..writeByte(18)
      ..write(obj.marketCap);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StockModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
