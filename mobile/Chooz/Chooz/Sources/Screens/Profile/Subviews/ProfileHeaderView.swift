import SwiftUI

struct ProfileHeaderView: View {
    
    // MARK: - Internal Types
    
    struct Model {
        let userName: String
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
            
            Text(model.userName)
                .lineLimit(1)
                .font(.velaSans(size: 24.0, weight: .extraBold))
        }
    }
    
    // MARK: - Private Properties
    
    private let model: Model
}
