//
//  AddActivityView.swift
//  ParentPal
//
//  Created by Lexter Tapawan on 2/27/26.
//

import SwiftUI
import SwiftData

// MARK: - AddActivityView

struct AddActivityView: View {

    // MARK: Environment
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    // MARK: Query — used to link the new activity to the first child
    @Query private var children: [Child]

    // MARK: Form State
    @State private var activityType: ActivityType = .feeding
    @State private var timestamp: Date = .now
    @State private var trackDuration = false
    @State private var durationMinutes: Int = 15
    @State private var notes = ""

    // MARK: Body
    var body: some View {
        NavigationStack {
            Form {
                activityTypeSection
                timestampSection
                durationSection
                notesSection
            }
            .navigationTitle("Log Activity")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // MARK: Cancel
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                // MARK: Save
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save", action: save)
                        .fontWeight(.semibold)
                }
            }
        }
    }

    // MARK: - Form Sections

    /// Large icon preview + segmented type picker.
    private var activityTypeSection: some View {
        Section {
            // Animated icon badge that reflects the selected type
            HStack {
                Spacer()
                ZStack {
                    Circle()
                        .fill(activityType.color.opacity(0.15))
                        .frame(width: 64, height: 64)

                    Image(systemName: activityType.icon)
                        .font(.system(size: 30, weight: .medium))
                        .foregroundStyle(activityType.color)
                }
                .animation(.spring(response: 0.3), value: activityType)
                Spacer()
            }
            .listRowBackground(Color.clear)
            .padding(.vertical, 4)

            // Segmented control for the three activity types
            Picker("Activity Type", selection: $activityType) {
                ForEach(ActivityType.allCases, id: \.self) { type in
                    Text(type.rawValue).tag(type)
                }
            }
            .pickerStyle(.segmented)
            .listRowBackground(Color.clear)
        } header: {
            Text("Activity")
        }
    }

    /// Date + time picker for when the activity occurred.
    private var timestampSection: some View {
        Section("When") {
            DatePicker(
                "Date & Time",
                selection: $timestamp,
                displayedComponents: [.date, .hourAndMinute]
            )
        }
    }

    /// Optional duration toggle + stepper, shown in increments of 5 minutes.
    private var durationSection: some View {
        Section {
            Toggle("Track Duration", isOn: $trackDuration.animation())

            if trackDuration {
                // Stepper in 5-minute increments, up to 8 hours
                Stepper(
                    durationLabel,
                    value: $durationMinutes,
                    in: 5...480,
                    step: 5
                )
            }
        } header: {
            Text("Duration")
        } footer: {
            if trackDuration {
                Text(durationFormatted)
                    .foregroundStyle(.secondary)
            }
        }
    }

    /// Free-text notes field — expands vertically as user types.
    private var notesSection: some View {
        Section("Notes") {
            TextField("Optional notes…", text: $notes, axis: .vertical)
                .lineLimit(3...6)
        }
    }

    // MARK: - Helpers

    /// Short stepper label showing the current minute value.
    private var durationLabel: String {
        "\(durationMinutes) min"
    }

    /// Human-readable duration breakdown (e.g. "1 hr 30 min").
    private var durationFormatted: String {
        let hours = durationMinutes / 60
        let mins  = durationMinutes % 60
        switch (hours, mins) {
        case (0, _):          return "\(mins) min"
        case (_, 0):          return "\(hours) hr"
        default:              return "\(hours) hr \(mins) min"
        }
    }

    // MARK: - Save

    /// Persists a new Activity to SwiftData and links it to the first available child.
    /// If no child exists yet, a placeholder "Baby" child is created automatically.
    private func save() {
        // MARK: Resolve or create a child
        let child: Child
        if let existing = children.first {
            child = existing
        } else {
            // Temporary default — replaced once full child-setup flow is built
            let placeholder = Child(name: "Baby", birthdate: .now)
            modelContext.insert(placeholder)
            child = placeholder
        }

        // MARK: Build and insert the new activity
        let activity = Activity(
            timestamp: timestamp,
            activityType: activityType,
            duration: trackDuration ? TimeInterval(durationMinutes * 60) : nil,
            notes: notes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                        ? nil
                        : notes.trimmingCharacters(in: .whitespacesAndNewlines),
            child: child
        )
        modelContext.insert(activity)

        dismiss()
    }
}

// MARK: - Preview

#Preview {
    AddActivityView()
        .modelContainer(for: [Child.self, Activity.self], inMemory: true)
}
