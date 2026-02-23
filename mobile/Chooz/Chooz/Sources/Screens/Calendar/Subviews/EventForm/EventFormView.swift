import SwiftUI

struct EventFormView: View {
    
    // MARK: - Init
    
    init(
        formType: EventFormType,
        onSave: @escaping @MainActor (String, String?, Date, String?) -> Bool
    ) {
        self.formType = formType
        self.onSave = onSave
        
        switch formType {
        case .add:
            _date = State(initialValue: .now)
            _isDateSelected = State(initialValue: false)
            _title = State(initialValue: "")
            _description = State(initialValue: "")
            _link = State(initialValue: "")
        case .edit(let event):
            _date = State(initialValue: event.date)
            _isDateSelected = State(initialValue: true)
            _title = State(initialValue: event.title)
            _description = State(initialValue: event.description ?? "")
            _link = State(initialValue: event.link?.absoluteString ?? "")
        }
    }
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 24.0) {
            toolbarView
            
            dateRowView
            
            VStack(spacing: 16.0) {
                titleView
                
                descriptionView
                
                EventAddLinkView(linkString: $link)
            }
            
            Spacer()
            
            saveButtonView
        }
        .padding(.top, 24.0)
        .padding(.horizontal, 16.0)
        .padding(.bottom, Static.bottomPadding.value(for: interfaceLayout))
        .background(Colors.Common.white)
    }
    
    // MARK: - Private Types
    
    private enum Static {
        static let bottomPadding: InterfaceLayoutValue<CGFloat> = InterfaceLayoutValue(
            large: 32.0,
            compact: .zero
        )
    }
    
    // MARK: - Private Properties
    
    private let formType: EventFormType
    private let onSave: @MainActor (String, String?, Date, String?) -> Bool
    
    @State private var date: Date
    @State private var isDateSelected: Bool
    @State private var isDatePickerPresented: Bool = false
    @State private var title: String
    @State private var description: String
    @State private var link: String
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.interfaceLayout) private var interfaceLayout
    
    private var isSaveEnabled: Bool {
        !title.trimmingCharacters(in: .whitespaces).isEmpty && isDateSelected
    }
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yy"
        return formatter.string(from: date)
    }
    
    // MARK: - Private Views
    
    private var toolbarView: some View {
        HStack(spacing: .zero) {
            Spacer()
            
            Button(
                action: { dismiss() },
                label: {
                    Images.Icons.crossLarge
                        .foregroundStyle(Colors.Neutral.grey5b)
                }
            )
            .buttonStyle(ScaleButtonStyle())
        }
        .frame(height: 24.0)
        .frame(maxWidth: .infinity)
    }
    
    private var dateRowView: some View {
        VStack(spacing: 8.0) {
            Button {
                isDatePickerPresented = true
            } label: {
                HStack(spacing: 8.0) {
                    Images.Icons.calendarBlue
                        .resizable()
                        .scaledToFit()
                        .frame(width: 18.0, height: 18.0)
                        .foregroundStyle(Colors.Blue.blue500)
                    
                    Text(isDateSelected ? formattedDate : "ДД/ММ/ГГ")
                        .font(.velaSans(size: 16.0, weight: .bold))
                        .foregroundStyle(Colors.Neutral.grey500)
                    
                    Spacer()
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            
            Rectangle()
                .fill(Colors.Neutral.grey200)
                .frame(height: 1.0)
        }
        .sheet(isPresented: $isDatePickerPresented) {
            datePickerSheet
                .presentationDetents([.medium])
        }
    }
    
    private var datePickerSheet: some View {
        VStack(spacing: 16.0) {
            DatePicker(
                "",
                selection: $date,
                displayedComponents: .date
            )
            .datePickerStyle(.graphical)
            .labelsHidden()
            .onChange(of: date) {
                isDateSelected = true
            }
            
            MainActionButton(
                title: "Готово",
                backgroundColor: Colors.Blue.blue500,
                foregroundColor: Colors.Common.white,
                action: { isDatePickerPresented = false }
            )
        }
        .padding(16.0)
        .background(Colors.Common.white)
    }
    
    private var titleView: some View {
        TextField(
            "",
            text: $title,
            prompt:
                Text("Заголовок")
                .font(.velaSans(size: 20.0, weight: .bold))
                .foregroundStyle(Colors.Common.black)
        )
        .lineLimit(1)
        .font(.velaSans(size: 20.0, weight: .bold))
        .foregroundStyle(Colors.Common.black)
    }
    
    private var descriptionView: some View {
        TextField(
            "Добавить описание здесь...",
            text: $description,
            axis: .vertical
        )
        .font(.velaSans(size: 16.0, weight: .bold))
        .foregroundStyle(Colors.Neutral.grey700)
        .lineLimit(3...6)
    }
    
    private var saveButtonTitle: String {
        switch formType {
        case .add:
            return "Создать событие"
        case .edit:
            return "Сохранить"
        }
    }
    
    private var saveButtonView: some View {
        MainActionButton(
            title: saveButtonTitle,
            backgroundColor: isSaveEnabled ? Colors.Blue.blue500 : Colors.Neutral.grey200,
            foregroundColor: isSaveEnabled ? Colors.Common.white : Colors.Neutral.grey400,
            action: {
                let shouldDismiss = onSave(
                    title,
                    description.isEmpty ? nil : description,
                    date,
                    link.isEmpty ? nil : link
                )
                if shouldDismiss {
                    dismiss()
                }
            }
        )
        .disabled(!isSaveEnabled)
    }
}
