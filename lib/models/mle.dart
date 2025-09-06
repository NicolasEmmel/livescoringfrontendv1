class MLE {
  final String name;
  final String gender;
  final int drunkBackClubs;
  final int ladyCount;
  final int putts;
  final int strokes;
  final int thru;
  final int brutto;
  final int netto;
  final int mulligans;

  MLE({
    required this.name,
    required this.gender,
    required this.drunkBackClubs,
    required this.ladyCount,
    required this.putts,
    required this.strokes,
    required this.thru,
    required this.brutto,
    required this.netto,
    required this.mulligans,
  });

  factory MLE.fromJson(Map<String, dynamic> json) {
    return MLE(
      name: json['name'] ?? "",
      gender: json['gender'] ?? "",
      drunkBackClubs: json['drunkBackClubs'] ?? 0,
      ladyCount: json['ladyCount'] ?? 0,
      putts: json['putts'] ?? 0,
      strokes: json['strokes'] ?? 0,
      thru: json['thru'] ?? 0,
      brutto: json['brutto'] ?? 0,
      netto: json['netto'] ?? 0,
      mulligans: json['mulligans'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'gender': gender,
      'drunkBackClubs': drunkBackClubs,
      'ladyCount': ladyCount,
      'putts': putts,
      'strokes': strokes,
      'thru': thru,
      'brutto': brutto,
      'netto': netto,
      'mulligans': mulligans,
    };
  }
}
