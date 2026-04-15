# Take Flight

5-in-1 high-score survival game set on Belle Isle. You rotate through mini-games that test memory, coordination, speed, and reflexes while managing hunger, building nests, finding a mate, raising babies, and pushing for higher scores.

[Try on TestFlight](https://testflight.apple.com/join/vwcyPcTW)

## Stack

Swift, SwiftUI, SpriteKit, SwiftData, Game Center, AVFoundation

## The games

Each game is its own `SKScene` subclass:

- **Getting Hungry**: catch caterpillars, ladybugs, and berries while avoiding spiders to refill your hunger bar
- **Build Your Home**: memorize a randomized sequence of materials (stick, leaf, spiderweb, dandelion), then drag them into slots in the correct order
- **Avoid Predators**: dodge red zones and tap or press Space when the needle hits a green zone to escape
- **Feed Your Baby**: cut ropes to drop food into the baby bird's mouth twice before time runs out
- **Escape the Island**: tap to fly and dodge cars and light poles to escape Belle Isle (final sequence)

## Architecture

The app is a SwiftUI shell with SpriteKit scenes embedded using `SpriteView`. All shared state lives on a single `MainGameView.ViewModel` (ObservableObject) that every scene reads from and writes to.

**ViewModel as the central hub.** Hunger, score, inventory, nest state, baby count, mate status, and game phase are all `@Published` properties on one ViewModel. The mini-game scenes mutate these directly and SwiftUI picks up the changes for HUD updates, overlays, and sheet presentation.

**Mini-game flow.** When a player hits a trigger zone, the current scene gets paused and an instruction sheet pops up with start and cancel closures stored on the ViewModel. Hitting "Start" calls `startPendingMiniGame()` which unpauses the scene, clears the closures, and hands control to gameplay. Every game gets onboarding through this same path so there's no scene-specific instruction logic.

**Persistence.** SwiftData handles saving. A `GameState` model stores player position, camera position, inventory counts, hunger, score, nest position, baby state, and progression flags. The ViewModel uses Combine subscribers on key properties to call `scheduleSave()` on change, which debounces writes to 1 second with a `DispatchWorkItem`. On init the saved state gets fetched and mapped back onto the ViewModel.

**Input.** I built a custom SwiftUI joystick that normalizes `DragGesture` input into a `CGPoint` velocity clamped to the joystick radius. Keyboard input writes to the same `joystickVelocity` property. SpriteKit just reads one value per frame so there's no platform-specific branching in game logic.

**Game loop.** The `SKScene.update` method clamps delta time to a safe range (1/120 to 1/30), ticks hunger down on a 35-second accumulator, persists player and camera position every second, then handles movement and camera follow.

**Onboarding.** Tutorial sheets fire once at specific moments like first item pickup, inventory full, predator nearby, etc. Shown types get tracked in a `Set<InstructionType>` so they never repeat. The system pauses the world while instructions are up and resumes when dismissed. Can be toggled on/off in settings.

**Game Center.** Authenticates on launch, reports achievements with native banners, and submits high scores to the leaderboard.

**Nest build sequence.** Once the player has one of each material they enter the Build Your Home game. A shuffled 4-item sequence gets generated, the player fills slots by dragging items in order, and `checkWinCondition()` compares the attempt. If it matches, inventory clears, a nest node spawns on the map, and the mating phase kicks off (male bird spawns). If not, the scene resets for another try.

## Requirements

- Xcode 15+
- iOS 17+
- Swift 5.9+

## Setup

```bash
git clone https://github.com/jaidenhenley/TakeFlight.git
```

Open `TakeFlight.xcodeproj` in Xcode and run. Or use the TestFlight link above.

## Team

Built by a team of 5 at the Apple Developer Academy | MSU Detroit. I owned Game Center integration, the custom virtual controller and keyboard support, tutorial mode, and the core game loop.

## Developers

Jaiden Henley | [Portfolio](https://jaidenhenley.github.io/JaidenHenleyPort/) | [LinkedIn](https://www.linkedin.com/in/jaiden-henley) | [jaidenhenleydev@gmail.com](mailto:jaidenhenleydev@gmail.com)

George Clinkscales | [Portfolio](https://geoclink.github.io/portfolio/) | [LinkedIn](https://www.linkedin.com/in/george-clinkscales/) | [1lclink2@att.net](mailto:1lclink2@att.net)


## Credits
- **Music**: Menu Music
- **Author**: mrpoly
- **Source**: [Link to Music](https://opengameart.org/content/menu-music)
- **License**: Licensed under Public Domain, CC0 1.0

- **Music**: Car Engine Start
- **Author**: Looney Bits
- **Source**: [Link to Music](https://opengameart.org/content/car-engine-start-up-02)
- **License**: Licensed under Public Domain, CC0 1.0

- **Music**: Invasion
- **Author**: el-corleo
- **Source**: [Link to Music](https://opengameart.org/content/invasion)
- **License**: Licensed under CC BY 3.0

- **Music**: COMPLETION SOUND.
- **Author**: Brandon Morris
- **Source**: [Link to Music](https://opengameart.org/content/completion-sound)
- **License**: Licensed under Public Domain, CC0 1.0

- **Music**: Cyberpunk Moonlight Sonata
- **Author**: Joth
- **Source**: [Link to Music](https://opengameart.org/content/cyberpunk-moonlight-sonata)
- **License**: Licensed under Public Domain, CC0 1.0

- **Music**: TOWER DEFENSE THEME
- **Author**: DST
- **Source**: [Link to Music](https://opengameart.org/content/tower-defense-theme)
- **License**: Licensed under Public Domain, CC0 1.0

- **Music**: ONE
- **Author**: pheonton
- **Source**: [Link to Music](https://opengameart.org/content/one)
- **License**: Licensed under CC BY 3.0

- **Music**: CRYSTAL CAVE(SONG18)
- **Author**: cynicmusic
- **Source**: [Link to Music](https://opengameart.org/content/crystal-cave-song18)
- **License**: Licensed under Public Domain, CC0 1.0


- **Music**: APPLE BITE
- **Author**: AntumDeluge
- **Source**: [Link to Music](https://opengameart.org/content/apple-bite)
- **License**: Licensed under Public Domain, CC0 1.0

- **Music**: BIRD SONG(1)
- **Author**: qubodup
- **Source**: [Link to Music](https://opengameart.org/content/bird-song-1-second)
- **License**: Licensed under CC BY-SA 3.0
