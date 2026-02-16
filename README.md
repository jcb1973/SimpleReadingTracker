<p align="center">
  <img src="logo.png" alt="Marginalia" width="100" height="100" style="border-radius: 20px;">
</p>

<h1 align="center">Marginalia</h1>

<p align="center">
  A private reading notebook for iOS.<br>
  Track books, capture quotes, and organise your reading life.
</p>

<p align="center">
  <img src="https://img.shields.io/badge/platform-iOS%2018%2B-blue" alt="iOS 18+">
  <img src="https://img.shields.io/badge/swift-6-orange" alt="Swift 6">
  <img src="https://img.shields.io/badge/UI-SwiftUI-purple" alt="SwiftUI">
  <img src="https://img.shields.io/badge/data-SwiftData-green" alt="SwiftData">
</p>

---

## Features

**Library management**
- Add books by scanning an ISBN barcode, typing an ISBN, or entering details manually
- Automatic lookup via Open Library and Google Books APIs
- Track reading status (To Read / Reading / Read) with date timestamps
- Star ratings (1-5)
- Tag books with custom colour-coded labels
- Search, sort, and filter across your entire library

**Quotes & Notes**
- Save quotes with optional page numbers and personal comments
- Photograph a book page and select text using on-device Live Text (OCR)
- Crop images before text recognition
- Write freeform reading notes
- Search and sort within notes and quotes

**Data & Privacy**
- All data stored locally on-device using SwiftData
- No accounts, no tracking, no analytics
- CSV import and export for full data portability
- No subscription required

## Architecture

| Layer | Technology |
|---|---|
| UI | SwiftUI with Composition |
| Architecture | MVVM + `@Observable` |
| Persistence | SwiftData |
| Concurrency | Swift 6 Strict Concurrency, async/await |
| Barcode scanning | AVFoundation |
| Text recognition | VisionKit (Live Text) |
| Book lookup | Open Library + Google Books APIs |
| Caching | Actor-based dual-level (memory + disk) |

## Project Structure

```
SimpleReadingTracker/
├── Models/          SwiftData models (Book, Author, Note, Quote, Tag)
├── ViewModels/      @Observable view models (8 files)
├── Views/
│   ├── Home/        Dashboard, stats, getting started
│   ├── Library/     Search, filter, sort, tag bar
│   ├── BookDetail/  Book info, tags, notes/quotes tabs
│   ├── BookForm/    Add/edit book with ISBN lookup
│   ├── Notes/       All notes screen with search
│   ├── Quotes/      All quotes screen, live text, image crop
│   ├── Scanner/     ISBN barcode camera scanner
│   ├── ManageTags/  Tag CRUD with colour picker
│   └── Shared/      Reusable components
├── Services/        Book lookup, search, caching
└── Errors/          Typed error enums
```

## Requirements

- iOS 18.0+
- Xcode 26+
- Swift 6

## Building

```bash
git clone https://github.com/jcb1973/SimpleReadingTracker.git
cd SimpleReadingTracker/SimpleReadingTracker
open SimpleReadingTracker.xcodeproj
```

Build and run on a simulator or device from Xcode. No third-party dependencies.

## Support

[Marginalia Support Page](https://jcb1973.github.io/marginalia-support/)

For bug reports or feature requests, email [jcb1973+support@gmail.com](mailto:jcb1973+support@gmail.com).

## License

Copyright 2026 John Cieslik-Bridgen. All rights reserved.
