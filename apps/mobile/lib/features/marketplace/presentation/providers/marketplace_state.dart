import '../../domain/marketplace_job_item.dart';

class MarketplaceState {
  final bool isLoading;
  final bool initialized;
  final List<MarketplaceJobItem> items;
  final String? errorMessage;

  const MarketplaceState({
    this.isLoading = false,
    this.initialized = false,
    this.items = const [],
    this.errorMessage,
  });

  MarketplaceState copyWith({
    bool? isLoading,
    bool? initialized,
    List<MarketplaceJobItem>? items,
    String? errorMessage,
    bool clearError = false,
  }) {
    return MarketplaceState(
      isLoading: isLoading ?? this.isLoading,
      initialized: initialized ?? this.initialized,
      items: items ?? this.items,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
