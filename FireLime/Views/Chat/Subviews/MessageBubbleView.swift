//
//  MessageBubbleView.swift
//  FireLime
//
//  Created by Apple on 08/05/2026.
//


import SwiftUI

struct MessageBubbleView: View {

    let message: Message
    let isGroup: Bool
    let showAvatar: Bool

    private var isMine: Bool { message.isSentByCurrentUser }

    var body: some View {
        HStack(alignment: .bottom, spacing: DesignSystem.Spacing.sm) {
            if isMine {
                Spacer(minLength: 60)
                bubbleContent
            } else {
                // Avatar slot — always takes space to keep alignment consistent
                if isGroup {
                    if showAvatar {
                        senderAvatar
                    } else {
                        Color.clear.frame(width: 28)
                    }
                }
                bubbleContent
                Spacer(minLength: 60)
            }
        }
        .padding(.horizontal, DesignSystem.Spacing.md)
        .padding(.vertical, 2)
    }

    // MARK: - Bubble
    private var bubbleContent: some View {
        VStack(alignment: isMine ? .trailing : .leading, spacing: 3) {
            // Sender name — group chats only, received messages only
            if isGroup && !isMine && showAvatar {
                Text(message.senderName)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(senderColor)
                    .padding(.leading, 4)
            }

            // The bubble itself
            HStack(alignment: .bottom, spacing: DesignSystem.Spacing.xs) {
                if !isMine {
                    Text(message.text)
                        .font(.system(size: 15))
                        .foregroundStyle(DesignSystem.Colors.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                if isMine {
                    Text(message.text)
                        .font(.system(size: 15))
                        .foregroundStyle(.white)
                        .fixedSize(horizontal: false, vertical: true)
                }

                // Timestamp + read receipt (sent messages)
                VStack(alignment: .trailing, spacing: 0) {
                    Spacer(minLength: 0)
                    HStack(spacing: 2) {
                        Text(message.timestamp.timeFormatted)
                            .font(.system(size: 10))
                            .foregroundStyle(
                                isMine ? .white.opacity(0.7) : DesignSystem.Colors.textSecondary
                            )
                        if isMine {
                            readReceiptIcon
                        }
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(isMine ? AnyView(bubbleBackground) : AnyView(receivedBackground))
            .clipShape(BubbleShape(isMine: isMine))
        }
    }

    // MARK: - Bubble Backgrounds
    private var bubbleBackground: some View {
        DesignSystem.Colors.gradientPrimary
    }

    private var receivedBackground: some View {
        Color.white
            .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }

    // MARK: - Read Receipt
    @ViewBuilder
    private var readReceiptIcon: some View {
        if message.isRead {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 11))
                .foregroundStyle(.white.opacity(0.9))
        } else {
            Image(systemName: "checkmark.circle")
                .font(.system(size: 11))
                .foregroundStyle(.white.opacity(0.6))
        }
    }

    // MARK: - Sender Avatar (group)
    private var senderAvatar: some View {
        Group {
            if let urlStr = message.senderAvatarURL,
               let url = URL(string: urlStr) {
                AsyncImage(url: url) { phase in
                    if case .success(let img) = phase {
                        img.resizable().scaledToFill()
                    } else {
                        avatarFallback
                    }
                }
            } else {
                avatarFallback
            }
        }
        .frame(width: 28, height: 28)
        .clipShape(Circle())
    }

    private var avatarFallback: some View {
        ZStack {
            Circle().fill(senderColor.opacity(0.2))
            Text(message.senderName.prefix(1).uppercased())
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(senderColor)
        }
    }

    /// Deterministic color per sender — same user always gets same color
    private var senderColor: Color {
        let colors: [Color] = [
            .purple, .orange, .pink, .teal, .indigo, .mint, .cyan
        ]
        let hash = abs(message.senderId.hashValue)
        return colors[hash % colors.count]
    }
}

// MARK: - Bubble Shape (pointed corner like WhatsApp)
struct BubbleShape: Shape {
    let isMine: Bool

    func path(in rect: CGRect) -> Path {
        let r: CGFloat = 16
        let tip: CGFloat = 6
        var path = Path()

        if isMine {
            path.move(to: CGPoint(x: rect.minX + r, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX - r - tip, y: rect.minY))
            path.addQuadCurve(
                to: CGPoint(x: rect.maxX - tip, y: rect.minY + r),
                control: CGPoint(x: rect.maxX - tip, y: rect.minY)
            )
            // Pointed tip top-right
            path.addLine(to: CGPoint(x: rect.maxX - tip, y: rect.minY + r + 4))
            path.addQuadCurve(
                to: CGPoint(x: rect.maxX, y: rect.minY + r),
                control: CGPoint(x: rect.maxX - tip + 2, y: rect.minY + r + 2)
            )
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY + r))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - r))
            path.addQuadCurve(
                to: CGPoint(x: rect.maxX - r, y: rect.maxY),
                control: CGPoint(x: rect.maxX, y: rect.maxY)
            )
            path.addLine(to: CGPoint(x: rect.minX + r, y: rect.maxY))
            path.addQuadCurve(
                to: CGPoint(x: rect.minX, y: rect.maxY - r),
                control: CGPoint(x: rect.minX, y: rect.maxY)
            )
            path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + r))
            path.addQuadCurve(
                to: CGPoint(x: rect.minX + r, y: rect.minY),
                control: CGPoint(x: rect.minX, y: rect.minY)
            )
        } else {
            path.move(to: CGPoint(x: rect.minX + r + tip, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX - r, y: rect.minY))
            path.addQuadCurve(
                to: CGPoint(x: rect.maxX, y: rect.minY + r),
                control: CGPoint(x: rect.maxX, y: rect.minY)
            )
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - r))
            path.addQuadCurve(
                to: CGPoint(x: rect.maxX - r, y: rect.maxY),
                control: CGPoint(x: rect.maxX, y: rect.maxY)
            )
            path.addLine(to: CGPoint(x: rect.minX + r, y: rect.maxY))
            path.addQuadCurve(
                to: CGPoint(x: rect.minX, y: rect.maxY - r),
                control: CGPoint(x: rect.minX, y: rect.maxY)
            )
            path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + r + 4))
            // Pointed tip top-left
            path.addQuadCurve(
                to: CGPoint(x: rect.minX + tip, y: rect.minY + r),
                control: CGPoint(x: rect.minX + tip - 2, y: rect.minY + r + 2)
            )
            path.addLine(to: CGPoint(x: rect.minX + tip, y: rect.minY + r))
            path.addQuadCurve(
                to: CGPoint(x: rect.minX + r + tip, y: rect.minY),
                control: CGPoint(x: rect.minX + tip, y: rect.minY)
            )
        }

        path.closeSubpath()
        return path
    }
}
