# Contributing to ContentCapture Pro

Thank you for your interest in contributing to ContentCapture Pro! This document provides guidelines for contributing.

---

## Ways to Contribute

### Report Bugs

Found a bug? Please create an issue on GitHub with:
- Clear description of the problem
- Steps to reproduce
- Expected behavior vs actual behavior
- Your Windows version and AutoHotkey version
- Screenshots if applicable

### Suggest Features

Have an idea? Create an issue with:
- Clear description of the feature
- Why it would be useful
- How you envision it working

### Submit Code

Want to fix a bug or add a feature? Great!

1. Fork the repository
2. Create a branch for your changes
3. Make your changes
4. Test thoroughly
5. Submit a pull request

---

## Code Guidelines

### AutoHotkey Style

- Use AutoHotkey v2 syntax
- Use meaningful variable names
- Add comments for complex logic
- Follow existing code patterns

### Naming Conventions

- Functions: `PascalCase` (e.g., `CC_CaptureContent`)
- Variables: `camelCase` (e.g., `captureData`)
- Constants: `UPPER_SNAKE_CASE` (e.g., `MAX_CAPTURES`)
- Prefix internal functions with `CC_`

### File Structure

- Keep related functions together
- Use `#Include` for modular code
- Don't modify core files unless necessary

---

## Testing

Before submitting:

1. Test on a clean Windows installation if possible
2. Test with both new and existing captures
3. Verify hotstrings work correctly
4. Check that suffixes function properly
5. Test email and social features if changed

---

## Documentation

If you add features:
- Update relevant documentation files
- Add comments in code
- Update CHANGELOG.md
- Update README.md if needed

---

## Pull Request Process

1. **Fork** the repository
2. **Create a branch** with a descriptive name
3. **Make changes** following code guidelines
4. **Test** your changes thoroughly
5. **Commit** with clear, descriptive messages
6. **Push** to your fork
7. **Create Pull Request** with:
   - Clear title
   - Description of changes
   - Any related issues

### Commit Messages

Good: `Fix clipboard timing issue in paste function`
Bad: `Fixed stuff`

Good: `Add LinkedIn sharing support with li suffix`
Bad: `New feature`

---

## Code of Conduct

- Be respectful and inclusive
- Focus on constructive feedback
- Help newcomers
- Keep discussions on-topic

---

## Questions?

- Create an issue on GitHub
- Visit AutoHotkey forums
- Check existing documentation

---

Thank you for contributing! 🎉
