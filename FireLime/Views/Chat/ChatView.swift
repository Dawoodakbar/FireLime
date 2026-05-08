//
//  ChatView.swift
//  FireLime
//
//  Created by Apple on 08/05/2026.
//


import SwiftUI

struct ChatView: View {

    @StateObject private var vm: ChatViewModel
    @FocusState private var inputFocused: Bool
    @State private var showGroupInfo = false
    @State private var showDeleteAlert: Message? = nil
    @State private var scrollProxy: ScrollViewProxy? = nil

    init(conversation: Conversation) {
        _vm = StateObject(wrappedValue: ChatViewModel(conversation: conversation))
    }

    var body: some View {
        ZStack {
            // Chat background — subtle pattern like WhatsApp
            DesignSystem.Colors.background
                .ignoresSafeArea()

            VStack(spacing: 0) {
                messagesList
                typingIndicator
                inputBar
            }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { toolbarContent }
        .toolbarBackground(DesignSystem.Colors.surface, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .navigationBarBackButtonHidden(false)
        .onAppear { vm.onAppear() }
        .onDisappear { vm.onDisappear() }
        .alert("Delete Message?", isPresented: .constant(showDeleteAlert != nil)) {
            Button("Delete", role: .destructive) {
                if let msg = showDeleteAlert { vm.deleteMessage(msg) }
                showDeleteAlert = nil
            }
            Button("Cancel", role: .cancel) { showDeleteAlert = nil }
        }
        .sheet(isPresented: $showGroupInfo) {
            GroupInfoView(conversation: vm.conversation)
        }
    }

    // MARK: - Messages List
    private var messagesList: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 0) {
                    if vm.isLoading {
                        loadingView
                    } else {
                        ForEach(Array(vm.messages.enumerated()), id: \.element.id) { idx, message in
                            let showDate = shouldShowDate(at: idx)
                            let showAvatar = shouldShowAvatar(at: idx)

                            VStack(spacing: 0) {
                                if showDate {
                                    DateSeparatorView(date: message.timestamp)
                                }
                                MessageBubbleView(
                                    message: message,
                                    isGroup: vm.isGroup,
                                    showAvatar: showAvatar
                                )
                                .id(message.id)
                                .contextMenu {
                                    if message.isSentByCurrentUser {
                                        Button(role: .destructive) {
                                            showDeleteAlert = message
                                        } label: {
                                            Label("Delete", systemImage: "trash")
                                        }
                                    }
                                    Button {
                                        UIPasteboard.general.string = message.text
                                    } label: {
                                        Label("Copy", systemImage: "doc.on.doc")
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(.vertical, DesignSystem.Spacing.sm)
            }
            .scrollDismissesKeyboard(.interactively)
            .onAppear {
                scrollProxy = proxy
                scrollToBottom(proxy: proxy, animated: false)
            }
            .onChange(of: vm.messages) { _, _ in
                scrollToBottom(proxy: proxy, animated: true)
            }
            .onChange(of: inputFocused) { _, focused in
                if focused { scrollToBottom(proxy: proxy, animated: true) }
            }
        }
    }

    // MARK: - Typing Indicator
    @ViewBuilder
    private var typingIndicator: some View {
        if !vm.typingUsers.isEmpty {
            HStack(spacing: DesignSystem.Spacing.sm) {
                TypingIndicatorView()
                Text(typingText)
                    .font(.system(size: 12))
                    .foregroundStyle(DesignSystem.Colors.textSecondary)
                Spacer()
            }
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.vertical, 6)
            .transition(.move(edge: .bottom).combined(with: .opacity))
        }
    }

    private var typingText: String {
        switch vm.typingUsers.count {
        case 1: return "\(vm.typingUsers[0]) is typing..."
        case 2: return "\(vm.typingUsers[0]) and \(vm.typingUsers[1]) are typing..."
        default: return "Several people are typing..."
        }
    }

    // MARK: - Input Bar
    private var inputBar: some View {
        ChatInputBarView(
            text: $vm.inputText,
            isFocused: $inputFocused,
            onSend: { vm.sendMessage() },
            onTypingChanged: { vm.setTyping($0) }
        )
    }

    // MARK: - Toolbar
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .principal) {
            Button {
                if vm.isGroup { showGroupInfo = true }
            } label: {
                HStack(spacing: DesignSystem.Spacing.sm) {
                    // Avatar
                    chatHeaderAvatar

                    VStack(alignment: .leading, spacing: 1) {
                        Text(vm.navigationTitle)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(DesignSystem.Colors.textPrimary)

                        Text(vm.navigationSubtitle)
                            .font(.system(size: 12))
                            .foregroundStyle(
                                vm.conversation.otherUser?.isOnline == true && !vm.isGroup
                                    ? DesignSystem.Colors.secondary
                                    : DesignSystem.Colors.textSecondary
                            )
                    }
                }
            }
            .buttonStyle(.plain)
        }

        ToolbarItem(placement: .topBarTrailing) {
            if vm.isGroup {
                Button {
                    showGroupInfo = true
                } label: {
                    Image(systemName: "info.circle")
                        .foregroundStyle(DesignSystem.Colors.primary)
                }
            }
        }
    }

    // MARK: - Header Avatar
    @ViewBuilder
    private var chatHeaderAvatar: some View {
        if vm.isGroup {
            ZStack {
                Circle()
                    .fill(DesignSystem.Colors.gradientPrimary)
                    .frame(width: 36, height: 36)
                Image(systemName: "person.3.fill")
                    .font(.system(size: 14))
                    .foregroundStyle(.white)
            }
        } else if let user = vm.conversation.otherUser {
            AvatarView(user: user, size: 36)
        }
    }

    // MARK: - Loading View
    private var loadingView: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            ForEach(0..<8, id: \.self) { i in
                MessageSkeletonRow(isSent: i % 3 == 0)
            }
        }
        .padding(.horizontal, DesignSystem.Spacing.md)
    }

    // MARK: - Helpers
    private func scrollToBottom(proxy: ScrollViewProxy, animated: Bool) {
        guard let last = vm.messages.last?.id else { return }
        if animated {
            withAnimation(.easeOut(duration: 0.25)) {
                proxy.scrollTo(last, anchor: .bottom)
            }
        } else {
            proxy.scrollTo(last, anchor: .bottom)
        }
    }

    /// Show date separator when date changes between messages
    private func shouldShowDate(at index: Int) -> Bool {
        guard index > 0 else { return true }
        let prev = vm.messages[index - 1].timestamp
        let curr = vm.messages[index].timestamp
        return !Calendar.current.isDate(prev, inSameDayAs: curr)
    }

    /// Show avatar in group only when sender changes
    private func shouldShowAvatar(at index: Int) -> Bool {
        guard vm.isGroup, !vm.messages[index].isSentByCurrentUser else { return false }
        if index == vm.messages.count - 1 { return true }
        return vm.messages[index + 1].senderId != vm.messages[index].senderId
    }
}

#Preview {
    NavigationStack {
        ChatView(conversation: .mockDirect)
    }
}
