import 'dart:convert';
import 'package:hive/hive.dart';
import '../models/salary_settlement_model.dart';

abstract class SalaryLocalDataSource {
  Future<void> cacheSettlements(int maidId, List<SalarySettlementModel> settlements);
  Future<List<SalarySettlementModel>> getCachedSettlements(int maidId);
  Future<void> cacheLatestSettlement(SalarySettlementModel settlement);
}

class SalaryLocalDataSourceImpl implements SalaryLocalDataSource {
  static const String boxName = 'salary_settlements_cache';

  @override
  Future<void> cacheSettlements(int maidId, List<SalarySettlementModel> settlements) async {
    final box = await Hive.openBox<String>(boxName);
    final jsonList = settlements.map((s) => s.toJson()).toList();
    await box.put('maid_$maidId', jsonEncode(jsonList));
  }

  @override
  Future<List<SalarySettlementModel>> getCachedSettlements(int maidId) async {
    final box = await Hive.openBox<String>(boxName);
    final str = box.get('maid_$maidId');
    if (str != null) {
      final decoded = jsonDecode(str) as List<dynamic>;
      return decoded.map((e) => SalarySettlementModel.fromJson(e as Map<String, dynamic>)).toList();
    }
    return [];
  }

  @override
  Future<void> cacheLatestSettlement(SalarySettlementModel settlement) async {
    final box = await Hive.openBox<String>(boxName);
    await box.put('receipt_${settlement.id}', jsonEncode(settlement.toJson()));
  }
}
