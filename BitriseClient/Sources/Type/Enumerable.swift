public protocol Enumerable {
    associatedtype Element = Self
}

extension Enumerable where Element: Hashable {
    private static var iterator: AnyIterator<Element> {
        var n = 0
        return AnyIterator {
            defer { n += 1 }

            let next = withUnsafePointer(to: &n) {
                UnsafeRawPointer($0).assumingMemoryBound(to: Element.self).pointee
            }
            return next.hashValue == n ? next : nil
        }
    }

    static var enumerate: EnumeratedSequence<AnySequence<Element>> {
        return AnySequence(self.iterator).enumerated()
    }

    public static var elements: [Element] {
        return Array(self.iterator)
    }

    public static var count: Int {
        return self.elements.count
    }
}
