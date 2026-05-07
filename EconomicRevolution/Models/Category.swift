import SwiftUI

enum ExpCategory: String, Codable, CaseIterable, Identifiable {
    case food, transport, housing, shopping, entertainment
    case health, education, subscriptions, utilities, travel, pets
    case salary, freelance, investment, gift, refund
    case other

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .food: return "fork.knife"
        case .transport: return "car.fill"
        case .housing: return "house.fill"
        case .shopping: return "bag.fill"
        case .entertainment: return "film.fill"
        case .health: return "heart.fill"
        case .education: return "book.fill"
        case .subscriptions: return "repeat"
        case .utilities: return "bolt.fill"
        case .travel: return "airplane"
        case .pets: return "pawprint.fill"
        case .salary: return "banknote.fill"
        case .freelance: return "laptopcomputer"
        case .investment: return "chart.line.uptrend.xyaxis"
        case .gift: return "gift.fill"
        case .refund: return "arrow.uturn.backward"
        case .other: return "ellipsis.circle.fill"
        }
    }

    var label: String {
        switch self {
        case .food: return "Food"
        case .transport: return "Transport"
        case .housing: return "Housing"
        case .shopping: return "Shopping"
        case .entertainment: return "Entertainment"
        case .health: return "Health"
        case .education: return "Education"
        case .subscriptions: return "Subscriptions"
        case .utilities: return "Utilities"
        case .travel: return "Travel"
        case .pets: return "Pets"
        case .salary: return "Salary"
        case .freelance: return "Freelance"
        case .investment: return "Investment"
        case .gift: return "Gift"
        case .refund: return "Refund"
        case .other: return "Other"
        }
    }

    var color: Color {
        switch self {
        case .food: return Color(hex: 0xFF6B35)
        case .transport: return Color(hex: 0x4FC3F7)
        case .housing: return Color(hex: 0xAB47BC)
        case .shopping: return Color(hex: 0xEC407A)
        case .entertainment: return Color(hex: 0xFFA726)
        case .health: return Color(hex: 0xEF5350)
        case .education: return Color(hex: 0x42A5F5)
        case .subscriptions: return Color(hex: 0x7E57C2)
        case .utilities: return Color(hex: 0xFFEE58)
        case .travel: return Color(hex: 0x26A69A)
        case .pets: return Color(hex: 0x8D6E63)
        case .salary: return Color(hex: 0x66BB6A)
        case .freelance: return Color(hex: 0x29B6F6)
        case .investment: return Color(hex: 0x9CCC65)
        case .gift: return Color(hex: 0xF06292)
        case .refund: return Color(hex: 0x78909C)
        case .other: return Color(hex: 0x90A4AE)
        }
    }

    var isIncome: Bool {
        [.salary, .freelance, .investment, .gift, .refund].contains(self)
    }

    static var incomeCategories: [ExpCategory] {
        [.salary, .freelance, .investment, .gift, .refund]
    }

    static var expenseCategories: [ExpCategory] {
        [.food, .transport, .housing, .shopping, .entertainment, .health, .education, .subscriptions, .utilities, .travel, .pets, .other]
    }
}
