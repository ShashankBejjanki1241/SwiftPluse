import SwiftUI
import SwiftData

struct FavoritesView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel: FavoritesViewModel
    @State private var showingClearConfirmation = false
    
    init(repository: ArticleRepositoryProtocol) {
        self._viewModel = StateObject(wrappedValue: FavoritesViewModel(repository: repository))
    }
    
    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading {
                    loadingView
                } else if viewModel.favorites.isEmpty {
                    emptyStateView
                } else {
                    favoritesList
                }
            }
            .navigationTitle("Favorites")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                if !viewModel.favorites.isEmpty {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Clear All") {
                            showingClearConfirmation = true
                        }
                        .foregroundColor(.error)
                    }
                }
            }
            .task {
                await viewModel.loadFavorites()
            }
            .refreshable {
                await viewModel.loadFavorites()
            }
            .alert("Clear All Favorites", isPresented: $showingClearConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Clear All", role: .destructive) {
                    viewModel.clearAllFavorites()
                }
            } message: {
                Text("Are you sure you want to remove all favorites? This action cannot be undone.")
            }
        }
    }
    
    private var loadingView: some View {
        VStack(spacing: .spacing16) {
            ProgressView()
                .scaleEffect(1.2)
            
            Text("Loading favorites...")
                .font(.body)
                .foregroundColor(.secondaryText)
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: .spacing24) {
            Image(systemName: "heart")
                .font(.system(size: 60))
                .foregroundColor(.secondaryText)
            
            Text("No Favorites Yet")
                .font(.title2)
                .foregroundColor(.primaryText)
            
            Text("Articles you favorite will appear here for easy access")
                .font(.body)
                .foregroundColor(.secondaryText)
                .multilineTextAlignment(.center)
        }
        .padding(.spacing32)
    }
    
    private var favoritesList: some View {
        List {
            ForEach(viewModel.favorites) { article in
                NavigationLink(destination: DetailView(article: article, repository: ArticleRepository(
                    httpClient: HTTPClient(apiKey: ConfigurationManager.shared.apiKey),
                    modelContext: modelContext
                ))) {
                    FavoriteArticleRow(article: article) {
                        viewModel.removeFavorite(article)
                    }
                }
            }
        }
        .listStyle(PlainListStyle())
    }
}

struct FavoriteArticleRow: View {
    let article: ArticleViewData
    let onRemove: () -> Void
    
    var body: some View {
        HStack(alignment: .top, spacing: .spacing12) {
            // Article image
            AsyncImage(url: article.imageURL) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                RoundedRectangle(cornerRadius: .cornerRadiusSmall)
                    .fill(Color.secondaryBackground)
                    .overlay(
                        Image(systemName: "photo")
                            .font(.title2)
                            .foregroundColor(.tertiaryText)
                    )
            }
            .frame(width: 80, height: 80)
            .clipShape(RoundedRectangle(cornerRadius: .cornerRadiusSmall))
            
            // Article content
            VStack(alignment: .leading, spacing: .spacing8) {
                // Title
                Text(article.title)
                    .font(.headline)
                    .foregroundColor(.primaryText)
                    .lineLimit(3)
                    .multilineTextAlignment(.leading)
                
                // Summary
                if let summary = article.summary, !summary.isEmpty {
                    Text(summary)
                        .font(.subheadline)
                        .foregroundColor(.secondaryText)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                }
                
                // Source and date
                HStack {
                    if let source = article.source {
                        Text(source)
                            .font(.caption)
                            .foregroundColor(.accent)
                            .padding(.horizontal, .spacing8)
                            .padding(.vertical, .spacing4)
                            .background(Color.accent.opacity(0.1))
                            .cornerRadius(.cornerRadiusSmall)
                    }
                    
                    Spacer()
                    
                    Text(article.publishedAt, style: .relative)
                        .font(.caption)
                        .foregroundColor(.tertiaryText)
                }
            }
            
            // Remove button
            Button(action: onRemove) {
                Image(systemName: "heart.slash")
                    .foregroundColor(.error)
                    .font(.title3)
            }
            .buttonStyle(PlainButtonStyle())
            .accessibilityLabel("Remove from favorites")
        }
        .padding(.vertical, .spacing8)
        .contentShape(Rectangle())
    }
}

#Preview {
    FavoritesView(repository: ArticleRepository(
        httpClient: HTTPClient(apiKey: "test"),
        modelContext: try! ModelContainer(for: Article.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true)).mainContext
    ))
}
