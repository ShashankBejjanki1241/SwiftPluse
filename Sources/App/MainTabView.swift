import SwiftUI
import SwiftData

struct MainTabView: View {
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        TabView {
            FeedView()
                .tabItem {
                    Image(systemName: "newspaper")
                    Text("Feed")
                }
            
            FavoritesView(repository: ArticleRepository(
                httpClient: HTTPClient(apiKey: ConfigurationManager.shared.apiKey),
                modelContext: modelContext
            ))
            .tabItem {
                Image(systemName: "heart")
                Text("Favorites")
            }
            
            SettingsView()
                .tabItem {
                    Image(systemName: "gear")
                    Text("Settings")
                }
        }
        .accentColor(.accentColor)
    }
}

#Preview {
    MainTabView()
        .modelContainer(for: Article.self, inMemory: true)
}
