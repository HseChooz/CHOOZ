import SwiftUI

struct CollectionHeaderView: View {
    
    // MARK: - Internal Types
    
    struct Model: Hashable {
        let title: String
        let description: String
    }
    
    // MARK: - Init
    
    init(model: Model) {
        self.model = model
    }
    
    // MARK: - Body
    
    var body: some View {
        VStack(alignment: .leading, spacing: 3.0) {
            Text(model.title)
                .font(.velaSans(size: 24.0, weight: .bold))
                .foregroundStyle(Colors.Neutral.grey900)
                .lineLimit(1)
            
            Text(model.description)
                .font(.velaSans(size: 12.0, weight: .semiBold))
                .foregroundStyle(Colors.Neutral.grey900)
                .lineLimit(4)
        }
    }
    
    // MARK: - Private Properties
    
    private let model: Model
    
}
