class MulliganHoleScore {
  final int holeNumber;
  final int strokes;
  final bool mulligan;
  final int putts;
  final bool lady;

  MulliganHoleScore({
    required this.holeNumber,
    required this.strokes,
    required this.mulligan,
    required this.putts,
    required this.lady,
  });

  factory MulliganHoleScore.fromJson(Map<String, dynamic> json) {
    return MulliganHoleScore(
      holeNumber: json['holeNumber'] ?? 0,
      strokes: json['strokes'] ?? 0,
      mulligan: json['mulligan'] ?? false,
      putts: json['putts'] ?? 0,
      lady: json['lady'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'holeNumber': holeNumber,
      'strokes': strokes,
      'mulligan': mulligan,
      'putts': putts,
      'lady': lady,
    };
  }
}
