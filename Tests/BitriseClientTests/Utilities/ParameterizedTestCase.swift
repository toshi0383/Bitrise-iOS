/// Parameterized tests
/// See Also: https://github.com/junit-team/junit4/wiki/parameterized-tests
struct ParameterizedTestCase<Input, Output> {
    let input: Input
    let expected: Output

    let description: String
    let file: StaticString
    let line: UInt

    init(description: String = "", input: Input, expected: Output, file: StaticString = #file, line: UInt = #line) {
        self.input = input
        self.expected = expected
        self.description = description
        self.file = file
        self.line = line
    }
}
