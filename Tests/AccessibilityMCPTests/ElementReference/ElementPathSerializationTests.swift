import Testing
import Foundation
@testable import AccessibilityMCP

@Suite("ElementPath Serialization Tests")
struct ElementPathSerializationTests {
    @Test("Path serializes to string")
    func serializesToString() throws {
        let path = try ElementPath(parsing: "app(1234)/window[0]")
        let string = path.toString()
        #expect(string == "app(1234)/window[0]")
    }

    @Test("Path round-trips through string")
    func roundTripsString() throws {
        let original = "app(1234)/window[0]/AXButton[\"Save\"]"
        let path = try ElementPath(parsing: original)
        let serialized = path.toString()
        let reparsed = try ElementPath(parsing: serialized)
        #expect(path == reparsed)
    }

    @Test("Path with app by name round-trips")
    func appByNameRoundTrips() throws {
        let original = "app(\"Finder\")/window[0]"
        let path = try ElementPath(parsing: original)
        let serialized = path.toString()
        #expect(serialized == original)
    }

    @Test("Path with window by title round-trips")
    func windowByTitleRoundTrips() throws {
        let original = "app(1234)/window[\"Document1\"]"
        let path = try ElementPath(parsing: original)
        let serialized = path.toString()
        #expect(serialized == original)
    }

    @Test("Path with child by index round-trips")
    func childByIndexRoundTrips() throws {
        let original = "app(1234)/window[0]/AXButton[0]"
        let path = try ElementPath(parsing: original)
        let serialized = path.toString()
        #expect(serialized == original)
    }

    @Test("Path encodes to JSON as string")
    func encodesToJSON() throws {
        let path = try ElementPath(parsing: "app(1234)/window[0]")
        let encoder = JSONEncoder()
        let data = try encoder.encode(path)
        let string = String(data: data, encoding: .utf8)
        #expect(string != nil)
        #expect(string?.isEmpty == false)
    }

    @Test("Path decodes from JSON string")
    func decodesFromJSON() throws {
        let json = "\"app(1234)/window[0]\""
        let decoder = JSONDecoder()
        let data = json.data(using: .utf8)!
        let path = try decoder.decode(ElementPath.self, from: data)
        #expect(path.components.count == 2)
    }
}
