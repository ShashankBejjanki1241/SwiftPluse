import Foundation
import SwiftUI
import SwiftData

// MARK: - Article Models
struct ArticleRemote: Decodable, Identifiable {
    struct Source: Decodable { let id: String?; let name: String? }

    let source: Source
    let author: String?
    let title: String
    let description: String?
    let url: URL
    let urlToImage: URL?
    let publishedAt: Date
    let content: String?

    var id: String { url.absoluteString }
    var summary: String? { description }
    var imageURL: URL? { urlToImage }
    var sourceName: String? { source.name }
}

@Model
final class Article: Identifiable {
    @Attribute(.unique) var id: String
    var title: String
    var summary: String?
    var imageURL: URL?
    var source: String?
    var publishedAt: Date
    var url: URL
    var isFavorite: Bool
    var cachedAt: Date
    


    init(from remote: ArticleRemote, isFavorite: Bool = false) {
        self.id = remote.id
        self.title = remote.title
        self.summary = remote.summary
        self.imageURL = remote.imageURL
        self.source = remote.sourceName
        self.publishedAt = remote.publishedAt
        self.url = remote.url
        self.isFavorite = isFavorite
        self.cachedAt = Date()
    }

    init(id: String, title: String, summary: String?, imageURL: URL?, source: String?, publishedAt: Date, url: URL, isFavorite: Bool = false) {
        self.id = id
        self.title = title
        self.summary = summary
        self.imageURL = imageURL
        self.source = source
        self.publishedAt = publishedAt
        self.url = url
        self.isFavorite = isFavorite
        self.cachedAt = Date()
    }
}

struct ArticlesResponse: Decodable {
    let status: String
    let totalResults: Int
    let articles: [ArticleRemote]
}

// MARK: - Endpoint
struct Endpoint {
    let path: String
    let query: [URLQueryItem]

    var url: URL {
        var comps = URLComponents()
        comps.scheme = "https"
        comps.host = "newsapi.org"
        comps.path = path
        comps.queryItems = query
        // Force unwrap is OK here because we control components
        return comps.url!
    }

    let headers: [String: String] = [:]
}

// MARK: - NewsAPI Endpoints
enum NewsAPI {
    static func topHeadlines(country: String = "us", page: Int, pageSize: Int = 20, q: String? = nil) -> Endpoint {
        var items: [URLQueryItem] = [
            .init(name: "country", value: country),
            .init(name: "pageSize", value: String(pageSize)),
            .init(name: "page", value: String(page))
        ]
        if let q, !q.isEmpty { items.append(.init(name: "q", value: q)) }
        return Endpoint(path: "/v2/top-headlines", query: items)
    }

    static func everything(q: String, page: Int, pageSize: Int = 20, from: Date? = nil, to: Date? = nil, sortBy: String = "publishedAt") -> Endpoint {
        var items: [URLQueryItem] = [
            .init(name: "q", value: q),
            .init(name: "pageSize", value: String(pageSize)),
            .init(name: "page", value: String(page)),
            .init(name: "sortBy", value: sortBy)
        ]
        let iso = ISO8601DateFormatter()
        if let from { items.append(.init(name: "from", value: iso.string(from: from))) }
        if let to   { items.append(.init(name: "to",   value: iso.string(from: to))) }
        return Endpoint(path: "/v2/everything", query: items)
    }
}

// MARK: - HTTP Client
actor HTTPClient {
    private let apiKey: String
    init(apiKey: String) { self.apiKey = apiKey }

    func get<T: Decodable>(_ endpoint: Endpoint) async throws -> T {
        var req = URLRequest(url: endpoint.url)
        req.addValue(apiKey, forHTTPHeaderField: "X-Api-Key")
        for (k, v) in endpoint.headers { req.setValue(v, forHTTPHeaderField: k) }

        let (data, resp) = try await URLSession.shared.data(for: req)
        guard let http = resp as? HTTPURLResponse else { throw APIError.unknown }

        switch http.statusCode {
        case 200: break
        case 400: throw APIError.badRequest
        case 401: throw APIError.unauthorized
        case 429: throw APIError.rateLimited
        case 500...: throw APIError.server
        default: throw APIError.unknown
        }

        do { return try JSONDecoder.news.decode(T.self, from: data) }
        catch { throw APIError.decoding }
    }
}

// MARK: - JSON Decoder Extension
extension JSONDecoder {
    static var news: JSONDecoder {
        let d = JSONDecoder()
        d.dateDecodingStrategy = .iso8601
        return d
    }
}

// MARK: - API Error
enum APIError: Error, LocalizedError {
    case unauthorized, rateLimited, badRequest, server, decoding, unknown

    var errorDescription: String? {
        switch self {
        case .unauthorized: return "Invalid API key. Please check your configuration."
        case .rateLimited:  return "Rate limit hit. Please retry later."
        case .badRequest:   return "Invalid request. Please check your search terms."
        case .server:       return "Server error. Please try again later."
        case .decoding:     return "Failed to process response from server."
        case .unknown:      return "An unexpected error occurred."
        }
    }
}

// MARK: - Configuration Manager
@MainActor
struct ConfigurationManager {
    static let shared = ConfigurationManager()
    private init() {}

    // TODO: move to .xcconfig or Secrets, do not hardcode
    var apiKey: String { "236f0f833d0d4b92bcdaea25326029a3" }
    var apiHost: String { "https://newsapi.org" }
    var pageSize: Int { 20 }
    var cacheDurationHours: Int { 2 }

    var isUsingTestKey: Bool { false }
    var maxDailyRequests: Int { 80 } // buffer below free limit
}

// MARK: - Rate Limiting Manager (UserDefaults-backed)
@MainActor
final class RateLimitManager: ObservableObject {
    static let shared = RateLimitManager()

    private let countKey = "dailyRequestCount"
    private let dateKey  = "lastRequestDate"
    private var defaults: UserDefaults { .standard }

    private init() {
        resetDailyCountIfNeeded()
    }

    private var dailyRequestCount: Int {
        get { defaults.integer(forKey: countKey) }
        set { defaults.set(newValue, forKey: countKey) }
    }

    private var lastRequestDate: Date {
        get { defaults.object(forKey: dateKey) as? Date ?? .distantPast }
        set { defaults.set(newValue, forKey: dateKey) }
    }

    func canMakeRequest() -> Bool {
        resetDailyCountIfNeeded()
        return dailyRequestCount < ConfigurationManager.shared.maxDailyRequests
    }

    func recordRequest() {
        dailyRequestCount += 1
    }

    private func resetDailyCountIfNeeded() {
        if !Calendar.current.isDate(lastRequestDate, inSameDayAs: Date()) {
            dailyRequestCount = 0
            lastRequestDate = Date()
        }
    }

    var remainingRequests: Int {
        resetDailyCountIfNeeded()
        return max(0, ConfigurationManager.shared.maxDailyRequests - dailyRequestCount)
    }

    func resetDailyCount() {
        dailyRequestCount = 0
        lastRequestDate = Date()
    }
}

// MARK: - Persistence Controller
@MainActor
final class PersistenceController {
    static let shared = PersistenceController()
    private init() {}

    lazy var modelContainer: ModelContainer = {
        do {
            // simplest and robust container creation
            return try ModelContainer(for: Article.self)
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    lazy var modelContext: ModelContext = {
        modelContainer.mainContext
    }()

    func clearAllData() throws {
        let fetch = FetchDescriptor<Article>()
        let all = try modelContext.fetch(fetch)
        for obj in all { modelContext.delete(obj) }
        try modelContext.save()
    }
}

// MARK: - Analytics (stub)
@MainActor
protocol AnalyticsProtocol { func track(event: String, properties: [String: Any]?) }

@MainActor
final class Analytics: AnalyticsProtocol {
    static let shared = Analytics()
    private init() {}
    func track(event: String, properties: [String: Any]? = nil) {
        var msg = "📊 Analytics Event: \(event)"
        if let p = properties, !p.isEmpty {
            msg += " | " + p.map { "\($0.key): \($0.value)" }.joined(separator: ", ")
        }
        print(msg)
    }
}

// MARK: - Design System
extension Color {
    static let primaryText = Color.primary
    static let secondaryText = Color.secondary
    static let tertiaryText = Color(.tertiaryLabel)
    static let primaryBackground = Color(.systemBackground)
    static let secondaryBackground = Color(.secondarySystemBackground)
    static let error = Color.red
}

extension CGFloat {
    static let spacing4: CGFloat = 4
    static let spacing8: CGFloat = 8
    static let spacing12: CGFloat = 12
    static let spacing16: CGFloat = 16
    static let spacing20: CGFloat = 20
    static let spacing24: CGFloat = 24
    static let spacing32: CGFloat = 32

    static let cornerRadiusSmall: CGFloat = 8
    static let cornerRadiusMedium: CGFloat = 12
    static let cornerRadiusLarge: CGFloat = 16
}

extension View {
    func standardButtonStyle() -> some View {
        self
            .font(.headline)
            .foregroundColor(.white)
            .padding(.horizontal, .spacing20)
            .padding(.vertical, .spacing12)
            .background(Color.accent)
            .cornerRadius(.cornerRadiusMedium)
    }
}

// MARK: - Feature Flags
struct FeatureFlags {
    static let shared = FeatureFlags()
    private init() {}
    var enableSearch = true
    var enableFavorites = true
    var enableOfflineReading = true
    var enableAnalytics = true
    var enableDarkMode = true
}

// MARK: - Article Repository
@MainActor
protocol ArticleRepositoryProtocol {
    func feed(page: Int) async throws -> [Article]
    func search(query: String, page: Int) async throws -> [Article]
    func setFavorite(_ id: String, isFavorite: Bool) throws
    func cachedFeed() throws -> [Article]
    func getFavorites() throws -> [Article]

    var remainingRequests: Int { get }
    var isRateLimited: Bool { get }
    func resetRateLimit()
}

@MainActor
final class ArticleRepository: ArticleRepositoryProtocol {
    private let httpClient: HTTPClient
    private let modelContext: ModelContext
    private let cacheDuration: TimeInterval

    init(httpClient: HTTPClient, modelContext: ModelContext, cacheDuration: TimeInterval = 2 * 60 * 60) {
        self.httpClient = httpClient
        self.modelContext = modelContext
        self.cacheDuration = cacheDuration
    }

    func feed(page: Int) async throws -> [Article] {
        guard RateLimitManager.shared.canMakeRequest() else { throw APIError.rateLimited }

        if page == 1 {
            let cached = try cachedFeed()
            if !cached.isEmpty && isCacheValid() { return cached }
        }

        let endpoint = NewsAPI.topHeadlines(page: page)
        let response: ArticlesResponse = try await httpClient.get(endpoint)

        RateLimitManager.shared.recordRequest()

        let articles = response.articles.map { Article(from: $0) }

        if page == 1 { try clearExpiredCache() }
        for a in articles { modelContext.insert(a) }
        try modelContext.save()

        return articles
    }

    func search(query: String, page: Int) async throws -> [Article] {
        guard RateLimitManager.shared.canMakeRequest() else { throw APIError.rateLimited }

        let endpoint = NewsAPI.everything(q: query, page: page)
        let response: ArticlesResponse = try await httpClient.get(endpoint)

        RateLimitManager.shared.recordRequest()

        let articles = response.articles.map { Article(from: $0) }
        // (Optional) persist search results if you want offline search history
        return articles
    }

    func setFavorite(_ id: String, isFavorite: Bool) throws {
        let fetch = FetchDescriptor<Article>(predicate: #Predicate { $0.id == id })
        if let article = try modelContext.fetch(fetch).first {
            article.isFavorite = isFavorite
            try modelContext.save()
        }
    }

    func cachedFeed() throws -> [Article] {
        let cutoff = Date().addingTimeInterval(-cacheDuration)
        let fetch = FetchDescriptor<Article>(
            predicate: #Predicate { $0.cachedAt > cutoff },
            sortBy: [SortDescriptor(\.publishedAt, order: .reverse)]
        )
        var fd = fetch
        fd.fetchLimit = 20
        return try modelContext.fetch(fd)
    }

    func getFavorites() throws -> [Article] {
        let fetch = FetchDescriptor<Article>(
            predicate: #Predicate { $0.isFavorite == true },
            sortBy: [SortDescriptor(\.publishedAt, order: .reverse)]
        )
        return try modelContext.fetch(fetch)
    }

    private func isCacheValid() -> Bool {
        (try? !cachedFeed().isEmpty) ?? false
    }

    private func clearExpiredCache() throws {
        let cutoff = Date().addingTimeInterval(-cacheDuration)
        let fetch = FetchDescriptor<Article>(predicate: #Predicate { $0.cachedAt < cutoff && $0.isFavorite == false })
        let expired = try modelContext.fetch(fetch)
        for e in expired { modelContext.delete(e) }
        try modelContext.save()
    }

    // Rate info
    var remainingRequests: Int { RateLimitManager.shared.remainingRequests }
    var isRateLimited: Bool { !RateLimitManager.shared.canMakeRequest() }
    func resetRateLimit() { RateLimitManager.shared.resetDailyCount() }
}
