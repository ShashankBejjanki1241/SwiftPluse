# SwiftPulse App Testing Checklist

## 🧪 Testing Instructions

### 1. Basic App Launch
- [ ] App opens without crashing
- [ ] Tab navigation works (Feed, Favorites, Settings)
- [ ] Mock data banner appears (indicating test mode)

### 2. Feed Tab Testing
- [ ] Mock articles display correctly
- [ ] Article images show placeholder icons
- [ ] Article titles and summaries are readable
- [ ] Source tags display correctly
- [ ] Timestamps show relative time
- [ ] Favorite buttons work (toggle heart icons)
- [ ] Search bar is visible and functional
- [ ] Search with "iPhone" returns results
- [ ] Search with "Swift" returns results
- [ ] Pull-to-refresh works

### 3. Detail View Testing
- [ ] Tap on any article opens detail view
- [ ] Detail view shows full article content
- [ ] Header image placeholder displays
- [ ] Title and summary are properly formatted
- [ ] Source and date information is visible
- [ ] Favorite toggle button works
- [ ] "Open in Safari" button is present
- [ ] Share button works (opens share sheet)

### 4. Favorites Tab Testing
- [ ] Initially shows "No Favorites Yet" message
- [ ] After favoriting articles, they appear in list
- [ ] Remove favorite button works
- [ ] Clear all favorites button works
- [ ] Favorites persist between app launches

### 5. Settings Tab Testing
- [ ] Dark mode toggle works
- [ ] Push notifications toggle works
- [ ] Analytics toggle works
- [ ] Cache size shows current value
- [ ] Clear cache button works
- [ ] Clear all data button works
- [ ] Version information displays
- [ ] Privacy policy and terms links work

### 6. Search Functionality
- [ ] Type "iPhone" in search - should show iPhone-related articles
- [ ] Type "Swift" in search - should show Swift-related articles
- [ ] Type "iOS" in search - should show iOS-related articles
- [ ] Clear search returns to main feed
- [ ] Search results update in real-time

### 7. Offline Features
- [ ] App works without internet connection
- [ ] Mock data displays offline
- [ ] Favorites work offline
- [ ] Settings work offline

### 8. UI/UX Testing
- [ ] Text is readable in both light and dark modes
- [ ] Buttons have proper touch targets
- [ ] Navigation is intuitive
- [ ] Loading states display correctly
- [ ] Error states handle gracefully

## 🐛 Known Issues to Check

- [ ] No crashes when tapping rapidly
- [ ] No memory leaks (check Xcode debugger)
- [ ] Smooth scrolling performance
- [ ] Proper accessibility labels

## ✅ Success Criteria

The app is working correctly if:
- All tabs load without errors
- Mock data displays properly
- Search functionality works
- Favorites system works
- Settings are functional
- No crashes occur
- UI is responsive and smooth

## 🔧 Next Steps After Testing

1. **Add Real API Key**: Get API key from NewsAPI.org
2. **Test Real Data**: Verify live news feed works
3. **Performance Testing**: Check memory usage and performance
4. **Device Testing**: Test on different iOS versions
5. **Accessibility Testing**: Verify VoiceOver support
