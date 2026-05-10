import 'dart:async';

import 'purchase_service.dart';

class PurchaseServiceStub implements PurchaseService {
  @override
  Future<bool> purchase(ProductType product) async {
    await Future<void>.delayed(const Duration(milliseconds: 800));
    await Future<void>.delayed(const Duration(milliseconds: 1200));
    return true;
  }
}
