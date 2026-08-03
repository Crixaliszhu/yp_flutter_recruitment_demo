import '../../../core/view_model/base_vm.dart';
import '../ui_state/market_detail_us.dart';

/// 集市二级页的 ViewModel。
class MarketDetailVM extends BaseVM<MarketDetailUS> {
  MarketDetailVM({required String skuId})
    : super(MarketDetailUS.initial(skuId));

  void changePrice() {
    final nextOperationCount = state.operationCount + 1;
    final nextPrice = nextOperationCount.isEven ? '¥128' : '¥98';
    safeEmit(
      state.copyWith(
        price: MarketPriceUS(
          priceText: nextPrice,
          discountText: '第 $nextOperationCount 次价格状态变化',
        ),
        operationCount: nextOperationCount,
      ),
    );
  }

  void reduceStock() {
    final nextCount = state.stock.count > 0 ? state.stock.count - 1 : 0;
    safeEmit(
      state.copyWith(
        stock: MarketStockUS(
          count: nextCount,
          warningText: nextCount < 10 ? '库存紧张' : '库存充足',
        ),
        operationCount: state.operationCount + 1,
      ),
    );
  }

  void toggleFilter() {
    safeEmit(
      state.copyWith(
        filter: MarketFilterUS(
          keyword: state.filter.keyword,
          onlyAvailable: !state.filter.onlyAvailable,
        ),
        operationCount: state.operationCount + 1,
      ),
    );
  }
}
