//
//  CreateGroupView.swift
//  FireLime
//
//  Created by Apple on 08/05/2026.
//


import SwiftUI

struct CreateGroupView: View {

    @StateObject private var vm = CreateGroupViewModel()
    @Environment(\.dismiss) private var dismiss

    // Called when group is created — navigate to ChatView
    var onGroupCreated: ((String) -> Void)?

    var body: some View {
        NavigationStack {
            ZStack {
                DesignSystem.Colors.background.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: DesignSystem.Spacing.lg) {
                        groupNameSection
                        addMembersSection
                        selectedMembersSection
                    }
                    .padding(DesignSystem.Spacing.md)
                }
            }
            .navigationTitle("New Group")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { toolbarContent }
            .onChange(of: vm.searchQuery) { _, _ in
                Task { await vm.searchUsers() }
            }
            .onChange(of: vm.createdConversationId) { _, id in
                if let id {
                    onGroupCreated?(id)
                    dismiss()
                }
            }
            .alert("Error", isPresented: .constant(vm.errorMessage != nil)) {
                Button("OK") { vm.errorMessage = nil }
            } message: {
                Text(vm.errorMessage ?? "")
            }
        }
    }

    // MARK: - Group Name Section
    private var groupNameSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            Text("GROUP NAME")
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(DesignSystem.Colors.textSecondary)
                .tracking(1)

            HStack(spacing: DesignSystem.Spacing.sm) {
                // Group icon placeholder
                ZStack {
                    Circle()
                        .fill(DesignSystem.Colors.gradientPrimary)
                        .frame(width: 44, height: 44)
                    Image(systemName: "person.3.fill")
                        .font(.system(size: 16))
                        .foregroundStyle(.white)
                }

                TextField("Enter group name...", text: $vm.groupName)
                    .font(.system(size: 16))
                    .foregroundStyle(DesignSystem.Colors.textPrimary)
                    .autocorrectionDisabled()
            }
            .padding(DesignSystem.Spacing.md)
            .background(DesignSystem.Colors.surface)
            .clipShape(RoundedRectangle(cornerRadius: DesignSystem.Radius.md))
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.Radius.md)
                    .stroke(
                        vm.groupName.isEmpty
                            ? Color.clear
                            : DesignSystem.Colors.primary.opacity(0.4),
                        lineWidth: 1.5
                    )
            )
        }
    }

    // MARK: - Add Members Section
    private var addMembersSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            Text("ADD MEMBERS")
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(DesignSystem.Colors.textSecondary)
                .tracking(1)

            // Search field
            HStack(spacing: DesignSystem.Spacing.sm) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(DesignSystem.Colors.textSecondary)
                    .font(.system(size: 14))

                TextField("Search by name...", text: $vm.searchQuery)
                    .font(.system(size: 15))
                    .autocorrectionDisabled()
            }
            .padding(DesignSystem.Spacing.md)
            .background(DesignSystem.Colors.surface)
            .clipShape(RoundedRectangle(cornerRadius: DesignSystem.Radius.md))

            // Search results
            if !vm.searchResults.isEmpty {
                VStack(spacing: 0) {
                    ForEach(vm.searchResults) { user in
                        UserSearchResultRow(user: user) {
                            withAnimation(.spring(response: 0.3)) {
                                vm.toggleMember(user)
                                vm.searchQuery = ""
                            }
                        }
                        if user.id != vm.searchResults.last?.id {
                            Divider()
                                .padding(.leading, 64)
                        }
                    }
                }
                .background(DesignSystem.Colors.surface)
                .clipShape(RoundedRectangle(cornerRadius: DesignSystem.Radius.md))
            }
        }
    }

    // MARK: - Selected Members Section
    @ViewBuilder
    private var selectedMembersSection: some View {
        if !vm.selectedMembers.isEmpty {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                HStack {
                    Text("MEMBERS")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(DesignSystem.Colors.textSecondary)
                        .tracking(1)
                    Spacer()
                    Text(vm.memberCountText)
                        .font(.system(size: 12))
                        .foregroundStyle(DesignSystem.Colors.primary)
                }

                // Horizontal scrollable avatar chips
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: DesignSystem.Spacing.md) {
                        ForEach(vm.selectedMembers) { member in
                            MemberChipView(user: member) {
                                withAnimation(.spring(response: 0.3)) {
                                    vm.removeMember(member)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 2)
                    .padding(.vertical, 4)
                }

                // Full member list
                VStack(spacing: 0) {
                    ForEach(vm.selectedMembers) { member in
                        SelectedMemberRow(user: member) {
                            withAnimation(.spring(response: 0.3)) {
                                vm.removeMember(member)
                            }
                        }
                        if member.id != vm.selectedMembers.last?.id {
                            Divider().padding(.leading, 64)
                        }
                    }
                }
                .background(DesignSystem.Colors.surface)
                .clipShape(RoundedRectangle(cornerRadius: DesignSystem.Radius.md))
            }
        }
    }

    // MARK: - Toolbar
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Button("Cancel") { dismiss() }
                .foregroundStyle(DesignSystem.Colors.textSecondary)
        }

        ToolbarItem(placement: .topBarTrailing) {
            Button {
                Task { await vm.createGroup() }
            } label: {
                if vm.isCreating {
                    ProgressView()
                        .tint(.white)
                        .frame(width: 60, height: 32)
                        .background(DesignSystem.Colors.gradientPrimary)
                        .clipShape(Capsule())
                } else {
                    Text("Create")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: 60, height: 32)
                        .background(
                            vm.isValid
                                ? AnyShapeStyle(DesignSystem.Colors.gradientPrimary)
                                : AnyShapeStyle(Color.gray.opacity(0.4))
                        )
                        .clipShape(Capsule())
                }
            }
            .disabled(!vm.isValid || vm.isCreating)
        }
    }
}

// MARK: - Sub-views

struct UserSearchResultRow: View {
    let user: UserProfile
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: DesignSystem.Spacing.md) {
                AvatarView(user: user, size: 44)

                VStack(alignment: .leading, spacing: 2) {
                    Text(user.displayName)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(DesignSystem.Colors.textPrimary)
                    if user.isOnline {
                        Text("Online")
                            .font(.system(size: 12))
                            .foregroundStyle(DesignSystem.Colors.secondary)
                    }
                }

                Spacer()

                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 22))
                    .foregroundStyle(DesignSystem.Colors.primary)
            }
            .padding(DesignSystem.Spacing.md)
        }
    }
}

struct SelectedMemberRow: View {
    let user: UserProfile
    let onRemove: () -> Void

    var body: some View {
        HStack(spacing: DesignSystem.Spacing.md) {
            AvatarView(user: user, size: 44)

            Text(user.displayName)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(DesignSystem.Colors.textPrimary)

            Spacer()

            Button(action: onRemove) {
                Image(systemName: "minus.circle.fill")
                    .font(.system(size: 22))
                    .foregroundStyle(DesignSystem.Colors.error)
            }
        }
        .padding(DesignSystem.Spacing.md)
    }
}

struct MemberChipView: View {
    let user: UserProfile
    let onRemove: () -> Void

    var body: some View {
        VStack(spacing: 4) {
            ZStack(alignment: .topTrailing) {
                AvatarView(user: user, size: 48)

                Button(action: onRemove) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundStyle(DesignSystem.Colors.error)
                        .background(Circle().fill(Color.white).padding(2))
                }
                .offset(x: 4, y: -4)
            }

            Text(user.displayName.components(separatedBy: " ").first ?? "")
                .font(.system(size: 11))
                .foregroundStyle(DesignSystem.Colors.textSecondary)
                .lineLimit(1)
                .frame(width: 52)
        }
    }
}


