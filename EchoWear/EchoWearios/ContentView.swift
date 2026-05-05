import SwiftUI
import Speech
import AVFoundation

// MARK: - Palette
struct EW {
    static let bg = Color(hex: "#F7F2EE")
    static let card = Color.white
    static let text = Color(hex: "#101418")
    static let sub = Color(hex: "#6B7280")
    static let accent = Color(hex: "#FF6B4A")
    static let accentSoft = Color(hex: "#FFE6DF")
    static let pill = Color(hex: "#F3F4F6")
}
extension Color {
    init(hex: String) {
        let h = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var i: UInt64 = 0; Scanner(string: h).scanHexInt64(&i)
        let a,r,g,b: UInt64
        switch h.count {
        case 6: (a,r,g,b) = (255, i>>16, i>>8 & 0xFF, i & 0xFF)
        case 8: (a,r,g,b) = (i>>24, i>>16 & 0xFF, i>>8 & 0xFF, i & 0xFF)
        default:(a,r,g,b) = (255,0,0,0)
        }
        self.init(.sRGB, red: Double(r)/255, green: Double(g)/255, blue: Double(b)/255, opacity: Double(a)/255)
    }
}
struct EWCard<Content: View>: View {
    let c: Content
    init(@ViewBuilder _ c: () -> Content) { self.c = c() }
    var body: some View {
        c.padding(16)
            .background(EW.card)
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            .shadow(color: .black.opacity(0.06), radius: 16, x: 0, y: 8)
    }
}

// MARK: - Logo (Heart + Ear + EW)
struct EWLogo: View {
    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                Image(systemName: "heart.fill")
                    .resizable().aspectRatio(contentMode: .fit)
                    .foregroundColor(EW.accent).padding(8)
                Image(systemName: "ear.fill")
                    .resizable().aspectRatio(contentMode: .fit)
                    .foregroundColor(.white).padding(34)
                    .offset(x: 6, y: 2)
            }.frame(width: 120, height: 120)
            Text("EW")
                .font(.system(size: 36, weight: .black, design: .rounded))
                .foregroundColor(EW.text)
                .kerning(2)
        }
    }
}

// MARK: - Root
struct ContentView: View {
    @StateObject private var authManager = AuthenticationManager()
    @State private var showSplash = true

    var body: some View {
        ZStack {
            if showSplash {
                SplashView()
                    .transition(.opacity.combined(with: .scale))
            } else {
                AuthFlow()
                    .environmentObject(authManager)
            }
        }
        .onAppear {
            // Check for existing session
            authManager.checkStoredSession()

            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                withAnimation(.spring()) { showSplash = false }
            }
        }
    }
}

struct SplashView: View {
    var body: some View {
        ZStack {
            EW.bg.ignoresSafeArea()
            EWLogo()
        }
    }
}

// MARK: - Auth → Tabs (Home + Profile)
struct AuthFlow: View {
    @EnvironmentObject var authManager: AuthenticationManager

    var body: some View {
        Group {
            if authManager.isAuthenticated {
                MainTabs()
            } else {
                ModernSignInView(authManager: authManager)
            }
        }
    }
}

// Old SignInView removed - now using ModernSignInView

struct MainTabs: View {
    @StateObject private var listener = SpeechRecognizer()
    @EnvironmentObject var authManager: AuthenticationManager

    var body: some View {
        TabView {
            HomeView()
                .environmentObject(listener)
                .tabItem { Image(systemName: "house.fill"); Text("Home") }
            ProfileView()
                .environmentObject(listener)
                .environmentObject(authManager)
                .tabItem { Image(systemName: "person.crop.circle"); Text("Profile") }
        }
        .tint(EW.accent)
    }
}

// MARK: - Home (single "functional" screen)
struct HomeView: View {
    @EnvironmentObject var listener: SpeechRecognizer

    var body: some View {
        NavigationStack {
            ZStack {
                EW.bg.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 16) {
                        // Voice monitor card
                        EWCard {
                            VStack(spacing: 10) {
                                HStack {
                                    Text("Voice Monitor")
                                        .font(.headline)
                                    Spacer()
                                    if listener.isListening {
                                        HStack(spacing: 4) {
                                            Circle()
                                                .fill(Color.red)
                                                .frame(width: 8, height: 8)
                                            Text("Live")
                                                .font(.caption)
                                                .foregroundColor(.red)
                                        }
                                    }
                                }

                                Text(listener.heardText.isEmpty ? "Say something..." : listener.heardText)
                                    .font(.caption)
                                    .foregroundColor(EW.sub)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .lineLimit(3)

                                // Detected keywords
                                if !listener.detectedKeywords.isEmpty {
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack(spacing: 8) {
                                            ForEach(listener.detectedKeywords, id: \.self) { keyword in
                                                Text(keyword)
                                                    .font(.caption)
                                                    .padding(.horizontal, 12)
                                                    .padding(.vertical, 6)
                                                    .background(EW.accentSoft)
                                                    .foregroundColor(EW.accent)
                                                    .clipShape(Capsule())
                                            }
                                        }
                                    }
                                }

                                Button(action: {
                                    if listener.isListening {
                                        listener.stopListening()
                                    } else {
                                        listener.requestPermissionAndStart()
                                    }
                                }) {
                                    HStack {
                                        Image(systemName: listener.isListening ? "stop.circle.fill" : "mic.circle.fill")
                                        Text(listener.isListening ? "Stop Listening" : "Start Listening")
                                    }
                                    .font(.headline)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(listener.isListening ? Color.red : EW.accent)
                                    .foregroundColor(.white)
                                    .clipShape(RoundedRectangle(cornerRadius: 16))
                                }
                            }
                        }
                        .padding(.horizontal, 20)

                        // EXISTING UI BELOW (unchanged)

                        Text("")
                        EWCard {
                            HStack(spacing: 16) {
                                ZStack {
                                    Circle().fill(EW.accentSoft)
                                    Image(systemName: "applewatch.watchface")
                                        .foregroundColor(EW.accent)
                                }
                                .frame(width: 52, height: 52)

                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Apple Watch").font(.headline)
                                    Text("Battery Life 86%")
                                        .font(.subheadline)
                                        .foregroundColor(EW.sub)
                                }

                                Spacer()
                                Image(systemName: "wifi").foregroundColor(EW.accent)
                            }
                        }
                        .padding(.horizontal, 20)

                        HStack(spacing: 12) {
                            alertCard(icon: "person.wave.2.fill", title: "Someone is trying to\ncommunicate with you")
                            alertCard(icon: "car.fill", title: "Car is Coming")
                        }
                        .padding(.horizontal, 20)
                    }
                    .padding(.top, 14)
                }
            }
            .navigationTitle("Hello, Soojal Kumar")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    @ViewBuilder private func alertCard(icon: String, title: String) -> some View {
        EWCard {
            VStack(alignment: .leading, spacing: 12) {
                ZStack {
                    Circle().fill(EW.accentSoft)
                    Image(systemName: icon).foregroundColor(EW.accent)
                }.frame(width: 40, height: 40)
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(EW.text)
                Spacer()
                HStack { Spacer()
                    Image(systemName: "chevron.right.circle.fill")
                        .foregroundColor(EW.accent)
                }
            }
            .frame(width: 160, height: 150)
        }
    }
}


// MARK: - Profile (minimal hub)
struct ProfileView: View {
    @EnvironmentObject var listener: SpeechRecognizer
    @EnvironmentObject var authManager: AuthenticationManager
    @State private var showSettings = false
    @State private var showSignOutAlert = false

    var body: some View {
        NavigationStack {
            ZStack {
                EW.bg.ignoresSafeArea()
                ScrollView {
                    VStack(spacing: 16) {
                        // User Profile Card
                        EWCard {
                            VStack(spacing: 12) {
                                HStack(spacing: 16) {
                                    Image(systemName: "person.crop.circle.fill")
                                        .resizable().frame(width: 44, height: 44)
                                        .foregroundColor(EW.accent)
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Hello, \(authManager.currentUser?.displayName ?? listener.userName)")
                                            .font(.headline)
                                        if let email = authManager.currentUser?.email {
                                            Text(email)
                                                .font(.caption)
                                                .foregroundColor(EW.sub)
                                        }
                                    }
                                    Spacer()
                                    // Provider badge
                                    if let provider = authManager.currentUser?.provider {
                                        Image(systemName: providerIcon(provider))
                                            .foregroundColor(EW.accent)
                                    }
                                }

                                // Sign Out Button
                                Button(action: { showSignOutAlert = true }) {
                                    HStack {
                                        Image(systemName: "rectangle.portrait.and.arrow.right")
                                        Text("Sign Out")
                                    }
                                    .font(.subheadline.weight(.medium))
                                    .foregroundColor(.red)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 8)
                                    .background(Color.red.opacity(0.1))
                                    .cornerRadius(8)
                                }
                            }
                        }
                        .padding(.horizontal, 20)

                        VStack(spacing: 12) {
                            Button(action: { showSettings = true }) {
                                profileRow("slider.horizontal.3", "Voice Monitor Settings")
                            }
                            profileRow("antenna.radiowaves.left.and.right", "Connected Devices")
                            profileRow("shield.righthalf.filled", "Security & Privacy")
                            profileRow("person.2.wave.2", "Emergency Contacts")
                            profileRow("bell.badge", "Notifications")
                            profileRow("info.circle", "About Us")
                        }
                        .padding(.horizontal, 20)
                        
                        HStack(spacing: 12) {
                            helpCard("Ask for\nthe help", "Get Answers From Community Experts.")
                            helpCard("Happy\nwith us?", "We're Delighted To Receive Your Feedback!")
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 24)
                    }
                    .padding(.top, 14)
                }
            }
#if os(iOS)
            .navigationTitle("Profile").navigationBarTitleDisplayMode(.inline)
#endif
            .sheet(isPresented: $showSettings) {
                VoiceMonitorSettingsView(listener: listener)
            }
            .alert("Sign Out", isPresented: $showSignOutAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Sign Out", role: .destructive) {
                    authManager.signOut()
                }
            } message: {
                Text("Are you sure you want to sign out?")
            }
        }
    }

    private func providerIcon(_ provider: AuthenticationManager.User.AuthProvider) -> String {
        switch provider {
        case .apple: return "apple.logo"
        case .google: return "g.circle.fill"
        case .email: return "envelope.fill"
        }
    }
    
    @ViewBuilder private func profileRow(_ icon: String, _ title: String) -> some View {
        EWCard {
            HStack {
                ZStack {
                    Circle().fill(EW.accentSoft)
                    Image(systemName: icon).foregroundColor(EW.accent)
                }.frame(width: 42, height: 42)
                Text(title).font(.headline)
                Spacer()
                Image(systemName: "chevron.right").foregroundColor(EW.sub)
            }
        }
    }
    @ViewBuilder private func helpCard(_ title: String, _ subtitle: String) -> some View {
        EWCard {
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(EW.text)
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(EW.sub)
            }
            .frame(width: 160, height: 120)
        }
    }
}

// MARK: - Voice Monitor Settings
struct VoiceMonitorSettingsView: View {
    @ObservedObject var listener: SpeechRecognizer
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                EW.bg.ignoresSafeArea()
                ScrollView {
                    VStack(spacing: 20) {
                        // User Name Section
                        EWCard {
                            VStack(alignment: .leading, spacing: 12) {
                                Label("Your Name", systemImage: "person.fill")
                                    .font(.headline)
                                    .foregroundColor(EW.text)

                                Text("Your name will trigger alerts when someone calls you")
                                    .font(.caption)
                                    .foregroundColor(EW.sub)

                                TextField("Enter your name", text: $listener.userName)
                                    .padding()
                                    .background(EW.pill)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                        }
                        .padding(.horizontal, 20)

                        // Listening Duration Section
                        EWCard {
                            VStack(alignment: .leading, spacing: 12) {
                                Label("Maximum Listening Duration", systemImage: "timer")
                                    .font(.headline)
                                    .foregroundColor(EW.text)

                                Text("Auto-stop after this many seconds (saves battery)")
                                    .font(.caption)
                                    .foregroundColor(EW.sub)

                                HStack {
                                    Text("\(listener.listenDuration)s")
                                        .font(.title2.bold())
                                        .foregroundColor(EW.accent)
                                        .frame(width: 60)

                                    Slider(value: Binding(
                                        get: { Double(listener.listenDuration) },
                                        set: { listener.listenDuration = Int($0) }
                                    ), in: 10...120, step: 5)
                                    .tint(EW.accent)
                                }

                                HStack {
                                    Text("10s")
                                        .font(.caption)
                                        .foregroundColor(EW.sub)
                                    Spacer()
                                    Text("2 min")
                                        .font(.caption)
                                        .foregroundColor(EW.sub)
                                }
                            }
                        }
                        .padding(.horizontal, 20)

                        // Silence Threshold Section
                        EWCard {
                            VStack(alignment: .leading, spacing: 12) {
                                Label("Silence Threshold", systemImage: "waveform.path")
                                    .font(.headline)
                                    .foregroundColor(EW.text)

                                Text("Auto-stop after this many seconds of silence")
                                    .font(.caption)
                                    .foregroundColor(EW.sub)

                                HStack {
                                    Text("\(listener.silenceThreshold)s")
                                        .font(.title2.bold())
                                        .foregroundColor(EW.accent)
                                        .frame(width: 60)

                                    Slider(value: Binding(
                                        get: { Double(listener.silenceThreshold) },
                                        set: { listener.silenceThreshold = Int($0) }
                                    ), in: 3...20, step: 1)
                                    .tint(EW.accent)
                                }

                                HStack {
                                    Text("3s")
                                        .font(.caption)
                                        .foregroundColor(EW.sub)
                                    Spacer()
                                    Text("20s")
                                        .font(.caption)
                                        .foregroundColor(EW.sub)
                                }
                            }
                        }
                        .padding(.horizontal, 20)

                        // Emergency Keywords Section
                        EWCard {
                            VStack(alignment: .leading, spacing: 12) {
                                Label("Emergency Keywords", systemImage: "exclamationmark.triangle.fill")
                                    .font(.headline)
                                    .foregroundColor(EW.text)

                                Text("These words will trigger alerts:")
                                    .font(.caption)
                                    .foregroundColor(EW.sub)

                                FlowLayout(spacing: 8) {
                                    ForEach(listener.emergencyKeywords, id: \.self) { keyword in
                                        Text(keyword)
                                            .font(.caption)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 6)
                                            .background(EW.accentSoft)
                                            .foregroundColor(EW.accent)
                                            .clipShape(Capsule())
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 20)

                        // Info Card
                        EWCard {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Image(systemName: "info.circle.fill")
                                        .foregroundColor(EW.accent)
                                    Text("Battery Saving Tips")
                                        .font(.headline)
                                        .foregroundColor(EW.text)
                                }

                                Text("• Lower durations save battery\n• Use silence detection for efficiency\n• Minimize keyword list for faster processing")
                                    .font(.caption)
                                    .foregroundColor(EW.sub)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 24)
                    }
                    .padding(.top, 20)
                }
            }
            .navigationTitle("Voice Monitor Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(EW.accent)
                }
            }
        }
    }
}

// Simple FlowLayout for wrapping keywords
struct FlowLayout<Content: View>: View {
    let spacing: CGFloat
    let content: Content

    init(spacing: CGFloat = 8, @ViewBuilder content: () -> Content) {
        self.spacing = spacing
        self.content = content()
    }

    var body: some View {
        content
    }
}
