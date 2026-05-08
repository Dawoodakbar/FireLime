//
//  DateSeparatorView.swift
//  FireLime
//
//  Created by Apple on 08/05/2026.
//


import SwiftUI

struct DateSeparatorView: View {
    let date: Date

    var body: some View {
        HStack {
            line
            Text(date.chatDateFormatted)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(DesignSystem.Colors.textSecondary)
                .padding(.horizontal, DesignSystem.Spacing.sm)
            line
        }
        .padding(.horizontal, DesignSystem.Spacing.lg)
        .padding(.vertical, DesignSystem.Spacing.sm)
    }

    private var line: some View {
        Rectangle()
            .fill(DesignSystem.Colors.textSecondary.opacity(0.2))
            .frame(height: 0.5)
    }
}

extension Date {

    var chatDateFormatted: String {
        if Calendar.current.isDateInToday(self)    { return "Today" }
        if Calendar.current.isDateInYesterday(self){ return "Yesterday" }
        let f = DateFormatter()
        f.dateFormat = Calendar.current.isDate(
            self, equalTo: Date(), toGranularity: .year
        ) ? "MMMM d" : "MMMM d, yyyy"
        return f.string(from: self)
    }
}
