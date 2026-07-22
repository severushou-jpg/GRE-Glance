#!/usr/bin/env swift

import Foundation
import NaturalLanguage

// Development-only classifier. It never ships in the app. The committed
// assignment manifest keeps pack membership stable across future rebuilds.

private struct Word: Codable {
    let word: String
    let synonyms: [String]
}

private struct ExistingPack: Codable {
    let words: [Word]
}

private struct Category {
    let id: String
    let name: String
    let subtitle: String
    let systemImage: String
    let seeds: [String]
    let preferredDomains: Set<String>
}

private struct LexicalContext {
    var terms: [String] = []
    var domains: Set<String> = []
}

private struct AssignmentPack: Codable {
    let id: String
    let name: String
    let subtitle: String
    let systemImage: String
    let order: Int
    let words: [String]
}

private struct AssignmentManifest: Codable {
    let schemaVersion: Int
    let basis: String
    let generatedBy: String
    let packs: [AssignmentPack]
}

private let categories: [Category] = [
    Category(
        id: "ielts-pack-01",
        name: "写作论证与证据",
        subtitle: "观点、证据、评价与逻辑",
        systemImage: "text.quote",
        seeds: ["argument", "evidence", "opinion", "claim", "reason", "logic", "analysis", "evaluate", "justify", "theory", "principle", "conclusion", "perspective", "valid", "relevant", "assumption", "interpret", "criticize"],
        preferredDomains: ["noun.cognition", "verb.cognition"]
    ),
    Category(
        id: "ielts-pack-02",
        name: "图表趋势与比较",
        subtitle: "Task 1 数据、变化与流程",
        systemImage: "chart.xyaxis.line",
        seeds: ["data", "trend", "increase", "decrease", "compare", "contrast", "percentage", "quantity", "rate", "proportion", "fluctuate", "stable", "gradual", "dramatic", "peak", "decline", "sequence", "process"],
        preferredDomains: ["noun.quantity", "noun.relation", "noun.time"]
    ),
    Category(
        id: "ielts-pack-03",
        name: "因果变化与解决方案",
        subtitle: "原因、影响、问题与对策",
        systemImage: "arrow.triangle.branch",
        seeds: ["cause", "effect", "impact", "change", "problem", "solution", "consequence", "influence", "result", "challenge", "improve", "prevent", "adapt", "resolve", "replace", "transform", "reduce", "enable"],
        preferredDomains: ["verb.change", "noun.process", "noun.event"]
    ),
    Category(
        id: "ielts-pack-04",
        name: "描述评价与程度",
        subtitle: "性质、质量、强弱与准确表达",
        systemImage: "slider.horizontal.3",
        seeds: ["describe", "quality", "degree", "characteristic", "appearance", "size", "shape", "color", "strong", "weak", "positive", "negative", "effective", "significant", "accurate", "complex", "similar", "different"],
        preferredDomains: ["adj.all", "adv.all", "noun.attribute", "noun.state", "noun.shape"]
    ),
    Category(
        id: "ielts-pack-05",
        name: "沟通语言与媒体",
        subtitle: "表达、信息、新闻与语言",
        systemImage: "bubble.left.and.text.bubble.right.fill",
        seeds: ["communication", "language", "speak", "write", "message", "information", "media", "news", "advertising", "journalism", "publish", "audience", "conversation", "explain", "announce", "report", "narrative", "meaning"],
        preferredDomains: ["noun.communication", "verb.communication"]
    ),
    Category(
        id: "ielts-pack-06",
        name: "教育研究与学习",
        subtitle: "学校、研究、能力与成长",
        systemImage: "graduationcap.fill",
        seeds: ["education", "school", "student", "teacher", "university", "academic", "learn", "study", "knowledge", "skill", "training", "curriculum", "classroom", "research", "literacy", "scholarship", "examination", "graduate"],
        preferredDomains: ["noun.cognition", "verb.cognition", "noun.act"]
    ),
    Category(
        id: "ielts-pack-07",
        name: "工作商业与经济",
        subtitle: "职业、企业、金融与贸易",
        systemImage: "briefcase.fill",
        seeds: ["work", "career", "job", "business", "company", "economy", "finance", "market", "employment", "industry", "trade", "salary", "profit", "investment", "management", "productivity", "consumer", "commercial"],
        preferredDomains: ["noun.possession", "verb.possession", "noun.act"]
    ),
    Category(
        id: "ielts-pack-08",
        name: "社会政府与公共服务",
        subtitle: "政策、群体、福利与公共议题",
        systemImage: "building.columns.fill",
        seeds: ["society", "government", "policy", "public", "community", "population", "welfare", "politics", "authority", "citizen", "democracy", "institution", "social", "poverty", "inequality", "tax", "service", "administration"],
        preferredDomains: ["noun.group", "verb.social", "noun.act"]
    ),
    Category(
        id: "ielts-pack-09",
        name: "环境自然与能源",
        subtitle: "生态、气候、资源与可持续发展",
        systemImage: "leaf.fill",
        seeds: ["environment", "nature", "climate", "pollution", "energy", "ecology", "sustainable", "carbon", "emission", "waste", "recycle", "conservation", "resource", "renewable", "atmosphere", "animal", "plant", "agriculture"],
        preferredDomains: ["noun.animal", "noun.plant", "noun.phenomenon", "verb.weather", "noun.substance"]
    ),
    Category(
        id: "ielts-pack-10",
        name: "科学技术与工程",
        subtitle: "发现、设备、数字化与创新",
        systemImage: "atom",
        seeds: ["science", "technology", "innovation", "computer", "digital", "internet", "engineering", "experiment", "discovery", "machine", "device", "software", "automation", "artificial", "laboratory", "technical", "invention", "space"],
        preferredDomains: ["noun.artifact", "verb.creation", "noun.cognition"]
    ),
    Category(
        id: "ielts-pack-11",
        name: "健康身心与医疗",
        subtitle: "身体、疾病、治疗与心理健康",
        systemImage: "cross.case.fill",
        seeds: ["health", "medicine", "disease", "medical", "doctor", "patient", "treatment", "hospital", "mental", "physical", "nutrition", "exercise", "therapy", "illness", "symptom", "diagnosis", "wellbeing", "stress"],
        preferredDomains: ["noun.body", "verb.body", "noun.feeling", "verb.emotion"]
    ),
    Category(
        id: "ielts-pack-12",
        name: "人物性格与关系",
        subtitle: "情绪、行为、家庭与人际互动",
        systemImage: "person.2.fill",
        seeds: ["person", "personality", "behavior", "emotion", "family", "relationship", "friend", "attitude", "character", "feeling", "motivation", "habit", "cooperate", "conflict", "parent", "child", "individual", "psychology"],
        preferredDomains: ["noun.person", "noun.feeling", "verb.emotion", "noun.motive"]
    ),
    Category(
        id: "ielts-pack-13",
        name: "法律犯罪与冲突",
        subtitle: "司法、安全、权利与国际冲突",
        systemImage: "scale.3d",
        seeds: ["law", "crime", "legal", "court", "police", "justice", "prison", "security", "rights", "violence", "war", "weapon", "military", "punishment", "victim", "offence", "illegal", "conflict"],
        preferredDomains: ["verb.competition", "verb.social", "noun.act"]
    ),
    Category(
        id: "ielts-pack-14",
        name: "城市住房与交通",
        subtitle: "城市化、建筑、出行与基础设施",
        systemImage: "building.2.fill",
        seeds: ["city", "urban", "housing", "home", "transport", "traffic", "road", "vehicle", "travel", "building", "architecture", "infrastructure", "railway", "airport", "resident", "construction", "accommodation", "commute"],
        preferredDomains: ["noun.location", "verb.motion", "noun.artifact"]
    ),
    Category(
        id: "ielts-pack-15",
        name: "生活文化与消费",
        subtitle: "饮食、艺术、购物、旅行与休闲",
        systemImage: "cart.fill",
        seeds: ["daily", "life", "food", "shopping", "consumer", "leisure", "sport", "clothing", "restaurant", "tourism", "hobby", "entertainment", "household", "cook", "purchase", "lifestyle", "holiday", "culture", "art", "music"],
        preferredDomains: ["noun.food", "verb.consumption", "noun.artifact", "noun.act"]
    )
]

// A compact editorial pass corrects polysemy that generic word embeddings
// cannot resolve reliably (for example, artery as anatomy rather than a road).
// These are headword-only placement hints; the licensed lexical fields remain
// untouched.
private let reviewedTopicOverrides: [String: String] = [
    "abrasion": "ielts-pack-11",
    "aesthetic": "ielts-pack-15",
    "ape": "ielts-pack-09",
    "archaeological": "ielts-pack-10",
    "arena": "ielts-pack-15",
    "artery": "ielts-pack-11",
    "artistic": "ielts-pack-15",
    "aspirin": "ielts-pack-11",
    "atlas": "ielts-pack-10",
    "audition": "ielts-pack-15",
    "ballroom": "ielts-pack-15",
    "barren": "ielts-pack-09",
    "bleach": "ielts-pack-15",
    "bowel": "ielts-pack-11",
    "breeding": "ielts-pack-09",
    "calorie": "ielts-pack-11",
    "canvas": "ielts-pack-15",
    "cavity": "ielts-pack-11",
    "checkup": "ielts-pack-11",
    "climate": "ielts-pack-09",
    "commute": "ielts-pack-14",
    "congestion": "ielts-pack-14",
    "cooking": "ielts-pack-15",
    "crime": "ielts-pack-13",
    "cultivation": "ielts-pack-09",
    "disease": "ielts-pack-11",
    "dose": "ielts-pack-11",
    "farming": "ielts-pack-09",
    "fossil": "ielts-pack-09",
    "galaxy": "ielts-pack-10",
    "health": "ielts-pack-11",
    "innovation": "ielts-pack-10",
    "judicial": "ielts-pack-13",
    "law": "ielts-pack-13",
    "lens": "ielts-pack-10",
    "maize": "ielts-pack-09",
    "marrow": "ielts-pack-11",
    "melody": "ielts-pack-15",
    "microbe": "ielts-pack-11",
    "molecule": "ielts-pack-10",
    "nourishment": "ielts-pack-11",
    "particle": "ielts-pack-10",
    "pharmacy": "ielts-pack-11",
    "photocopy": "ielts-pack-10",
    "pollution": "ielts-pack-09",
    "poultry": "ielts-pack-09",
    "prototype": "ielts-pack-10",
    "psychiatry": "ielts-pack-11",
    "recital": "ielts-pack-15",
    "respiration": "ielts-pack-11",
    "rhythm": "ielts-pack-15",
    "script": "ielts-pack-05",
    "simulate": "ielts-pack-10",
    "species": "ielts-pack-09",
    "sportswear": "ielts-pack-15",
    "syllabus": "ielts-pack-06",
    "taxation": "ielts-pack-08",
    "technology": "ielts-pack-10",
    "therapy": "ielts-pack-11",
    "tourism": "ielts-pack-15",
    "tumour": "ielts-pack-11",
    "ultraviolet": "ielts-pack-10",
    "vegetation": "ielts-pack-09",
    "vein": "ielts-pack-11",
    "warming": "ielts-pack-09"
]

private struct FlowEdge {
    var to: Int
    var reverseIndex: Int
    var capacity: Int
    let cost: Int
}

private struct HeapItem {
    let distance: Int
    let node: Int
}

private struct MinHeap {
    private var values: [HeapItem] = []

    var isEmpty: Bool { values.isEmpty }

    mutating func push(_ item: HeapItem) {
        values.append(item)
        var index = values.count - 1
        while index > 0 {
            let parent = (index - 1) / 2
            if ordered(values[parent], values[index]) { break }
            values.swapAt(parent, index)
            index = parent
        }
    }

    mutating func pop() -> HeapItem? {
        guard !values.isEmpty else { return nil }
        if values.count == 1 { return values.removeLast() }
        let first = values[0]
        values[0] = values.removeLast()
        var index = 0
        while true {
            let left = index * 2 + 1
            let right = left + 1
            var best = index
            if left < values.count, !ordered(values[best], values[left]) { best = left }
            if right < values.count, !ordered(values[best], values[right]) { best = right }
            if best == index { break }
            values.swapAt(index, best)
            index = best
        }
        return first
    }

    private func ordered(_ lhs: HeapItem, _ rhs: HeapItem) -> Bool {
        lhs.distance < rhs.distance || (lhs.distance == rhs.distance && lhs.node <= rhs.node)
    }
}

private struct MinCostFlow {
    private(set) var graph: [[FlowEdge]]

    init(nodeCount: Int) {
        graph = Array(repeating: [], count: nodeCount)
    }

    mutating func addEdge(from: Int, to: Int, capacity: Int, cost: Int) {
        let forward = FlowEdge(to: to, reverseIndex: graph[to].count, capacity: capacity, cost: cost)
        let reverse = FlowEdge(to: from, reverseIndex: graph[from].count, capacity: 0, cost: -cost)
        graph[from].append(forward)
        graph[to].append(reverse)
    }

    mutating func send(source: Int, sink: Int, amount: Int) throws {
        let infinity = Int.max / 4
        var potentials = Array(repeating: 0, count: graph.count)

        for _ in 0..<amount {
            var distances = Array(repeating: infinity, count: graph.count)
            var previousNode = Array(repeating: -1, count: graph.count)
            var previousEdge = Array(repeating: -1, count: graph.count)
            distances[source] = 0
            var heap = MinHeap()
            heap.push(HeapItem(distance: 0, node: source))

            while let item = heap.pop() {
                guard item.distance == distances[item.node] else { continue }
                for edgeIndex in graph[item.node].indices {
                    let edge = graph[item.node][edgeIndex]
                    guard edge.capacity > 0 else { continue }
                    let candidate = item.distance + edge.cost + potentials[item.node] - potentials[edge.to]
                    if candidate < distances[edge.to] {
                        distances[edge.to] = candidate
                        previousNode[edge.to] = item.node
                        previousEdge[edge.to] = edgeIndex
                        heap.push(HeapItem(distance: candidate, node: edge.to))
                    }
                }
            }

            guard distances[sink] < infinity else {
                throw NSError(domain: "IELTSGlanceClassifier", code: 1, userInfo: [NSLocalizedDescriptionKey: "Unable to satisfy 100-word capacity for every pack"])
            }

            for node in graph.indices where distances[node] < infinity {
                potentials[node] += distances[node]
            }

            var node = sink
            while node != source {
                let from = previousNode[node]
                let edgeIndex = previousEdge[node]
                let reverseIndex = graph[from][edgeIndex].reverseIndex
                graph[from][edgeIndex].capacity -= 1
                graph[node][reverseIndex].capacity += 1
                node = from
            }
        }
    }
}

private func featureTerms(for word: Word) -> [String] {
    let allowed = CharacterSet.letters
    let synonymTerms = word.synonyms.flatMap { synonym in
        synonym.lowercased().components(separatedBy: allowed.inverted)
    }
    return [word.word.lowercased()] + synonymTerms.filter { $0.count >= 3 }
}

private func lexicalContexts(for words: [Word], root: URL) throws -> [String: LexicalContext] {
    let wordnetDirectory = root.appendingPathComponent("data/.build/oewn-json", isDirectory: true)
    let wantedWords = Set(words.map { $0.word.lowercased() })
    var synsetsByWord: [String: [String]] = [:]

    for letter in "abcdefghijklmnopqrstuvwxyz0" {
        let url = wordnetDirectory.appendingPathComponent("entries-\(letter).json")
        guard FileManager.default.fileExists(atPath: url.path) else { continue }
        let object = try JSONSerialization.jsonObject(with: Data(contentsOf: url))
        guard let entries = object as? [String: Any] else { continue }

        for (headword, rawEntry) in entries where wantedWords.contains(headword.lowercased()) {
            guard let entry = rawEntry as? [String: Any] else { continue }
            var synsetIDs: [String] = []
            for rawPart in entry.values {
                guard let part = rawPart as? [String: Any],
                      let senses = part["sense"] as? [[String: Any]] else { continue }
                synsetIDs.append(contentsOf: senses.compactMap { $0["synset"] as? String })
            }
            synsetsByWord[headword.lowercased()] = synsetIDs
        }
    }

    let wantedSynsets = Set(synsetsByWord.values.flatMap { $0 })
    var records: [String: (domain: String, terms: [String])] = [:]
    let stopwords: Set<String> = [
        "about", "after", "again", "also", "another", "because", "being", "between", "could", "does", "either", "from", "having", "into", "itself", "made", "make", "more", "most", "other", "over", "person", "people", "something", "someone", "such", "than", "that", "their", "there", "these", "thing", "those", "through", "under", "used", "using", "very", "what", "when", "where", "which", "while", "with", "without", "would"
    ]
    let fileURLs = try FileManager.default.contentsOfDirectory(
        at: wordnetDirectory,
        includingPropertiesForKeys: nil
    ).filter {
        $0.pathExtension == "json"
            && !$0.lastPathComponent.hasPrefix("entries-")
            && $0.lastPathComponent != "frames.json"
    }

    for url in fileURLs {
        let object = try JSONSerialization.jsonObject(with: Data(contentsOf: url))
        guard let synsets = object as? [String: Any] else { continue }
        let domain = url.deletingPathExtension().lastPathComponent

        for (synsetID, rawSynset) in synsets where wantedSynsets.contains(synsetID) {
            guard let synset = rawSynset as? [String: Any] else { continue }
            let definitions = synset["definition"] as? [String] ?? []
            let members = synset["members"] as? [String] ?? []
            let rawText = (members + definitions).joined(separator: " ").lowercased()
            let terms = rawText
                .components(separatedBy: CharacterSet.letters.inverted)
                .filter { $0.count >= 4 && !stopwords.contains($0) }
            records[synsetID] = (domain, Array(terms.prefix(36)))
        }
    }

    var contexts: [String: LexicalContext] = [:]
    for word in words {
        var context = LexicalContext()
        var seenTerms = Set<String>()
        for synsetID in synsetsByWord[word.word.lowercased()] ?? [] {
            guard let record = records[synsetID] else { continue }
            context.domains.insert(record.domain)
            for term in record.terms where seenTerms.insert(term).inserted {
                context.terms.append(term)
            }
        }
        contexts[word.word.lowercased()] = context
    }
    return contexts
}

private func meanVector(_ vectors: [[Double]]) -> [Double]? {
    guard let first = vectors.first else { return nil }
    var result = Array(repeating: 0.0, count: first.count)
    for vector in vectors where vector.count == result.count {
        for index in result.indices {
            result[index] += vector[index]
        }
    }
    return result.map { $0 / Double(vectors.count) }
}

private func blendedVector(
    word: Word,
    context: LexicalContext,
    embedding: NLEmbedding
) -> [Double]? {
    let directVectors = featureTerms(for: word).prefix(10).compactMap { embedding.vector(for: $0) }
    let contextVectors = context.terms.prefix(28).compactMap { embedding.vector(for: $0) }
    guard let direct = meanVector(directVectors) ?? meanVector(contextVectors) else { return nil }
    guard let contextual = meanVector(contextVectors), contextual.count == direct.count else { return direct }
    return zip(direct, contextual).map { $0 * 0.78 + $1 * 0.22 }
}

private func cosineDistance(_ lhs: [Double]?, _ rhs: [Double]?) -> Double {
    guard let lhs, let rhs, lhs.count == rhs.count else { return 1.5 }
    let dot = zip(lhs, rhs).reduce(0.0) { $0 + $1.0 * $1.1 }
    let lhsNorm = sqrt(lhs.reduce(0.0) { $0 + $1 * $1 })
    let rhsNorm = sqrt(rhs.reduce(0.0) { $0 + $1 * $1 })
    guard lhsNorm > 0, rhsNorm > 0 else { return 1.5 }
    return 1 - dot / (lhsNorm * rhsNorm)
}

private func categoryCost(
    word: Word,
    wordVector: [Double]?,
    category: Category,
    categoryVector: [Double]?,
    context: LexicalContext
) -> Double {
    let terms = featureTerms(for: word)
    let normalizedTerms = Set(terms)
    let exactMatches = category.seeds.filter(normalizedTerms.contains).count
    let exactBonus = min(Double(exactMatches) * 0.22, 0.44)
    let domainBonus = context.domains.isDisjoint(with: category.preferredDomains) ? 0 : 0.11
    let reviewedBonus = reviewedTopicOverrides[word.word.lowercased()] == category.id ? 0.65 : 0
    return max(0.01, cosineDistance(wordVector, categoryVector) - exactBonus - domainBonus - reviewedBonus)
}

private func classify(
    words: [Word],
    contexts: [String: LexicalContext],
    embedding: NLEmbedding
) throws -> [[Word]] {
    guard words.count == categories.count * 100 else {
        throw NSError(domain: "IELTSGlanceClassifier", code: 2, userInfo: [NSLocalizedDescriptionKey: "Expected exactly 1,500 words"])
    }

    let source = 0
    let wordStart = 1
    let categoryStart = wordStart + words.count
    let sink = categoryStart + categories.count
    var flow = MinCostFlow(nodeCount: sink + 1)
    let categoryVectors = categories.map { category in
        meanVector(category.seeds.compactMap { embedding.vector(for: $0) })
    }
    let wordVectors = words.map { word in
        blendedVector(
            word: word,
            context: contexts[word.word.lowercased()] ?? LexicalContext(),
            embedding: embedding
        )
    }

    for wordIndex in words.indices {
        flow.addEdge(from: source, to: wordStart + wordIndex, capacity: 1, cost: 0)
        for categoryIndex in categories.indices {
            let context = contexts[words[wordIndex].word.lowercased()] ?? LexicalContext()
            let score = categoryCost(
                word: words[wordIndex],
                wordVector: wordVectors[wordIndex],
                category: categories[categoryIndex],
                categoryVector: categoryVectors[categoryIndex],
                context: context
            )
            flow.addEdge(
                from: wordStart + wordIndex,
                to: categoryStart + categoryIndex,
                capacity: 1,
                cost: Int((score * 100_000).rounded())
            )
        }
    }

    for categoryIndex in categories.indices {
        flow.addEdge(from: categoryStart + categoryIndex, to: sink, capacity: 100, cost: 0)
    }

    try flow.send(source: source, sink: sink, amount: words.count)

    var result = Array(repeating: [Word](), count: categories.count)
    for wordIndex in words.indices {
        let node = wordStart + wordIndex
        for edge in flow.graph[node] {
            let categoryIndex = edge.to - categoryStart
            if categories.indices.contains(categoryIndex), edge.capacity == 0 {
                result[categoryIndex].append(words[wordIndex])
                break
            }
        }
    }
    return result
}

private let root = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
private let inputURL = root.appendingPathComponent("Shared/Resources/ielts_word_packs.json")
private let outputURL = root.appendingPathComponent("data/ielts_pack_assignments.json")

do {
    guard let embedding = NLEmbedding.wordEmbedding(for: .english) else {
        throw NSError(domain: "IELTSGlanceClassifier", code: 3, userInfo: [NSLocalizedDescriptionKey: "The macOS English word embedding is unavailable"])
    }

    let existingPacks = try JSONDecoder().decode([ExistingPack].self, from: Data(contentsOf: inputURL))
    let words = existingPacks.flatMap(\.words)
    guard Set(words.map { $0.word.lowercased() }).count == words.count else {
        throw NSError(domain: "IELTSGlanceClassifier", code: 4, userInfo: [NSLocalizedDescriptionKey: "Input contains duplicate headwords"])
    }

    let contexts = try lexicalContexts(for: words, root: root)
    let classified = try classify(words: words, contexts: contexts, embedding: embedding)
    let packs = zip(categories.indices, classified).map { categoryIndex, categoryWords in
        let category = categories[categoryIndex]
        return AssignmentPack(
            id: category.id,
            name: category.name,
            subtitle: category.subtitle,
            systemImage: category.systemImage,
            order: categoryIndex + 1,
            words: categoryWords.map(\.word).sorted()
        )
    }
    let manifest = AssignmentManifest(
        schemaVersion: 1,
        basis: "IELTS task language plus high-demand Academic and General Training topics. Categories prioritize argumentation, Task 1 data language, problem-solution language, and recurring education, work, society, environment, technology, health, people, media, law, city, nature, and daily-life contexts.",
        generatedBy: "scripts/classify_ielts_packs.swift using macOS NaturalLanguage English embeddings and curated category seed words; exact 100-word capacity per pack.",
        packs: packs
    )

    let encoder = JSONEncoder()
    encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
    let data = try encoder.encode(manifest)
    try data.write(to: outputURL, options: .atomic)

    for pack in packs {
        print("\(pack.id) · \(pack.name) · \(pack.words.count)")
        print("  \(pack.words.prefix(12).joined(separator: ", "))")
    }
    print("Wrote \(outputURL.path)")
} catch {
    FileHandle.standardError.write(Data("Classification failed: \(error.localizedDescription)\n".utf8))
    exit(1)
}
