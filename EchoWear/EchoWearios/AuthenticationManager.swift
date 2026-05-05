//
//  AuthenticationManager.swift
//  EchoWear
//
//  Manages user authentication with multiple sign-in methods:
//  - Apple Sign In (native iOS with Face ID/Touch ID)
//  - Email/Password (with validation and auto account creation)
//  - Google Sign In (UI ready, simulated for demo)
//
//  Features:
//  - Session persistence (auto sign-in on app restart)
//  - Password hashing (SHA-256)
//  - Email validation
//  - Sign out functionality
//
//  SECURITY NOTES:
//  - Currently uses UserDefaults for demo purposes
//  - For production: migrate to Keychain Services for secure storage
//  - For production: add backend API (Firebase/Supabase)
//

import SwiftUI
import Foundation
import AuthenticationServices  // For Apple Sign In
import CryptoKit                // For password hashing
import Security                 // For Keychain credential storage

// MARK: - Authentication Manager

/// ObservableObject that manages authentication state and user sessions
/// Supports Apple Sign In, Email/Password, and Google Sign In (simulated)
class AuthenticationManager: ObservableObject {

    // MARK: - Published Properties (Observable by SwiftUI)

    /// Whether user is currently authenticated
    @Published var isAuthenticated = false

    /// Current logged-in user (nil if not authenticated)
    @Published var currentUser: User?

    /// Error message to display in UI (nil if no error)
    @Published var errorMessage: String?

    /// Whether authentication request is in progress
    @Published var isLoading = false

    // MARK: - User Model

    /// User data structure for storing user information
    /// Codable: can be encoded/decoded for UserDefaults storage
    struct User: Codable {
        /// Unique user identifier (Apple ID, UUID for email/Google)
        let id: String

        /// User's email address (optional for Apple Sign In)
        let email: String?

        /// User's full name or username
        let displayName: String?

        /// Authentication provider used (Apple, Google, Email)
        let provider: AuthProvider

        /// Enum representing authentication providers
        enum AuthProvider: String, Codable {
            case apple = "Apple"
            case google = "Google"
            case email = "Email"
        }
    }

    // MARK: - Apple Sign In

    /// Handle Apple Sign In authorization result
    /// Extracts user info from Apple ID credential and creates user session
    /// - Parameter authorization: Authorization object from Apple Sign In flow
    func signInWithApple(authorization: ASAuthorization) {
        isLoading = true
        errorMessage = nil

        // Extract Apple ID credential from authorization
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            errorMessage = "Failed to get Apple ID credentials"
            isLoading = false
            return
        }

        // Extract user information from credential
        let userID = appleIDCredential.user  // Unique Apple user ID
        let email = appleIDCredential.email  // Email (only provided on first sign-in)
        let fullName = appleIDCredential.fullName  // Full name (only on first sign-in)

        // Build display name from full name or email
        let displayName: String?
        if let givenName = fullName?.givenName, let familyName = fullName?.familyName {
            // Use full name if available (first sign-in only)
            displayName = "\(givenName) \(familyName)"
        } else {
            // Fallback to email username (e.g., "john" from "john@example.com")
            displayName = email?.components(separatedBy: "@").first
        }

        // Create user object
        let user = User(
            id: userID,
            email: email ?? "No email provided",  // Apple may not share email
            displayName: displayName,
            provider: .apple
        )

        // Persist user to UserDefaults for session persistence
        saveUser(user)

        // Update UI state on main thread
        DispatchQueue.main.async {
            self.currentUser = user
            self.isAuthenticated = true
            self.isLoading = false
        }
    }

    // MARK: - Google Sign In (Simulated)

    /// Simulate Google Sign In (requires Google Sign-In SDK for production)
    /// This is a placeholder implementation for UI demonstration
    /// - Parameters:
    ///   - email: User's Google email
    ///   - name: User's Google display name
    func signInWithGoogle(email: String, name: String) {
        isLoading = true
        errorMessage = nil

        // NOTE: In production, this would use Google Sign-In SDK:
        // 1. Configure GIDConfiguration
        // 2. Present Google Sign In flow
        // 3. Exchange auth code for tokens
        // 4. Get user info from Google API

        let user = User(
            id: UUID().uuidString,  // Generate random ID (would be Google ID in production)
            email: email,
            displayName: name,
            provider: .google
        )

        // Persist user to UserDefaults
        saveUser(user)

        // Update UI state
        DispatchQueue.main.async {
            self.currentUser = user
            self.isAuthenticated = true
            self.isLoading = false
        }
    }

    // MARK: - Email/Password Sign In

    /// Sign in with email and password
    /// Automatically creates account if user doesn't exist
    /// - Parameters:
    ///   - email: User's email address
    ///   - password: User's password (min 6 characters)
    func signInWithEmail(email: String, password: String) {
        let email = normalizedEmail(email)
        isLoading = true
        errorMessage = nil

        // Validate email format (must contain @ and domain)
        guard isValidEmail(email) else {
            errorMessage = "Please enter a valid email address"
            isLoading = false
            return
        }

        // Validate password length (minimum 6 characters)
        guard password.count >= 6 else {
            errorMessage = "Password must be at least 6 characters"
            isLoading = false
            return
        }

        // Check if user already exists in UserDefaults
        if let storedUser = loadStoredUser(email: email) {
            // Existing user: verify password
            if verifyPassword(password, for: email) {
                // Password correct: sign in
                DispatchQueue.main.async {
                    self.currentUser = storedUser
                    self.isAuthenticated = true
                    self.isLoading = false
                }
            } else {
                // Password incorrect: show error
                errorMessage = "Incorrect password"
                isLoading = false
            }
        } else {
            // New user: create account automatically
            createAccount(email: email, password: password)
        }
    }

    // MARK: - Create Account

    /// Create new account with email and password
    /// Automatically called by signInWithEmail for new users
    /// - Parameters:
    ///   - email: User's email address
    ///   - password: User's password (will be hashed before storage)
    func createAccount(email: String, password: String) {
        let email = normalizedEmail(email)
        // Validate email format
        guard isValidEmail(email) else {
            errorMessage = "Invalid email format"
            isLoading = false
            return
        }

        // Validate password length
        guard password.count >= 6 else {
            errorMessage = "Password must be at least 6 characters"
            isLoading = false
            return
        }

        // Create user object
        let user = User(
            id: UUID().uuidString,  // Generate unique ID
            email: email,
            displayName: email.components(separatedBy: "@").first,  // Use email username
            provider: .email
        )

        // Save credentials (password is hashed before storage)
        // WARNING: UserDefaults is not secure for production!
        // In production: use Keychain Services
        saveCredentials(email: email, password: password)
        saveUser(user)

        // Update UI state
        DispatchQueue.main.async {
            self.currentUser = user
            self.isAuthenticated = true
            self.isLoading = false
        }
    }

    // MARK: - Sign Out

    /// Sign out current user and clears the active session.
    /// Stored email credentials remain in Keychain so the user can sign in again.
    func signOut() {
        UserDefaults.standard.removeObject(forKey: "currentUser")
        currentUser = nil
        isAuthenticated = false
        errorMessage = nil
    }

    // MARK: - Auto Sign In

    /// Check for stored user session and restore if found
    /// Called on app launch to enable auto sign-in
    /// Loads user from UserDefaults if session exists
    func checkStoredSession() {
        // Attempt to load saved user data from UserDefaults
        if let userData = UserDefaults.standard.data(forKey: "currentUser"),
           let user = try? JSONDecoder().decode(User.self, from: userData) {
            // User session found: restore authentication state
            DispatchQueue.main.async {
                self.currentUser = user
                self.isAuthenticated = true
            }
        }
        // If no stored session, user will see sign-in screen
    }

    // MARK: - Helper Methods (Private)

    /// Validate email format using regex
    /// - Parameter email: Email address to validate
    /// - Returns: true if valid email format (e.g., user@domain.com)
    private func isValidEmail(_ email: String) -> Bool {
        // Email regex pattern: user@domain.ext
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }

    /// Save user object to UserDefaults for session persistence
    /// - Parameter user: User object to save
    private func saveUser(_ user: User) {
        if let encoded = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(encoded, forKey: "currentUser")
        }
    }

    /// Load user from UserDefaults by email
    /// - Parameter email: Email address to match
    /// - Returns: User object if found and email matches, nil otherwise
    private func loadStoredUser(email: String) -> User? {
        let email = normalizedEmail(email)
        guard let userData = UserDefaults.standard.data(forKey: "currentUser"),
              let user = try? JSONDecoder().decode(User.self, from: userData),
              user.email?.lowercased() == email else {
            return nil
        }
        return user
    }

    /// Save email/password credentials to Keychain (hashed)
    /// - Parameters:
    ///   - email: User's email address (used as key)
    ///   - password: User's password (will be hashed with SHA-256)
    private func saveCredentials(email: String, password: String) {
        let hashedPassword = hashPassword(password)
        let account = normalizedEmail(email)
        let data = Data(hashedPassword.utf8)
        let query = keychainQuery(account: account)

        SecItemDelete(query as CFDictionary)

        var attributes = query
        attributes[kSecValueData as String] = data
        attributes[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly

        let status = SecItemAdd(attributes as CFDictionary, nil)
        if status != errSecSuccess {
            errorMessage = "Unable to save credentials securely"
            print("Keychain save failed: \(status)")
        }
    }

    /// Verify password against stored hash
    /// - Parameters:
    ///   - password: Password to verify
    ///   - email: Email address (used to lookup stored hash)
    /// - Returns: true if password matches stored hash
    private func verifyPassword(_ password: String, for email: String) -> Bool {
        guard let storedHash = loadPasswordHash(email: email) else {
            return false
        }

        // Hash provided password and compare with stored hash
        return hashPassword(password) == storedHash
    }

    private func loadPasswordHash(email: String) -> String? {
        var query = keychainQuery(account: normalizedEmail(email))
        query[kSecMatchLimit as String] = kSecMatchLimitOne
        query[kSecReturnData as String] = kCFBooleanTrue

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess,
              let data = result as? Data,
              let hash = String(data: data, encoding: .utf8) else {
            return nil
        }

        return hash
    }

    private func normalizedEmail(_ email: String) -> String {
        email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }

    private func keychainQuery(account: String) -> [String: Any] {
        [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: "EchoWear.emailPassword",
            kSecAttrAccount as String: account
        ]
    }

    /// Hash password using SHA-256
    /// - Parameter password: Plain text password
    /// - Returns: Hex string of SHA-256 hash
    private func hashPassword(_ password: String) -> String {
        // NOTE: For production, use proper password hashing:
        //   - bcrypt (recommended)
        //   - scrypt
        //   - Argon2
        // SHA-256 is NOT ideal for passwords (too fast, no salt)
        // But acceptable for demo purposes

        let data = Data(password.utf8)
        let hash = SHA256.hash(data: data)  // Compute SHA-256 hash
        return hash.compactMap { String(format: "%02x", $0) }.joined()  // Convert to hex string
    }
}

// MARK: - Apple Sign In Coordinator

/// Coordinator that handles Apple Sign In authorization flow
/// Required to present Apple Sign In UI and handle callbacks
class AppleSignInCoordinator: NSObject, ObservableObject, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {

    /// Reference to authentication manager (to update auth state)
    var authManager: AuthenticationManager

    /// Initialize coordinator with authentication manager
    /// - Parameter authManager: AuthenticationManager instance
    init(authManager: AuthenticationManager) {
        self.authManager = authManager
    }

    /// Initiate Apple Sign In flow
    /// Presents native Apple Sign In UI with Face ID/Touch ID
    func handleSignInWithApple() {
        // Create Apple ID provider
        let provider = ASAuthorizationAppleIDProvider()

        // Create sign-in request
        let request = provider.createRequest()

        // Request user's full name and email
        // NOTE: Apple only provides these on FIRST sign-in
        // Subsequent sign-ins only provide user ID
        request.requestedScopes = [.fullName, .email]

        // Create and configure authorization controller
        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self  // Handle success/failure callbacks
        controller.presentationContextProvider = self  // Provide window for UI
        controller.performRequests()  // Present Apple Sign In UI
    }

    // MARK: - ASAuthorizationControllerDelegate

    /// Called when Apple Sign In succeeds
    /// - Parameters:
    ///   - controller: Authorization controller
    ///   - authorization: Authorization result with credentials
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        // Pass authorization to authentication manager
        authManager.signInWithApple(authorization: authorization)
    }

    /// Called when Apple Sign In fails or is cancelled
    /// - Parameters:
    ///   - controller: Authorization controller
    ///   - error: Error describing failure
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // Update authentication manager with error
        DispatchQueue.main.async {
            self.authManager.errorMessage = error.localizedDescription
            self.authManager.isLoading = false
        }
    }

    // MARK: - ASAuthorizationControllerPresentationContextProviding

    /// Provide window for Apple Sign In UI presentation
    /// - Parameter controller: Authorization controller
    /// - Returns: Window where UI should be presented
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        // Get the first window from connected scenes
        let scenes = UIApplication.shared.connectedScenes
        let windowScene = scenes.first as? UIWindowScene
        return windowScene?.windows.first ?? UIWindow()
    }
}
