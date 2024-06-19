
class Asset {
  final String id;
  final String name;
  final String? locationId;
  final String? parentId;
  final String? sensorType;
  final String? status;
  final String? gatewayId;
  final String? sensorId;

  Asset({
    required this.id,
    required this.name,
    this.locationId,
    this.parentId,
    this.sensorType,
    this.status,
    this.gatewayId,
    this.sensorId,
  });

  factory Asset.fromJson(Map<String, dynamic> json) {
    return Asset(
      id: json['id'],
      name: json['name'],
      locationId: json['locationId'],
      parentId: json['parentId'],
      sensorType: json['sensorType'],
      status: json['status'],
      gatewayId: json['gatewayId'],
      sensorId: json['sensorId'],
    );
  }
}

