/// A monetary amount paired with a currency code.
class Money {
  const Money({required this.amount, required this.currency});

  final double amount;
  final String currency;

  /// Currencies offered in the currency dropdown.
  static const List<String> supportedCurrencies = <String>[
    'CHF',
    'EUR',
    'USD',
    'GBP',
    'JPY',
  ];

  String format() {
    final fixed = amount.toStringAsFixed(2);
    return '$fixed $currency';
  }

  Money copyWith({double? amount, String? currency}) {
    return Money(
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'amount': amount,
    'currency': currency,
  };

  factory Money.fromJson(Map<String, dynamic> json) {
    return Money(
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is Money && other.amount == amount && other.currency == currency;

  @override
  int get hashCode => Object.hash(amount, currency);
}
