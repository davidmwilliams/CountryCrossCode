import SwiftUI
import ConfettiSwiftUI
import AVFoundation

// MARK: - Hint Types
enum HintType: String, CaseIterable, Identifiable {
    case firstLetter = "First Letter"
    case secondLetter = "Second Letter"
    case lastLetter = "Last Letter"
    case letterCount = "Letters Count"

    var id: String { rawValue }
}

// MARK: - Country Data
let countryTuples: [(code: String, name: String)] =
    Locale.isoRegionCodes
        .compactMap { code in
            guard let name = Locale.current.localizedString(forRegionCode: code) else { return nil }
            return (code: code, name: name)
        }
        .sorted { $0.name < $1.name }

struct GameView: View {
    @EnvironmentObject var scoreStore: ScoreStore

    @State private var session = GameSession(
        targetIndex: Int.random(in: 0..<countryTuples.count)
    )
    @State private var guess = ""
    @State private var showAlert = false
    @State private var history: [(guess: String, result: String)] = []

    @State private var usedHints = Set<HintType>()
    @State private var hintMessages: [HintType: String] = [:]

    @State private var confettiCounter = 0
    @FocusState private var isGuessFieldFocused: Bool

    var body: some View {
        ZStack {
            // Background Gradient
            LinearGradient(
                gradient: Gradient(colors: [.purple, .blue, .pink]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 20) {
                // Start music & focus
                Color.clear
                    .onAppear {
                        SoundManager.shared.playBackgroundMusic()
                        isGuessFieldFocused = true
                    }

                // Guess History with improved scrolling
                ScrollViewReader { proxy in
                    ScrollView {
                        VStack(spacing: 12) {
                            ForEach(history.indices, id: \.self) { i in
                                let entry = history[i]
                                HStack {
                                    Text(entry.guess)
                                        .bold()
                                        .foregroundColor(.black)
                                    Spacer()
                                    Text(entry.result)
                                        .italic()
                                        .foregroundColor(.black)
                                }
                                .padding()
                                .background(
                                    Color(
                                        hue: Double(i % 6) / 6.0,
                                        saturation: 0.4,
                                        brightness: 0.95
                                    )
                                )
                                .cornerRadius(12)
                                .shadow(radius: 2)
                                .transition(.move(edge: .bottom).combined(with: .opacity))
                                .id(i)
                            }
                        }
                        .padding(.horizontal)
                    }
                    .frame(maxHeight: 220)
                    .onChange(of: history.count) { newCount in
                        guard newCount > 0 else { return }
                        // Ensure scroll happens after view update
                        DispatchQueue.main.async {
                            withAnimation(.interpolatingSpring(stiffness: 70, damping: 9)) {
                                proxy.scrollTo(newCount - 1, anchor: .bottom)
                            }
                        }
                    }
                }

                // Input & Submit
                HStack {
                    TextField("Country name", text: $guess)
                        .submitLabel(.done)
                        .onSubmit(submitGuess)
                        .focused($isGuessFieldFocused)
                        .padding(8)
                        .background(Color.white.opacity(0.8))
                        .cornerRadius(8)
                        .foregroundColor(.black)
                        .textFieldStyle(PlainTextFieldStyle())

                    Button("Guess") {
                        submitGuess()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.green)
                }
                .padding(.horizontal)

                // Hint Buttons
                HStack(spacing: 12) {
                    ForEach(HintType.allCases) { type in
                        Button(type.rawValue) {
                            useHint(type)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(usedHints.contains(type) ? .gray : .orange)
                        .disabled(usedHints.contains(type))
                    }
                }
                .padding(.horizontal)

                // Display Hints
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(HintType.allCases) { type in
                        if let msg = hintMessages[type] {
                            Text("\(type.rawValue): \(msg)")
                                .italic()
                                .foregroundColor(.white)
                        }
                    }
                }
                .padding(.horizontal)

                // Progress Bar
                ProgressView(value: session.duration, total: 30)
                    .progressViewStyle(.linear)
                    .padding(.horizontal)

                // Stats
                HStack {
                    Text("Guesses: \(session.guessCount)")
                    Spacer()
                    Text("Time: \(Int(session.duration))s")
                }
                .padding(.horizontal)
                .foregroundColor(.white)
            }
            .navigationBarTitle("Guess the Country", displayMode: .inline)
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("🎉 You got it!"),
                    message: Text(
                        "In \(session.guessCount) guesses over " +
                        "\(Int(session.duration))s"
                    ),
                    primaryButton: .default(
                        Text("Play Again"), action: resetGame
                    ),
                    secondaryButton: .cancel(Text("Home"))
                )
            }
        }
        // Confetti modifier
        .confettiCannon(trigger: $confettiCounter, num: 50, radius: 300)
    }

    // MARK: - Guess Logic
    private func submitGuess() {
        let trimmed = guess.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        guess = ""
        isGuessFieldFocused = true

        if let idx = countryTuples.firstIndex(where: { $0.name == trimmed }) {
            session.recordGuess()
            if idx == session.targetIndex {
                session.finish()
                SoundManager.shared.playEffect(.correct)
                withAnimation(.interpolatingSpring(stiffness: 80, damping: 8)) {
                    history.append((guess: trimmed, result: "Correct!"))
                }
                scoreStore.add(
                    Score(
                        date: Date(), guesses: session.guessCount,
                        duration: session.duration
                    )
                )
                confettiCounter += 1
                showAlert = true
            } else {
                SoundManager.shared.playEffect(.wrong)
                let diff = abs(idx - session.targetIndex)
                let direction = idx < session.targetIndex ? "earlier" : "later"
                withAnimation(.interpolatingSpring(stiffness: 80, damping: 8)) {
                    history.append((guess: trimmed,
                                    result: "Your guess is \(diff) countries \(direction) than the answer."))
                }
            }
        } else {
            SoundManager.shared.playEffect(.wrong)
            withAnimation(.interpolatingSpring(stiffness: 80, damping: 8)) {
                history.append((guess: trimmed, result: "Country not found."))
            }
        }
    }

    // MARK: - Hint Logic
    private func useHint(_ type: HintType) {
        SoundManager.shared.playEffect(.hint)
        let name = countryTuples[session.targetIndex].name
        let hint: String
        switch type {
        case .firstLetter:
            hint = String(name.prefix(1))
        case .secondLetter:
            hint = name.count > 1 ? String(name[name.index(name.startIndex, offsetBy: 1)]) : ""
        case .lastLetter:
            hint = String(name.suffix(1))
        case .letterCount:
            hint = "\(name.count)"
        }
        hintMessages[type] = hint
        usedHints.insert(type)
    }

    // MARK: - Reset
    private func resetGame() {
        session = GameSession(targetIndex: Int.random(in: 0..<countryTuples.count))
        guess = ""
        history.removeAll()
        usedHints.removeAll()
        hintMessages.removeAll()
        isGuessFieldFocused = true
    }
}

