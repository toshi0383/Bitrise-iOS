@testable import BitriseClient

final class MockConfig: ConfigType {

    var personalAccessToken: String? {
        return "abcdefg"
    }

    var lastAppSlugVisited: String? {
        return "app-name-0"
    }

}
