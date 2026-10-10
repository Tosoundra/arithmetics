import XCTest
#if canImport(ArithmeticCore)
@testable import ArithmeticCore
#else
@testable import Arithmetics
#endif

private struct SeededRandom: RandomNumberGenerator {
    var state: UInt64 = 42
    mutating func next() -> UInt64 {
        state &+= 0x9e3779b97f4a7c15
        var value = state
        value = (value ^ (value >> 30)) &* 0xbf58476d1ce4e5b9
        value = (value ^ (value >> 27)) &* 0x94d049bb133111eb
        return value ^ (value >> 31)
    }
}

final class ArithmeticCoreTests: XCTestCase {
    func testTwelveThousandGeneratedProblemsRespectOperationRanges() {
        var random = SeededRandom()
        for operation in ArithmeticOperation.allCases {
            for range in NumberRange.allCases {
                var settings = TrainingSettings()
                settings.operation = operation
                settings.range = range
                var previous: ArithmeticProblem?
                for _ in 0..<1000 {
                    let problem = ProblemGenerator.next(settings: settings, excluding: previous, using: &random)
                    XCTAssertNotEqual(problem, previous)
                    XCTAssertEqual(problem.operation, operation)
                    XCTAssertGreaterThan(problem.answer, 0)
                    switch operation {
                    case .addition: XCTAssertLessThanOrEqual(problem.answer, range.rawValue)
                    case .subtraction:
                        XCTAssertLessThanOrEqual(problem.left, range.rawValue)
                        XCTAssertGreaterThan(problem.left, problem.right)
                    case .multiplication:
                        XCTAssertTrue((1...10).contains(problem.left))
                        XCTAssertTrue((1...10).contains(problem.right))
                    case .division:
                        XCTAssertTrue((1...10).contains(problem.right))
                        XCTAssertTrue((1...10).contains(problem.answer))
                        XCTAssertEqual(problem.left % problem.right, 0)
                    }
                    previous = problem
                }
            }
        }
    }

    func testParserRejectsNonIntegersAndOverflow() {
        for input in ["", "   ", "-1", "+1", "1.0", "1,0", "2e3", "abc", "١", String(repeating: "9", count: 40)] {
            XCTAssertNil(AnswerParser.parse(input), input)
        }
        XCTAssertEqual(AnswerParser.parse(" 005\n"), 5)
        XCTAssertEqual(AnswerParser.parse("0"), 0)
    }

    func testRetryKeepsProblemAndCannotCountResolvedQuestionTwice() {
        var session = sampleSession()
        XCTAssertEqual(session.submit(""), .invalid)
        XCTAssertEqual(session.attempts, 0)
        XCTAssertEqual(session.submit("4"), .incorrect)
        XCTAssertEqual(session.problem.answer, 5)
        XCTAssertEqual(session.phase, .answering)
        XCTAssertEqual(session.submit("5"), .correct)
        XCTAssertEqual(session.submit("5"), .ignored)
        session.reveal()
        XCTAssertEqual(session.correctAnswers, 1)
        XCTAssertEqual(session.correctOnFirstTry, 0)
        XCTAssertEqual(session.incorrectAttempts, 1)
        XCTAssertEqual(session.attempts, 2)
        XCTAssertEqual(session.skippedQuestions, 0)
    }

    func testRevealCountsSkipAndCannotBeRepeated() {
        var session = sampleSession()
        session.reveal()
        session.reveal()
        XCTAssertEqual(session.submit("5"), .ignored)
        XCTAssertEqual(session.skippedQuestions, 1)
        XCTAssertEqual(session.correctAnswers, 0)
        XCTAssertEqual(session.attempts, 0)
        XCTAssertEqual(session.result()?.accuracy, 0)
    }

    func testFixedTrainingStopsAtTenAndResetsQuestionMistakes() {
        var session = sampleSession()
        var random = SeededRandom()
        session.advance(using: &random)
        XCTAssertEqual(session.problem.answer, 5) // Can't advance an unanswered question.
        for _ in 0..<10 {
            XCTAssertEqual(session.submit(String(session.problem.answer)), .correct)
            session.advance(using: &random)
        }
        XCTAssertEqual(session.phase, .finished)
        XCTAssertEqual(session.completedQuestions, 10)
        XCTAssertEqual(session.submit("1"), .ignored)
        XCTAssertEqual(session.result()?.accuracy, 100)
        XCTAssertEqual(session.bestStreak, 10)
        XCTAssertEqual(session.result()?.completed, true)
    }

    func testStreakBreaksOnWrongAnswerAndOnSkip() {
        var session = sampleSession()
        var random = SeededRandom()
        session.submit("5")
        session.advance(using: &random)
        session.submit(String(session.problem.answer))
        XCTAssertEqual(session.bestStreak, 2)
        session.advance(using: &random)
        session.submit("0")
        session.submit(String(session.problem.answer))
        XCTAssertEqual(session.streak, 0)
        session.advance(using: &random)
        XCTAssertEqual(session.questionMistakes, 0)
        session.reveal()
        XCTAssertEqual(session.streak, 0)
        XCTAssertEqual(session.bestStreak, 2)
    }

    func testUnlimitedDoesNotFinishAutomatically() {
        var settings = TrainingSettings()
        settings.length = .unlimited
        var session = sampleSession(settings: settings)
        var random = SeededRandom()
        for _ in 0..<30 {
            session.submit(String(session.problem.answer))
            session.advance(using: &random)
        }
        XCTAssertEqual(session.phase, .answering)
        XCTAssertFalse(session.targetReached)
        XCTAssertEqual(session.result()?.completed, true)
    }

    func testEarlyExitAndEmptyExitHaveHonestResults() {
        var session = sampleSession()
        XCTAssertNil(session.result())
        session.submit("5")
        XCTAssertEqual(session.result()?.completed, false)
        XCTAssertEqual(session.result(endedAt: session.startedAt.addingTimeInterval(-10))?.durationSeconds, 0)
    }

    func testRoundTripPreservesUnfinishedAndResolvedSession() throws {
        var session = sampleSession()
        session.submit("0")
        var snapshot = AppSnapshot(activeSession: session)
        XCTAssertEqual(try JSONDecoder().decode(AppSnapshot.self, from: JSONEncoder().encode(snapshot)), snapshot)
        snapshot.activeSession?.submit("5")
        XCTAssertEqual(try JSONDecoder().decode(AppSnapshot.self, from: JSONEncoder().encode(snapshot)), snapshot)
    }

    func testFinishIsIdempotentAndHistoryIsBounded() {
        var session = sampleSession()
        session.submit("5")
        var snapshot = AppSnapshot(activeSession: session)
        XCTAssertNotNil(snapshot.finish())
        XCTAssertNil(snapshot.finish())
        snapshot.activeSession = session // Simulate stale duplicate callback.
        snapshot.finish()
        XCTAssertEqual(snapshot.history.count, 1)
        for _ in 0..<105 {
            var another = sampleSession()
            another.reveal()
            snapshot.activeSession = another
            snapshot.finish()
        }
        XCTAssertEqual(snapshot.history.count, 100)
        snapshot.clearProgress()
        XCTAssertEqual(snapshot.history.count, 0)
        XCTAssertNil(snapshot.activeSession)
    }

    func testMalformedSnapshotIsRejectedRatherThanExecuted() {
        XCTAssertThrowsError(try JSONDecoder().decode(AppSnapshot.self, from: Data("not-json".utf8)))
        XCTAssertThrowsError(try JSONDecoder().decode(AppSnapshot.self, from: Data("{\"settings\":{\"operation\":\"unknown\"}}".utf8)))
        for json in ["{\"left\":1,\"right\":0,\"operation\":\"division\"}", "{\"left\":7,\"right\":3,\"operation\":\"division\"}", "{\"left\":2,\"right\":3,\"operation\":\"subtraction\"}"] {
            XCTAssertThrowsError(try JSONDecoder().decode(ArithmeticProblem.self, from: Data(json.utf8)))
        }
    }

    private func sampleSession(settings: TrainingSettings = TrainingSettings()) -> TrainingSession {
        .init(settings: settings, problem: .init(left: 2, right: 3, operation: .addition))
    }
}
