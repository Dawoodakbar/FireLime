//
//  MessageSkeletonRow.swift
//  FireLime
//
//  Created by Apple on 08/05/2026.
//


import SwiftUI

struct MessageSkeletonRow: View {
    let isSent: Bool
    @State private var shimmer = false

    var body: some View {
        HStack {
            if isSent { Spacer() }
            RoundedRectangle(cornerRadius: 16)
                .fill(shimmerGradient)
                .frame(
                    width: CGFloat.random(in: 120...220),
                    height: CGFloat.random(in: 36...52)
                )
            if !isSent { Spacer() }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.1).repeatForever(autoreverses: true)) {
                shimmer = true
            }
        }
    }

    private var shimmerGradient: LinearGradient {
        LinearGradient(
            colors: shimmer
                ? [Color(.systemGray5), Color(.systemGray4), Color(.systemGray5)]
                : [Color(.systemGray4), Color(.systemGray5), Color(.systemGray4)],
            startPoint: .leading, endPoint: .trailing
        )
    }
}