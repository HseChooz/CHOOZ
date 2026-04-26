import SwiftUI

struct FavoriteNotesIdleView: View {

    // MARK: - Body

    var body: some View {
        VStack(spacing: 24.0) {
            VStack(spacing: 8.0) {
                Text("Здесь пока пусто")
                    .font(.velaSans(size: 18.0, weight: .bold))
                    .foregroundStyle(Colors.Neutral.grey800)

                Text("Создайте заметку и добавьте ее в избранные, чтобы наверняка не забыть о предпочтениях своих близких")
                    .font(.velaSans(size: 14.0, weight: .bold))
                    .foregroundStyle(Colors.Neutral.grey500)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.horizontal, 52.0)
    }

}
