import 'package:flutter/material.dart';
import '../commons/data/models/activity_entry.dart';
import '../commons/data/models/transaction.dart';
import '../commons/data/models/repayment.dart';
import '../core/services/transaction_service.dart';
import '../core/services/repayment_service.dart';
import '../core/network/api_exception.dart';

class ActivityProvider extends ChangeNotifier {
  final TransactionService _txService;
  final RepaymentService _repaymentService;

  ActivityProvider(this._txService, this._repaymentService);

  List<ActivityEntry> _entries = [];
  bool _loading = false;
  String? _error;

  List<ActivityEntry> get entries => _entries;
  bool get loading => _loading;
  String? get error => _error;

  Future<void> load({int? farmerId}) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final txFuture = _txService.getPaged(page: 1, perPage: 100, farmerId: farmerId);
      final repFuture = _repaymentService.getAll(farmerId: farmerId);

      final PagedResult<Transaction> txPage;
      final List<Repayment> repayments;
      (txPage, repayments) = await (txFuture, repFuture).wait;

      _entries = [
        ...txPage.items.map(PurchaseEntry.new),
        ...repayments.map(RepaymentEntry.new),
      ]..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      _error = null;
    } on ApiException catch (e) {
      _error = e.message;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> reload({int? farmerId}) => load(farmerId: farmerId);
}
