/// 集市二级页顶部商品状态。
class MarketHeaderUS {
  const MarketHeaderUS({required this.skuId, required this.title});

  final String skuId;
  final String title;

  @override
  bool operator ==(Object other) {
    return other is MarketHeaderUS &&
        other.skuId == skuId &&
        other.title == title;
  }

  @override
  int get hashCode => Object.hash(skuId, title);
}

/// 集市二级页价格状态。
class MarketPriceUS {
  const MarketPriceUS({required this.priceText, required this.discountText});

  final String priceText;
  final String discountText;

  @override
  bool operator ==(Object other) {
    return other is MarketPriceUS &&
        other.priceText == priceText &&
        other.discountText == discountText;
  }

  @override
  int get hashCode => Object.hash(priceText, discountText);
}

/// 集市二级页库存状态。
class MarketStockUS {
  const MarketStockUS({required this.count, required this.warningText});

  final int count;
  final String warningText;

  @override
  bool operator ==(Object other) {
    return other is MarketStockUS &&
        other.count == count &&
        other.warningText == warningText;
  }

  @override
  int get hashCode => Object.hash(count, warningText);
}

/// 集市二级页筛选状态。
class MarketFilterUS {
  const MarketFilterUS({required this.keyword, required this.onlyAvailable});

  final String keyword;
  final bool onlyAvailable;

  @override
  bool operator ==(Object other) {
    return other is MarketFilterUS &&
        other.keyword == keyword &&
        other.onlyAvailable == onlyAvailable;
  }

  @override
  int get hashCode => Object.hash(keyword, onlyAvailable);
}

/// 集市二级页的组合 UIState。
///
/// 一个页面可以只有一个主 UIState，但主 UIState 内可以组合多个相互独立的子状态。
class MarketDetailUS {
  const MarketDetailUS({
    required this.header,
    required this.price,
    required this.stock,
    required this.filter,
    required this.operationCount,
  });

  factory MarketDetailUS.initial(String skuId) {
    return MarketDetailUS(
      header: MarketHeaderUS(skuId: skuId, title: '曝光提升服务包'),
      price: const MarketPriceUS(priceText: '¥128', discountText: '新客 8 折'),
      stock: const MarketStockUS(count: 36, warningText: '库存充足'),
      filter: const MarketFilterUS(keyword: '找工人曝光', onlyAvailable: true),
      operationCount: 0,
    );
  }

  final MarketHeaderUS header;
  final MarketPriceUS price;
  final MarketStockUS stock;
  final MarketFilterUS filter;
  final int operationCount;

  @override
  bool operator ==(Object other) {
    return other is MarketDetailUS &&
        other.header == header &&
        other.price == price &&
        other.stock == stock &&
        other.filter == filter &&
        other.operationCount == operationCount;
  }

  @override
  int get hashCode {
    return Object.hash(header, price, stock, filter, operationCount);
  }

  MarketDetailUS copyWith({
    MarketHeaderUS? header,
    MarketPriceUS? price,
    MarketStockUS? stock,
    MarketFilterUS? filter,
    int? operationCount,
  }) {
    return MarketDetailUS(
      header: header ?? this.header,
      price: price ?? this.price,
      stock: stock ?? this.stock,
      filter: filter ?? this.filter,
      operationCount: operationCount ?? this.operationCount,
    );
  }
}
