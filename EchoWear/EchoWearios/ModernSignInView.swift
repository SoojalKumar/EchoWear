//
//  ModernSignInView.swift
//  EchoWear
//
//  Modern, beautiful sign-in screen with multiple authentication options:
//  - Apple Sign In (native with Face ID/Touch ID)
//  - Google Sign In (UI ready, simulated for demo)
//  - Email/Password (with validation and auto account creation)
//
//  Features:
//  - Gradient background for visual appeal
//  - Form validation with visual feedback
//  - Error message display
//  - Loading states
//  - Sign Up / Sign In toggle
//  - Password show/hide toggle
//

import SwiftUI
import AuthenticationServices  // For Apple Sign In button

// MARK: - Modern Sign-In View

/// SwiftUI View for user authentication
/// Presents multiple sign-in options with modern, beautiful UI
struct ModernSignInView: View {

    // MARK: - Properties

    /// Reference to authentication manager (observes auth state changes)
    @ObservedObject var authManager: AuthenticationManager

    /// Email input (bound to text field)
    @State private var email = ""

    /// Password input (bound to secure field)
    @State private var password = ""

    /// Whether to show password in plain text (toggle with eye icon)
    @State private var showPassword = false

    /// Whether in sign-up mode (vs sign-in mode)
    @State private var isSignUp = false

    /// Coordinator for handling Apple Sign In flow
    @StateObject private var appleSignInCoordinator: AppleSignInCoordinator

    // MARK: - Initialization

    /// Initialize view with authentication manager
    /// - Parameter authManager: AuthenticationManager instance to use
    init(authManager: AuthenticationManager) {
        self.authManager = authManager
        // Create Apple Sign In coordinator (StateObject for lifecycle management)
        _appleSignInCoordinator = StateObject(wrappedValue: AppleSignInCoordinator(authManager: authManager))
    }

    // MARK: - Body

    var body: some View {
        ZStack {
            // MARK: - Background Gradient
            // Beautiful gradient from background to accent color
            LinearGradient(
                colors: [EW.bg, EW.accentSoft.opacity(0.3)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            // MARK: - Main Content
            ScrollView {
                VStack(spacing: 32) {
                    Spacer(minLength: 40)

                    // MARK: - Logo & Title Section
                    VStack(spacing: 16) {
                        // App logo
                        EWLogo()

                        // Dynamic title (changes based on sign-up vs sign-in mode)
                        Text(isSignUp ? "Create Account" : "Welcome Back")
                            .font(.largeTitle.bold())
                            .foregroundColor(EW.text)

                        // Subtitle with context
                        Text(isSignUp ? "Sign up to get started with EchoWear" : "Sign in to continue monitoring")
                            .font(.subheadline)
                            .foregroundColor(EW.sub)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.bottom, 20)

                    // MARK: - Social Sign-In Buttons
                    VStack(spacing: 12) {

                        // MARK: Apple Sign In Button
                        // Native Apple button with built-in styling
                        SignInWithAppleButton(.signIn) { request in
                            // Request user's name and email from Apple
                            // NOTE: Only provided on FIRST sign-in
                            request.requestedScopes = [.fullName, .email]
                        } onCompletion: { result in
                            // Handle Apple Sign In result
                            switch result {
                            case .success(let authorization):
                                // Success: pass to authentication manager
                                authManager.signInWithApple(authorization: authorization)
                            case .failure(let error):
                                // Failure: display error message
                                authManager.errorMessage = error.localizedDescription
                            }
                        }
                        .signInWithAppleButtonStyle(.black)  // Black Apple-style button
                        .frame(height: 50)
                        .cornerRadius(12)

                        // MARK: Google Sign In Button (Simulated)
                        // Custom button styled like Google's official button
                        // NOTE: In production, use GoogleSignIn SDK
                        Button(action: {
                            // Simulated Google Sign In (placeholder)
                            // Real implementation would present Google Sign In UI
                            authManager.signInWithGoogle(
                                email: "user@gmail.com",
                                name: "Demo User"
                            )
                        }) {
                            HStack {
                                // Google icon (using system image as placeholder)
                                Image(systemName: "g.circle.fill")
                                    .font(.title2)
                                Text("Continue with Google")
                                    .font(.headline)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.white)
                            .foregroundColor(.black)
                            .cornerRadius(12)
                            .overlay(
                                // Subtle border
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                        }
                    }
                    .padding(.horizontal, 24)

                    // MARK: - Divider with "or" Text
                    HStack {
                        Rectangle()
                            .fill(EW.sub.opacity(0.3))
                            .frame(height: 1)
                        Text("or")
                            .font(.subheadline)
                            .foregroundColor(EW.sub)
                            .padding(.horizontal, 12)
                        Rectangle()
                            .fill(EW.sub.opacity(0.3))
                            .frame(height: 1)
                    }
                    .padding(.horizontal, 24)

                    // MARK: - Email/Password Form
                    VStack(spacing: 16) {

                        // MARK: Email Input Field
                        VStack(alignment: .leading, spacing: 8) {
                            // Label
                            Text("Email")
                                .font(.subheadline.weight(.medium))
                                .foregroundColor(.black)

                            // Input with icon
                            HStack {
                                Image(systemName: "envelope")
                                    .foregroundColor(EW.sub)
                                TextField("", text: $email, prompt: Text("Enter your email").foregroundColor(.black))
                                    .foregroundColor(.black)  // Black text for visibility
                                    .textInputAutocapitalization(.never)  // Email lowercase
                                    .keyboardType(.emailAddress)  // Email keyboard
                                    .autocorrectionDisabled()  // No autocorrect for emails
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                            .overlay(
                                // Accent border when filled (visual feedback)
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(email.isEmpty ? Color.clear : EW.accent.opacity(0.3), lineWidth: 2)
                            )
                        }

                        // MARK: Password Input Field
                        VStack(alignment: .leading, spacing: 8) {
                            // Label
                            Text("Password")
                                .font(.subheadline.weight(.medium))
                                .foregroundColor(.black)

                            // Input with icon and show/hide toggle
                            HStack {
                                Image(systemName: "lock")
                                    .foregroundColor(EW.sub)

                                // Toggle between SecureField and TextField based on showPassword
                                if showPassword {
                                    TextField("", text: $password, prompt: Text("Enter your password").foregroundColor(.black))
                                        .foregroundColor(.black)  // Black text for visibility
                                } else {
                                    SecureField("", text: $password, prompt: Text("Enter your password").foregroundColor(.black))
                                        .foregroundColor(.black)  // Black text for visibility
                                }

                                // Show/Hide password button
                                Button(action: { showPassword.toggle() }) {
                                    Image(systemName: showPassword ? "eye.slash" : "eye")
                                        .foregroundColor(EW.sub)
                                }
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                            .overlay(
                                // Accent border when filled (visual feedback)
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(password.isEmpty ? Color.clear : EW.accent.opacity(0.3), lineWidth: 2)
                            )
                        }

                        // MARK: Error Message Display
                        // Show error message if authentication fails
                        if let error = authManager.errorMessage {
                            HStack {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.red)
                                Text(error)
                                    .font(.caption)
                                    .foregroundColor(.red)
                            }
                            .padding(.horizontal)
                        }

                        // MARK: Sign In/Up Button
                        Button(action: {
                            // Call appropriate method based on mode
                            if isSignUp {
                                authManager.createAccount(email: email, password: password)
                            } else {
                                authManager.signInWithEmail(email: email, password: password)
                            }
                        }) {
                            // Show loading spinner or button text
                            if authManager.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 50)
                            } else {
                                Text(isSignUp ? "Create Account" : "Sign In")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 50)
                            }
                        }
                        .background(
                            // Disabled state: gray, Enabled state: accent color
                            (email.isEmpty || password.isEmpty) ?
                            EW.sub.opacity(0.3) : EW.accent
                        )
                        .cornerRadius(12)
                        .disabled(email.isEmpty || password.isEmpty || authManager.isLoading)

                        // MARK: Sign Up / Sign In Toggle
                        // Allow user to switch between modes
                        HStack {
                            Text(isSignUp ? "Already have an account?" : "Don't have an account?")
                                .font(.subheadline)
                                .foregroundColor(.black)

                            Button(action: {
                                withAnimation {
                                    isSignUp.toggle()  // Toggle mode
                                    authManager.errorMessage = nil  // Clear errors
                                }
                            }) {
                                Text(isSignUp ? "Sign In" : "Sign Up")
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundColor(EW.accent)
                            }
                        }
                    }
                    .padding(.horizontal, 24)

                    // MARK: - Privacy Note
                    // Legal disclaimer at bottom
                    Text("By continuing, you agree to our Terms of Service and Privacy Policy")
                        .font(.caption)
                        .foregroundColor(.black)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                        .padding(.bottom, 24)

                    Spacer(minLength: 20)
                }
            }
        }
    }
}

// MARK: - Preview

/// SwiftUI preview for development
#Preview {
    ModernSignInView(authManager: AuthenticationManager())
}
