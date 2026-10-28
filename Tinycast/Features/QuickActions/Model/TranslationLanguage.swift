import Foundation

/// A language the translate action can name. The raw value is what the model is prompted with; the
/// picker shows the reader's own name for it.
enum TranslationLanguage: String, CaseIterable, Identifiable, Sendable {
    case arabic = "Arabic"
    case bengali = "Bengali"
    case bulgarian = "Bulgarian"
    case cantonese = "Cantonese"
    case catalan = "Catalan"
    case chinese = "Chinese"
    case croatian = "Croatian"
    case czech = "Czech"
    case danish = "Danish"
    case dutch = "Dutch"
    case english = "English"
    case estonian = "Estonian"
    case filipino = "Filipino"
    case finnish = "Finnish"
    case french = "French"
    case german = "German"
    case greek = "Greek"
    case hebrew = "Hebrew"
    case hindi = "Hindi"
    case hungarian = "Hungarian"
    case indonesian = "Indonesian"
    case italian = "Italian"
    case japanese = "Japanese"
    case korean = "Korean"
    case latvian = "Latvian"
    case lithuanian = "Lithuanian"
    case malay = "Malay"
    case norwegian = "Norwegian"
    case persian = "Persian"
    case polish = "Polish"
    case portuguese = "Portuguese"
    case romanian = "Romanian"
    case russian = "Russian"
    case slovak = "Slovak"
    case slovenian = "Slovenian"
    case spanish = "Spanish"
    case swedish = "Swedish"
    case thai = "Thai"
    case turkish = "Turkish"
    case ukrainian = "Ukrainian"
    case vietnamese = "Vietnamese"

    var id: Self { self }

    func displayName(locale: Locale) -> String {
        locale.localizedString(forLanguageCode: code) ?? rawValue
    }

    init?(code: String) {
        guard let match = Self.allCases.first(where: { $0.code == code }) else { return nil }
        self = match
    }

    /// Empty follows the Mac; an unknown code falls back to the Mac, then English.
    static func resolving(_ code: String) -> TranslationLanguage {
        if let match = Self(code: code) { return match }
        let system = Locale.current.language.languageCode?.identifier ?? ""
        return Self(code: system) ?? .english
    }

    /// Sorted by the reader's own names, so the menu reads alphabetically in every locale.
    static var menu: [TranslationLanguage] {
        allCases.sorted { $0.displayName(locale: .current) < $1.displayName(locale: .current) }
    }

    var code: String {
        switch self {
        case .arabic: "ar"
        case .bengali: "bn"
        case .bulgarian: "bg"
        case .cantonese: "yue"
        case .catalan: "ca"
        case .chinese: "zh"
        case .croatian: "hr"
        case .czech: "cs"
        case .danish: "da"
        case .dutch: "nl"
        case .english: "en"
        case .estonian: "et"
        case .filipino: "fil"
        case .finnish: "fi"
        case .french: "fr"
        case .german: "de"
        case .greek: "el"
        case .hebrew: "he"
        case .hindi: "hi"
        case .hungarian: "hu"
        case .indonesian: "id"
        case .italian: "it"
        case .japanese: "ja"
        case .korean: "ko"
        case .latvian: "lv"
        case .lithuanian: "lt"
        case .malay: "ms"
        case .norwegian: "nb"
        case .persian: "fa"
        case .polish: "pl"
        case .portuguese: "pt"
        case .romanian: "ro"
        case .russian: "ru"
        case .slovak: "sk"
        case .slovenian: "sl"
        case .spanish: "es"
        case .swedish: "sv"
        case .thai: "th"
        case .turkish: "tr"
        case .ukrainian: "uk"
        case .vietnamese: "vi"
        }
    }
}

/// Where a translation goes: to one language, or the swap between a pair.
enum TranslateTarget: Equatable, Sendable {
    case single(TranslationLanguage)
    case pair(primary: TranslationLanguage, secondary: TranslationLanguage)
}
