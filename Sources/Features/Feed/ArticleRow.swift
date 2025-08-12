import SwiftUI

struct ArticleRow: View {
    let article: ArticleViewData
    let onFavoriteToggle: () -> Void
    
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
            
            // Favorite button
            Button(action: onFavoriteToggle) {
                Image(systemName: article.isFavorite ? "heart.fill" : "heart")
                    .foregroundColor(article.isFavorite ? .red : .secondaryText)
                    .font(.title3)
            }
            .buttonStyle(PlainButtonStyle())
            .accessibilityLabel(article.isFavorite ? "Remove from favorites" : "Add to favorites")
        }
        .padding(.vertical, .spacing8)
        .contentShape(Rectangle())
    }
}

#Preview {
    ArticleRow(
        article: ArticleViewData(
            id: "1",
            title: "Sample Article Title",
            summary: "This is a sample article summary that demonstrates how the article row looks with content.",
            imageURL: nil,
            source: "Tech News",
            publishedAt: Date(),
            url: URL(string: "https://example.com")!,
            isFavorite: false
        )
    ) {
        print("Favorite toggled")
    }
    .padding()
}
