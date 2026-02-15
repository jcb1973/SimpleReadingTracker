import Foundation
import SwiftData

#if DEBUG
@MainActor
enum SampleDataSeeder {
    static func seed(into context: ModelContext) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"

        // MARK: - Tags

        let fiction = Tag(name: "Fiction")
        let nonFiction = Tag(name: "Non Fiction")
        let cycling = Tag(name: "Cycling")
        let nature = Tag(name: "Nature")
        let bookerPrize = Tag(name: "Booker Prize")
        let classics = Tag(name: "Classics")
        let allTags = [fiction, nonFiction, cycling, nature, bookerPrize, classics]
        for tag in allTags { context.insert(tag) }

        // MARK: - Authors

        func makeAuthor(_ name: String) -> Author {
            let author = Author(name: name)
            context.insert(author)
            return author
        }

        let sovndal = makeAuthor("Shannon Sovndal")
        let wohlleben = makeAuthor("Peter Wohlleben")
        let penn = makeAuthor("Robert Penn")
        let crace = makeAuthor("Jim Crace")
        let tokarczuk = makeAuthor("Olga Tokarczuk")
        let dickens = makeAuthor("Charles Dickens")
        let jones = makeAuthor("Peter Jones")

        // MARK: - Books

        // 1. Cycling Anatomy — To Read
        let book1 = Book(
            title: "Cycling Anatomy",
            isbn: "9780736075879",
            publisher: "Human Kinetics",
            publishedDate: "2009",
            status: .toRead,
            dateAdded: dateFormatter.date(from: "15/02/2026") ?? .now
        )
        context.insert(book1)
        book1.authors = [sovndal]
        book1.tags = [nonFiction, cycling]

        // 2. The Inner Life of Animals — To Read
        let book2 = Book(
            title: "The Inner Life of Animals",
            isbn: "9781847924544",
            publisher: "Jonathan Cape",
            publishedDate: "2017",
            pageCount: 0,
            status: .toRead,
            dateAdded: dateFormatter.date(from: "15/02/2026") ?? .now
        )
        context.insert(book2)
        book2.authors = [wohlleben]
        book2.tags = [nonFiction, nature]

        // 3. It's All about the Bike — To Read (with quote)
        let book3 = Book(
            title: "It's All about the Bike",
            isbn: "9780141043791",
            publisher: "Penguin Books, Limited",
            publishedDate: "2011",
            pageCount: 202,
            status: .toRead,
            dateAdded: dateFormatter.date(from: "15/02/2026") ?? .now
        )
        context.insert(book3)
        book3.authors = [penn]
        book3.tags = [nonFiction, cycling]

        let quote3 = Quote(
            text: "We don't do planned obsolescence. We don't have model years. We don't change products annually. In fact, the i-inch threaded headset we still sell today is exactly the same as the model Chris King first started making and selling to his friends in 1976.",
            book: book3
        )
        context.insert(quote3)

        // 4. Quarantine — Reading (with note)
        let book4 = Book(
            title: "Quarantine",
            isbn: "9780140239744",
            publisher: "Penguin",
            publishedDate: "1998",
            pageCount: 242,
            status: .reading,
            dateAdded: dateFormatter.date(from: "15/02/2026") ?? .now,
            dateStarted: dateFormatter.date(from: "15/02/2026")
        )
        context.insert(book4)
        book4.authors = [crace]
        book4.tags = [fiction, bookerPrize]

        let note4 = Note(content: "Satirical reimagining of the UK's COVID-19 response", book: book4)
        context.insert(note4)

        // 5. Flights — Reading
        let book5 = Book(
            title: "Flights",
            isbn: "9781910695821",
            publisher: "PENGUIN INDIA",
            publishedDate: "Aug 14, 2018",
            pageCount: 424,
            status: .reading,
            dateAdded: dateFormatter.date(from: "15/02/2026") ?? .now,
            dateStarted: dateFormatter.date(from: "15/02/2026")
        )
        context.insert(book5)
        book5.authors = [tokarczuk]
        book5.tags = [fiction, bookerPrize]

        // 6. Nicholas Nickleby — To Read
        let book6 = Book(
            title: "Nicholas Nickleby",
            isbn: "9780140435122",
            publisher: "Penguin Books",
            publishedDate: "1999",
            pageCount: 816,
            status: .toRead,
            dateAdded: dateFormatter.date(from: "15/02/2026") ?? .now
        )
        context.insert(book6)
        book6.authors = [dickens]
        book6.tags = [fiction]

        // 7. Eureka! — Read, rated 4 stars (with quote + comment)
        let book7 = Book(
            title: "Eureka!",
            isbn: "9781782395164",
            publisher: "Atlantic Books, Limited",
            publishedDate: "2015",
            status: .read,
            rating: 4,
            dateAdded: dateFormatter.date(from: "15/02/2026") ?? .now,
            dateStarted: dateFormatter.date(from: "15/02/2026"),
            dateFinished: dateFormatter.date(from: "15/02/2026")
        )
        context.insert(book7)
        book7.authors = [jones]
        book7.tags = [nonFiction, classics]

        let quote7 = Quote(
            text: "Spartans claimed to be descended from Heracles: Sparta had undergone its poverty-stricken Dark Age too, and emerged by ruthlessly reshaping their world: they conquered the neighbouring territory of Messenia and enslaved its whole population.",
            comment: "Ruthless indeed",
            book: book7
        )
        context.insert(quote7)

        try? context.save()
    }
}
#endif
