import SwiftUI

struct AIInsightsView: View {

    // MARK: - Init

    init(viewModel: AIInsightsViewModel) {
        self.viewModel = viewModel
    }

    // MARK: - Body

    var body: some View {
        VStack(spacing: .zero) {
            headerView

            Divider()
                .padding(.horizontal, 20.0)

            contentView
        }
        .background(Colors.Common.white)
        .onAppear {
            viewModel.generateInsights()
        }
        .onDisappear {
            viewModel.cancelGeneration()
        }
    }

    // MARK: - Private Properties

    @Bindable
    private var viewModel: AIInsightsViewModel

    // MARK: - Private Views

    private var headerView: some View {
        HStack {
            Image(systemName: "sparkles")
                .font(.system(size: 20.0, weight: .semibold))
                .foregroundStyle(Colors.Blue.blue500)

            Text("AI-анализ интересов")
                .font(.velaSans(size: 18.0, weight: .bold))
                .foregroundStyle(Colors.Neutral.grey800)

            Spacer()
        }
        .padding(.horizontal, 20.0)
        .padding(.vertical, 16.0)
    }

    @ViewBuilder
    private var contentView: some View {
        switch viewModel.state {
        case .loading:
            loadingView
        case .generating:
            generatingView
        case .completed:
            completedView
        case .error(let message):
            errorView(message: message)
        case .emptyWishlist:
            emptyWishlistView
        case .modelNotAvailable:
            modelNotAvailableView
        case .languageNotSupported:
            languageNotSupportedView
        }
    }

    private var loadingView: some View {
        VStack(spacing: 16.0) {
            Spacer()

            ProgressView()
                .controlSize(.large)

            Text("Анализирую вишлист...")
                .font(.velaSans(size: 16.0, weight: .medium))
                .foregroundStyle(Colors.Neutral.grey600)

            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 20.0)
    }

    private var generatingView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16.0) {
                Text(viewModel.generatedText)
                    .font(.velaSans(size: 16.0, weight: .regular))
                    .foregroundStyle(Colors.Neutral.grey800)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .animation(.easeIn(duration: 0.1), value: viewModel.generatedText)

                typingIndicatorView
            }
            .padding(.horizontal, 20.0)
            .padding(.vertical, 16.0)
        }
        .scrollIndicators(.hidden)
    }

    private var completedView: some View {
        VStack(spacing: 20.0) {
            ScrollView {
                Text(viewModel.generatedText)
                    .font(.velaSans(size: 16.0, weight: .regular))
                    .foregroundStyle(Colors.Neutral.grey800)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20.0)
                    .padding(.vertical, 16.0)
            }
            .scrollIndicators(.hidden)

            regenerateButtonView
                .padding(.horizontal, 20.0)
                .padding(.bottom, 16.0)
        }
    }

    private func errorView(message: String) -> some View {
        VStack(spacing: 16.0) {
            Spacer()

            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 40.0))
                .foregroundStyle(Colors.Red.red500)

            Text("Не удалось сгенерировать анализ")
                .font(.velaSans(size: 16.0, weight: .bold))
                .foregroundStyle(Colors.Neutral.grey800)

            Text(message)
                .font(.velaSans(size: 14.0, weight: .regular))
                .foregroundStyle(Colors.Neutral.grey600)
                .multilineTextAlignment(.center)

            MainActionButton(
                title: "Попробовать снова",
                backgroundColor: Colors.Common.white,
                foregroundColor: Colors.Blue.blue500,
                action: viewModel.regenerate
            )
            .padding(.horizontal, 40.0)

            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 20.0)
    }

    private var modelNotAvailableView: some View {
        VStack(spacing: 16.0) {
            Spacer()

            Image(systemName: "apple.intelligence")
                .font(.system(size: 40.0))
                .foregroundStyle(Colors.Neutral.grey400)

            Text("Apple Intelligence недоступен")
                .font(.velaSans(size: 16.0, weight: .bold))
                .foregroundStyle(Colors.Neutral.grey800)

            Text("Включите Apple Intelligence в Настройках, чтобы использовать AI-анализ")
                .font(.velaSans(size: 14.0, weight: .regular))
                .foregroundStyle(Colors.Neutral.grey600)
                .multilineTextAlignment(.center)

            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 20.0)
    }

    private var languageNotSupportedView: some View {
        VStack(spacing: 16.0) {
            Spacer()

            Image(systemName: "globe")
                .font(.system(size: 40.0))
                .foregroundStyle(Colors.Neutral.grey400)

            Text("Язык не поддерживается")
                .font(.velaSans(size: 16.0, weight: .bold))
                .foregroundStyle(Colors.Neutral.grey800)

            Text("Apple Intelligence пока не поддерживает русский язык. Установите язык Siri на английский в Настройках → Apple Intelligence и Siri → Язык")
                .font(.velaSans(size: 14.0, weight: .regular))
                .foregroundStyle(Colors.Neutral.grey600)
                .multilineTextAlignment(.center)

            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 20.0)
    }

    private var emptyWishlistView: some View {
        VStack(spacing: 16.0) {
            Spacer()

            Image(systemName: "list.star")
                .font(.system(size: 40.0))
                .foregroundStyle(Colors.Neutral.grey400)

            Text("Вишлист пуст")
                .font(.velaSans(size: 16.0, weight: .bold))
                .foregroundStyle(Colors.Neutral.grey800)

            Text("Добавьте желания, чтобы ИИ мог проанализировать интересы")
                .font(.velaSans(size: 14.0, weight: .regular))
                .foregroundStyle(Colors.Neutral.grey600)
                .multilineTextAlignment(.center)

            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 20.0)
    }

    private var typingIndicatorView: some View {
        HStack(spacing: 4.0) {
            ForEach(0..<3, id: \.self) { index in
                Circle()
                    .fill(Colors.Blue.blue500)
                    .frame(width: 6.0, height: 6.0)
                    .opacity(typingDotOpacity(for: index))
                    .animation(
                        .easeInOut(duration: 0.6)
                            .repeatForever(autoreverses: true)
                            .delay(Double(index) * 0.2),
                        value: viewModel.state
                    )
            }
        }
    }

    private func typingDotOpacity(for index: Int) -> Double {
        viewModel.state == .generating ? 0.3 : 1.0
    }

    private var regenerateButtonView: some View {
        Button(action: viewModel.regenerate) {
            HStack(spacing: 8.0) {
                Image(systemName: "arrow.clockwise")
                    .font(.system(size: 14.0, weight: .semibold))

                Text("Сгенерировать заново")
                    .font(.velaSans(size: 14.0, weight: .bold))
            }
            .foregroundStyle(Colors.Blue.blue500)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12.0)
            .background(
                RoundedRectangle(cornerRadius: 12.0)
                    .stroke(Colors.Blue.blue500, lineWidth: 1.5)
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }
}
