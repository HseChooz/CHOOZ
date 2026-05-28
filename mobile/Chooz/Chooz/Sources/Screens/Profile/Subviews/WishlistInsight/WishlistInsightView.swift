import SwiftUI

struct WishlistInsightView: View {

    // MARK: - Init

    init(viewModel: WishlistInsightViewModel) {
        self.viewModel = viewModel
    }

    // MARK: - Body

    var body: some View {
        VStack(spacing: 24.0) {
            headerView

            contentView

            Spacer()
        }
        .padding(.horizontal, 20.0)
        .padding(.top, 24.0)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Colors.Common.white)
        .task {
            await viewModel.generate()
        }
    }

    // MARK: - Private Properties

    private let viewModel: WishlistInsightViewModel

    // MARK: - Private Views

    private var headerView: some View {
        HStack(spacing: 8.0) {
            Images.Icons.sparkle
                .foregroundStyle(Colors.Blue.blue500)
                .font(.system(size: 20.0, weight: .medium))

            Text("AI-анализ интересов")
                .font(.velaSans(size: 20.0, weight: .bold))
                .foregroundStyle(Colors.Neutral.grey800)

            Spacer()
        }
    }

    @ViewBuilder
    private var contentView: some View {
        switch viewModel.state {
        case .idle, .loading:
            loadingView
        case .streaming, .generated:
            resultView
        case .error:
            errorView
        }
    }

    private var loadingView: some View {
        VStack(spacing: 16.0) {
            ForEach(0..<3, id: \.self) { _ in
                let mask = RoundedRectangle(cornerRadius: 6.0)
                    .frame(height: 16.0)

                mask
                    .foregroundStyle(Colors.Neutral.grey200)
                    .shimmering(mask: mask)
            }
        }
    }

    private var resultView: some View {
        VStack(alignment: .leading, spacing: 16.0) {
            Text(viewModel.displayText)
                .font(.velaSans(size: 16.0, weight: .regular))
                .foregroundStyle(Colors.Neutral.grey700)
                .lineSpacing(4.0)
                .frame(maxWidth: .infinity, alignment: .leading)

            if viewModel.isStreaming {
                typingIndicatorView
            }
        }
    }

    private var typingIndicatorView: some View {
        HStack(spacing: 4.0) {
            ForEach(0..<3, id: \.self) { index in
                Circle()
                    .fill(Colors.Blue.blue300)
                    .frame(width: 6.0, height: 6.0)
                    .opacity(dotOpacity(for: index))
                    .animation(
                        .easeInOut(duration: 0.6)
                            .repeatForever()
                            .delay(Double(index) * 0.2),
                        value: viewModel.isStreaming
                    )
            }
        }
    }

    private var errorView: some View {
        VStack(spacing: 16.0) {
            Text(viewModel.displayText)
                .font(.velaSans(size: 14.0, weight: .regular))
                .foregroundStyle(Colors.Red.red500)
                .multilineTextAlignment(.center)

            Button(action: {
                Task { await viewModel.retry() }
            }) {
                Text("Повторить")
                    .font(.velaSans(size: 14.0, weight: .semiBold))
                    .foregroundStyle(Colors.Common.white)
                    .padding(.horizontal, 24.0)
                    .padding(.vertical, 12.0)
                    .background(Colors.Blue.blue500)
                    .clipShape(RoundedRectangle(cornerRadius: 12.0))
            }
            .buttonStyle(ScaleButtonStyle())
        }
    }

    // MARK: - Private Methods

    private func dotOpacity(for index: Int) -> Double {
        viewModel.isStreaming ? 1.0 : 0.3
    }
}
