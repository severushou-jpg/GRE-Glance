import Foundation

struct VocabularyPack: Codable, Identifiable, Hashable, Sendable {
    let id: String
    let name: String
    let subtitle: String
    let systemImage: String?
    let order: Int
    let words: [IELTSWord]

    var iconName: String { systemImage ?? "square.stack.3d.up.fill" }

    var wordCountDescription: String { "\(words.count) 个词" }

    static let fallback = VocabularyPack(
        id: "fallback",
        name: "安全示例",
        subtitle: "词库加载失败时使用",
        systemImage: "exclamationmark.triangle.fill",
        order: 1,
        words: IELTSWord.fallbackWords
    )
}
