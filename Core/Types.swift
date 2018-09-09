public typealias JSON = [String: Any]

infix operator |+|: AdditionPrecedence
infix operator |==|: AdditionPrecedence

public func |+| (_ lhs: JSON, _ rhs: JSON) -> JSON {
    var r: JSON = [:]
    lhs.forEach { r[$0] = $1 }
    rhs.forEach { r[$0] = $1 }
    return r
}
