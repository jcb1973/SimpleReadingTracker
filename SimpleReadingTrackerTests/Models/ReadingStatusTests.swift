import Testing
@testable import SimpleReadingTracker

struct ReadingStatusTests {
    @Test func allCasesHaveDisplayNames() {
        for status in ReadingStatus.allCases {
            #expect(!status.displayName.isEmpty)
        }
    }

    @Test func allCasesHaveSystemImages() {
        for status in ReadingStatus.allCases {
            #expect(!status.systemImage.isEmpty)
        }
    }

    @Test func rawValueRoundTrip() {
        for status in ReadingStatus.allCases {
            let restored = ReadingStatus(rawValue: status.rawValue)
            #expect(restored == status)
        }
    }

    @Test func toReadProperties() {
        let status = ReadingStatus.toRead
        #expect(status.rawValue == "toRead")
        #expect(status.displayName == "To Read")
        #expect(status.systemImage == "bookmark")
    }

    @Test func readingProperties() {
        let status = ReadingStatus.reading
        #expect(status.rawValue == "reading")
        #expect(status.displayName == "Reading")
        #expect(status.systemImage == "book.fill")
    }

    @Test func readProperties() {
        let status = ReadingStatus.read
        #expect(status.rawValue == "read")
        #expect(status.displayName == "Read")
        #expect(status.systemImage == "checkmark.circle.fill")
    }
}
