# 🤝 Contributing to SwiftPulse

Thank you for your interest in contributing to SwiftPulse! This document provides guidelines and information for contributors.

## 🎯 How Can I Contribute?

### **Reporting Bugs**
- Use the GitHub issue tracker
- Include detailed reproduction steps
- Provide device and iOS version information
- Include crash logs if applicable

### **Suggesting Enhancements**
- Describe the feature in detail
- Explain why it would be useful
- Consider the impact on existing functionality
- Provide mockups or examples if possible

### **Code Contributions**
- Fork the repository
- Create a feature branch
- Make your changes
- Add tests for new functionality
- Ensure all tests pass
- Submit a pull request

## 🏗️ Development Setup

### **Prerequisites**
- Xcode 15.0+
- iOS 17.0+ Simulator
- Swift 5.9+
- NewsAPI account

### **Local Development**
1. Fork and clone the repository
2. Install dependencies
3. Configure your API key
4. Build and run the project
5. Run tests to ensure everything works

## 📝 Code Style Guidelines

### **Swift Style**
- Follow [Swift API Design Guidelines](https://www.swift.org/documentation/api-design-guidelines/)
- Use 4-space indentation
- Prefer `let` over `var` when possible
- Use meaningful variable and function names

### **SwiftUI Best Practices**
- Keep views small and focused
- Use `@StateObject` for owned objects
- Prefer `@ObservedObject` for injected dependencies
- Use `@Environment` for system values

### **Architecture Principles**
- Follow MVVM pattern
- Use protocols for dependency injection
- Keep business logic in ViewModels
- Use repositories for data access

## 🧪 Testing Requirements

### **Test Coverage**
- Aim for ≥85% code coverage
- Test all ViewModel business logic
- Test repository data operations
- Test error handling scenarios

### **Test Naming**
```swift
// Good
func test_whenUserTapsFavorite_thenArticleIsMarkedAsFavorite()

// Avoid
func test1()
```

### **Running Tests**
```bash
# Run all tests
xcodebuild test -scheme SwiftPulse

# Run specific test target
xcodebuild test -scheme SwiftPulse -only-testing:SwiftPulseTests
```

## 🔄 Pull Request Process

### **Before Submitting**
1. Ensure all tests pass
2. Update documentation if needed
3. Add screenshots for UI changes
4. Test on multiple device sizes

### **Pull Request Template**
```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## Testing
- [ ] Unit tests pass
- [ ] UI tests pass
- [ ] Tested on multiple devices

## Screenshots
Add screenshots for UI changes

## Checklist
- [ ] Code follows style guidelines
- [ ] Self-review completed
- [ ] Documentation updated
- [ ] Tests added/updated
```

## 🚀 Release Process

### **Versioning**
We use [Semantic Versioning](https://semver.org/):
- **MAJOR**: Breaking changes
- **MINOR**: New features, backward compatible
- **PATCH**: Bug fixes, backward compatible

### **Release Checklist**
- [ ] All tests pass
- [ ] Documentation updated
- [ ] Changelog updated
- [ ] Version bumped
- [ ] Tagged release

## 📚 Documentation

### **Code Documentation**
- Document public APIs
- Use Swift documentation comments
- Include usage examples
- Document complex algorithms

### **README Updates**
- Update setup instructions
- Add new features to feature list
- Update screenshots if UI changes
- Keep configuration examples current

## 🐛 Issue Templates

### **Bug Report**
```markdown
## Bug Description
Clear description of the bug

## Steps to Reproduce
1. Step 1
2. Step 2
3. Step 3

## Expected Behavior
What should happen

## Actual Behavior
What actually happens

## Environment**
- iOS Version:
- Device:
- App Version:
- Xcode Version:

## Additional Information
Any other context, logs, or screenshots
```

### **Feature Request**
```markdown
## Feature Description
Clear description of the feature

## Use Case
Why this feature would be useful

## Proposed Implementation
How you think it should work

## Alternatives Considered
Other approaches you've thought about

## Additional Context
Any other information
```

## 🤝 Community Guidelines

### **Be Respectful**
- Treat all contributors with respect
- Welcome newcomers and help them learn
- Provide constructive feedback
- Be patient with questions

### **Communication**
- Use clear, concise language
- Ask questions when unsure
- Provide context for your suggestions
- Be open to different approaches

## 📞 Getting Help

### **Resources**
- [Swift Documentation](https://swift.org/documentation/)
- [SwiftUI Tutorials](https://developer.apple.com/tutorials/swiftui)
- [iOS Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/)

### **Contact**
- **Maintainer**: Shashank B (ShashankBejjanki1241)
- **Email**: shashank.bejj1241@gmail.com
- **GitHub Issues** for bugs and features
- **GitHub Discussions** for questions
- **Pull Request reviews** for code feedback

## 🙏 Recognition

Contributors will be recognized in:
- Project README
- Release notes
- Contributor statistics
- Special acknowledgments for significant contributions

---

Thank you for contributing to SwiftPulse! Your contributions help make this project better for everyone. 🗞️💓
