import Foundation
import FirebaseAuth
import Combine
import GoogleSignIn
import FirebaseFirestore

enum AuthError: LocalizedError {
    case invalidEmail
    case userNotFound
    case wrongPassword
    case emailAlreadyInUse
    case weakPassword
    case networkError
    case userCancelled
    case unknown(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidEmail: return "The email address is badly formatted."
        case .userNotFound: return "No user found with this email."
        case .wrongPassword: return "Incorrect password. Please try again."
        case .emailAlreadyInUse: return "This email is already registered."
        case .weakPassword: return "The password must be at least 6 characters long."
        case .networkError: return "A network error occurred. Please check your connection."
        case .userCancelled: return "Sign-in was cancelled."
        case .unknown(let message): return message
        }
    }
}

protocol AuthManagerProtocol {
    var user: User? { get }
    var isAuthenticated: Bool { get }
    
    func signIn(email: String, password: String) async throws
    func signUp(email: String, password: String, displayName: String) async throws
    func signInWithApple() async throws
    func signInWithGoogle() async throws
    func verifyPhoneNumber(_ phoneNumber: String) async throws -> String
    func signInWithPhone(verificationID: String, verificationCode: String) async throws
    func signOut() throws
    func resetPassword(email: String) async throws
}

class AuthManager: ObservableObject, AuthManagerProtocol {
    
    static let shared = AuthManager()
    
    @Published var user: User?
    private var cancellables = Set<AnyCancellable>()
    private let appleSignInHelper = AppleSignInHelper()
    
    var isAuthenticated: Bool {
        return user != nil
    }

    var currentUserId: String? {
        Auth.auth().currentUser?.uid
    }

    var currentDisplayName: String? {
        Auth.auth().currentUser?.displayName
    }

    var currentAvatarURL: String? {
        Auth.auth().currentUser?.photoURL?.absoluteString
    }

    private init() {
        // Listen to Auth state changes
        Auth.auth().addStateDidChangeListener { [weak self] _, user in
            self?.user = user
        }
    }
    
    @MainActor
    func signIn(email: String, password: String) async throws {
        do {
            try await Auth.auth().signIn(withEmail: email, password: password)
        } catch {
            throw mapFirebaseError(error)
        }
    }
    
    @MainActor
    func signUp(email: String, password: String, displayName: String) async throws {
        do {
            // 1. Create the user in Firebase Auth
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            let uid = result.user.uid

            // 2. Create the user profile in Firestore
            let userData: [String: Any] = [
                "id": uid,
                "displayName": displayName,
                "email": email,
                "avatarURL": "",
                "isOnline": true,
                "lastSeen": FieldValue.serverTimestamp()
            ]

            try await Firestore.firestore().collection("users").document(uid).setData(userData)

        } catch {
            throw mapFirebaseError(error)
        }
    }

    @MainActor
    func signInWithApple() async throws {
        _ = try await appleSignInHelper.startSignInWithApple()
    }
    
    @MainActor
    func signInWithGoogle() async throws {
        guard let topVC = Utilities.shared.topViewController() else {
            throw AuthError.unknown("Cannot find top view controller to present Google Sign-In.")
        }
        
        do {
            let gidSignInResult = try await GIDSignIn.sharedInstance.signIn(withPresenting: topVC)
            
            guard let idToken = gidSignInResult.user.idToken?.tokenString else {
                throw AuthError.unknown("Missing ID Token from Google.")
            }
            
            let accessToken = gidSignInResult.user.accessToken.tokenString
            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
            
            try await Auth.auth().signIn(with: credential)
        } catch {
            // Check if the user cancelled the flow
            let nsError = error as NSError
            if nsError.domain == kGIDSignInErrorDomain && nsError.code == GIDSignInError.canceled.rawValue {
                // Return a special error or unknown, which your ViewModel can silently ignore or you can map it
                throw AuthError.unknown("User cancelled Google Sign-In.")
            }
            throw mapFirebaseError(error)
        }
    }
    
    @MainActor
    func verifyPhoneNumber(_ phoneNumber: String) async throws -> String {
        return try await withCheckedThrowingContinuation { continuation in
            PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil) { verificationID, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                continuation.resume(returning: verificationID ?? "")
            }
        }
    }
    
    @MainActor
    func signInWithPhone(verificationID: String, verificationCode: String) async throws {
        let credential = PhoneAuthProvider.provider().credential(
            withVerificationID: verificationID,
            verificationCode: verificationCode
        )
        try await Auth.auth().signIn(with: credential)
    }
    
    func signOut() throws {
        try Auth.auth().signOut()
    }
    
    @MainActor
    func resetPassword(email: String) async throws {
        do {
            try await Auth.auth().sendPasswordReset(withEmail: email)
        } catch {
            throw mapFirebaseError(error)
        }
    }
    
    private func mapFirebaseError(_ error: Error) -> AuthError {
        let nsError = error as NSError
        guard let errorCode = AuthErrorCode(rawValue: nsError.code) else {
            return .unknown(error.localizedDescription)
        }
        
        switch errorCode {
        case .invalidEmail: return .invalidEmail
        case .userNotFound: return .userNotFound
        case .wrongPassword: return .wrongPassword
        case .emailAlreadyInUse: return .emailAlreadyInUse
        case .weakPassword: return .weakPassword
        case .networkError: return .networkError
        default: return .unknown(error.localizedDescription)
        }
    }
}
