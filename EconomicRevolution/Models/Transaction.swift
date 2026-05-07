import Foundation

struct Transaction: Identifiable, Codable, Hashable {
    let id: UUID
    var amount: Double
    var category: ExpCategory
    var isIncome: Bool
    var note: String
    var date: Date

    init(id: UUID = UUID(), amount: Double, category: ExpCategory, isIncome: Bool, note: String = "", date: Date = Date()) {
        self.id = id
        self.amount = amount
        self.category = category
        self.isIncome = isIncome
        self.note = note
        self.date = date
    }

    var signedAmount: Double { isIncome ? amount : -amount }
}
