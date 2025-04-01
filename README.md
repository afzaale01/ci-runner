# 🚀 Unity CI/CD Pipeline

**Robust GitHub Actions workflows to automate tests, builds, and continuous integration for your Unity projects.**

![Unity CI/CD](https://github.com/Avalin/CI-CD-Unity-Test-Project/actions/workflows/ci-cd-full.yml/badge.svg)

---

## 📌 Features:

🧪 Automatic Test Detection & Execution
Detects and runs EditMode and PlayMode tests with no manual setup.

🛠️ Cross-Platform Builds
Supports Android, iOS, WebGL, macOS, Windows (x86 & x64), and Linux.

🧩 Modular & Reusable Workflows
Clean separation of test/build logic using workflow_call.

🚀 Dynamic Versioning & Tag-based Releases
Builds are versioned using Git tags (for releases) or timestamps (for previews).

⚡ Efficient & Parallel Execution
Matrix builds across macOS and Ubuntu, optimized for CI speed.

🗃️ CI Optimizations
Unity Library/ caching and Git LFS support built-in.

| Feature                      | Status   | Description |
|-----------------------------|----------|-------------|
| 🧭 CI Workflow Dispatch      | ✅ Done   | Manual dispatch with custom `buildType` and `targetPlatforms`. |
| 🧪 Test Detection            | ✅ Done   | Automatically detects and runs EditMode and PlayMode tests. |
| 🛠️ Multi-Platform Build      | ✅ Done   | Supports Android, iOS, WebGL, Linux, macOS, and Windows. |
| 🏷️ Versioning                | ✅ Done   | Git tag or timestamp + commit hash for builds. |
| 🔐 Unity License Activation  | ✅ Done   | Activates Unity license securely in CI. |
| 🧮 GitHub Actions Matrix     | ✅ Done   | Parallel build strategy by OS. |
| 🧩 Workflow Reusability      | ✅ Done   | Modular steps with `workflow_call`. |
| 🗃️ Git LFS & Caching         | ✅ Done   | Git LFS support and Library folder caching. |
| 🧪 Test Summary Comments     | 📝 To do  | Add PR comments with test pass/fail summary using `actions/github-script`. |
| 📦 GitHub Release Deployment | 📝 To do  | Auto-create GitHub Releases & attach artifacts on version tag push. |
| 📣 Notifications             | 📝 To do  | Optional Slack/Discord notifications for CI events. |
| 🧼 Code Formatting           | 📝 To do  | Run `dotnet format`, `csharpier`, or similar before test/build. |
| 📊 Test Coverage Reporting   | 📝 To do  | Integrate with Codecov or similar tools. |
| 🔍 Pre-merge Linting         | 📝 To do  | Run static analysis or linting in PRs. |
| 🚀 Unity Performance Tests   | 📝 To do  | Add support for Unity Performance Testing API. |
| 🤖 AI/Smoke Testing          | 📝 To do  | Optional gameplay sanity checks for CI stability. |

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
- ✅ Tag pushes (`v*.*.*`, `v*.*.*-*`)
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
