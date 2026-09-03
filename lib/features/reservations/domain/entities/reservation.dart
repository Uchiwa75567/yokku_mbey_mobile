enum ReservationStatus { newRequest, accepted, pending }

class Reservation {
  const Reservation({
    required this.id,
    required this.buyerName,
    required this.productName,
    required this.quantityKg,
    required this.unitPrice,
    required this.depositAmount,
    required this.paymentDetails,
    required this.status,
    required this.transactionCount,
    required this.recoveryMode,
  });

  final String id;
  final String buyerName;
  final String productName;
  final int quantityKg;
  final int unitPrice;
  final int depositAmount;
  final String paymentDetails;
  final ReservationStatus status;
  final int transactionCount;
  final String recoveryMode;

  int get totalAmount => quantityKg * unitPrice;
  int get remainingAmount => totalAmount - depositAmount;
  int get commissionAmount => (totalAmount * 0.05).round();
  int get estimatedNetAmount => totalAmount - commissionAmount;
}
