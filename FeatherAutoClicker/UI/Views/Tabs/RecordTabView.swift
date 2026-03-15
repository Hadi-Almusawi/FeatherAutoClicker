import SwiftUI

struct RecordTabView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 4) {
                Text("Coming Soon!")
                    .font(.system(size: 24, weight: .semibold))
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 160)  // Same padding as PatternTabView
                    .padding(.bottom, 4)
                
                Text("Record and replay\nclick sequences")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.bottom, 20)
                
                VStack(spacing: 24) {
                    // Placeholder for future functionality
                }
                .padding(.horizontal)
                .padding(.vertical, 10)
            }
        }
    }
}