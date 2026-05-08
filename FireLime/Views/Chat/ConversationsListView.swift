//
//  ConversationsListView.swift
//  FireLime
//
//  Created by Apple on 08/05/2026.
//
import SwiftUI


struct ConversationsListView: View {

    @State private var showUserList = false
    @State private var selectedConversation: Conversation? = nil
    @StateObject private var vm = ConversationsViewModel() // You'll need this VM
    
    var body: some View {
        List(vm.conversations) { conversation in
            NavigationLink(destination: ChatView(conversation: conversation)) {
                ConversationRow(conversation: conversation)
            }
        }
        .navigationTitle("Messages")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showUserList = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title3)
                        .foregroundStyle(DesignSystem.Colors.primary)
                }
            }
        }
        .sheet(isPresented: $showUserList) {
            UserListView { user in
                startNewChat(with: user)
            }
        }
    }

    func startNewChat(with user: UserProfile) {
        Task {
            do {
                // 1. Create or find the DM ID in Firebase
                let chatId = try await ConversationService.shared.getOrCreateDirect(with: user.id!)

                // 2. Create a conversation object to navigate to
                // (You can also fetch the full object from the DB here)
                let newChat = Conversation(id: chatId, type: .direct, participants: [], admins: [], lastMessage: "", lastMessageTime: Date(), unreadCounts: [:], otherUser: user)

                // 3. Set this as the selected chat to trigger navigation
                self.selectedConversation = newChat
            } catch {
                print("Error starting chat: \(error)")
            }
        }
    }
}


