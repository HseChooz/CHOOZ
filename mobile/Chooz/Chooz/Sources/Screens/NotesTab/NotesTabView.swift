import SwiftUI

struct NotesTabView<
    ViewModel: NotesTabViewModel,
    NotesContent: View,
    FavoriteNotesContent: View
>: View {
    
    // MARK: - Init
    
    init(
        viewModel: ViewModel,
        notesView: NotesContent,
        favoriteNotesView: FavoriteNotesContent
    ) {
        self.viewModel = viewModel
        self.notesView = notesView
        self.favoriteNotesView = favoriteNotesView
    }
    
    // MARK: - Body
    
    var body: some View {
        contentView
            .onAppear {
                viewModel.onAppear()
            }
            .toolbar {
                NotesTabToolbarContent(
                    selectedSegment: Binding(
                        get: { viewModel.selectedSegment },
                        set: { viewModel.selectedSegment = $0 }
                    ),
                    eventsHandler: viewModel
                )
            }
    }
    
    // MARK: - Private Properties
    
    private let viewModel: ViewModel
    private let notesView: NotesContent
    private let favoriteNotesView: FavoriteNotesContent
    
    // MARK: - Private Views
    
    @ViewBuilder
    private var contentView: some View {
        switch viewModel.selectedSegment {
        case .allNotes:
            notesView
        case .favoriteNotes:
            favoriteNotesView
        }
    }
    
}
