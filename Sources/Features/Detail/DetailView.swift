import SwiftUI
import UIKit
import SwiftData

struct DetailView: View {
    let article: ArticleViewData
    @StateObject private var viewModel: DetailViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showingShareSheet = false
    
    init(article: ArticleViewData, repository: ArticleRepositoryProtocol) {
        self.article = article
        self._viewModel = StateObject(wrappedValue: DetailViewModel(
            article: article,
            repository: repository
        ))
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: .spacing20) {
                // Header image
                headerImage
                
                VStack(alignment: .leading, spacing: .spacing16) {
                    // Title
                    Text(article.title)
                        .font(.largeTitle)
                        .foregroundColor(.primaryText)
                        .multilineTextAlignment(.leading)
                    
                    // Source and date
                    HStack {
                        if let source = article.source {
                            Text(source)
                                .font(.subheadline)
                                .foregroundColor(.accent)
                                .padding(.horizontal, .spacing12)
                                .padding(.vertical, .spacing8)
                                .background(Color.accent.opacity(0.1))
                                .cornerRadius(.cornerRadiusMedium)
                        }
                        
                        Spacer()
                        
                        Text(article.publishedAt, style: .date)
                            .font(.subheadline)
                            .foregroundColor(.secondaryText)
                    }
                    
                    // Summary
                    if let summary = article.summary, !summary.isEmpty {
                        Text(summary)
                            .font(.body)
                            .foregroundColor(.primaryText)
                            .multilineTextAlignment(.leading)
                    }
                    
                    // Action buttons
                    actionButtons
                    
                    // Full article link
                    Button(action: viewModel.openInSafari) {
                        HStack {
                            Image(systemName: "safari")
                            Text("Read Full Article")
                        }
                        .frame(maxWidth: .infinity)
                        .standardButtonStyle()
                    }
                }
                .padding(.horizontal, .spacing20)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showingShareSheet = true }) {
                    Image(systemName: "square.and.arrow.up")
                }
            }
        }
        .sheet(isPresented: $showingShareSheet) {
            ShareSheet(activityItems: [article.title, article.url])
        }
    }
    
    private var headerImage: some View {
        AsyncImage(url: article.imageURL) { image in
            image
                .resizable()
                .aspectRatio(contentMode: .fill)
        } placeholder: {
            Rectangle()
                .fill(Color.secondaryBackground)
                .overlay(
                    Image(systemName: "photo")
                        .font(.system(size: 60))
                        .foregroundColor(.tertiaryText)
                )
        }
        .frame(height: 200)
        .clipped()
    }
    
    private var actionButtons: some View {
        HStack(spacing: .spacing16) {
            // Favorite button
            Button(action: viewModel.toggleFavorite) {
                HStack {
                    Image(systemName: article.isFavorite ? "heart.fill" : "heart")
                    Text(article.isFavorite ? "Favorited" : "Favorite")
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, .spacing12)
                .background(article.isFavorite ? Color.red.opacity(0.1) : Color.accent.opacity(0.1))
                .foregroundColor(article.isFavorite ? .red : .accent)
                .cornerRadius(.cornerRadiusMedium)
            }
            
            // Share button
            Button(action: { showingShareSheet = true }) {
                HStack {
                    Image(systemName: "square.and.arrow.up")
                    Text("Share")
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, .spacing12)
                .background(Color.accent.opacity(0.1))
                .foregroundColor(.accent)
                .cornerRadius(.cornerRadiusMedium)
            }
        }
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    NavigationStack {
        DetailView(
            article: ArticleViewData(
                id: "1",
                title: "Sample Article Title",
                summary: "This is a sample article summary that demonstrates how the detail view looks with content.",
                imageURL: nil,
                source: "Tech News",
                publishedAt: Date(),
                url: URL(string: "https://example.com")!,
                isFavorite: false
            ),
            repository: ArticleRepository(
                httpClient: HTTPClient(apiKey: "test"),
                modelContext: try! ModelContainer(for: Article.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true)).mainContext
            )
        )
    }
}
