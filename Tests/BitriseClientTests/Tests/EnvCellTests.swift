import Foundation
import XCTest

@testable import BitriseClient

final class EnvCellTests: XCTestCase {
    var cell: EnvCell!
    var enabledSwitch: UISwitch!

    override func setUp() {
        super.setUp()

        enabledSwitch = UISwitch()
        cell = EnvCell(style: .default, reuseIdentifier: nil, enabledSwitch: enabledSwitch)
    }

    func testConfigure() {

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
}
