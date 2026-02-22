# CLAUDE.md — iOS Development (iOS 18+)

## Tech Stack
- **Environment:** Swift 6 (Strict Concurrency), SwiftUI, iOS 18+. Use async/await. Prefer structured concurrency; use Task.detached only for offloading CPU-bound work.
- **Architecture:** MVVM + Observation Framework (`@Observable`).
- **Data:** SwiftData for persistence; `UserDefaults` for simple flags.

## Architecture Rules
- **Views:** Passive UI only. Use `.task` for async lifecycle. No `Task { }` unless necessary.
- **ViewModels:** Always `@MainActor`. Minimize SwiftUI usage in ViewModels; use `import Observation`.
- **Models:** Value types (`struct`) for data. `@Model` classes for SwiftData only.
- **DI:** Use Initializer Injection or `@Environment`. No global singletons.

## Code Standards
- **Clarity:** Prefer `guard` over nested `if`. No force unwraps (`!`) or `try!`.
- **Composition:** Extract subviews if `body` exceeds 30 lines.
- **Resources:** Use Asset Catalog symbols; no magic strings or numbers.
- **Error Handling:** Use custom `Error` enums. No `fatalError`.

## Accessibility
- **Identifiers:** Add `.accessibilityIdentifier(_:)` to all interactive elements (buttons, links, text fields, toggles, pickers) and key content views. Use stable, descriptive camelCase strings (e.g. `"addBookButton"`, `"bookTitleField"`, `"quoteRow_\(quote.id)"`). These enable UI testing and assistive technology.
- **Labels:** Add `.accessibilityLabel(_:)` when the control's visible text or SF Symbol is insufficient (e.g. icon-only buttons, images with meaning). Prefer concise, action-oriented labels ("Add book", "Sort oldest first").
- **Traits & Hints:** Use `.accessibilityAddTraits(_:)` and `.accessibilityHint(_:)` where the element's role or expected interaction is non-obvious.
- **Grouping:** Use `.accessibilityElement(children: .combine)` for composite views that should be read as one unit (e.g. a card with title + subtitle). Use `.accessibilityElement(children: .ignore)` with a custom label for decorative groupings.
- **Images:** Mark decorative images with `.accessibilityHidden(true)`. Provide meaningful labels for informational images.
- **Dynamic Type:** Never hard-code font sizes. Use semantic styles (`.body`, `.caption`, etc.) and test with large text sizes.

## Testing Guidelines
- **Pre-commit:** Run `swift test` before every commit. All tests must pass. This runs natively on macOS via SPM — no simulator, sub-second execution.
- **Full xcodebuild tests:** Only run when explicitly requested. Requires `-project` flag: `xcodebuild test -project SimpleReadingTracker.xcodeproj -scheme SimpleReadingTracker -destination 'platform=iOS Simulator,name=iPhone 17 Pro' -only-testing:SimpleReadingTrackerTests -parallel-testing-enabled NO -quiet`
- **Coverage:** Add unit tests for all non-trivial logic (branching, async, state, errors).
- **Async-first:** Prefer `async`/`await` tests; avoid `XCTestExpectation` unless required.
- **Behavioral:** Test observable behavior, not implementation details.
- **Deterministic:** Inject time, randomness, and external dependencies.
- **Isolated:** No real network, file system, or persistent store I/O.

## Output Guidelines
- Provide complete, compilable code.
- Skip basic explanations or alternative architecture suggestions.
- Ensure all logic is unit-testable.