# Publishing to pub.dev

This guide will help you publish the `i_google_drive` package to pub.dev.

## Pre-Publishing Checklist

### 1. Update Repository URLs

Before publishing, update the following in `pubspec.yaml`:

```yaml
homepage: https://github.com/YOUR_USERNAME/i_google_drive
repository: https://github.com/YOUR_USERNAME/i_google_drive
issue_tracker: https://github.com/YOUR_USERNAME/i_google_drive/issues
```

Replace `YOUR_USERNAME` with your actual GitHub username.

### 2. Verify Package Structure

Ensure your package has:
- ✅ `pubspec.yaml` with correct metadata
- ✅ `README.md` with comprehensive documentation
- ✅ `CHANGELOG.md` with version history
- ✅ `LICENSE` file (MIT recommended)
- ✅ `example/` directory with working example app
- ✅ `lib/` directory with source code
- ✅ `analysis_options.yaml` for linting

### 3. Test the Package

```bash
# Run tests
flutter test
c
# Analyze the code
flutter analyze

# Check for issues
flutter pub publish --dry-run
```

### 4. Update Version

Update the version in `pubspec.yaml` following semantic versioning:
- `1.0.0` - Initial release
- `1.0.1` - Bug fixes
- `1.1.0` - New features (backward compatible)
- `2.0.0` - Breaking changes

### 5. Update CHANGELOG

Add your changes to `CHANGELOG.md` before publishing.

## Publishing Steps

### 1. Create pub.dev Account

1. Go to https://pub.dev/
2. Sign in with your Google account
3. Complete your profile

### 2. Verify Package

```bash
cd packages/i_google_drive
flutter pub publish --dry-run
```

Fix any issues that appear.

### 3. Publish

```bash
flutter pub publish
```

You'll be prompted to:
- Confirm the package details
- Enter your Google account credentials
- Confirm publication

### 4. Verify Publication

After publishing, check:
- Package appears on pub.dev
- README displays correctly
- Example is accessible
- All links work

## Post-Publishing

### 1. Create GitHub Repository

Create a GitHub repository and push your code:

```bash
git init
git add .
git commit -m "Initial release v1.0.0"
git remote add origin https://github.com/YOUR_USERNAME/i_google_drive.git
git push -u origin main
```

### 2. Update pubspec.yaml

After creating the repository, update the URLs in `pubspec.yaml` and republish if needed.

### 3. Add Badges

Add badges to your README.md:

```markdown
[![pub package](https://img.shields.io/pub/v/i_google_drive.svg)](https://pub.dev/packages/i_google_drive)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
```

### 4. Monitor

- Watch for issues on pub.dev
- Respond to user feedback
- Update package as needed

## Updating the Package

When updating:

1. Update version in `pubspec.yaml`
2. Update `CHANGELOG.md`
3. Test thoroughly
4. Run `flutter pub publish --dry-run`
5. Publish with `flutter pub publish`

## Important Notes

- ⚠️ Once published, you cannot delete a package version
- ⚠️ You cannot republish the same version
- ✅ You can publish new versions anytime
- ✅ Update README and documentation as needed

## Resources

- [pub.dev Publishing Guide](https://dart.dev/tools/pub/publishing)
- [Semantic Versioning](https://semver.org/)
- [pub.dev Package Guidelines](https://dart.dev/tools/pub/package-layout)

