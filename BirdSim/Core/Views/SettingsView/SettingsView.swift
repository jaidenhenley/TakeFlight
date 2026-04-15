//
//  SettingsView.swift
//  BirdSim
//
//  Created by Jaiden Henley on 2/6/26.
//

import SwiftData
import SwiftUI
import Observation

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var allSettings: [GameSettings]
    @Environment(\.dismiss) var dismiss

    // Helper to get the single settings object
    var settings: GameSettings? { allSettings.first }

    var body: some View {
        VStack(spacing: 20) {
            if let settings = settings {
                SettingsForm(settings: settings, dismiss: dismiss)
            } else {
                Text("Loading...")
                    .onAppear { createInitialSettings() }
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(15)
    }

    // Creates the settings object if the database is empty
    private func createInitialSettings() {
        if allSettings.isEmpty {
            let newSettings = GameSettings(soundOn: true, soundVolume: 0.8, hapticsOn: true, tutorialOn: true, coordinatesOn: false)
            modelContext.insert(newSettings)
        }
    }
}
private struct SettingsForm: View {
    @Bindable var settings: GameSettings
    var dismiss: DismissAction
    
    @State private var showTutorialAlert = false

    var body: some View {
        
        let tutorialBinding = Binding<Bool>(
            get: { settings.tutorialOn }, set: { newValue in
                if newValue {
                    showTutorialAlert = true
                } else {
                    settings.tutorialOn = false
                }
            }
        )
        
        VStack(spacing: 20) {
            Text("Settings").font(.title.bold())

            Toggle("Haptics", isOn: $settings.hapticsOn)
            
            Toggle("Music", isOn: $settings.soundOn)
                .onChange(of: settings.soundOn) { _, newValue in
                    SoundManager.shared.setMusicEnabled(newValue)
                    if !newValue {
                        SoundManager.shared.stopMusic()
                    }
                }
            
            Toggle("Tutorial", isOn: tutorialBinding)
            
            Toggle("Minigame Instructions", isOn: $settings.minigameInstructionsOn)
            
            Toggle("Coordinates", isOn: $settings.coordinatesOn)

            VStack(alignment: .leading, spacing: 8) {
                Text("Volume")
                Slider(value: $settings.soundVolume, in: 0...1)
                    .onChange(of: settings.soundVolume) { _, newValue in
                        SoundManager.shared.setMusicVolume(Float(newValue))
                    }
            }

            Button("Done") { dismiss() }
        }
        .alert("Reset Progress?", isPresented: $showTutorialAlert) {
            Button("Reset & Start Tutorial", role: .destructive) {
                settings.tutorialOn = true
            }
            Button("Cancel", role: .cancel) {
                
            }
        } message: {
            Text("Turning on tutorial mode will reset your current game progress. This cannot be undone.")
        }
    }
}

