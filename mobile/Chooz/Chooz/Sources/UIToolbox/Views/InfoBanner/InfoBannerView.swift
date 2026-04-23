import SwiftUI

struct InfoBannerView: View {
    
    // MARK: - Internal Types
    
    struct Model {
        let title: String
        let mainAction: @MainActor () -> Void
        let closeAction: @MainActor () -> Void
    }
    
    // MARK: - Init
    
    init(model: Model) {
        self.model = model
    }
    
    // MARK: - Body
    
    var body: some View {
        Button(
            action: model.mainAction,
            label: {
                HStack(alignment: .top, spacing: .zero) {
                    HStack(alignment: .top, spacing: 12.0) {
                        Images.Icons.human
                            .resizable()
                            .scaledToFill()
                            .frame(width: 17.0, height: 27.0)
                        
                        Text(model.title)
                            .font(.velaSans(size: 14.0, weight: .bold))
                            .foregroundStyle(Colors.Green.green1B)
                            .lineLimit(2)
                    }
                    
                    Spacer()
                    
                    Button(
                        action: model.closeAction,
                        label: {
                            Images.Icons.cross
                                .renderingMode(.template)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 24.0, height: 24.0)
                                .foregroundStyle(Colors.Green.green1B)
                        }
                    )
                }
                .padding(.vertical, 8.0)
                .padding(.horizontal, 18.0)
                .frame(height: 58.0, alignment: .top)
                .background(Colors.Green.greenEF)
                .clipShape(RoundedRectangle(cornerRadius: 14.0))
                .overlay {
                    RoundedRectangle(cornerRadius: 14.0)
                        .stroke(Colors.Green.greenC9, lineWidth: 1.0)
                }
            }
        )
        .buttonStyle(ScaleButtonStyle())
    }
    
    // MARK: - Private Properties
    
    private let model: Model
    
}
