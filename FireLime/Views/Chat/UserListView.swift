//
//  UserListView.swift
//  FireLime
//
//  Created by Apple on 08/05/2026.
//


import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct UserListView: View {
    @Environment(\.dismiss) var dismiss
    @State private var users: [UserProfile] = []
    @State private var searchText = ""
    
    // This closure will pass the selected user back to the main list
    var onUserSelected: (UserProfile) -> Void
    
    var body: some View {
        NavigationStack {
            List(filteredUsers) { user in
                Button {
                    onUserSelected(user)
                    dismiss()
                } label: {
                    HStack(spacing: 12) {
                        AvatarView(user: user, size: 44)
                        VStack(alignment: .leading) {
                            Text(user.displayName)
                                .font(.headline)
                            Text(user.email)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("New Message")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $searchText, prompt: "Search people...")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
            .task {
                // Fetch users from Firestore
                let db = Firestore.firestore()
                let snapshot = try? await db.collection("users").getDocuments()
                self.users = snapshot?.documents.compactMap { try? $0.data(as: UserProfile.self) } ?? []
            }
        }
    }
    
    var filteredUsers: [UserProfile] {
        let currentUID = Auth.auth().currentUser?.uid ?? ""

        // Filter out yourself AND apply search text
        return users.filter { user in
            let isNotMe = user.id != currentUID
            let matchesSearch = searchText.isEmpty || user.displayName.localizedCaseInsensitiveContains(searchText)
            return isNotMe && matchesSearch
        }
    }
}
