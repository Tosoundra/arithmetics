import Foundation

public enum AnswerOutcome: Equatable, Sendable { case invalid, incorrect, correct, ignored }
public enum TrainingPhase: String, Codable, Sendable { case answering, correct, revealed, finished }

public struct TrainingSession: Codable, Equatable, Sendable, Identifiable {
    public let id: UUID
    public let settings: TrainingSettings
    public let startedAt: Date
    public private(set) var problem: ArithmeticProblem
    public private(set) var phase: TrainingPhase = .answering
    public private(set) var correctAnswers = 0
    public private(set) var correctOnFirstTry = 0
    public private(set) var incorrectAttempts = 0
    public private(set) var skippedQuestions = 0
    public private(set) var questionMistakes = 0
    public private(set) var streak = 0
    public private(set) var bestStreak = 0

    public init(settings: TrainingSettings, problem: ArithmeticProblem, startedAt: Date = Date(), id: UUID = UUID()) {
        precondition(settings.operation == problem.operation)
        self.settings = settings
        self.problem = problem
        self.startedAt = startedAt
        self.id = id
    }
    public var completedQuestions: Int { correctAnswers + skippedQuestions }
    public var attempts: Int { correctAnswers + incorrectAttempts }
    public var targetReached: Bool { settings.length.target.map { completedQuestions >= $0 } ?? false }
    public var questionNumber: Int { phase == .answering ? completedQuestions + 1 : max(1, completedQuestions) }

    @discardableResult public mutating func submit(_ text: String) -> AnswerOutcome {
        guard phase == .answering else { return .ignored }
        guard let answer = AnswerParser.parse(text) else { return .invalid }
        if answer != problem.answer {
            incorrectAttempts += 1
            questionMistakes += 1
            streak = 0
            return .incorrect
        }
        correctAnswers += 1
        if questionMistakes == 0 {
            correctOnFirstTry += 1
            streak += 1
            bestStreak = max(bestStreak, streak)
        }
        phase = .correct
        return .correct
    }

    /// Revealing an answer is a skip, never a successful answer.
    public mutating func reveal() {
        guard phase == .answering else { return }
        skippedQuestions += 1
        streak = 0
        phase = .revealed
    }

    public mutating func advance<R: RandomNumberGenerator>(using random: inout R) {
        guard phase == .correct || phase == .revealed else { return }
        if targetReached {
            phase = .finished
        } else {
            problem = ProblemGenerator.next(settings: settings, excluding: problem, using: &random)
            questionMistakes = 0
            phase = .answering
        }
    }

    public func result(endedAt: Date = Date()) -> TrainingResult? {
        // An empty/abandoned first question must not fabricate a zero-result workout.
        guard completedQuestions > 0 else { return nil }
        return TrainingResult(
            id: id, settings: settings, startedAt: startedAt, endedAt: endedAt,
            correctAnswers: correctAnswers, correctOnFirstTry: correctOnFirstTry,
            incorrectAttempts: incorrectAttempts, skippedQuestions: skippedQuestions,
            bestStreak: bestStreak, completed: targetReached || settings.length == .unlimited
        )
    }
}

public struct TrainingResult: Codable, Equatable, Sendable, Identifiable {
    public let id: UUID
    public let settings: TrainingSettings
    public let startedAt: Date
    public let endedAt: Date
    public let correctAnswers: Int
    public let correctOnFirstTry: Int
    public let incorrectAttempts: Int
    public let skippedQuestions: Int
    public let bestStreak: Int
    public let completed: Bool
    public var completedQuestions: Int { correctAnswers + skippedQuestions }
    public var attempts: Int { correctAnswers + incorrectAttempts }
    public var accuracy: Int { completedQuestions == 0 ? 0 : Int((Double(correctOnFirstTry) / Double(completedQuestions) * 100).rounded()) }
    public var durationSeconds: Int { Int(min(max(0, endedAt.timeIntervalSince(startedAt)), Double(Int.max / 4))) }
}
