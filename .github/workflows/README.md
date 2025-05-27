# CI/CD Setup for VTS_IOS

This document explains the Continuous Integration/Continuous Deployment (CI/CD) setup for the VTS_IOS project.

## Workflow Configuration

The CI/CD pipeline is configured in the file `.github/workflows/ios-tests.yml` and automatically runs on:
- Every push to the `main` branch
- Every pull request targeting the `main` branch

## What the Workflow Does

1. **Build and Test**:
   - Builds the application using Xcode
   - Runs all unit and integration tests
   - Generates code coverage reports

2. **Environment Setup**:
   - Uses the latest stable version of Xcode
   - Sets up Ruby for CocoaPods dependency management
   - Implements caching for CocoaPods and Xcode build artifacts

3. **Artifacts**:
   - Test results (xcresult)
   - Code coverage report (JSON format)
   - Build logs

## Requirements for Tests to Pass

For a PR to pass the CI/CD checks:
- All unit tests must pass
- All integration tests must pass
- The build must complete without errors

## Interpreting Test Results

After the workflow completes, you can:
- View the test results in the GitHub Actions tab
- Download the test artifacts for more detailed examination
- Check the code coverage report to see which parts of the codebase are covered by tests

## Troubleshooting

If the workflow fails, check the following:
- Build errors in the logs
- Failed tests in the test results
- Missing dependencies
- Xcode version compatibility issues

## Local Testing

Before pushing changes, you can run the same tests locally using:

```bash
xcodebuild test -project VTS_IOS.xcodeproj -scheme VTS_IOS -destination "platform=iOS Simulator,name=iPhone 14,OS=latest" -enableCodeCoverage YES
```

## Extending the Workflow

To extend the workflow:
1. Edit the `.github/workflows/ios-tests.yml` file
2. Add new steps or modify existing ones
3. Commit and push the changes to activate the updated workflow