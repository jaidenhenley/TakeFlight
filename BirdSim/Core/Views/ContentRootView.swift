//  ContentRootView.swift
//  BirdSimulator
//
//  Created by Jaiden Henley on 2/2/2026
//  Root coordinator for switching between main menu and main game.

import SwiftUI
import SwiftData
import UIKit

// MARK: - Root Navigation State
/// Represents the two possible root screens in the app.
enum RootScreen {
    case menu                 // Main menu UI
    case game(newGame: Bool)  // Main game (new or resumed)
}

// MARK: - ContentRootView
/// Top-level view controlling app navigation between menu and game.
struct ContentRootView: View {
    let container: ModelContainer // Shared persistent data container
    @State private var rootScreen: RootScreen = .menu // Current navigation state
    @State private var presentingViewController: UIViewController?

    var body: some View {
        Group {
            switch rootScreen {
            case .menu:
                // Main menu with callbacks to start or resume a game.
            MainMenuView(
                container: container,
                presentingViewController: presentingViewController,
                onStartNewGame: { rootScreen = .game(newGame: true) },
                onResumeGame: { rootScreen = .game(newGame: false) }
            )
            case .game(let isNew):
                // Game view. Returns to menu on exit.
                MainGameView(
                    container: container,
                    newGame: isNew,
                    onExit: { rootScreen = .menu }
                )
            }
        }
        .background(PresentingViewControllerReader { presentingViewController = $0 })
        .task(id: presentingViewController) {
            guard let presentingViewController else { return }
            await GameKitManager.shared.authenticateLocalPlayer(presentingViewController: presentingViewController)
        }
    }
}

private struct PresentingViewControllerReader: UIViewControllerRepresentable {
    let onResolve: (UIViewController) -> Void
    
    func makeUIViewController(context: Context) -> UIViewController {
        let controller = UIViewController()
        DispatchQueue.main.async {
            onResolve(controller)
        }
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}
