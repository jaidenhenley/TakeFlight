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
            title: "Design",
            entries: [
                (role: "UI / UX Design", name: "Dorien Harris"),
                (role: "UI / UX Design", name: "Zoe Talley"),
            ]
        ),
        (
            title: "Development",
            entries: [
                (role: "iOS Engineer", name: "George Clinkscales Jr."),
                (role: "iOS Engineer", name: "Jaiden Henley"),
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
        NavigationStack {
            // Credits list
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    ForEach(sections, id: \.title) { section in
                        VStack(spacing: 8) {
                            Text(section.title.uppercased())
                                .font(.system(.caption, design: .rounded))
                                .bold()
                                .foregroundStyle(.secondary)
                                .kerning(1)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            ForEach(section.entries, id: \.name) { entry in
                                HStack {
                                    Text(entry.role)
                                        .font(.system(.body, design: .rounded))
                                        .foregroundStyle(.secondary)
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
            .navigationTitle("Credits")
            .navigationBarTitleDisplayMode(.inline)
        }
        .padding(30)
        .presentationDetents([.medium])

    }
}
