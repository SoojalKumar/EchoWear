//
//  SpeechRecognizer.swift
//  EchoWear
//
//  Handles real-time speech recognition with smart features:
//  - Timer-based auto-stop (configurable 10-120s)
//  - Silence detection (configurable 3-20s)
//  - Custom name detection with alerts
//  - Emergency keyword detection
//  - Sound + vibration feedback
//

import SwiftUI
import Foundation
import Speech
import AVFoundation
import AudioToolbox  // Required for AudioServicesPlaySystemSound
import UIKit
import UserNotifications  // For background notifications

/// ObservableObject that manages real-time speech recognition with smart auto-stop features
/// Uses Apple's Speech Framework for continuous voice monitoring
class SpeechRecognizer: NSObject, ObservableObject, SFSpeechRecognizerDelegate {

    // MARK: - Private Properties

    /// Speech recognizer configured for US English
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))

    /// Current recognition request (buffers audio data)
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?

    /// Current recognition task (processes speech)
    private var recognitionTask: SFSpeechRecognitionTask?

    /// Audio engine that captures microphone input
    private let audioEngine = AVAudioEngine()

    /// Timer that stops listening after maximum duration
    private var listeningTimer: Timer?

    /// Timer that stops listening after silence period
    private var silenceTimer: Timer?

    // MARK: - Published Properties (Observable by SwiftUI)

    /// Transcribed text from speech recognition (displayed in UI)
    @Published var heardText: String = ""

    /// Whether currently listening for speech
    @Published var isListening: Bool = false

    /// Array of detected keywords/names (displayed as badges in UI)
    @Published var detectedKeywords: [String] = []

    /// Maximum duration to listen before auto-stop (seconds)
    /// Range: 10-120 seconds, Default: 30s
    /// Prevents continuous battery drain
    @Published var listenDuration: Int = 30

    /// How long to wait in silence before auto-stop (seconds)
    /// Range: 3-20 seconds, Default: 5s
    /// Stops listening when user stops speaking
    @Published var silenceThreshold: Int = 5

    // MARK: - Configurable Detection Settings

    /// User's name to detect in speech
    /// When detected, triggers vibration + sound
    /// currently application has some problems detecting unique names like "soojal"
    @Published var userName: String = "Soojal"

    /// Emergency keywords to detect
    /// When detected, triggers vibration + sound + notification
    @Published var emergencyKeywords: [String] = [
        // Greetings
        "hello", "hey", "hi", "hiya", "yo", "greetings", "howdy",
        // Emergency
        "help", "emergency"
    ]

    // MARK: - Tracking

    /// Timestamp of last detected speech (used for silence detection)
    private var lastSpeechTime: Date?

    /// Tracks whether an audio tap is installed so cleanup is safe and repeatable.
    private var hasInstalledTap = false

    // MARK: - Initialization

    override init() {
        super.init()
        speechRecognizer?.delegate = self
        requestAuthorization()
    }

    /// Request notification permission for background alerts
    /// Shows iOS permission dialog on first call
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            DispatchQueue.main.async {
                if granted {
                    print("✅ Notification permission granted")
                } else {
                    print("❌ Notification permission denied")
                }
                if let error = error {
                    print("⚠️ Notification permission error: \(error.localizedDescription)")
                }
            }
        }
    }

    /// Clean up timers and audio session when object is deallocated
    deinit {
        stopListening()
    }

    // MARK: - Authorization

    /// Request speech recognition permission from user
    /// Shows iOS permission dialog on first call
    func requestAuthorization() {
        SFSpeechRecognizer.requestAuthorization { status in
            DispatchQueue.main.async {
                switch status {
                case .authorized:
                    print("✅ Speech permission granted")
                case .denied:
                    print("❌ Speech permission denied by user")
                case .restricted:
                    print("❌ Speech permission restricted (parental controls?)")
                case .notDetermined:
                    print("⚠️ Speech permission not determined")
                @unknown default:
                    print("❓ Unknown speech authorization status")
                }
            }
        }
    }

    /// Request permission and immediately start listening if granted
    /// Used when user taps "Start Listening" button
    func requestPermissionAndStart() {
        SFSpeechRecognizer.requestAuthorization { status in
            DispatchQueue.main.async {
                if status == .authorized {
                    self.startListening()
                } else {
                    print("❌ Cannot start listening: permission denied")
                }
            }
        }
    }

    // MARK: - Listening Control

    /// Start real-time speech recognition with smart auto-stop features
    /// Sets up:
    /// - Audio session (microphone access)
    /// - Recognition request (speech-to-text)
    /// - Maximum duration timer
    /// - Silence detection timer
    func startListening() {
        // Stop any existing listening session first
        stopListening()
        requestNotificationPermission()

        // Create new recognition request
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else {
            print("❌ Failed to create recognition request")
            return
        }

        // Configure audio session for recording
        let audioSession = AVAudioSession.sharedInstance()
        do {
            // .playAndRecord allows simultaneous recording and playback
            // .duckOthers lowers volume of other audio during recording
            try audioSession.setCategory(.playAndRecord, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("❌ Failed to configure audio session: \(error)")
            return
        }

        // Get microphone input node
        let inputNode = audioEngine.inputNode

        // Show partial results as user speaks (not just final result)
        recognitionRequest.shouldReportPartialResults = true

        // Update UI state
        DispatchQueue.main.async {
            self.isListening = true
            self.detectedKeywords.removeAll()
            self.lastSpeechTime = Date()
        }

        // TIMER 1: Maximum listening duration (prevents infinite listening)
        // Stops automatically after configured duration (default 30s)
        listeningTimer = Timer.scheduledTimer(withTimeInterval: TimeInterval(listenDuration), repeats: false) { [weak self] _ in
            DispatchQueue.main.async {
                self?.stopListening()
                print("⏱️ Listening timeout: stopped after \(self?.listenDuration ?? 0) seconds")
            }
        }

        // Start recognition task (processes speech in real-time)
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            guard let self = self else { return }

            // Handle errors (microphone issues, network problems, etc.)
            if let error = error {
                DispatchQueue.main.async {
                    print("❌ Recognition error: \(error.localizedDescription)")
                    self.stopListening()
                }
                return
            }

            // Process recognition result
            if let result = result {
                // Get transcribed text (converted to lowercase for keyword matching)
                let spoken = result.bestTranscription.formattedString.lowercased()

                DispatchQueue.main.async {
                    // Update UI with transcribed text
                    self.heardText = spoken
                    self.lastSpeechTime = Date()

                    // TIMER 2: Silence detection (stops when user stops talking)
                    // Reset timer on every new speech segment
                    self.silenceTimer?.invalidate()
                    self.silenceTimer = Timer.scheduledTimer(withTimeInterval: TimeInterval(self.silenceThreshold), repeats: false) { [weak self] _ in
                        guard let self = self else { return }
                        print("🤫 Silence detected: stopping after \(self.silenceThreshold) seconds")
                        self.stopListening()
                    }
                }

                // DETECTION 1: Check if user's name was spoken
                // Uses substring matching (e.g., "Hey Soojal" contains "soojal")
                if spoken.contains(self.userName.lowercased()) {
                    self.handleNameDetection(spoken)
                }

                // DETECTION 2: Check for emergency keywords
                // Checks all keywords in the emergencyKeywords array
                for keyword in self.emergencyKeywords {
                    if spoken.contains(keyword) {
                        self.handleKeywordDetection(keyword: keyword, fullText: spoken)
                    }
                }
            }
        }

        
        // Using smaller buffer size (512 bytes) for faster processing and lower latency
        // This ensures keyword detection happens quickly (typically within 1-2 seconds)
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.removeTap(onBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 512, format: recordingFormat) { [weak self] buffer, _ in
            // Send audio buffer to recognition request
            self?.recognitionRequest?.append(buffer)
        }
        hasInstalledTap = true

        // Start audio engine (begins capturing audio)
        audioEngine.prepare()
        do {
            try audioEngine.start()
            print("🎤 Listening started (max \(listenDuration)s, silence threshold \(silenceThreshold)s)...")
        } catch {
            print("❌ Failed to start audio engine: \(error)")
            stopListening()
        }
    }

    /// Stop speech recognition and clean up resources
    /// Called automatically by timers or manually by user
    func stopListening() {
        // Invalidate all timers
        listeningTimer?.invalidate()
        listeningTimer = nil
        silenceTimer?.invalidate()
        silenceTimer = nil

        // Stop audio engine if running
        if audioEngine.isRunning {
            audioEngine.stop()
        }

        if hasInstalledTap {
            audioEngine.inputNode.removeTap(onBus: 0)
            hasInstalledTap = false
        }

        // End recognition request and task
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        recognitionTask = nil

        // Deactivate audio session (allows other apps to play audio)
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setActive(false, options: .notifyOthersOnDeactivation)
        } catch {
            print("⚠️ Failed to deactivate audio session: \(error)")
        }

        if Thread.isMainThread {
            isListening = false
        } else {
            DispatchQueue.main.async { [weak self] in
                self?.isListening = false
            }
        }
        print("🛑 Stopped listening")
    }

    // MARK: - Detection Handlers

    /// Handle detection of user's name in speech
    /// Triggers: vibration + sound + notification
    /// Adds badge to UI with user's name
    /// - Parameter fullText: The complete transcribed text
    private func handleNameDetection(_ fullText: String) {
        DispatchQueue.main.async {
            // Add name badge to UI (if not already present)
            let badge = "👤 \(self.userName)"
            guard !self.detectedKeywords.contains(badge) else { return }
            self.detectedKeywords.append(badge)

            // Provide haptic and audio feedback
            self.vibrate()
            self.playNotificationSound()

            // Send notification (works in background)
            self.sendNotification(title: "Name Detected!", body: "Someone said '\(self.userName)'", sound: true)

            print("👤 Name detected: \(self.userName) in '\(fullText)'")
        }
    }

    /// Handle detection of emergency keyword in speech
    /// Triggers: vibration + sound + notification
    /// Adds badge to UI with keyword emoji
    /// - Parameters:
    ///   - keyword: The detected keyword (hello, hey, help, emergency)
    ///   - fullText: The complete transcribed text
    private func handleKeywordDetection(keyword: String, fullText: String) {
        DispatchQueue.main.async {
            // Get emoji for keyword and create badge
            let emoji = self.getEmojiForKeyword(keyword)
            let detection = "\(emoji) \(keyword)"

            // Add keyword badge to UI (if not already present)
            guard !self.detectedKeywords.contains(detection) else { return }
            self.detectedKeywords.append(detection)

            // Provide haptic and audio feedback
            self.vibrate()
            self.playNotificationSound()

            // Send notification (works in background)
            self.sendNotification(title: "\(emoji) Keyword Detected!", body: "Someone said '\(keyword)'", sound: true)

            print("\(emoji) Keyword detected: \(keyword) in '\(fullText)'")
        }
    }

    /// Map keyword to corresponding emoji for UI display
    /// - Parameter keyword: The detected keyword
    /// - Returns: Emoji representing the keyword type
    private func getEmojiForKeyword(_ keyword: String) -> String {
        switch keyword.lowercased() {
        case "hello", "hey", "hi", "hiya", "yo", "greetings", "howdy":
            return "👋"  // Greeting
        case "help":
            return "🆘"  // Help request
        case "emergency":
            return "🚨"  // Emergency alert
        default:
            return "⚠️"  // Generic alert
        }
    }

    // MARK: - Feedback (iOS-specific)

    #if os(iOS)
    /// Trigger haptic vibration on iOS devices
    /// Uses heavy impact for immediate attention and strong feedback
    /// Skips on simulator to avoid console errors
    private func vibrate() {
        #if targetEnvironment(simulator)
        // Skip haptics on simulator (no hardware support)
        print("🔇 Haptic feedback skipped (Simulator)")
        #else
        // Real device: trigger strong haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.prepare()  // Pre-warm the haptic engine for lower latency
        generator.impactOccurred()
        #endif
    }

    /// Play system notification sound (iOS only)
    /// Sound ID 1007 = SMS received tone (familiar to users)
    private func playNotificationSound() {
        AudioServicesPlaySystemSound(1007)
    }

    /// Send local notification (works in background)
    /// Notifies user when keywords are detected, even when app is minimized
    /// - Parameters:
    ///   - title: Notification title
    ///   - body: Notification message
    ///   - sound: Whether to play notification sound
    private func sendNotification(title: String, body: String, sound: Bool = true) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        if sound {
            content.sound = .default
        }
        content.badge = 1

        // Create trigger (immediate delivery)
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)

        // Create request with unique identifier
        let identifier = UUID().uuidString
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

        // Add notification to notification center
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Failed to send notification: \(error.localizedDescription)")
            } else {
                print("✅ Notification sent: \(title)")
            }
        }
    }

    #else
    // MARK: - Feedback (watchOS fallback)

    /// Vibration not implemented for watchOS (placeholder)
    private func vibrate() {
        print("⚠️ Vibration not supported on this platform")
    }

    /// Sound not implemented for watchOS (placeholder)
    private func playNotificationSound() {
        print("⚠️ Sound playback not supported on this platform")
    }
    #endif
}
