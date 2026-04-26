import SwiftUI

struct NoteRowView: View {
    
    // MARK: - Init
    
    init(
        model: NoteModel,
        mainAction: @escaping () -> Void,
        bookmarkAction: @escaping () -> Void
    ) {
        self.model = model
        self.mainAction = mainAction
        self.bookmarkAction = bookmarkAction
    }
    
    // MARK: - Body
    
    var body: some View {
        Button(
            action: mainAction,
            label: {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 8.0) {
                        Text(model.title)
                            .font(.velaSans(size: 16.0, weight: .bold))
                            .foregroundStyle(Colors.Neutral.grey800)
                            .lineLimit(1)
                        
                        Text(model.description)
                            .font(.velaSans(size: 12.0, weight: .semiBold))
                            .foregroundStyle(Colors.Neutral.grey500)
                            .lineLimit(1)
                    }
                    
                    Spacer()
                    
                    Button(
                        action: bookmarkAction,
                        label: {
                            bookmarkImage
                                .resizable()
                                .scaledToFill()
                                .frame(width: 17.0, height: 17.0)
                        }
                    )
                    .buttonStyle(ScaleButtonStyle())
                    .offset(y: 3.0)
                }
                .padding(.top, 20.0)
                .padding(.bottom, 24.0)
                .padding(.horizontal, 16.0)
                .frame(height: 86.0)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Colors.Common.white)
                .clipShape(RoundedRectangle(cornerRadius: 20.0))
                .overlay {
                    RoundedRectangle(cornerRadius: 20.0)
                        .stroke(Colors.Neutral.grey200)
                }
            }
        )
        .buttonStyle(ScaleButtonStyle())
    }
    
    // MARK: - Private Properties
    
    private let model: NoteModel
    private let mainAction: @MainActor () -> Void
    private let bookmarkAction: @MainActor () -> Void
    
    // MARK: - Private Views
    
    @ViewBuilder
    private var bookmarkImage: Image {
        model.isFavorite ? Images.Icons.bookmarked : Images.Icons.bookmark
    }
    
}
