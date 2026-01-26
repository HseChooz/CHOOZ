import SwiftUI

struct ToastView: View {
    
    // MARK: - Init
    
    init(model: ToastModel, onDismiss: @escaping () -> Void) {
        self.model = model
        self.onDismiss = onDismiss
    }
    
    // MARK: - Body
    
    var body: some View {
        HStack(alignment: .top, spacing: .zero) {
            model.icon
                .resizable()
                .scaledToFill()
                .frame(width: 24.0, height: 24.0)
            
            VStack(alignment: .leading, spacing: .zero) {
                Text(model.title)
                    .font(.velaSans(size: 14.0, weight: .bold))
                    .foregroundStyle(Colors.Common.white)
                    .lineLimit(1)
                
                if let subtitle = model.subtitle {
                    Text(subtitle)
                        .font(.velaSans(size: 12.0, weight: .bold))
                        .foregroundStyle(model.subtitleColor)
                        .lineLimit(2)
                }
            }
            .padding(.leading, 4.0)
            
            Spacer()
            
            Button(action: onDismiss) {
                Images.Icons.cross
                    .resizable()
                    .scaledToFill()
                    .frame(width: 24.0, height: 24.0)
            }
            .padding(.bottom, 3.0)
            .frame(width: 24.0, height: 24.0)
        }
        .padding(.vertical, 12.0)
        .padding(.horizontal, 16.0)
        .frame(width: 330.0)
        .background(model.backgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: 20.0))
    }
    
    // MARK: - Private Properties
    
    private let model: ToastModel
    private let onDismiss: () -> Void
}

#Preview {
    ToastView(model: .info(title: "Информация", subtitle: "Дополнительная информация"), onDismiss: {})
}
