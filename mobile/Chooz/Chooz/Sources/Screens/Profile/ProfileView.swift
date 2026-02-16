import SwiftUI

struct ProfileView: View {
    
    // MARK: - Init
    
    init(viewModel: ProfileViewModel) {
        self.viewModel = viewModel
    }
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 32.0) {
            ProfileHeaderView(model: viewModel.headerModel)
            
            VStack(spacing: .zero) {
                ProfileSegmentPickerView(
                    segments: ProfileSegment.allCases,
                    selectedSegment: $viewModel.selectedSegment,
                )
                
                ProfileContentView(
                    selectedSegment: viewModel.selectedSegment,
                    wishlistViewModel: viewModel.wishlistViewModel
                )
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Colors.Common.white)
        .navigationBarBackButtonHidden()
        .toolbar {
            toolbarContentView
        }
        .onAppear {
            viewModel.fetchProfile()
        }
    }
    
    // MARK: - Private Properties
    
    @Bindable
    private var viewModel: ProfileViewModel
    
    // MARK: - Private Views
    
    @ToolbarContentBuilder
    private var toolbarContentView: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            HStack(spacing: 16.0) {
                settingsButtonView
                
                shareButtonView
            }
        }
    }
    
    private var settingsButtonView: some View {
        Button(
            action: {},
            label: {
                Images.Icons.settings
                    .resizable()
                    .scaledToFill()
                    .frame(width: 24.0, height: 24.0)
            }
        )
        .buttonStyle(ScaleButtonStyle())
    }
    
    private var shareButtonView: some View {
        Button(
            action: {},
            label: {
                Images.Icons.share
                    .resizable()
                    .scaledToFill()
                    .frame(width: 24.0, height: 24.0)
            }
        )
        .buttonStyle(ScaleButtonStyle())
    }
}
