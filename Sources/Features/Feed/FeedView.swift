import SwiftUI
import SwiftData

struct FeedView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel = FeedViewModel()
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Search bar
                searchBar
                
                // Content
                Group {
                    switch viewModel.state {
                    case .idle:
                        idleView
                    case .loading:
                        loadingView
                    case .loaded:
                        articleList(viewModel.items)
                    case .error(let message):
                        errorView(message)
                    }
                }
            }
            .navigationTitle("SwiftPulse")
            .navigationBarTitleDisplayMode(.large)
            .task {
                viewModel.configure(modelContext: modelContext)
                await viewModel.loadFeed()
            }
        }
    }
    
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondaryText)
            
            TextField("Search articles...", text: $viewModel.query)
                .textFieldStyle(PlainTextFieldStyle())
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
            
            if !viewModel.query.isEmpty {
                Button("Clear") {
                    viewModel.query = ""
                }
                .foregroundColor(.accent)
            }
        }
        .padding(.horizontal, .spacing16)
        .padding(.vertical, .spacing12)
        .background(Color.secondaryBackground)
        .cornerRadius(.cornerRadiusMedium)
        .padding(.horizontal, .spacing16)
        .padding(.vertical, .spacing8)
    }
    
    private var idleView: some View {
        VStack(spacing: .spacing24) {
            Image(systemName: "newspaper")
                .font(.system(size: 60))
                .foregroundColor(.secondaryText)
            
            Text("Welcome to SwiftPulse")
                .font(.title2)
                .foregroundColor(.primaryText)
            
            Text("Your personalized news feed will appear here")
                .font(.body)
                .foregroundColor(.secondaryText)
                .multilineTextAlignment(.center)
        }
        .padding(.spacing32)
    }
    
    private var loadingView: some View {
        VStack(spacing: .spacing16) {
            ProgressView()
                .scaleEffect(1.2)
            
            Text("Loading articles...")
                .font(.body)
                .foregroundColor(.secondaryText)
        }
    }
    
    private func articleList(_ articles: [ArticleViewData]) -> some View {
        List {
            ForEach(articles) { article in
                ArticleRow(article: article) {
                    viewModel.toggleFavorite(for: article)
                }
                .onAppear {
                    // Load next page when approaching the end
                    if articles.lastIndex(of: article) == articles.count - 3 {
                        Task {
                            await viewModel.loadNextPage()
                        }
                    }
                }
            }
        }
        .listStyle(PlainListStyle())
        .refreshable {
            await viewModel.refreshFeed()
        }
    }
    
    private func errorView(_ message: String) -> some View {
        VStack(spacing: .spacing24) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 60))
                .foregroundColor(.error)
            
            Text("Something went wrong")
                .font(.title2)
                .foregroundColor(.primaryText)
            
            Text(message)
                .font(.body)
                .foregroundColor(.secondaryText)
                .multilineTextAlignment(.center)
            
            Button("Try Again") {
                Task {
                    await viewModel.retry()
                }
            }
            .standardButtonStyle()
        }
        .padding(.spacing32)
    }
}

#Preview {
    FeedView()
        .modelContainer(for: Article.self, inMemory: true)
}
