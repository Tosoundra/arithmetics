import Foundation

public enum ArithmeticOperation: String, CaseIterable, Codable, Identifiable, Sendable {
    case addition, subtraction, multiplication, division

    public var id: String { rawValue }
    public var symbol: String {
        switch self {
        case .addition: return "+"
        case .subtraction: return "−"
        case .multiplication: return "×"
        case .division: return "÷"
        }
    }
    public var titleKey: String { "operation.\(rawValue)" }
    public var usesTable: Bool { self == .multiplication || self == .division }
}

public enum NumberRange: Int, CaseIterable, Codable, Identifiable, Sendable {
    case small = 20, medium = 100, large = 1000
    public var id: Int { rawValue }
}

public enum TrainingLength: Int, CaseIterable, Codable, Identifiable, Sendable {
    case ten = 10, twenty = 20, unlimited = 0
    public var id: Int { rawValue }
    public var target: Int? { self == .unlimited ? nil : rawValue }
}

public struct TrainingSettings: Codable, Equatable, Sendable {
    public var operation: ArithmeticOperation = .addition
    public var range: NumberRange = .small
    public var length: TrainingLength = .ten
    public init() {}
}

public struct ArithmeticProblem: Codable, Equatable, Sendable {
    public let left: Int
    public let right: Int
    public let operation: ArithmeticOperation
    public init(left: Int, right: Int, operation: ArithmeticOperation) {
        precondition((1...1000).contains(left) && (1...1000).contains(right))
        precondition(operation != .division || left % right == 0)
        precondition(operation != .subtraction || left > right)
        self.left = left
        self.right = right
        self.operation = operation
    }
    private enum CodingKeys: String, CodingKey { case left, right, operation }
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let left = try values.decode(Int.self, forKey: .left)
        let right = try values.decode(Int.self, forKey: .right)
        let operation = try values.decode(ArithmeticOperation.self, forKey: .operation)
        guard (1...1000).contains(left), (1...1000).contains(right),
              operation != .division || left % right == 0,
              operation != .subtraction || left > right else {
            throw DecodingError.dataCorrupted(.init(codingPath: decoder.codingPath, debugDescription: "Invalid saved arithmetic problem"))
        }
        self.init(left: left, right: right, operation: operation)
    }
    public var answer: Int {
        switch operation {
        case .addition: return left + right
        case .subtraction: return left - right
        case .multiplication: return left * right
        case .division: return left / right
        }
    }
    public var expression: String { "\(left) \(operation.symbol) \(right)" }
}

public enum ProblemGenerator {
    /// Construct valid operands directly; never search for a divisor or loop indefinitely.
    public static func next<R: RandomNumberGenerator>(
        settings: TrainingSettings, excluding previous: ArithmeticProblem? = nil, using random: inout R
    ) -> ArithmeticProblem {
        for _ in 0..<8 {
            let problem = draw(settings: settings, using: &random)
            if problem != previous { return problem }
        }
        // Fall back to a different valid problem after eight repeated draws.
        let alternatives: [ArithmeticProblem]
        switch settings.operation {
        case .addition:
            alternatives = [.init(left: 1, right: 2, operation: .addition), .init(left: 2, right: 2, operation: .addition)]
        case .subtraction:
            alternatives = [.init(left: 3, right: 1, operation: .subtraction), .init(left: 4, right: 2, operation: .subtraction)]
        case .multiplication:
            alternatives = [.init(left: 2, right: 3, operation: .multiplication), .init(left: 3, right: 4, operation: .multiplication)]
        case .division:
            alternatives = [.init(left: 6, right: 2, operation: .division), .init(left: 12, right: 3, operation: .division)]
        }
        return alternatives.first { $0 != previous }!
    }

    private static func draw<R: RandomNumberGenerator>(settings: TrainingSettings, using random: inout R) -> ArithmeticProblem {
        let limit = settings.range.rawValue
        switch settings.operation {
        case .addition:
            let left = Int.random(in: 1..<limit, using: &random)
            let right = Int.random(in: 1...(limit - left), using: &random)
            return .init(left: left, right: right, operation: .addition)
        case .subtraction:
            let left = Int.random(in: 2...limit, using: &random)
            let right = Int.random(in: 1..<left, using: &random)
            return .init(left: left, right: right, operation: .subtraction)
        case .multiplication:
            return .init(left: Int.random(in: 1...10, using: &random), right: Int.random(in: 1...10, using: &random), operation: .multiplication)
        case .division:
            let divisor = Int.random(in: 1...10, using: &random)
            let quotient = Int.random(in: 1...10, using: &random)
            return .init(left: divisor * quotient, right: divisor, operation: .division)
        }
    }
}

public enum AnswerParser {
    /// Empty input, signs, decimal values, non-ASCII digits, and overflow are not attempts.
    public static func parse(_ text: String) -> Int? {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, trimmed.utf8.allSatisfy({ (48...57).contains($0) }) else { return nil }
        return Int(trimmed)
    }
}
