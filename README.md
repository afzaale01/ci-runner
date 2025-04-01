# 🚀 Unity CI/CD Pipeline

**Robust GitHub Actions workflows to automate tests, builds, and continuous integration for your Unity projects.**

![Unity CI/CD](https://github.com/Avalin/CI-CD-Unity-Test-Project/actions/workflows/ci-cd-full.yml/badge.svg)

---

## 📌 Features:

- ✅ **Automatic Unity Test Detection**:  
  Automatically detects and runs EditMode and PlayMode tests.

- ✅ **Full Multi-Platform Unity Builds**:  
  Supports builds for:
  - Android (`.apk`)
  - WebGL
  - Standalone Linux (x64)
  - Standalone Windows (x86 & x64)
  - Standalone macOS
  - iOS

- ✅ **Dynamic Versioning**:  
  Automatically tags builds with semantic versions (from Git tags) or timestamp + commit hashes for previews.

- ✅ **Parallelized Builds**:  
  Efficiently parallelizes builds across Ubuntu and macOS for optimized CI performance.

- ✅ **Conditional & Flexible Triggers**:  
  Runs tests/builds on:
  - Commits to `main` or release tags (`v*.*.*`)
  - Pull Requests modifying project files
  - Manual workflow dispatches (`workflow_dispatch`) with custom inputs

- ✅ **Reusable & Modular Workflows**:  
  Designed with reusable workflow calls (`workflow_call`) for maintainability and simplicity.

- ✅ **Git LFS & Cache Optimizations**:  
  Includes optional caching for Unity's `Library` folder and Git LFS support.

---

## 📂 Repository Structure:

### Main Workflows
| Workflow                                  | Description                                     |
|-------------------------------------------|-------------------------------------------------|
| [`ci-cd-full.yml`](./.github/workflows/ci-cd-full.yml) | Complete CI/CD pipeline: detects tests, builds project for all platforms, uploads artifacts |
| [`ci-cd-stripped.yml`](./.github/workflows/ci-cd-stripped.yml) *(Experimental)* | Builds project without running tests (useful for quick platform checks or debugging purposes) |

### Reusable Modular Workflows
| Workflow | Description |
|----------|-------------|
| [`step-1-test.yml`](./.github/workflows/step-1-test.yml) | Runs EditMode and PlayMode tests |
| [`step-2-build.yml`](./.github/workflows/step-2-build.yml) | Builds project artifacts across all target platforms |
| [`unity-tests-detection.yml`](./.github/workflows/unity-tests-detection.yml) | Automatically detects presence of EditMode and PlayMode tests |
| [`unity-tests-runner.yml`](./.github/workflows/unity-tests-runner.yml) | Runs Unity tests in specified mode (EditMode/PlayMode) |
| [`unity-license-uploader.yml`](./.github/workflows/unity-license-uploader.yml) | Uploads and activates Unity license artifact |

---

## ⚙️ Initial Setup Instructions:

### 1. ✅ Enable GitHub Token Permissions:

To ensure workflows function properly, give workflows read/write permissions:

- **Navigate to**:  
  `Settings → Actions → General → Workflow permissions`

- **Select**:  
  ✅ **Read and write permissions**

---

### 2. 🔐 Add Repository Secrets:

Add the following repository secrets to secure your Unity license activation:

- **Navigate to**:  
  `Settings → Secrets and variables → Actions → New repository secret`

| Secret Name      | Description                                                |
|------------------|------------------------------------------------------------|
| `UNITY_EMAIL`    | Email address for your Unity account                       |
| `UNITY_PASSWORD` | Password for your Unity account                            |
| `UNITY_LICENSE`  | Content of your `.ulf` Unity license file (e.g., at `C:/ProgramData/Unity` on Windows) |

---

## 🚦 Triggering CI/CD Workflows:

### Automatic Triggers:
- ✅ Pushes to `main` branch
- ✅ Tag pushes (`v*.*.*`)
- ✅ Pull Requests modifying `Assets/`, `Packages/`, `ProjectSettings/`, or `Tests/`

### Manual Trigger:
- ✅ Workflow Dispatch with selectable build type (`preview`/`release`) and target platforms.

---

## 🔍 Workflow Input Details:

- **`buildType`** *(preview | release)*: Determines build versioning.
- **`targetPlatforms`** *(JSON array)*: Specify target platforms.

Example manual dispatch inputs:

```json
buildType: "preview"
targetPlatforms: '["Android","iOS","WebGL"]'
```

---

## 🧩 Artifacts:

Artifacts generated and uploaded by builds are named clearly:

```
{buildType}-{ProjectName}-{TargetPlatform}-{Version}
```

Example:

```
preview-My_Project-Android-T20250401123000_CHabc1234
release-My_Project-StandaloneWindows64-v1.0.0
```

---

## 📑 Roadmap to v1.0:

- [ ] Automatic deployment to GitHub Releases
- [ ] Slack/Discord notifications for CI status
- [ ] Changelog automation with release notes
