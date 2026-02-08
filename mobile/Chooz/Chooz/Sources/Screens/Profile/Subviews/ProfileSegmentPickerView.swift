import SwiftUI

struct ProfileSegmentPickerView: View {
    
    // MARK: - Init
    
    init(
        segments: [ProfileSegment],
        selectedSegment: Binding<ProfileSegment>,
    ) {
        self.segments = segments
        self._selectedSegment = selectedSegment
    }
    
    // MARK: - Body
    
    var body: some View {
        HStack(spacing: 24.0) {
            ForEach(segments, id: \.self) { segment in
                Button(
                    action: { selectedSegment = segment },
                    label: {
                        Text(segment.title)
                            .font(.velaSans(size: 20.0, weight: .bold))
                            .foregroundStyle(segment.isAvailable ? Colors.Neutral.grey800 : Colors.Neutral.grey400)
                            .padding(.bottom, 2.0)
                            .overlay(alignment: .bottom) {
                                if segment == selectedSegment {
                                    Rectangle()
                                        .fill(Colors.Neutral.grey800)
                                        .frame(height: 2.0)
                                }
                            }
                    }
                )
                .disabled(!segment.isAvailable)
                .buttonStyle(ScaleButtonStyle())
            }
        }
    }
    
    // MARK: - Private Properties
    
    private let segments: [ProfileSegment]
    @Binding private var selectedSegment: ProfileSegment
}
