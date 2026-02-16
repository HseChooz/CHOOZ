import SwiftUI

struct SplashView: View {
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            Colors.Blue.blue500
                .ignoresSafeArea()
            
            Images.Logo.Full.v1
                .resizable()
                .scaledToFit()
                .frame(width: 180.0, height: 34.0)
        }
    }
}
