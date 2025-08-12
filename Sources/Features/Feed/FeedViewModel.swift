import Foundation
import Combine
import SwiftUI
import SwiftData

// MARK: - Article View Data (Sendable)
struct ArticleViewData: Identifiable, Sendable, Equatable {
    let id: String
    let title: String
    let summary: String?
    let imageURL: URL?
    let source: String?
    let publishedAt: Date
    let url: URL
    let isFavorite: Bool
    
    @MainActor
    static func from(_ article: Article) -> ArticleViewData {
        ArticleViewData(
            id: article.id,
            title: article.title,
            summary: article.summary,
            imageURL: article.imageURL,
            source: article.source,
            publishedAt: article.publishedAt,
            url: article.url,
            isFavorite: article.isFavorite
        )
    }
    
    init(id: String, title: String, summary: String?, imageURL: URL?, source: String?, publishedAt: Date, url: URL, isFavorite: Bool) {
        self.id = id
        self.title = title
        self.summary = summary
        self.imageURL = imageURL
        self.source = source
        self.publishedAt = publishedAt
        self.url = url
        self.isFavorite = isFavorite
    }
}

@MainActor
final class FeedViewModel: ObservableObject {
    enum State {
        case idle
        case loading
        case loaded
        case error(String)
    }
    
    @Published private(set) var state: State = .idle
    @Published private(set) var items: [ArticleViewData] = []
    @Published var query: String = ""
    @Published var isRefreshing = false
    
    private var bag = Set<AnyCancellable>()
    private var repository: ArticleRepositoryProtocol?
    private var analytics: AnalyticsProtocol
    private var currentPage = 1
    private var hasMorePages = true
    
    init(analytics: AnalyticsProtocol? = nil) {
        self.analytics = analytics ?? Analytics.shared
        setupSearchBinding()
    }
    
    func configure(modelContext: ModelContext) {
        self.repository = ArticleRepository(
            httpClient: HTTPClient(apiKey: ConfigurationManager.shared.apiKey),
            modelContext: modelContext
        )
    }
    
    func loadFeed() async {
        guard let repository = repository else { return }
        guard case .idle = state else { return }
        
        state = .loading
        currentPage = 1
        hasMorePages = true
        
        do {
            let articles = try await repository.feed(page: currentPage)
            items = await MainActor.run { articles.map(ArticleViewData.from) }
            state = .loaded
            analytics.track(event: "feed_loaded", properties: [
                "page": currentPage,
                "article_count": articles.count
            ])
        } catch {
            state = .error(error.localizedDescription)
            analytics.track(event: "error_occurred", properties: [
                "error_type": String(describing: type(of: error)),
                "error_message": error.localizedDescription,
                "context": "feed_loading"
            ])
        }
    }
    
    func refreshFeed() async {
        guard let repository = repository else { return }
        
        isRefreshing = true
        currentPage = 1
        hasMorePages = true
        
        do {
            let articles = try await repository.feed(page: currentPage)
            items = await MainActor.run { articles.map(ArticleViewData.from) }
            state = .loaded
            analytics.track(event: "feed_loaded", properties: [
                "page": currentPage,
                "article_count": articles.count
            ])
        } catch {
            state = .error(error.localizedDescription)
            analytics.track(event: "error_occurred", properties: [
                "error_type": String(describing: type(of: error)),
                "error_message": error.localizedDescription,
                "context": "feed_refresh"
            ])
        }
        
        isRefreshing = false
    }
    
    func loadNextPage() async {
        guard let repository = repository,
              case .loaded = state,
              hasMorePages,
              !isRefreshing else { return }
        
        currentPage += 1
        
        do {
            let newArticles = try await repository.feed(page: currentPage)
            if newArticles.isEmpty {
                hasMorePages = false
            } else {
                let newItems = await MainActor.run { newArticles.map(ArticleViewData.from) }
                items.append(contentsOf: newItems)
                analytics.track(event: "feed_loaded", properties: [
                    "page": currentPage,
                    "article_count": newArticles.count
                ])
            }
        } catch {
            // Don't change state on pagination error, just log it
            analytics.track(event: "error_occurred", properties: [
                "error_type": String(describing: type(of: error)),
                "error_message": error.localizedDescription,
                "context": "feed_pagination"
            ])
        }
    }
    
    private func setupSearchBinding() {
        $query
            .removeDuplicates()
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .sink { [weak self] term in
                guard let self = self else { return }
                Task { await self.performSearch(term) }
            }
            .store(in: &bag)
    }
    
    private func performSearch(_ term: String) async {
        guard let repository = repository,
              !term.trimmingCharacters(in: .whitespaces).isEmpty else {
            // Reset to feed when search is cleared
            await loadFeed()
            return
        }
        
        state = .loading
        currentPage = 1
        hasMorePages = true
        
        do {
            let articles = try await repository.search(query: term, page: currentPage)
            items = await MainActor.run { articles.map(ArticleViewData.from) }
            state = .loaded
            analytics.track(event: "search_performed", properties: [
                "query": term,
                "result_count": articles.count
            ])
        } catch {
            state = .error(error.localizedDescription)
            analytics.track(event: "error_occurred", properties: [
                "error_type": String(describing: type(of: error)),
                "error_message": error.localizedDescription,
                "context": "search"
            ])
        }
    }
    
    func retry() async {
        if query.isEmpty {
            await loadFeed()
        } else {
            await performSearch(query)
        }
    }
    
    func toggleFavorite(for article: ArticleViewData) {
        guard let repository = repository else { return }
        
        do {
            try repository.setFavorite(article.id, isFavorite: !article.isFavorite)
            analytics.track(event: "favorite_toggled", properties: [
                "article_id": article.id,
                "is_favorite": !article.isFavorite
            ])
            
            // Update the state to reflect the change
            if let index = items.firstIndex(where: { $0.id == article.id }) {
                items[index] = ArticleViewData(
                    id: article.id,
                    title: article.title,
                    summary: article.summary,
                    imageURL: article.imageURL,
                    source: article.source,
                    publishedAt: article.publishedAt,
                    url: article.url,
                    isFavorite: !article.isFavorite
                )
            }
        } catch {
            analytics.track(event: "error_occurred", properties: [
                "error_type": String(describing: type(of: error)),
                "error_message": error.localizedDescription,
                "context": "toggle_favorite"
            ])
        }
    }
    
    deinit {
        bag.removeAll()
    }
}
