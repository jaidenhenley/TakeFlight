//
//  GameKitManger.swift
//  BirdSim
//
//  Created by Jaiden Henley on 2/17/26.
//
import GameKit
import UIKit
import Combine

final class GameKitManager: NSObject, ObservableObject {
    static let shared = GameKitManager()
    
    @Published private(set) var isAuthenticated = false
    
    /// Achievements that have already been completed locally – prevents duplicate reports.
    private var completedAchievements: Set<String> = []
    private let completedKey = "completedAchievements"
    
    // Replace these with the exact identifiers from App Store Connect.
    enum AchievementID {
        static let mateWithMaleBird = "mateWithMaleBird.ac.classicMode"
        static let raisedOneBaby = "raiseOneBabyBirdSuccesfully.ac.classicmode"
        static let haveFiveBabiesOnScreen = "have5BabyBirdsOnTheMapAtOnce.ac.classicmode"
        static let escapeBelleIsle = "escapeBelleIsle.ac.classicmode"
        static let defeatThreePredators = "defeat3Predators.ac.classicmode"
        static let feedYourselfTenTimesInOneGame = "feedYourself10TimesInOneGame.ac.classicmode"
        static let stayInAGameForFiveMinutes = "stayInGameFor5Minutes.ac.classicmode"
        static let buildANest = "buildANest.ac.classicmode"
    }
    
    private override init() {
        super.init()
        // Restore previously completed achievements from disk
        if let saved = UserDefaults.standard.stringArray(forKey: completedKey) {
            completedAchievements = Set(saved)
        }
    }
    
    // Call once at app start or main menu.
    @MainActor
    func authenticateLocalPlayer(presentingViewController: UIViewController?) async {
        let localPlayer = GKLocalPlayer.local
        localPlayer.authenticateHandler = { viewController, error in
            if let viewController, let presentingViewController {
                presentingViewController.present(viewController, animated: true)
                return
            }
            
            if let error {
                print("Game Center auth error: \(error.localizedDescription)")
                return
            }
            
            self.isAuthenticated = localPlayer.isAuthenticated
        }
    }
    
    // Set an achievement to 100% immediately (one-shot).
    // Skips the report if this achievement was already completed.
    func completeAchievement(id: String, showBanner: Bool = true) async {
        guard GKLocalPlayer.local.isAuthenticated else { return }
        guard !completedAchievements.contains(id) else { return }
        
        let achievement = GKAchievement(identifier: id)
        achievement.percentComplete = 100
        achievement.showsCompletionBanner = showBanner
        
        do {
            try await GKAchievement.report([achievement])
            markCompleted(id)
        } catch {
            print("Achievement report error: \(error.localizedDescription)")
        }
    }
    
    // Incremental progress (0...100). Example: 10% per event.
    // Skips the report if this achievement was already completed.
    func reportProgress(id: String, percent: Double, showBanner: Bool = true) async {
        guard GKLocalPlayer.local.isAuthenticated else { return }
        guard !completedAchievements.contains(id) else { return }
        
        do {
            let existing = try await GKAchievement.loadAchievements()
            let achievement = existing.first(where: { $0.identifier == id }) ?? GKAchievement(identifier: id)
            achievement.percentComplete = min(100, max(achievement.percentComplete, percent))
            achievement.showsCompletionBanner = showBanner
            try await GKAchievement.report([achievement])
            if achievement.percentComplete >= 100 {
                markCompleted(id)
            }
        } catch {
            print("Achievement progress error: \(error.localizedDescription)")
        }
    }
    
    /// Persist a completed achievement locally so it is never reported again.
    private func markCompleted(_ id: String) {
        completedAchievements.insert(id)
        UserDefaults.standard.set(Array(completedAchievements), forKey: completedKey)
    }
    
    /// Call when the user resets all Game Center achievements (e.g. via a debug menu).
    func resetLocalCompletionCache() {
        completedAchievements.removeAll()
        UserDefaults.standard.removeObject(forKey: completedKey)
    }
    
    // Optional: show Game Center UI.
    func showGameCenterUI(from presentingViewController: UIViewController) {
        let topViewController = topMostViewController(from: presentingViewController)
        guard topViewController.viewIfLoaded?.window != nil else {
            print("Game Center UI not shown: presenter not in window hierarchy.")
            return
        }
        
        let gcView = GKGameCenterViewController(state: .dashboard)
        gcView.gameCenterDelegate = self
        topViewController.present(gcView, animated: true)
    }
    
    
}

extension GameKitManager: GKGameCenterControllerDelegate {
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated: true)
    }
}
private extension GameKitManager {
    func topMostViewController(from root: UIViewController) -> UIViewController {
        var top = root
        while let presented = top.presentedViewController {
            top = presented
        }
        return top
    }
}

