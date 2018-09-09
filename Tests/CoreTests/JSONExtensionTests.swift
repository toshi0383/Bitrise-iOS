import Core
import XCTest

class JSONExtensionTests: XCTestCase {
    func testOperator() {
        let json1: JSON = ["a": 1, "b": 2]
        let json2: JSON = ["a": 3, "b": 4, "c": 5]
        let expected: JSON = ["a": 3, "b": 4, "c": 5]
        let r = json1 |+| json2
        XCTAssertEqual(r["a"] as! Int, expected["a"] as! Int)
        XCTAssertEqual(r["b"] as! Int, expected["b"] as! Int)
        XCTAssertEqual(r["c"] as! Int, expected["c"] as! Int)
    }
}
