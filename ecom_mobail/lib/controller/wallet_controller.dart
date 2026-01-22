import 'package:get/get.dart';
import 'package:nice/model/wallet_model.dart';

class WalletController extends GetxController {
  // قائمة العمليات المالية (Observable)
  var transactions = <TransactionModel>[
    TransactionModel(title: 'إيداع رصيد', date: '20-12-2025', amount: 50000, isCredit: true),
    TransactionModel(title: 'شراء منتج #12345', date: '25-12-2025', amount: -15000, isCredit: false),
    TransactionModel(title: 'استرجاع منتج #12322', date: '26-12-2025', amount: 4500, isCredit: true),
  ].obs;

  // حساب الرصيد الحالي تلقائياً (Computed Property)
  double get currentBalance => transactions.fold(0.0, (sum, item) => sum + item.amount);

  // دالة لإضافة عملية جديدة (مثلاً عند الشحن)
  void addTransaction(TransactionModel transaction) {
    transactions.add(transaction);
  }
}