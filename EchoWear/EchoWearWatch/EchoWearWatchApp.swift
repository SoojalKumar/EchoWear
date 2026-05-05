import SwiftUI
import Speech
import AVFoundation
import WatchKit

@main
struct EchoWearWatchApp: App {
    @StateObject private var speechMonitor = SpeechMonitor()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(speechMonitor)
        }
    }
}

// MARK: - Root Flow (Splash → Auth → Tabs)
struct RootView: View {
    @EnvironmentObject private var speechMonitor: SpeechMonitor
    @State private var showSplash = true
    @State private var signedIn = false

    var body: some View {
        ZStack {
            if showSplash {
                SplashView()
                    .transition(.opacity.combined(with: .scale))
            } else if signedIn {
                MainTabs()
                    .environmentObject(speechMonitor)
            } else {
                SignInView { signedIn = true }
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                withAnimation(.easeOut(duration: 0.4)) {
                    showSplash = false
                }
            }
        }
    }
}

// MARK: - Splash
struct SplashView: View {
    var body: some View {
        ZStack {
            EW.bg.ignoresSafeArea()
            EWLogo()
        }
    }
}

// MARK: - Auth
struct SignInView: View {
    var onSignIn: () -> Void
    @State private var rememberMe = true

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                EWLogo()
                    .frame(height: 80)

                Text("EchoWear")
                    .font(.title3.bold())
                    .foregroundColor(EW.text)

                Text("Get alerts about nearby emergency events right from your wrist.")
                    .font(.footnote)
                    .foregroundColor(EW.sub)
                    .multilineTextAlignment(.center)

                Toggle(isOn: $rememberMe) {
                    Text("Remember me")
                        .font(.footnote)
                }
                .toggleStyle(SwitchToggleStyle(tint: EW.accent))

                Button(action: onSignIn) {
                    Text("Continue")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(EW.text)
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                }
            }
            .padding(20)
        }
        .background(EW.bg.ignoresSafeArea())
    }
}

// MARK: - Tabs
struct MainTabs: View {
    @State private var selection = 0

    var body: some View {
        TabView(selection: $selection) {
            HomeView()
                .tag(0)
            ProfileView()
                .tag(1)
        }
        .tabViewStyle(.page(indexDisplayMode: .automatic))
    }
}

// MARK: - Home
struct HomeView: View {
    @EnvironmentObject private var speechMonitor: SpeechMonitor

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                VoiceMonitorCard()
                    .environmentObject(speechMonitor)

                DeviceCard()

                AlertCard(
                    icon: "person.wave.2.fill",
                    title: "Communication Alert",
                    subtitle: "Someone nearby is trying to reach you."
                )

                AlertCard(
                    icon: "car.fill",
                    title: "Vehicle Alert",
                    subtitle: "A fast moving car detected nearby."
                )
            }
            .padding(12)
        }
        .background(EW.bg.ignoresSafeArea())
    }
}

struct VoiceMonitorCard: View {
    @EnvironmentObject private var speechMonitor: SpeechMonitor

    var body: some View {
        EWCard {
            VStack(alignment: .leading, spacing: 8) {
                Text("Voice Monitor")
                    .font(.headline)

                Text(speechMonitor.heardText.isEmpty ? "Say something…" : speechMonitor.heardText)
                    .font(.caption)
                    .foregroundColor(EW.sub)
                    .lineLimit(3)

                Button {
                    if speechMonitor.isListening {
                        speechMonitor.stopListening()
                    } else {
                        speechMonitor.requestPermissionAndStart()
                    }
                } label: {
                    Label(
                        speechMonitor.isListening ? "Stop Listening" : "Start Listening",
                        systemImage: speechMonitor.isListening ? "stop.circle" : "mic.circle"
                    )
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 6)
                }
                .background(speechMonitor.isListening ? Color.red : EW.accent)
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
        }
    }
}

struct DeviceCard: View {
    var body: some View {
        EWCard {
            HStack(spacing: 10) {
                ZStack {
                    Circle().fill(EW.accentSoft)
                    Image(systemName: "applewatch.watchface")
                        .foregroundColor(EW.accent)
                }
                .frame(width: 36, height: 36)

                VStack(alignment: .leading, spacing: 2) {
                    Text("Apple Watch")
                        .font(.headline)
                    Text("Battery 86%")
                        .font(.caption2)
                        .foregroundColor(EW.sub)
                }

                Spacer()
                Image(systemName: "wifi")
                    .foregroundColor(EW.accent)
            }
        }
    }
}

struct AlertCard: View {
    let icon: String
    let title: String
    let subtitle: String

    var body: some View {
        EWCard {
            HStack(alignment: .top, spacing: 8) {
                ZStack {
                    Circle().fill(EW.accentSoft)
                    Image(systemName: icon)
                        .foregroundColor(EW.accent)
                }
                .frame(width: 30, height: 30)

                VStack(alignment: .leading, spacing: 4) {
                    Text(title).font(.headline)
                    Text(subtitle)
                        .font(.caption2)
                        .foregroundColor(EW.sub)
                }
                Spacer()
            }
        }
    }
}

// MARK: - Profile
struct ProfileView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                EWCard {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Soojal Kumar")
                            .font(.headline)
                        Text("Emergency contact ready.")
                            .font(.caption2)
                            .foregroundColor(EW.sub)
                    }
                }

                ProfileRow(icon: "antenna.radiowaves.left.and.right", title: "Connected Devices")
                ProfileRow(icon: "person.2.wave.2", title: "Emergency Contacts")
                ProfileRow(icon: "bell.badge", title: "Notifications")
                ProfileRow(icon: "info.circle", title: "About EchoWear")
            }
            .padding(12)
        }
        .background(EW.bg.ignoresSafeArea())
    }
}

struct ProfileRow: View {
    let icon: String
    let title: String

    var body: some View {
        EWCard {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(EW.accent)
                Text(title)
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(EW.sub)
                    .font(.caption)
            }
        }
    }
}

// MARK: - Palette + Card helper reused from iOS target
struct EW {
    static let bg = Color(hex: "#0F1420")
    static let card = Color(hex: "#1F2632")
    static let text = Color.white
    static let sub = Color(hex: "#9CA3AF")
    static let accent = Color(hex: "#FF6B4A")
    static let accentSoft = Color(hex: "#FFE6DF").opacity(0.2)
}

extension Color {
    init(hex: String) {
        let cleaned = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var value: UInt64 = 0
        Scanner(string: cleaned).scanHexInt64(&value)
        let r, g, b: UInt64
        switch cleaned.count {
        case 6:
            (r, g, b) = (value >> 16, value >> 8 & 0xFF, value & 0xFF)
        default:
            (r, g, b) = (255, 255, 255)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: 1.0
        )
    }
}

struct EWCard<Content: View>: View {
    let content: Content

    init(@ViewBuilder _ content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(EW.card)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
    }
}

struct EWLogo: View {
    var body: some View {
        VStack(spacing: 6) {
            ZStack {
                Image(systemName: "heart.fill")
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(EW.accent)
                    .padding(8)
                Image(systemName: "ear.fill")
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(.white)
                    .padding(28)
                    .offset(x: 4, y: 2)
            }
            .frame(width: 80, height: 80)

            Text("EW")
                .font(.system(size: 28, weight: .black, design: .rounded))
                .foregroundColor(EW.text)
                .kerning(2)
        }
    }
}

// MARK: - Speech Monitor
final class SpeechMonitor: NSObject, ObservableObject {
    private let audioEngine = AVAudioEngine()
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let recognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))

    @Published var heardText: String = ""
    @Published var isListening = false
    @Published var authorizationStatus: SFSpeechRecognizerAuthorizationStatus = .notDetermined

    override init() {
        super.init()
        requestAuthorization()
    }

    func requestAuthorization() {
        SFSpeechRecognizer.requestAuthorization { status in
            DispatchQueue.main.async {
                self.authorizationStatus = status
            }
        }
    }

    func requestPermissionAndStart() {
        switch authorizationStatus {
        case .authorized:
            startListening()
        case .notDetermined:
            requestAuthorization()
        default:
            break
        }
    }

    func startListening() {
        guard !audioEngine.isRunning else { return }

        recognitionTask?.cancel()
        recognitionTask = nil

        let request = SFSpeechAudioBufferRecognitionRequest()
        recognitionRequest = request
        request.shouldReportPartialResults = true

        let audioSession = AVAudioSession.sharedInstance()
        try? audioSession.setCategory(.playAndRecord, mode: .measurement, options: .duckOthers)
        try? audioSession.setActive(true, options: .notifyOthersOnDeactivation)

        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)

        inputNode.removeTap(onBus: 0)
        // Using smaller buffer size (512 bytes) for faster processing and lower latency
        inputNode.installTap(onBus: 0, bufferSize: 512, format: recordingFormat) { [weak self] buffer, _ in
            self?.recognitionRequest?.append(buffer)
        }

        recognitionTask = recognizer?.recognitionTask(with: request) { [weak self] result, error in
            guard let self else { return }

            if let result = result {
                let transcript = result.bestTranscription.formattedString
                DispatchQueue.main.async {
                    self.heardText = transcript
                }

                // Check for greeting keywords and trigger haptic feedback
                let lowerTranscript = transcript.lowercased()
                let greetingKeywords = ["hello", "hey", "hi", "hiya", "yo", "greetings", "howdy"]
                if greetingKeywords.contains(where: { lowerTranscript.contains($0) }) {
                    WKInterfaceDevice.current().play(.notification)
                }
            }

            if error != nil || (result?.isFinal ?? false) {
                self.stopListening()
            }
        }

        audioEngine.prepare()
        try? audioEngine.start()
        DispatchQueue.main.async {
            self.heardText = ""
            self.isListening = true
        }
    }

    func stopListening() {
        if audioEngine.isRunning {
            audioEngine.stop()
            audioEngine.inputNode.removeTap(onBus: 0)
        }
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        recognitionTask = nil
        DispatchQueue.main.async {
            self.isListening = false
        }
    }

    deinit {
        stopListening()
    }
}

#Preview("Root") {
    RootView()
        .environmentObject(SpeechMonitor())
}
