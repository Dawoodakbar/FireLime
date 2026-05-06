import SwiftUI
import FirebaseAuth

struct HomeView: View {
    @StateObject private var viewModel = AuthViewModel()
    
    var body: some View {
        NavigationView {
            ZStack {
                DesignSystem.Colors.background.ignoresSafeArea()
                
                VStack(spacing: 24) {
                    // Profile Section
                    VStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(DesignSystem.Colors.gradientPrimary)
                                .frame(width: 100, height: 100)
                            
                            Image(systemName: "person.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 50, height: 50)
                                .foregroundColor(.white)
                        }
                        
                        VStack(spacing: 4) {
                            Text("Welcome Home!")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Text(AuthManager.shared.user?.email ?? "User")
                                .font(.subheadline)
                                .foregroundColor(DesignSystem.Colors.textSecondary)
                        }
                    }
                    .padding(.top, 40)
                    
                    // Card Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Your Dashboard")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                DashboardCard(title: "Progress", icon: "chart.bar.fill", value: "85%", color: .blue)
                                DashboardCard(title: "Activity", icon: "bolt.fill", value: "12h", color: .orange)
                                DashboardCard(title: "Score", icon: "star.fill", value: "2400", color: .purple)
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                    Spacer()
                    
                    Button(action: { viewModel.signOut() }) {
                        HStack {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                            Text("Sign Out")
                        }
                        .fontWeight(.semibold)
                        .foregroundColor(DesignSystem.Colors.error)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(DesignSystem.Colors.error.opacity(0.1))
                        .cornerRadius(DesignSystem.Radius.md)
                    }
                    .padding(DesignSystem.Spacing.lg)
                }
            }
            .navigationTitle("FireLime")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct DashboardCard: View {
    let title: String
    let icon: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(DesignSystem.Colors.textSecondary)
                Text(value)
                    .font(.title3)
                    .fontWeight(.bold)
            }
        }
        .frame(width: 120, height: 120)
        .padding()
        .background(DesignSystem.Colors.surface)
        .cornerRadius(DesignSystem.Radius.md)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
}

#Preview {
    HomeView()
}
