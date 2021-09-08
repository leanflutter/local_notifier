import 'dart:ui';

class Display {
  // Unique identifier associated with the display.
  num id;
  // display name
  String name;
  Size size;

  Display({
    required this.id,
    required this.name,
    required this.size,
  });

  factory Display.fromJson(Map<String, dynamic> json) {
    return Display(
      id: json['id'],
      name: json['name'],
      size: Size(
        json['size']['width'],
        json['size']['height'],
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'size': {
        'width': size.width,
        'height': size.height,
      },
    };
  }
}
