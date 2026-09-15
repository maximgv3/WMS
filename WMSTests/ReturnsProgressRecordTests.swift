import Foundation
import SwiftData
import Testing
import UIKit

@testable import WMS

@MainActor
struct ReturnsProgressRecordTests {
    @Test
    func jpegPhotoDataCanBeDecoded() throws {
        let image = UIGraphicsImageRenderer(
            size: CGSize(width: 32, height: 32)
        ).image { context in
            UIColor.red.setFill()
            context.fill(CGRect(x: 0, y: 0, width: 32, height: 32))
        }
        let data = try #require(image.jpegData(compressionQuality: 0.8))

        #expect(UIImage(data: data) != nil)
    }

    @Test
    func recordStoresDecisionContainerAndPhoto() throws {
        let container = try ModelContainer(
            for: PickingProgressRecord.self,
            PutawayProgressRecord.self,
            ReturnsProgressRecord.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        let writeContext = container.mainContext
        let image = UIGraphicsImageRenderer(
            size: CGSize(width: 32, height: 32)
        ).image { context in
            UIColor.red.setFill()
            context.fill(CGRect(x: 0, y: 0, width: 32, height: 32))
        }
        let photo = try #require(image.jpegData(compressionQuality: 0.8))
        writeContext.insert(
            ReturnsProgressRecord(
                sourceContainerId: "source",
                decisions: [123: ReturnDecision.defect.rawValue],
                photos: [123: photo],
                itemContainers: [123: "inspection"]
            )
        )

        try writeContext.save()
        let readContext = ModelContext(container)
        let record = try #require(
            readContext.fetch(FetchDescriptor<ReturnsProgressRecord>()).first
        )

        #expect(record.sourceContainerId == "source")
        #expect(record.decisions == [123: ReturnDecision.defect.rawValue])
        #expect(record.photos == [123: photo])
        #expect(UIImage(data: record.photos[123] ?? Data()) != nil)
        #expect(record.itemContainers == [123: "inspection"])
    }
}
