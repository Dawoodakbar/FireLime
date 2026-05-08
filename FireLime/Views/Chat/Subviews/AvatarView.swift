//
//  AvatarView.swift
//  FireLime
//
//  Created by Apple on 08/05/2026.
//
import SwiftUI

// MARK: - Reusable AvatarView
struct AvatarView: View {
    let user: UserProfile
    let size: CGFloat

    var body: some View {
        Group {
            if let urlStr = user.avatarURL, let url = URL(string: urlStr) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let img): img.resizable().scaledToFill()
                    default: fallbackAvatar
                    }
                }
            } else {
                fallbackAvatar
            }
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
    }

    private var fallbackAvatar: some View {
        ZStack {
            DesignSystem.Colors.gradientPrimary
            Text(user.displayName.prefix(1).uppercased())
                .font(.system(size: size * 0.38, weight: .semibold))
                .foregroundStyle(.white)
        }
    }
}
