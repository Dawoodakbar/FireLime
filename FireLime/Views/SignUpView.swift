import SwiftUI

struct SignUpView: View {
    @StateObject private var viewModel = AuthViewModel()
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            DesignSystem.Colors.background.ignoresSafeArea()
            
            VStack(spacing: DesignSystem.Spacing.xl) {
                // Header
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                            .foregroundColor(DesignSystem.Colors.textPrimary)
                    }
                    Spacer()
                }
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Create Account")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(DesignSystem.Colors.textPrimary)
                    
                    Text("Join us today and start your journey")
                        .font(.subheadline)
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                // Form
                VStack(spacing: DesignSystem.Spacing.md) {
                    CustomTextField(icon: "envelope", placeholder: "Email", text: $viewModel.email)
                    
                    CustomTextField(icon: "lock", placeholder: "Password", text: $viewModel.password, isSecure: true)
                    
                    CustomTextField(icon: "lock.shield", placeholder: "Confirm Password", text: $viewModel.confirmPassword, isSecure: true)
                }
                .padding(.top, 20)
                
                if let error = viewModel.errorMessage {
                    Text(error)
                        .font(.footnote)
                        .foregroundColor(DesignSystem.Colors.error)
                }
                
                PrimaryButton(title: "Create Account", isLoading: viewModel.isLoading) {
                    Task {
                        await viewModel.signUp()
                    }
                }
                
                Spacer()
                
                Button(action: { dismiss() }) {
                    HStack {
                        Text("Already have an account?")
                            .foregroundColor(DesignSystem.Colors.textSecondary)
                        Text("Sign In")
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

#Preview {
    SignUpView()
}
