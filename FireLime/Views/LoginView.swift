import SwiftUI

struct LoginView: View {
    @StateObject private var viewModel = AuthViewModel()
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                DesignSystem.Colors.background.ignoresSafeArea()
                
                VStack(spacing: DesignSystem.Spacing.xl) {
                    Spacer()
                    
                    // Logo/Header
                    VStack(spacing: 12) {
                        Image(systemName: "flame.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80, height: 80)
                            .foregroundStyle(DesignSystem.Colors.gradientPrimary)
                        
                        Text("Welcome Back")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(DesignSystem.Colors.textPrimary)
                        
                        Text("Sign in to continue your journey")
                            .font(.subheadline)
                            .foregroundColor(DesignSystem.Colors.textSecondary)
                    }
                    
                    // Form
                    VStack(spacing: DesignSystem.Spacing.md) {
                        CustomTextField(icon: "envelope", placeholder: "Email", text: $viewModel.email)
                        
                        CustomTextField(icon: "lock", placeholder: "Password", text: $viewModel.password, isSecure: true)
                        
                        HStack {
                            Spacer()
                            Button("Forgot Password?") {
                                // Action for forgot password
                            }
                            .font(.footnote)
                            .foregroundColor(DesignSystem.Colors.primary)
                        }
                    }
                    .padding(.top, 20)
                    
                    if let error = viewModel.errorMessage {
                        Text(error)
                            .font(.footnote)
                            .foregroundColor(DesignSystem.Colors.error)
                    }
                    
                    PrimaryButton(title: "Sign In", isLoading: viewModel.isLoading) {
                        Task {
                            await viewModel.signIn()
                        }
                    }
                    
                    HStack {
                        Rectangle().frame(height: 1).foregroundColor(DesignSystem.Colors.textSecondary.opacity(0.2))
                        Text("OR").font(.caption2).foregroundColor(DesignSystem.Colors.textSecondary)
                        Rectangle().frame(height: 1).foregroundColor(DesignSystem.Colors.textSecondary.opacity(0.2))
                    }
                    
                    VStack(spacing: 12) {
                        SocialAuthButton(title: "Continue with Google", iconName: "google_logo") {
                            Task {
                                await viewModel.signInWithGoogle()
                            }
                        }
                        SocialAuthButton(title: "Continue with Apple", iconName: "apple_logo") {
                            Task {
                                await viewModel.signInWithApple()
                            }
                        }
                    }
                    
                    Spacer()
                    
                    NavigationLink(destination: SignUpView()) {
                        HStack {
                            Text("Don't have an account?")
                                .foregroundColor(DesignSystem.Colors.textSecondary)
                            Text("Sign Up")
                                .fontWeight(.bold)
                                .foregroundColor(DesignSystem.Colors.primary)
                        }
                        .font(.footnote)
                    }
                }
                .padding(DesignSystem.Spacing.lg)
            }
            .navigationBarHidden(true)
        }
    }
}

#Preview {
    LoginView()
}
