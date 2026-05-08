//
//  ChatInputBarView.swift
//  FireLime
//
//  Created by Apple on 08/05/2026.
//


import SwiftUI

struct ChatInputBarView: View {

    @Binding var text: String
    var isFocused: FocusState<Bool>.Binding
    let onSend: () -> Void
    let onTypingChanged: (Bool) -> Void

    @State private var textHeight: CGFloat = 36

    var body: some View {
        HStack(alignment: .bottom, spacing: DesignSystem.Spacing.sm) {
            // Expandable text field
            ZStack(alignment: .leading) {
                if text.isEmpty {
                    Text("Message...")
                        .font(.system(size: 15))
                        .foregroundStyle(DesignSystem.Colors.textSecondary.opacity(0.6))
                        .padding(.leading, 14)
                        .padding(.bottom, 8)
                }

                TextEditor(text: $text)
                    .font(.system(size: 15))
                    .foregroundStyle(DesignSystem.Colors.textPrimary)
                    .scrollContentBackground(.hidden)
                    .focused(isFocused)
                    .frame(minHeight: 36, maxHeight: 120)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .onChange(of: text) { _, newValue in
                        onTypingChanged(!newValue.isEmpty)
                    }
            }
            .background(DesignSystem.Colors.surface)
            .clipShape(RoundedRectangle(cornerRadius: DesignSystem.Radius.full))
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.Radius.full)
                    .stroke(DesignSystem.Colors.textSecondary.opacity(0.2), lineWidth: 1)
            )

            // Send button
            Button(action: onSend) {
                ZStack {
                    Circle()
                        .fill(
                            text.trimmingCharacters(in: .whitespaces).isEmpty
                                ? AnyShapeStyle(Color.gray.opacity(0.3))
                                : AnyShapeStyle(DesignSystem.Colors.gradientPrimary)
                        )
                        .frame(width: 38, height: 38)

                    Image(systemName: "arrow.up")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.white)
                }
            }
            .disabled(text.trimmingCharacters(in: .whitespaces).isEmpty)
            .scaleEffect(text.trimmingCharacters(in: .whitespaces).isEmpty ? 0.9 : 1.0)
            .animation(.spring(response: 0.2), value: text.isEmpty)
        }
        .padding(.horizontal, DesignSystem.Spacing.md)
        .padding(.vertical, DesignSystem.Spacing.sm)
        .background(
            DesignSystem.Colors.surface
                .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: -2)
        )
    }
}