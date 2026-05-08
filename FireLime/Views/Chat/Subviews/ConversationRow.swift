//
//  ConversationRow.swift
//  FireLime
//
//  Created by Apple on 08/05/2026.
//


import SwiftUI
import FirebaseAuth

struct ConversationRow: View {
    let conversation: Conversation
    @State private var currentUID = Auth.auth().currentUser?.uid ?? ""
    
    var body: some View {
        HStack(spacing: DesignSystem.Spacing.md) {
            // 1. Avatar
            ZStack(alignment: .bottomTrailing) {
                AvatarView(
                    user: conversation.otherUser ?? UserProfile(displayName: "Group", email: ""),
                    size: 56
                )
                
                // Online indicator (for DMs)
                if conversation.type == .direct && conversation.otherUser?.isOnline == true {
                    Circle()
                        .fill(DesignSystem.Colors.secondary)
                        .frame(width: 14, height: 14)
                        .overlay(Circle().stroke(Color.white, lineWidth: 2))
                }
            }
            
            // 2. Content
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(conversation.displayName(currentUID: currentUID))
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(DesignSystem.Colors.textPrimary)
                    
                    Spacer()
                    
                    // Time
                    Text(conversation.lastMessageTime.timeFormatted)
                        .font(.system(size: 12))
                        .foregroundStyle(DesignSystem.Colors.textSecondary)
                }
                
                HStack {
                    // Message Preview
                    Text(conversation.lastMessage.isEmpty ? "Start a conversation" : conversation.lastMessage)
                        .font(.system(size: 14))
                        .foregroundStyle(DesignSystem.Colors.textSecondary)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    // Unread Count Badge
                    let count = conversation.unreadCount(for: currentUID)
                    if count > 0 {
                        Text("\(count)")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 3)
                            .background(DesignSystem.Colors.primary)
                            .clipShape(Capsule())
                    }
                }
            }
        }
        .padding(.vertical, 8)
    }
}
