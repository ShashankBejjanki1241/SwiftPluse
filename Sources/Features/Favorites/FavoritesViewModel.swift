import Foundation
import SwiftUI
import SwiftData

@MainActor
final class FavoritesViewModel: ObservableObject {
    @Published private(set) var favorites: [ArticleViewData] = []
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?
    
    private let repository: ArticleRepositoryProtocol
    private let analytics: AnalyticsProtocol
    
    init(repository: ArticleRepositoryProtocol, analytics: AnalyticsProtocol? = nil) {
        self.repository = repository
        self.analytics = analytics ?? Analytics.shared
    }
    
    func loadFavorites() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let articles = try repository.getFavorites()
            favorites = await MainActor.run { articles.map(ArticleViewData.from) }
            analytics.track(event: "favorites_loaded", properties: ["count": favorites.count])
        } catch {
            errorMessage = "Failed to load favorites: \(error.localizedDescription)"
            analytics.track(event: "error_occurred", properties: [
                "error_type": String(describing: type(of: error)),
                "error_message": error.localizedDescription,
                "context": "load_favorites"
            ])
        }
        
        isLoading = false
    }
    
    func removeFavorite(_ article: ArticleViewData) {
        do {
            try repository.setFavorite(article.id, isFavorite: false)
            favorites.removeAll { $0.id == article.id }
            analytics.track(event: "favorite_toggled", properties: [
                "article_id": article.id,
                "is_favorite": false
            ])
        } catch {
            errorMessage = "Failed to remove favorite: \(error.localizedDescription)"
            analytics.track(event: "error_occurred", properties: [
                "error_type": String(describing: type(of: error)),
                "error_message": error.localizedDescription,
                "context": "remove_favorite"
            ])
        }
    }
    
    func clearAllFavorites() {
        do {
            for article in favorites {
                try repository.setFavorite(article.id, isFavorite: false)
            }
            favorites.removeAll()
            analytics.track(event: "all_favorites_cleared", properties: nil)
        } catch {
            errorMessage = "Failed to clear favorites: \(error.localizedDescription)"
            analytics.track(event: "error_occurred", properties: [
                "error_type": String(describing: type(of: error)),
                "error_message": error.localizedDescription,
                "context": "clear_all_favorites"
            ])
        }
    }
}
