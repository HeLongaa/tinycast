import Foundation

enum TranslateMode: String, CaseIterable, Identifiable, Codable, Sendable {
    case single
    case pair

    var id: Self { self }

    var title: String {
        self == .single ? String(localized: "One language") : String(localized: "Two languages")
    }
}

struct QuickActionSettings: Equatable, Sendable {
    /// Only what the reader chose: an absent action takes its default, so a default may move later.
    var previewChoices: [BuiltInQuickAction: Bool] = [:]

    var translateMode: TranslateMode = .single

    /// BCP-47, e.g. `es`. The single target, or the pair's primary. Empty means the Mac's own language.
    var targetLanguage: String = ""

    /// BCP-47. The pair's secondary. Empty means the Mac's own language.
    var secondaryLanguage: String = ""

    private(set) var instructionOverrides: [BuiltInQuickAction: String] = [:]

    func translateTarget() -> TranslateTarget {
        switch translateMode {
        case .single:
            return .single(TranslationLanguage.resolving(targetLanguage))
        case .pair:
            return .pair(
                primary: TranslationLanguage.resolving(targetLanguage),
                secondary: TranslationLanguage.resolving(secondaryLanguage))
        }
    }

    func previewsResult(_ action: QuickAction) -> Bool {
        switch action {
        case .builtIn(let builtIn): return previewsResult(builtIn)
        case .custom(let custom): return custom.previewsResult
        }
    }

    func previewsResult(_ action: BuiltInQuickAction) -> Bool {
        if action.alwaysPreviews { return true }
        return previewChoices[action] ?? !action.replacesDirectlyByDefault
    }

    mutating func setPreviewsResult(_ previews: Bool, for action: BuiltInQuickAction) {
        guard !action.alwaysPreviews else { return }
        previewChoices[action] = previews
    }

    func instructionOverride(for action: QuickAction) -> String? {
        action.builtInAction.flatMap(instructionOverride)
    }

    func instructionOverride(for action: BuiltInQuickAction) -> String? {
        instructionOverrides[action]
    }

    mutating func setInstructionOverride(_ instructions: String?, for action: BuiltInQuickAction) {
        guard action.allowsInstructions else { return }
        instructionOverrides[action] = instructions
    }

    /// Round-trips through `UserDefaults`; an unknown key is an action that no longer exists.
    var storedPreviewChoices: [String: Bool] {
        get { Dictionary(uniqueKeysWithValues: previewChoices.map { ($0.rawValue, $1) }) }
        set {
            previewChoices = Dictionary(
                uniqueKeysWithValues: newValue.compactMap { key, value in
                    BuiltInQuickAction(rawValue: key).map { ($0, value) }
                })
        }
    }

    var storedInstructionOverrides: [String: String] {
        get { Dictionary(uniqueKeysWithValues: instructionOverrides.map { ($0.rawValue, $1) }) }
        set {
            instructionOverrides = Dictionary(
                uniqueKeysWithValues: newValue.compactMap { key, value in
                    guard let action = BuiltInQuickAction(rawValue: key),
                        action.allowsInstructions
                    else { return nil }
                    return (action, value)
                })
        }
    }
}
