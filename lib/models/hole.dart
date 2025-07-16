class Hole {
  final String id;
  final int number;
  final int length;
  final int par;
  final int strokeIndex;

  Hole({
    required this.id,
    required this.number,
    required this.length,
    required this.par,
    required this.strokeIndex,
  });

  factory Hole.fromJson(Map<String, dynamic> json) {
    return Hole(
      id: json['id'],
      number: json['number'],
      length: json['length'],
      par: json['par'],
      strokeIndex: json['strokeIndex'],
    );
  }
}
