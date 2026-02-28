//
//  Activity.swift
//  ParentPal
//
//  Created by Lexter Tapawan on 2/27/26.
//

import Foundation
import SwiftData

enum ActivityType: String, Codable, CaseIterable {
    case feeding = "Feeding"
    case sleep   = "Sleep"
    case diaper  = "Diaper"
}

@Model
final class Activity {
    var id: UUID
    var timestamp: Date
    var activityType: ActivityType
    var duration: TimeInterval?
    var notes: String?

    var child: Child?

    init(
        id: UUID = UUID(),
        timestamp: Date = .now,
        activityType: ActivityType,
        duration: TimeInterval? = nil,
        notes: String? = nil,
        child: Child? = nil
    ) {
        self.id = id
        self.timestamp = timestamp
        self.activityType = activityType
        self.duration = duration
        self.notes = notes
        self.child = child
    }
}
