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
    @State private var showSplash = true
    var body: some View {
        ZStack {
            if showSplash {
                SplashView()
                    .transition(.opacity.combined(with: .scale))
            } else {
                AuthFlow()
            }
        }
        .onAppear {
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
    @State private var signedIn = false
    var body: some View {
        Group {
            if signedIn { MainTabs() }
            else { SignInView { signedIn = true } }
        }
    }
}

struct SignInView: View {
    var onSignIn: () -> Void
    @State private var email = "soojalkumar@gmail.com"
    @State private var password = "password"
    @State private var remember = true

    var body: some View {
        ZStack {
            EW.bg.ignoresSafeArea()
            VStack(spacing: 24) {
                Spacer(minLength: 12)
                EWLogo()
                EWCard {
                    VStack(alignment: .leading, spacing: 14) {
                        Text("Sign in to your account")
                            .font(.title3.bold()).foregroundColor(EW.text)
                        Text("Get to know any sudden emergency near your vicinity")
                            .font(.footnote).foregroundColor(EW.sub)

                        VStack(spacing: 12) {
                            HStack {
                                Image(systemName: "envelope").foregroundColor(EW.sub)
                                TextField("Email Address", text: $email)
                                #if os(iOS)
                                .textInputAutocapitalization(.never)
                                #endif

                            }
                            .padding().background(EW.pill)
                            .clipShape(RoundedRectangle(cornerRadius: 14))

                            HStack {
                                Image(systemName: "lock").foregroundColor(EW.sub)
                                SecureField("Password", text: $password)
                                Image(systemName: "eye").foregroundColor(EW.sub.opacity(0.6))
                            }
                            .padding().background(EW.pill)
                            .clipShape(RoundedRectangle(cornerRadius: 14))

                            Toggle(isOn: $remember) {
                                Text("Remember me").foregroundColor(EW.sub)
                            }.toggleStyle(SwitchToggleStyle(tint: EW.accent))
                        }

                        Button(action: onSignIn) {
                            Text("Sign in").frame(maxWidth: .infinity).padding()
                                .background(EW.text).foregroundColor(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                        }.padding(.top, 6)
                    }
                }
                .padding(.horizontal, 24)
                Spacer()
            }
        }
    }
}

struct MainTabs: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem { Image(systemName: "house.fill"); Text("Home") }
            ProfileView()
                .tabItem { Image(systemName: "person.crop.circle"); Text("Profile") }
        }
        .tint(EW.accent)
    }
}

// MARK: - Home (single "functional" screen)
struct HomeView: View {
    @StateObject private var listener = SpeechRecognizer()

    var body: some View {
        NavigationStack {
            ZStack {
                EW.bg.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 16) {
                        // Listening UI
                        EWCard {
                            VStack(spacing: 10) {
                                Text("Voice Monitor")
                                    .font(.headline)

                                Text(listener.heardText.isEmpty ? "Say something..." : listener.heardText)
                                    .font(.caption)
                                    .foregroundColor(EW.sub)

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

                        // Existing UI continues below
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
                                    Text("Battery Life 86%").font(.subheadline)
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
    var body: some View {
        NavigationStack {
            ZStack {
                EW.bg.ignoresSafeArea()
                ScrollView {
                    VStack(spacing: 16) {
                        EWCard {
                            HStack(spacing: 16) {
                                Image(systemName: "person.crop.circle.fill")
                                    .resizable().frame(width: 44, height: 44)
                                    .foregroundColor(EW.accent)
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Hello, Soojal").font(.headline)
                                    Text(" ").font(.caption)
                                }
                                Spacer()
                                Image(systemName: "link").foregroundColor(EW.sub)
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        VStack(spacing: 12) {
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
