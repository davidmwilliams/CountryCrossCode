import SwiftUI

struct AboutView: View {
    var body: some View {
        VStack(spacing: 16) {
            Text("About Country Guess Game")
                .font(.largeTitle)
                .bold()
            Text("Version 1.0")
            Text("Developed with help from ChatGPT")
                .italic()
            Spacer()
        }
        .padding()
        .navigationTitle("About")
    }
}

