//
//  TypingIndicatorView.swift
//  FireLime
//
//  Created by Apple on 08/05/2026.
//


import SwiftUI

struct TypingIndicatorView: View {

    @State private var animating = false

    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<3, id: \.self) { i in
                Circle()
                    .fill(DesignSystem.Colors.textSecondary.opacity(0.5))
                    .frame(width: 7, height: 7)
                    .scaleEffect(animating ? 1.0 : 0.5)
                    .animation(
                        .easeInOut(duration: 0.5)
                        .repeatForever()
                        .delay(Double(i) * 0.15),
                        value: animating
                    )
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.Radius.full))
        .shadow(color: .black.opacity(0.06), radius: 3, x: 0, y: 1)
        .onAppear { animating = true }
    }
}