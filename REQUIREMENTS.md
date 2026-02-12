# Reading Tracker iOS App - Development Instructions

## Project Overview
Build a native iOS reading tracker app using SwiftUI and Core Data. The app allows users to track books they want to read, are currently reading, and have read, with support for notes, tags, ratings, and flexible search.

## Technical Stack
- **Platform**: iOS (iPhone)
- **UI Framework**: SwiftUI
- **Persistence**: Core Data
- **Minimum iOS Version**: iOS 16.0+
- **Language**: Swift

## Core Data Model

### Entity: Book
| Attribute | Type | Optional | Notes |
|-----------|------|----------|-------|
| id | UUID | No | Primary key |
| title | String | No | Book title |
| isbn | String | Yes | Store as-is with hyphens |
| rating | Integer 16 | Yes | 1-5, nil if not rated |
| status | String | No | "toRead", "reading", "read" |
| dateAdded | Date | No | Auto-set on creation |
| dateStarted | Date | Yes | User editable |
| dateFinished | Date | Yes | User editable |
| authors | Relationship | Yes | ↔ Author many-to-many |
| notes | Relationship | Yes | → Note one-to-many, cascade delete |
| tags | Relationship | Yes | ↔ Tag many-to-many |

**Indexes**: title, status, dateAdded, dateStarted, dateFinished

### Entity: Author
| Attribute | Type | Optional | Notes |
|-----------|------|----------|-------|
| id | UUID | No | Primary key |
| name | String | No | Full name, case-preserved |
| books | Relationship | Yes | ↔ Book many-to-many |

**Indexes**: name

### Entity: Note
| Attribute | Type | Optional | Notes |
|-----------|------|----------|-------|
| id | UUID | No | Primary key |
| content | String | No | Plain text |
| createdAt | Date | No | Timestamp |
| book | Relationship | No | → Book (inverse: notes) |

**Indexes**: content (for search)

### Entity: Tag
| Attribute | Type | Optional | Notes |
|-----------|------|----------|-------|
| id | UUID | No | Primary key |
| name | String | No | Lowercase for uniqueness |
| displayName | String | No | Original case for display |
| createdAt | Date | No | Timestamp |
| books | Relationship | Yes | ↔ Book many-to-many |

**Indexes**: name

### Relationship Delete Rules
- Delete Book → cascade delete Notes
- Delete Book → nullify Author.books, Tag.books
- Delete Author → nullify Book.authors
- Delete Tag → nullify Book.tags

## App Structure

### Navigation
Tab bar with three tabs:
1. **Home** - Dashboard view
2. **Library** - Searchable/filterable catalog
3. **Add Book** (center + button or navigation bar +)

### Screen Specifications

#### 1. Home Screen
**Purpose**: Quick overview of current reading activity

**Content**:
- Header with app title and + button (to add book)
- **Currently Reading** section
  - Shows all books with status = "reading"
  - Display as cards or list items with: title, author(s), cover placeholder
  - Tap to navigate to book detail
  - Empty state: "No books currently reading" if none
- **Recently Read** section
  - Shows 3-5 most recent books with status = "read"
  - Sorted by dateFinished descending
  - Same card/list style as Currently Reading
  - Tap to navigate to book detail
  - Empty state: "No books read yet" if none

#### 2. Library Screen
**Purpose**: Browse, search, and filter all books

**Features**:
- Search bar at top (searches: title, author name, ISBN, note content)
- Filter controls (expandable/collapsible):
  - Status (To Read, Reading, Read) - multi-select
  - Tags - multi-select from user's tags
  - Rating (1-5 stars) - multi-select
  - Date ranges (date added, date started, date finished)
- Sort options:
  - Recently added
  - Recently read (by dateFinished)
  - Title A-Z
  - Rating (high to low)
- Results list showing filtered/sorted books
- Each book shows: title, author(s), status, rating (if set), tags
- Tap book to navigate to detail
- Swipe actions: Quick status change, delete

**Search Behavior**:
- Unified search across title, author names, tags, note content
- Visual indication of why book matched (e.g., "Matched in notes: '...'")
- Search is real-time/dynamic as user types

#### 3. Book Detail Screen
**Purpose**: View and edit all book information

**Layout**:
- Navigation bar with "Edit" button
- Book information display:
  - Title (large, prominent)
  - Authors (comma-separated list)
  - ISBN (if present)
  - Status badge (To Read / Reading / Read)
  - Rating (star display, tappable to change)
  - Dates:
    - Date added
    - Date started (if set)
    - Date finished (if set)
  - Tags (displayed as chips/bubbles)
- **Notes Section**:
  - List of notes with timestamps
  - "+ Add Note" button
  - Each note shows content and date
  - Swipe to delete note
- **Actions**:
  - Change status button
  - Edit book button
  - Delete book button (with confirmation)

#### 4. Add/Edit Book Screen
**Purpose**: Create new book or edit existing

**Form Fields**:
- Title (required, text field)
- Authors (multi-entry with autocomplete)
  - Shows suggestions from existing authors as user types
  - Can add multiple authors
  - Can create new or select existing
- ISBN (optional, text field)
  - "Scan ISBN" button → camera barcode scanner
- Status (picker: To Read, Reading, Read)
- Rating (optional, star selector 1-5)
- Date started (optional, date picker)
- Date finished (optional, date picker)
- Tags (multi-select with autocomplete)
  - Shows existing tags as suggestions
  - Can create new tags on-the-fly
  - Tag entry normalizes to lowercase for storage but preserves displayName
- Notes section
  - Can add notes during creation

**Validation**:
- Title is required
- No date validation (user has full flexibility)
- Authors, ISBN, rating, dates, tags all optional

**Save Behavior**:
- Create new book record
- Create/link to Author entities
- Create/link to Tag entities (check for existing by lowercase name)
- Auto-set dateAdded to current date on creation

#### 5. ISBN Scanner (Modal/Sheet)
**Purpose**: Scan book barcode to auto-populate book data

**Functionality**:
- Camera view using Vision framework barcode detection
- Detects ISBN-10 and ISBN-13 barcodes
- On successful scan:
  - Look up book via Open Library API: `https://openlibrary.org/api/books?bibkeys=ISBN:{isbn}&format=json&jscmd=data`
  - Fall back to Google Books API if needed: `https://www.googleapis.com/books/v1/volumes?q=isbn:{isbn}`
  - Extract: title, authors, ISBN
  - Pre-fill add/edit book form
  - Let user confirm/edit before saving
- Cancel button to dismiss
- Visual feedback on successful scan

## Key Features & Behaviors

### Tag Management
- **Creation**: User types tag name, if not exists (case-insensitive check), create new Tag entity
- **Storage**: name = lowercase, displayName = original case
- **Display**: Always use displayName
- **Autocomplete**: Show existing tags as user types (match on lowercase name)
- **Many-to-many**: Books can have multiple tags, tags can be on multiple books

### Author Management
- **Creation**: User types author name, show autocomplete from existing authors
- **Storage**: Store name exactly as entered (case-preserved)
- **Autocomplete**: Show existing authors as user types
- **Many-to-many**: Books can have multiple authors, authors can have multiple books
- **No deduplication**: User manually manages if "J.K. Rowling" vs "J. K. Rowling"

### Status Management
- Three states: "toRead", "reading", "read"
- User can change status at any time
- No automatic date setting (fully flexible)
- Display as human-readable: "To Read", "Reading", "Read"

### Rating
- Optional 1-5 star rating
- Can be set/changed anytime after book is started (status = reading or read)
- Stored as Integer16, nil if not rated
- UI shows star selector (tappable stars)

### Search Implementation
- Single search query searches across:
  - Book title
  - Author names
  - ISBN
  - Tag displayNames
  - Note content
- Results show all matching books
- Visual indicator of match type (e.g., "Matched in notes")
- Combine with filters (AND logic between filters)

### Data Persistence
- Use Core Data with NSPersistentContainer
- All data stored locally on device
- No iCloud sync in v1
- Implement basic error handling for Core Data operations

## Technical Implementation Notes

### Core Data Setup
1. Create .xcdatamodeld file with all entities
2. Set up NSPersistentContainer in app initialization
3. Provide managed object context to views via environment
4. Use @FetchRequest for data binding in SwiftUI views

### Barcode Scanning
- Use AVFoundation or Vision framework
- Request camera permissions
- Detect ISBN-10 and ISBN-13 formats
- Handle scan success/failure

### API Integration
- Use URLSession for HTTP requests
- Parse JSON responses
- Handle network errors gracefully
- Show loading states during API calls

### SwiftUI Best Practices
- Use MVVM pattern where appropriate
- Separate views into reusable components
- Use @State, @Binding, @ObservedObject correctly
- Implement proper navigation (NavigationStack)
- Use List for scrollable content
- Implement proper form handling

### UI/UX Guidelines
- Follow iOS Human Interface Guidelines
- Use SF Symbols for icons
- Consistent spacing and layout
- Proper keyboard handling (dismiss on tap, submit actions)
- Loading indicators for async operations
- Empty states with helpful messages
- Confirmation dialogs for destructive actions
- Swipe actions for common operations

## Version 1 Scope
**In scope**:
- All features described above
- Manual book entry
- ISBN scanning and API lookup
- Tag and author management
- Comprehensive search and filtering
- Notes with timestamps
- Ratings

**Out of scope (for later)**:
- Export/backup functionality
- Cover images (can use placeholder)
- iCloud sync
- Multiple reading sessions per book
- Statistics/analytics
- Sharing features

## Testing Considerations
- Test with empty library (empty states)
- Test search with various queries
- Test tag creation with different cases
- Test ISBN scanner with real barcodes
- Test with many books (performance)
- Test Core Data relationships (cascading deletes)

## Deliverables
1. Complete Xcode project
2. Core Data model (.xcdatamodeld)
3. All SwiftUI views and view models
4. ISBN scanning implementation
5. API integration for book lookup
6. Search and filter logic
7. Basic app icon and launch screen

## Additional Notes
- Use sensible default values and graceful degradation
- Provide helpful error messages to users
- Keep UI clean and uncluttered
- Prioritize performance (lazy loading, efficient queries)
- Code should be well-commented and maintainable
