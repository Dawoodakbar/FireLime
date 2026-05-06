import SwiftUI

struct PrimaryButton: View {
    let title: String
    let isLoading: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                DesignSystem.Colors.gradientPrimary
                
                if isLoading {
                    ProgressView()
                        .tint(.white)
                } else {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.white)
                }
            }
            .frame(height: 56)
            .cornerRadius(DesignSystem.Radius.md)
            .shadow(color: DesignSystem.Colors.primary.opacity(0.3), radius: 10, x: 0, y: 5)
        }
        .disabled(isLoading)
    }
}

struct CustomTextField: View {
    let icon: String
    let placeholder: String
    @Binding var text: String
    var isSecure: Bool = false
    @State private var isShowing = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .foregroundColor(DesignSystem.Colors.textSecondary)
                    .frame(width: 24)
                
                if isSecure && !isShowing {
                    SecureField(placeholder, text: $text)
                        .autocapitalization(.none)
                } else {
                    TextField(placeholder, text: $text)
                        .autocapitalization(.none)
                        .keyboardType(icon == "envelope" ? .emailAddress : .default)
                }
                
                if isSecure {
                    Button(action: { isShowing.toggle() }) {
                        Image(systemName: isShowing ? "eye.slash" : "eye")
                            .foregroundColor(DesignSystem.Colors.textSecondary)
                    }
                }
            }
            .padding()
            .background(DesignSystem.Colors.surface)
            .cornerRadius(DesignSystem.Radius.md)
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.Radius.md)
                    .stroke(DesignSystem.Colors.textSecondary.opacity(0.2), lineWidth: 1)
            )
        }
    }
}

struct SocialAuthButton: View {
    let title: String
    let iconName: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(iconName) // Replace with real asset names
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(DesignSystem.Colors.textPrimary)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(DesignSystem.Colors.surface)
            .cornerRadius(DesignSystem.Radius.md)
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.Radius.md)
                    .stroke(DesignSystem.Colors.textSecondary.opacity(0.2), lineWidth: 1)
            )
        }
    }
}
