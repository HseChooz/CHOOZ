import SwiftUI

struct ProfileHeaderView: View {
    
    // MARK: - Internal Types
    
    struct Model {
        let firstName: String?
        let lastName: String?
        let isLoading: Bool
    }
    
    // MARK: - Init
    
    init(model: Model) {
        self.model = model
    }
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 16.0) {
            Circle()
                .fill(Colors.Green.green400)
                .frame(width: 85.0)
                .overlay {
                    Images.Mascotte.Joyful.v1
                        .resizable()
                        .scaledToFill()
                        .frame(width: 54.0, height: 23.0)
                }
            
            if model.isLoading {
                userNameSkeletonView
            } else {
                Text([model.firstName, model.lastName]
                    .compactMap { $0 }
                    .joined(separator: " "))
                    .lineLimit(1)
                    .font(.velaSans(size: 24.0, weight: .extraBold))
            }
        }
    }
    
    // MARK: - Private Properties
    
    private let model: Model
    
    // MARK: - Private Views
    
    private var userNameSkeletonView: some View {
        let mask = RoundedRectangle(cornerRadius: 6.0)
            .frame(width: 160.0, height: 24.0)
        
        return mask
            .foregroundStyle(Colors.Neutral.grey200)
            .shimmering(mask: mask)
    }
}
