import SwiftUI

@MainActor
final class TrainingStore: ObservableObject {
    @Published private(set) var snapshot: AppSnapshot
    @Published private(set) var lastResult: TrainingResult?
    @Published private(set) var storageWarning = false
    private let defaults: UserDefaults
    private let key = "arithmetics.snapshot.v1"
    private let isUITesting: Bool

    init() {
        let args = ProcessInfo.processInfo.arguments
        isUITesting = args.contains("--ui-testing")
        defaults = isUITesting ? UserDefaults(suiteName: "arithmetics.ui-tests")! : .standard
        if isUITesting && !args.contains("--preserve-test-data") {
            defaults.removePersistentDomain(forName: "arithmetics.ui-tests")
        }
        if let data = defaults.data(forKey: key) {
            do { snapshot = try JSONDecoder().decode(AppSnapshot.self, from: data) }
            catch {
                // Keep corrupt data for recovery instead of overwriting it at launch.
                defaults.set(data, forKey: "arithmetics.snapshot.recovery")
                snapshot = AppSnapshot()
                storageWarning = true
            }
        } else { snapshot = AppSnapshot() }
    }

    func configure(_ change: (inout TrainingSettings) -> Void) {
        change(&snapshot.settings)
        persist()
    }

    func start() {
        guard snapshot.activeSession == nil else { return }
        var random = SystemRandomNumberGenerator()
        let problem: ArithmeticProblem
        if isUITesting {
            switch snapshot.settings.operation {
            case .addition: problem = .init(left: 2, right: 3, operation: .addition)
            case .subtraction: problem = .init(left: 8, right: 3, operation: .subtraction)
            case .multiplication: problem = .init(left: 4, right: 3, operation: .multiplication)
            case .division: problem = .init(left: 12, right: 3, operation: .division)
            }
        } else { problem = ProblemGenerator.next(settings: snapshot.settings, using: &random) }
        lastResult = nil
        snapshot.activeSession = TrainingSession(settings: snapshot.settings, problem: problem)
        persist()
    }

    @discardableResult func submit(_ answer: String) -> AnswerOutcome {
        guard var session = snapshot.activeSession else { return .ignored }
        let outcome = session.submit(answer)
        snapshot.activeSession = session
        if outcome == .correct || outcome == .incorrect { persist() }
        return outcome
    }

    func reveal() {
        snapshot.activeSession?.reveal()
        persist()
    }

    func advance() {
        var random = SystemRandomNumberGenerator()
        snapshot.activeSession?.advance(using: &random)
        if snapshot.activeSession?.phase == .finished { finish() }
        else { persist() }
    }

    func finish() {
        lastResult = snapshot.finish()
        persist()
    }

    func clearProgress() {
        snapshot.clearProgress()
        lastResult = nil
        defaults.removeObject(forKey: "arithmetics.snapshot.recovery")
        storageWarning = false
        persist()
    }

    func dismissStorageWarning() { storageWarning = false }

    private func persist() {
        do { defaults.set(try JSONEncoder().encode(snapshot), forKey: key) }
        catch { storageWarning = true }
    }
}
