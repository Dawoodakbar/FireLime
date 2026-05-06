import SwiftUI
import Combine

@MainActor
class AuthViewModel: ObservableObject {
    
    @Published var email = ""
    @Published var password = ""
    @Published var confirmPassword = ""
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showPassword = false
    
    private let authManager: AuthManager
    private var cancellables = Set<AnyCancellable>()
    
    init(authManager: AuthManager = .shared) {
        self.authManager = authManager
    }
    
    var isSignInValid: Bool {
        !email.isEmpty && email.contains("@") && password.count >= 8
    }
    
    var isSignUpValid: Bool {
        isSignInValid && password == confirmPassword
    }
    
    func signIn() async {
        guard isSignInValid else { return }
        
        isLoading = true
        errorMessage = nil
        
        do {
            try await authManager.signIn(email: email, password: password)
            triggerHaptic(style: .success)
        } catch {
            errorMessage = error.localizedDescription
            triggerHaptic(style: .error)
        }
        
        isLoading = false
    }
    
    func signUp() async {
        guard isSignUpValid else { return }
        
        isLoading = true
        errorMessage = nil
        
        do {
            try await authManager.signUp(email: email, password: password)
            triggerHaptic(style: .success)
        } catch {
            errorMessage = error.localizedDescription
            triggerHaptic(style: .error)
        }
        
        isLoading = false
    }
    
    func signInWithApple() async {
        isLoading = true
        errorMessage = nil
        
        do {
            try await authManager.signInWithApple()
            triggerHaptic(style: .success)
        } catch {
            errorMessage = error.localizedDescription
            triggerHaptic(style: .error)
        }
        
        isLoading = false
    }
    
    func signInWithGoogle() async {
        isLoading = true
        errorMessage = nil
        
        do {
            try await authManager.signInWithGoogle()
            triggerHaptic(style: .success)
        } catch {
            errorMessage = error.localizedDescription
            triggerHaptic(style: .error)
        }
        
        isLoading = false
    }
    
    func signOut() {
        do {
            try authManager.signOut()
            triggerHaptic(style: .medium)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    private func triggerHaptic(style: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(style)
    }
    
    private func triggerHaptic(style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
}
