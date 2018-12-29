import Foundation
import XCTest

@testable import BitriseClient

final class EnvCellTests: XCTestCase {
    var cell: EnvCell!
    var enabledSwitch: UISwitch!
    var key: UITextField!
    var value: UITextField!

    override func setUp() {
        super.setUp()

        enabledSwitch = UISwitch()
        key = UITextField()
        value = UITextField()
        cell = EnvCell(style: .default,
                       reuseIdentifier: nil,
                       key: key,
                       value: value,
                       enabledSwitch: enabledSwitch)
    }

    func testConfigure_enabledSwitch() {

        let env = BuildTriggerEnvironment(pkey: "pkey000",
                                          enabled: true,
                                          key: "PLATFORM",
                                          value: "tvOS")

        let ex = expectation(description: "")

        var result: [BuildTriggerEnvironment] = []

        cell.configure(env, switchHandler: { newValue in
            result.append(newValue)
            if result.count == 3 {
                ex.fulfill()
            }
        })

        enabledSwitch.isOn = false
        enabledSwitch.sendActions(for: .valueChanged)
        enabledSwitch.isOn = true
        enabledSwitch.sendActions(for: .valueChanged)

        wait(for: [ex], timeout: 0.5)

        XCTAssertEqual(result.map { $0.enabled }, [true, false, true])
    }

    func testConfigure_key_value() {

        let env = BuildTriggerEnvironment(pkey: "pkey000",
                                          enabled: true,
                                          key: "PLATFORM",
                                          value: "tvOS")

        let ex = expectation(description: "")

        var result: [BuildTriggerEnvironment] = []

        cell.configure(env, switchHandler: { newValue in
            result.append(newValue)
            if result.count == 5 {
                ex.fulfill()
            }
        })

        key.updateText("b")
        key.updateText("c")

        value.updateText("d")
        value.updateText("e")

        wait(for: [ex], timeout: 0.5)

        XCTAssertEqual(result.map { $0.key }, ["PLATFORM", "b", "c", "c", "c"])
        XCTAssertEqual(result.map { $0.value }, ["tvOS", "tvOS", "tvOS", "d", "e"])
    }
}
