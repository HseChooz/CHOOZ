import SwiftUI

struct SocialProfileLoadedView: View {
    
    // MARK: - Init
    
    init(model: SocialProfileLoadedModel, eventsHandler: SocialProfileLoadedViewEventsHandler) {
        self.model = model
        self.eventsHandler = eventsHandler
    }
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 32.0) {
            ProfileHeaderView(model: model.header)
            
            if !model.isEmpty {
                aiInsightsButtonView
            }
            
            if model.isEmpty {
                emptyStateView
            } else {
                wishlistView
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Colors.Common.white)
        .sheet(isPresented: Binding(
            get: { eventsHandler.isAIInsightsPresented },
            set: { eventsHandler.isAIInsightsPresented = $0 }
        )) {
            AIInsightsView(viewModel: eventsHandler.makeAIInsightsViewModel())
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
    }
    
    // MARK: - Private Types
    
    private enum Static {
        
        static let columns = [
            GridItem(.adaptive(minimum: 160.0, maximum: 220.0), spacing: 16.0)
        ]
        
    }
    
    // MARK: - Private Properties
    
    private let model: SocialProfileLoadedModel
    private let eventsHandler: SocialProfileLoadedViewEventsHandler
    
    // MARK: - Private Views
    
    private var aiInsightsButtonView: some View {
        Button(action: { eventsHandler.isAIInsightsPresented = true }) {
            HStack(spacing: 8.0) {
                Image(systemName: "sparkles")
                    .font(.system(size: 14.0, weight: .semibold))
                
                Text("AI-анализ интересов")
                    .font(.velaSans(size: 14.0, weight: .semiBold))
            }
            .foregroundStyle(Colors.Blue.blue500)
            .padding(.horizontal, 16.0)
            .padding(.vertical, 10.0)
            .background(
                RoundedRectangle(cornerRadius: 12.0)
                    .stroke(Colors.Blue.blue500, lineWidth: 1.5)
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }
    
    private var emptyStateView: some View {
        ScrollView {
            Text("Вишлист пуст")
                .font(.velaSans(size: 18.0, weight: .bold))
                .foregroundStyle(Colors.Neutral.grey800)
                .padding(.top, 41.0)
        }
        .refreshable {
            eventsHandler.refreshProfile()
        }
    }
    
    private var wishlistView: some View {
        ScrollView {
            LazyVGrid(columns: Static.columns, alignment: .leading, spacing: 14.0) {
                ForEach(model.itemCards) { item in
                    socialItemCardView(item: item)
                }
            }
        }
        .scrollIndicators(.hidden)
        .padding(.horizontal, 18.0)
        .refreshable {
            eventsHandler.refreshProfile()
        }
    }
    
    private func socialItemCardView(item: SocialProfileItemCard) -> some View {
        Button(
            action: { eventsHandler.openWishlistItem(id: item.id) },
            label: {
                VStack(alignment: .leading, spacing: 12.0) {
                    imagePlaceholderView
                        .frame(height: 193.0)
                        .overlay(alignment: .top) {
                            CachedAsyncImage(url: item.imageUrl.flatMap { URL(string: $0) }) {
                                imagePlaceholderView
                            }
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 20.0))
                    
                    VStack(alignment: .leading, spacing: 4.0) {
                        Text(item.title)
                            .font(.velaSans(size: 14.0, weight: .bold))
                            .foregroundStyle(Colors.Neutral.grey800)
                            .lineLimit(1)
                        
                        if let price = item.price,
                           let currency = item.currency {
                            Text("\(price) \(currency.symbol)")
                                .font(.velaSans(size: 14.0, weight: .bold))
                                .foregroundStyle(Colors.Neutral.grey600)
                                .lineLimit(1)
                        }
                    }
                }
                .frame(height: 254.0)
            }
        )
        .buttonStyle(ScaleButtonStyle())
    }
    
    private var imagePlaceholderView: some View {
        Colors.Neutral.grey200
    }
    
}
