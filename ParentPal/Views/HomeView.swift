//
//  HomeView.swift
//  ParentPal
//
//  Created by Lexter Tapawan on 2/27/26.
//

import SwiftUI
import SwiftData

// MARK: - ActivityType View Helpers

private extension ActivityType {
    /// SF Symbol name representing each activity type.
    var icon: String {
        switch self {
        case .feeding: return "fork.knife"
        case .sleep:   return "moon.zzz.fill"
        case .diaper:  return "wind"
        }
    }

    /// Accent color associated with each activity type.
    var color: Color {
        switch self {
        case .feeding: return .orange
        case .sleep:   return .indigo
        case .diaper:  return .teal
        }
    }
}

// MARK: - HomeView

struct HomeView: View {

    // MARK: Query — fetches all activities, newest first
    @Query(sort: [SortDescriptor(\Activity.timestamp, order: .reverse)])
    private var activities: [Activity]

    // MARK: State
    @State private var showingAddActivity = false

    // MARK: Body
    var body: some View {
        NavigationStack {
            Group {
                if activities.isEmpty {
                    emptyStateView
                } else {
                    activityList
                }
            }
            .navigationTitle("ParentPal")
            .toolbar {
                // MARK: Add Activity Button
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingAddActivity = true
                    } label: {
                        Image(systemName: "plus")
                            .accessibilityLabel("Add Activity")
                    }
                }
            }
            // Placeholder sheet — replaced by AddActivityView when built
            .sheet(isPresented: $showingAddActivity) {
                Text("Add Activity — Coming Soon")
                    .font(.headline)
                    .padding()
            }
        }
    }

    // MARK: - Subviews

    /// Shown when no activities have been logged yet.
    private var emptyStateView: some View {
        ContentUnavailableView(
            "No Activities Yet",
            systemImage: "list.bullet.clipboard",
            description: Text("Tap the + button to log your baby's first activity.")
        )
    }

    /// Scrollable list of all logged activities.
    private var activityList: some View {
        List(activities) { activity in
            ActivityRow(activity: activity)
        }
        .listStyle(.insetGrouped)
    }
}

// MARK: - ActivityRow

/// A single row displaying an activity's icon, type, relative time, and optional notes.
private struct ActivityRow: View {

    let activity: Activity

    var body: some View {
        HStack(spacing: 14) {

            // MARK: Icon Badge
            ZStack {
                Circle()
                    .fill(activity.activityType.color.opacity(0.15))
                    .frame(width: 42, height: 42)

                Image(systemName: activity.activityType.icon)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(activity.activityType.color)
            }

            // MARK: Text Content
            VStack(alignment: .leading, spacing: 3) {
                Text(activity.activityType.rawValue)
                    .font(.headline)

                // Relative timestamp (e.g. "2 minutes ago")
                Text(activity.timestamp, style: .relative)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                // Optional notes — truncated to two lines
                if let notes = activity.notes, !notes.isEmpty {
                    Text(notes)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Preview

#Preview {
    HomeView()
        .modelContainer(for: [Child.self, Activity.self], inMemory: true)
}
