import 'transaction.dart';
import 'repayment.dart';

sealed class ActivityEntry {
  DateTime get createdAt;
}

final class PurchaseEntry extends ActivityEntry {
  final Transaction transaction;
  PurchaseEntry(this.transaction);

  @override
  DateTime get createdAt => transaction.createdAt;
}

final class RepaymentEntry extends ActivityEntry {
  final Repayment repayment;
  RepaymentEntry(this.repayment);

  @override
  DateTime get createdAt => repayment.createdAt;
}
