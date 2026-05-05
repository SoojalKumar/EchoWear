import SwiftUI
import Foundation
import Speech
import AVFoundation
import AudioToolbox
import UIKit

class SpeechRecognizer: NSObject, ObservableObject, SFSpeechRecognizerDelegate {
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    private var listeningTimer: Timer?
    private var silenceTimer: Timer?

    // Published properties
    @Published var heardText: String = ""
    @Published var isListening: Bool = false
    @Published var detectedKeywords: [String] = []
    @Published var listenDuration: Int = 30 // Default 30 seconds
    @Published var silenceThreshold: Int = 5 // Stop after 5 seconds of silence

    // Configurable keywords
    @Published var userName: String = "Soojal" // User's name
    @Published var emergencyKeywords: [String] = [
        // Greetings
        "hello", "hey", "hi", "hiya", "yo", "greetings", "howdy",
        // Emergency
        "help", "emergency"
    ]

    // Tracking
    private var lastSpeechTime: Date?

    override init() {
        super.init()
        speechRecognizer?.delegate = self
        requestAuthorization()
    }

    func requestAuthorization() {
        SFSpeechRecognizer.requestAuthorization { status in
            DispatchQueue.main.async {
                switch status {
                case .authorized:
                    print("Speech permission granted")
                case .denied, .restricted, .notDetermined:
                    print("Speech permission denied")
                @unknown default:
                    print("Unknown speech authorization status")
                }
            }
        }
    }

    func requestPermissionAndStart() {
        SFSpeechRecognizer.requestAuthorization { status in
            DispatchQueue.main.async {
                if status == .authorized {
                    self.startListening()
                } else {
                    print("Speech permission denied")
                }
            }
        }
    }

    func startListening() {
        stopListening()

        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else { return }

        let audioSession = AVAudioSession.sharedInstance()
        try? audioSession.setCategory(.playAndRecord, mode: .measurement, options: .duckOthers)
        try? audioSession.setActive(true, options: .notifyOthersOnDeactivation)

        let inputNode = audioEngine.inputNode
        recognitionRequest.shouldReportPartialResults = true
        isListening = true
        detectedKeywords.removeAll()
        lastSpeechTime = Date()

        // Set up maximum listening duration timer
        listeningTimer = Timer.scheduledTimer(withTimeInterval: TimeInterval(listenDuration), repeats: false) { [weak self] _ in
            DispatchQueue.main.async {
                self?.stopListening()
                print("⏱️ Listening timeout: stopped after \(self?.listenDuration ?? 0) seconds")
            }
        }

        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            guard let self = self else { return }

            if let error = error {
                DispatchQueue.main.async {
                    self.isListening = false
                    print("Recognition error: \(error.localizedDescription)")
                }
                self.stopListening()
                return
            }

            if let result = result {
                let spoken = result.bestTranscription.formattedString.lowercased()

                DispatchQueue.main.async {
                    self.heardText = spoken
                    self.lastSpeechTime = Date()

                    // Reset silence timer on new speech
                    self.silenceTimer?.invalidate()
                    self.silenceTimer = Timer.scheduledTimer(withTimeInterval: TimeInterval(self.silenceThreshold), repeats: false) { [weak self] _ in
                        guard let self = self else { return }
                        print("🤫 Silence detected: stopping after \(self.silenceThreshold) seconds")
                        self.stopListening()
                    }
                }

                // Check for user name
                if spoken.contains(self.userName.lowercased()) {
                    self.handleNameDetection(spoken)
                }

                // Check for emergency keywords
                for keyword in self.emergencyKeywords {
                    if spoken.contains(keyword) {
                        self.handleKeywordDetection(keyword: keyword, fullText: spoken)
                    }
                }
            }
        }

        // Using smaller buffer size (512 bytes) for faster processing and lower latency
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 512, format: recordingFormat) { [weak self] buffer, _ in
            self?.recognitionRequest?.append(buffer)
        }

        audioEngine.prepare()
        try? audioEngine.start()
        print("🎤 Listening started (max \(listenDuration)s, silence threshold \(silenceThreshold)s)...")
    }

    func stopListening() {
        // Invalidate timers
        listeningTimer?.invalidate()
        listeningTimer = nil
        silenceTimer?.invalidate()
        silenceTimer = nil

        if audioEngine.isRunning {
            audioEngine.stop()
            audioEngine.inputNode.removeTap(onBus: 0)
        }
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        recognitionTask = nil

        // Deactivate audio session
        let audioSession = AVAudioSession.sharedInstance()
        try? audioSession.setActive(false, options: .notifyOthersOnDeactivation)

        isListening = false
        print("🛑 Stopped listening")
    }

    deinit {
        stopListening()
    }

    // MARK: - Detection Handlers

    private func handleNameDetection(_ fullText: String) {
        DispatchQueue.main.async {
            if !self.detectedKeywords.contains("👤 \(self.userName)") {
                self.detectedKeywords.append("👤 \(self.userName)")
            }
            self.vibrate()
            self.playNotificationSound()
            print("👤 Name detected: \(self.userName)")
        }
    }

    private func handleKeywordDetection(keyword: String, fullText: String) {
        DispatchQueue.main.async {
            let emoji = self.getEmojiForKeyword(keyword)
            let detection = "\(emoji) \(keyword)"
            if !self.detectedKeywords.contains(detection) {
                self.detectedKeywords.append(detection)
            }
            self.vibrate()
            self.playNotificationSound()
            print("\(emoji) Keyword detected: \(keyword)")
        }
    }

    private func getEmojiForKeyword(_ keyword: String) -> String {
        switch keyword.lowercased() {
        case "hello", "hey", "hi", "hiya", "yo", "greetings", "howdy": return "👋"
        case "help": return "🆘"
        case "emergency": return "🚨"
        default: return "⚠️"
        }
    }

    // MARK: - Feedback

    private func vibrate() {
        // Using heavy impact for immediate attention and noticeable feedback
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.prepare()
        generator.impactOccurred()
    }

    private func playNotificationSound() {
        // Play system sound
        AudioServicesPlaySystemSound(1007) // SMS received tone
    }
}
