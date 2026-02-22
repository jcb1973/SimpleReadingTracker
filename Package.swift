// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "SimpleReadingTracker",
    platforms: [.macOS(.v15)],
    targets: [
        .target(
            name: "SimpleReadingTracker",
            path: "SimpleReadingTracker",
            sources: [
                "Models/Author.swift",
                "Models/Book.swift",
                "Models/Note.swift",
                "Models/Quote.swift",
                "Models/ReadingStatus.swift",
                "Models/Tag.swift",
                "Models/TagColor.swift",
                "Services/BookLookupCache.swift",
                "Services/BookLookupService.swift",
                "Services/SearchService.swift",
                "Services/TagDeduplicator.swift",
                "Errors/AppError.swift",
                "ViewModels/HomeViewModel.swift",
                "ViewModels/LibraryViewModel.swift",
                "ViewModels/BookDetailViewModel.swift",
                "ViewModels/BookFormViewModel.swift",
            ]
        ),
        .testTarget(
            name: "SimpleReadingTrackerCoreTests",
            dependencies: ["SimpleReadingTracker"],
            path: "SimpleReadingTrackerTests"
        ),
    ]
)
