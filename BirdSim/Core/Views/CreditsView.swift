//
//  CreditsView.swift
//  BirdSim
//
//  Created by Jaiden Henley on 4/15/26.
//

import SwiftUI

struct CreditsView: View {
    @Environment(\.dismiss) private var dismiss

    private let sections: [(title: String, entries: [(role: String, name: String)])] = [
        (
            title: "Management",
            entries: [
                (role: "Project Manager", name: "Ashlee Cunningham"),
            ]
        ),
        (
            title: "Development",
            entries: [
                (role: "iOS Engineer", name: "Jaiden Henley"),
                (role: "iOS Engineer", name: "George Clinkscales Jr."),
            ]
        ),
        (
            title: "Design",
            entries: [
                (role: "UI / UX Design", name: "Dorrien Harris"),
                (role: "UI / UX Design", name: "Zoe Talley"),
            ]
        ),
        (
            title: "Special Thanks",
            entries: [
                (role: "Apple Developer Academy", name: "Detroit · 2025"),
            ]
        ),
    ]

    var body: some View {
        VStack(spacing: 16) {
            // Header
            VStack(spacing: 8) {
                Text("Credits")
                    .font(.system(.title, design: .rounded))
                    .bold()
                
                Capsule()
                    .fill(Color.secondary.opacity(0.3))
                    .frame(width: 40, height: 4)
            }
            
            // Credits list
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    ForEach(sections, id: \.title) { section in
                        VStack(spacing: 8) {
                            Text(section.title.uppercased())
                                .font(.system(.caption, design: .rounded))
                                .bold()
                                .foregroundStyle(.black.opacity(0.8))
                                .kerning(1)
                                .frame(maxWidth: .infinity, alignment: .leading)

                            ForEach(section.entries, id: \.name) { entry in
                                HStack {
                                    Text(entry.role)
                                        .font(.system(.body, design: .rounded))
                                        .foregroundStyle(.black.opacity(0.8))
                                    Spacer()
                                    Text(entry.name)
                                        .font(.system(.body, design: .rounded))
                                        .fontWeight(.medium)
                                }
                            }
                        }
                    }
                }
                .padding(.bottom, 4)
            }
            
            // Action Button
            Button {
                dismiss()
            } label: {
                Text("Done")
                    .font(.system(.headline, design: .rounded))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
            }
            .buttonStyle(.borderedProminent)
            .tint(.green)
            .keyboardShortcut(.space, modifiers: [])
        }
        .padding(30)
        .presentationDragIndicator(.hidden)
    }
}
