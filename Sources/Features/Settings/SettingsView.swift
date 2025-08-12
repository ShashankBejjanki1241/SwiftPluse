import SwiftUI

struct SettingsView: View {
    @AppStorage("isDarkMode") private var isDarkMode = false
    @AppStorage("enableNotifications") private var enableNotifications = true
    @AppStorage("enableAnalytics") private var enableAnalytics = true
    @AppStorage("cacheSize") private var cacheSize = 100
    
    @State private var showingClearCacheAlert = false
    @State private var showingResetAlert = false
    
    var body: some View {
        NavigationStack {
            List {
                // Appearance Section
                Section("Appearance") {
                    HStack {
                        Image(systemName: "paintbrush")
                            .foregroundColor(.accent)
                            .frame(width: 24)
                        
                        Toggle("Dark Mode", isOn: $isDarkMode)
                    }
                }
                
                // Content Section
                Section("Content") {
                    HStack {
                        Image(systemName: "bell")
                            .foregroundColor(.accent)
                            .frame(width: 24)
                        
                        Toggle("Push Notifications", isOn: $enableNotifications)
                    }
                    
                    HStack {
                        Image(systemName: "chart.bar")
                            .foregroundColor(.accent)
                            .frame(width: 24)
                        
                        Toggle("Analytics", isOn: $enableAnalytics)
                    }
                    
                    HStack {
                        Image(systemName: "externaldrive")
                            .foregroundColor(.accent)
                            .frame(width: 24)
                        
                        VStack(alignment: .leading) {
                            Text("Cache Size")
                            Text("\(cacheSize) MB")
                                .font(.caption)
                                .foregroundColor(.secondaryText)
                        }
                        
                        Spacer()
                        
                        Button("Clear") {
                            showingClearCacheAlert = true
                        }
                        .foregroundColor(.error)
                    }
                }
                
                // Data Section
                Section("Data") {
                    HStack {
                        Image(systemName: "trash")
                            .foregroundColor(.error)
                            .frame(width: 24)
                        
                        Button("Clear All Data") {
                            showingResetAlert = true
                        }
                        .foregroundColor(.error)
                    }
                }
                
                // About Section
                Section("About") {
                    HStack {
                        Image(systemName: "info.circle")
                            .foregroundColor(.accent)
                            .frame(width: 24)
                        
                        VStack(alignment: .leading) {
                            Text("Version")
                            Text("1.0.0")
                                .font(.caption)
                                .foregroundColor(.secondaryText)
                        }
                    }
                    
                    HStack {
                        Image(systemName: "globe")
                            .foregroundColor(.accent)
                            .frame(width: 24)
                        
                        Link("Privacy Policy", destination: URL(string: "https://example.com/privacy")!)
                    }
                    
                    HStack {
                        Image(systemName: "doc.text")
                            .foregroundColor(.accent)
                            .frame(width: 24)
                        
                        Link("Terms of Service", destination: URL(string: "https://example.com/terms")!)
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
        }
        .alert("Clear Cache", isPresented: $showingClearCacheAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Clear", role: .destructive) {
                clearCache()
            }
        } message: {
            Text("This will clear all cached articles. Favorites will be preserved.")
        }
        .alert("Reset All Data", isPresented: $showingResetAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Reset", role: .destructive) {
                resetAllData()
            }
        } message: {
            Text("This will clear all data including favorites. This action cannot be undone.")
        }
    }
    
    private func clearCache() {
        // Clear cache logic would go here
        // For now, just show a success message
        print("Cache cleared")
    }
    
    private func resetAllData() {
        // Reset all data logic would go here
        // For now, just show a success message
        print("All data reset")
    }
}

#Preview {
    SettingsView()
}
