class FloosakPaymentAttemptModel {
  final int paymentAttemptId;
  final int orderId;
  final String requestId;
  final int? gatewayPurchaseId;
  final int? gatewayTransactionId;
  final String? gatewayReferenceId;
  final String status;
  final String? gatewayStatusEn;
  final String? gatewayStatusAr;
  final double? amount;
  final double? net;
  final double? fee;
  final double? gross;
  final bool requiresOtp;
  final DateTime? nextReconcileAt;

  const FloosakPaymentAttemptModel({
    required this.paymentAttemptId,
    required this.orderId,
    required this.requestId,
    this.gatewayPurchaseId,
    this.gatewayTransactionId,
    this.gatewayReferenceId,
    required this.status,
    this.gatewayStatusEn,
    this.gatewayStatusAr,
    this.amount,
    this.net,
    this.fee,
    this.gross,
    required this.requiresOtp,
    this.nextReconcileAt,
  });

  factory FloosakPaymentAttemptModel.fromJson(Map<String, dynamic> json) {
    final gatewayStatus = json['gateway_status'];
    final gatewayStatusMap = gatewayStatus is Map
        ? Map<String, dynamic>.from(gatewayStatus)
        : <String, dynamic>{};

    return FloosakPaymentAttemptModel(
      paymentAttemptId: _toInt(json['payment_attempt_id']),
      orderId: _toInt(json['order_id']),
      requestId: (json['request_id'] ?? '').toString(),
      gatewayPurchaseId: _toNullableInt(json['gateway_purchase_id']),
      gatewayTransactionId: _toNullableInt(json['gateway_transaction_id']),
      gatewayReferenceId: json['gateway_reference_id']?.toString(),
      status: (json['status'] ?? '').toString(),
      gatewayStatusEn: gatewayStatusMap['en']?.toString(),
      gatewayStatusAr: gatewayStatusMap['ar']?.toString(),
      amount: _toNullableDouble(json['amount']),
      net: _toNullableDouble(json['net']),
      fee: _toNullableDouble(json['fee']),
      gross: _toNullableDouble(json['gross']),
      requiresOtp: json['requires_otp'] == true,
      nextReconcileAt: _toNullableDateTime(json['next_reconcile_at']),
    );
  }

  bool get isCompleted => status == 'completed';

  bool get isPendingOtp => requiresOtp || status == 'pending';

  bool get isProcessing =>
      status == 'initiating' ||
      status == 'send_unknown' ||
      status == 'confirming' ||
      status == 'confirm_unknown';

  bool get isFailed => status == 'failed' || status == 'send_failed';

  static int _toInt(dynamic value) {
    return _toNullableInt(value) ?? 0;
  }

  static int? _toNullableInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }

  static double? _toNullableDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }

  static DateTime? _toNullableDateTime(dynamic value) {
    if (value == null || value.toString().isEmpty) return null;
    return DateTime.tryParse(value.toString());
  }
}
