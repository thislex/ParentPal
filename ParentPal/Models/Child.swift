//
//  Child.swift
//  ParentPal
//
//  Created by Lexter Tapawan on 2/27/26.
//

import Foundation
import SwiftData

@Model
final class Child {
    var id: UUID
    var name: String
    var birthdate: Date
    var photoData: Data?

    @Relationship(deleteRule: .cascade, inverse: \Activity.child)
    var activities: [Activity] = []

    init(id: UUID = UUID(), name: String, birthdate: Date, photoData: Data? = nil) {
        self.id = id
        self.name = name
        self.birthdate = birthdate
        self.photoData = photoData
    }

    /// Returns a human-readable age string appropriate for infants and toddlers.
    var age: String {
        let components = Calendar.current.dateComponents(
            [.year, .month, .weekOfMonth],
            from: birthdate,
            to: .now
        )
        if let years = components.year, years >= 1 {
            return years == 1 ? "1 year" : "\(years) years"
        } else if let months = components.month, months >= 1 {
            return months == 1 ? "1 month" : "\(months) months"
        } else {
            let weeks = components.weekOfMonth ?? 0
            return weeks == 1 ? "1 week" : "\(weeks) weeks"
        }
    }
}
