//
//  GroupInfoView.swift
//  FireLime
//
//  Created by Apple on 08/05/2026.
//


import SwiftUI

struct GroupInfoView: View {

    let conversation: Conversation
    @Environment(\.dismiss) private var dismiss
    @State private var showAddMember = false

    private var currentUID: String? { AuthManager.shared.currentUserId }
    private var isAdmin: Bool {
        conversation.isAdmin(currentUID ?? "")
    }

    var body: some View {
        NavigationStack {
            List {
                // Group header
                Section {
                    HStack(spacing: DesignSystem.Spacing.md) {
                        ZStack {
                            Circle()
                                .fill(DesignSystem.Colors.gradientPrimary)
                                .frame(width: 64, height: 64)
                            Image(systemName: "person.3.fill")
                                .font(.system(size: 26))
                                .foregroundStyle(.white)
                        }
                        VStack(alignment: .leading, spacing: 4) {
                            Text(conversation.groupName ?? "Group")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundStyle(DesignSystem.Colors.textPrimary)
                            Text("\(conversation.participants.count) members")
                                .font(.system(size: 14))
                                .foregroundStyle(DesignSystem.Colors.textSecondary)
                        }
                    }
                    .padding(.vertical, DesignSystem.Spacing.sm)
                }

                // Members
                Section("Members") {
                    ForEach(conversation.groupMembers ?? [], id: \.id) { member in
                        HStack(spacing: DesignSystem.Spacing.md) {
                            AvatarView(user: member, size: 40)

                            VStack(alignment: .leading, spacing: 2) {
                                Text(member.displayName)
                                    .font(.system(size: 15, weight: .medium))
                                    .foregroundStyle(DesignSystem.Colors.textPrimary)
                                if member.isOnline {
                                    Text("Online")
                                        .font(.system(size: 12))
                                        .foregroundStyle(DesignSystem.Colors.secondary)
                                }
                            }

                            Spacer()

                            if conversation.isAdmin(member.id ?? "") {
                                Text("Admin")
                                    .font(.system(size: 11, weight: .semibold))
                                    .foregroundStyle(DesignSystem.Colors.primary)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 3)
                                    .background(DesignSystem.Colors.primary.opacity(0.1))
                                    .clipShape(Capsule())
                            }
                        }
                        .padding(.vertical, 4)
                    }

                    if isAdmin {
                        Button {
                            showAddMember = true
                        } label: {
                            HStack(spacing: DesignSystem.Spacing.md) {
                                ZStack {
                                    Circle()
                                        .fill(DesignSystem.Colors.primary.opacity(0.1))
                                        .frame(width: 40, height: 40)
                                    Image(systemName: "plus")
                                        .foregroundStyle(DesignSystem.Colors.primary)
                                }
                                Text("Add Member")
                                    .foregroundStyle(DesignSystem.Colors.primary)
                            }
                        }
                    }
                }

                // Leave group
                Section {
                    Button(role: .destructive) {
                        guard let uid = currentUID,
                              let id = conversation.id else { return }
                        Task {
                            try? await ConversationService.shared
                                .removeMember(uid, from: id)
                            dismiss()
                        }
                    } label: {
                        Label("Leave Group", systemImage: "rectangle.portrait.and.arrow.right")
                    }
                }
            }
            .navigationTitle("Group Info")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}
