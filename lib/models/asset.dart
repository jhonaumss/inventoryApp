class Asset {
  final int? id;
  final String name;
  final String type;
  final String serial;
  final String? imagePath; // file path to the asset image
  final String? barcode;
  final int? assignedTo; // user id

  Asset({
    this.id,
    required this.name,
    required this.type,
    required this.serial,
    this.imagePath,
    this.barcode,
    this.assignedTo,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'serial': serial,
      'imagePath': imagePath,
      'barcode': barcode,
      'assignedTo': assignedTo,
    };
  }

  factory Asset.fromMap(Map<String, dynamic> map) {
    return Asset(
      id: map['id'],
      name: map['name'],
      type: map['type'],
      serial: map['serial'],
      imagePath: map['imagePath'],
      barcode: map['barcode'],
      assignedTo: map['assignedTo'],
    );
  }
}
