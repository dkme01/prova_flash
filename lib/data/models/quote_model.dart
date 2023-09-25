class QuoteModel {
  final String code;
  final String name;
  final DateTime createdAt;
  final double ask;
  final double bid;

  QuoteModel({
    required this.code,
    required this.name,
    required this.createdAt,
    required this.ask,
    required this.bid,
  });

  factory QuoteModel.fromMap(Map<String, dynamic> map) {
    return QuoteModel(
      code: map['code'],
      name: map['name'],
      createdAt: map['createdAt'],
      ask: map['ask'] * 1.0,
      bid: map['bid'] * 1.0,
    );
  }
}
