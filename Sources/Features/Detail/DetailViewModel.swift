import Foundation
import SwiftUI
import SwiftData

@MainActor
final class DetailViewModel: ObservableObject {
    @Published var article: ArticleViewData
    @Published var isLoading = false
    
    private let repository: ArticleRepositoryProtocol
    private let analytics: AnalyticsProtocol
    
    init(article: ArticleViewData, repository: ArticleRepositoryProtocol, analytics: AnalyticsProtocol? = nil) {
        self.article = article
        self.repository = repository
        self.analytics = analytics ?? Analytics.shared
        
        // Track article view
        self.analytics.track(event: "article_opened", properties: [
            "article_id": article.id,
            "title": article.title
        ])
    }
    
    func toggleFavorite() {
        do {
            try repository.setFavorite(article.id, isFavorite: !article.isFavorite)
            article = ArticleViewData(
                id: article.id,
                title: article.title,
                summary: article.summary,
                imageURL: article.imageURL,
                source: article.source,
                publishedAt: article.publishedAt,
                url: article.url,
                isFavorite: !article.isFavorite
            )
            analytics.track(event: "favorite_toggled", properties: [
                "article_id": article.id,
                "is_favorite": article.isFavorite
            ])
        } catch {
            analytics.track(event: "error_occurred", properties: [
                "error_type": String(describing: type(of: error)),
                "error_message": error.localizedDescription,
                "context": "detail_favorite_toggle"
            ])
        }
    }
    
    func openInSafari() {
        guard let url = URL(string: article.url.absoluteString) else { return }
        UIApplication.shared.open(url)
    }
    
    func share() {
        // This would typically be handled by the view
        // The view can use UIActivityViewController
    }
}
