import Foundation

public struct AppSnapshot: Codable, Equatable, Sendable {
    public static let historyLimit = 100
    public var settings: TrainingSettings
    public var activeSession: TrainingSession?
    public private(set) var history: [TrainingResult]

    public init(settings: TrainingSettings = TrainingSettings(), activeSession: TrainingSession? = nil, history: [TrainingResult] = []) {
        self.settings = settings
        self.activeSession = activeSession
        self.history = Array(history.prefix(Self.historyLimit))
    }
    private enum CodingKeys: String, CodingKey { case settings, activeSession, history }
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let settings = try values.decode(TrainingSettings.self, forKey: .settings)
        let activeSession = try values.decodeIfPresent(TrainingSession.self, forKey: .activeSession)
        let history = try values.decode([TrainingResult].self, forKey: .history)
        func countersAreValid(correct: Int, first: Int, wrong: Int, skipped: Int, best: Int) -> Bool {
            [correct, first, wrong, skipped, best].allSatisfy { (0...1_000_000).contains($0) }
                && first <= correct && best <= first
        }
        let validHistory = history.allSatisfy {
            countersAreValid(correct: $0.correctAnswers, first: $0.correctOnFirstTry, wrong: $0.incorrectAttempts, skipped: $0.skippedQuestions, best: $0.bestStreak)
        }
        let validActive = activeSession.map { session in
            countersAreValid(correct: session.correctAnswers, first: session.correctOnFirstTry, wrong: session.incorrectAttempts, skipped: session.skippedQuestions, best: session.bestStreak)
                && (0...session.incorrectAttempts).contains(session.questionMistakes)
                && (0...session.bestStreak).contains(session.streak)
                && session.problem.operation == session.settings.operation
                && (session.settings.length.target.map { session.completedQuestions <= $0 } ?? true)
        } ?? true
        guard validHistory && validActive else {
            throw DecodingError.dataCorrupted(.init(codingPath: decoder.codingPath, debugDescription: "Invalid saved training counters"))
        }
        self.init(settings: settings, activeSession: activeSession, history: history)
    }
    /// Session UUID makes repeated finish callbacks idempotent.
    @discardableResult public mutating func finish(endedAt: Date = Date()) -> TrainingResult? {
        guard let result = activeSession?.result(endedAt: endedAt) else {
            activeSession = nil
            return nil
        }
        if !history.contains(where: { $0.id == result.id }) {
            history.insert(result, at: 0)
            history = Array(history.prefix(Self.historyLimit))
        }
        activeSession = nil
        return result
    }
    public mutating func clearProgress() { history = []; activeSession = nil }
}
