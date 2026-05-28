import SwiftUI
import SwiftData

enum TimerState { case idle, running, paused, complete }

@Observable
final class GhostModeViewModel {
    var state: TimerState = .idle
    var selectedMinutes = 25
    var remainingSeconds = 25 * 60
    var sessionLabel = ""
    var justCompleted = false

    let durationOptions = [25, 50, 90]

    private var timer: Timer?
    private var sessionStart: Date?

    var progress: Double {
        let total = Double(selectedMinutes * 60)
        return total > 0 ? 1.0 - Double(remainingSeconds) / total : 0
    }

    func selectDuration(_ minutes: Int) {
        guard state == .idle else { return }
        selectedMinutes = minutes
        remainingSeconds = minutes * 60
    }

    func start() {
        sessionStart = .now
        state = .running
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.tick()
        }
    }

    func pause() {
        state = .paused
        timer?.invalidate()
        timer = nil
    }

    func resume() {
        state = .running
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.tick()
        }
    }

    func endEarly(run: Run?, context: ModelContext) {
        timer?.invalidate()
        timer = nil
        let elapsed = (selectedMinutes * 60) - remainingSeconds
        if elapsed > 30 { persist(actualSeconds: elapsed, completed: false, run: run, context: context) }
        reset()
    }

    func reset() {
        state = .idle
        remainingSeconds = selectedMinutes * 60
        justCompleted = false
        sessionStart = nil
    }

    func handleBackground() {
        guard state == .running else { return }
        timer?.invalidate()
        timer = nil
        UserDefaults.standard.set(Date().timeIntervalSince1970, forKey: AppStorageKeys.ghostModeBackgroundedAt)
        UserDefaults.standard.set(remainingSeconds, forKey: AppStorageKeys.ghostModeRemainingSeconds)
    }

    func handleForeground() {
        guard state == .running else { return }
        let bgTime = UserDefaults.standard.double(forKey: AppStorageKeys.ghostModeBackgroundedAt)
        let savedRemaining = UserDefaults.standard.integer(forKey: AppStorageKeys.ghostModeRemainingSeconds)
        guard bgTime > 0, savedRemaining > 0 else { return }
        let elapsed = Int(Date().timeIntervalSince1970 - bgTime)
        remainingSeconds = max(savedRemaining - elapsed, 0)
        UserDefaults.standard.removeObject(forKey: AppStorageKeys.ghostModeBackgroundedAt)
        if remainingSeconds == 0 {
            completeSession(run: nil, context: nil)
        } else {
            resume()
        }
    }

    private func tick() {
        guard state == .running else { return }
        if remainingSeconds > 0 {
            remainingSeconds -= 1
        } else {
            completeSession(run: nil, context: nil)
        }
    }

    private func completeSession(run: Run?, context: ModelContext?) {
        timer?.invalidate()
        timer = nil
        state = .complete
        justCompleted = true
        if let context {
            persist(actualSeconds: selectedMinutes * 60, completed: true, run: run, context: context)
        }
    }

    private func persist(actualSeconds: Int, completed: Bool, run: Run?, context: ModelContext) {
        let session = FocusSession(plannedDurationMinutes: selectedMinutes, sessionLabel: sessionLabel)
        session.actualDurationSeconds = actualSeconds
        session.wasCompleted = completed
        session.endTime = .now
        session.run = run
        context.insert(session)

        if let run {
            let entry = todayEntry(for: run, context: context)
            entry.totalFocusMinutes += actualSeconds / 60
        }
        try? context.save()
    }
}
