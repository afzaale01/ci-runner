# 🚀 Unity CI/CD Pipeline

**Robust GitHub Actions workflows to automate tests, builds, and continuous integration for your Unity projects.**

![Unity CI/CD](https://github.com/Avalin/CI-CD-Unity-Test-Project/actions/workflows/ci-cd-full.yml/badge.svg)

---

## 📌 Features

| Feature                        | Description |
|-------------------------------|-------------|
| 🧪 **Test Detection**          | Automatically runs EditMode & PlayMode tests. |
| 🛠️ **Cross-Platform Builds**   | Android, iOS, WebGL, macOS, Windows, Linux. |
| 🧩 **Modular Workflows**       | Reusable steps via `workflow_call`. |
| 🏷️ **Dynamic Versioning**      | Git tag (release) or timestamp (preview). |
| ⚡ **Parallel Execution**      | Matrix builds across macOS & Ubuntu. |
| 🔐 **License Activation**      | Activates Unity license securely in CI. |
| 🗃️ **LFS & Cache Support**     | Git LFS & Unity `Library` caching. |
| 🧭 **Manual Workflow Dispatch**| Custom `buildType` and `targetPlatforms`. |

<details>
  <summary><strong>🧪 Roadmap / To-Do</strong></summary>

<br>

| Feature                        | Description |
|-------------------------------|-------------|
| 🧪 Test Summary Comments       | PR comment with test results using `github-script`. |
| 📦 GitHub Release Deployment   | Auto-attach builds on tag push. |
| 📣 CI Notifications            | Optional Slack/Discord webhooks. |
| 🧼 Code Formatting             | Run `dotnet format`, `csharpier`, etc. |
| 📊 Test Coverage               | Coverage reporting via Codecov or others. |
| 🔍 Pre-merge Linting           | Static analysis during PRs. |
| 🚀 Performance Tests           | Support Unity Performance API. |
| 🤖 Smoke Testing               | Basic gameplay/UI sanity checks. |

</details>


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
| [`target-platforms-filter.yml`](./.github/workflows/target-platforms-filter.yml) | Filters selected Unity build targets into macOS and Ubuntu groups |
| [`build-version-generator.yml`](./.github/workflows/build-version-generator.yml) | Generates a version string for builds based on Git tags or timestamps |

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

### 3. ⚙️ Add Repository Variables:

Add the following repository variables to configure and control your Unity CI/CD pipeline:

- **Navigate to**:  
  `Settings → Secrets and variables → Actions → New repository variable`

| Variable Name               | Description                                                                 |
|-----------------------------|-----------------------------------------------------------------------------|
| `PROJECT_NAME`              | Project name used in artifact naming and builds (e.g., `MyGame`)            |
| `UNITY_VERSION`             | Unity version to use (e.g., `2022.3.13f1`)                                  |
| `USE_GIT_LFS`               | Whether to use Git LFS (`true` or `false`)                                  |
| `LICENSE_ARTIFACT_NAME`     | Name for storing the uploaded Unity license artifact (e.g., `unity-license`)|
| `UNITY_TESTS_EDITMODE_PATH` | Path to your EditMode tests folder (e.g., `Assets/Tests/Editor`)            |
| `UNITY_TESTS_PLAYMODE_PATH` | Path to your PlayMode tests folder (e.g., `Assets/Tests/PlayMode`)          |
| `TIMEOUT_TESTS_IN_MINUTES` | Timeout for test jobs in minutes (e.g., `15`)                               |
| `TIMEOUT_BUILD_IN_MINUTES` | Timeout for each build job in minutes (e.g., `30`)                          |
| `TARGET_PLATFORMS`          | JSON array of platforms to build (e.g., `["Android","WebGL","StandaloneWindows64"]`) |
| `RETENTION_DAYS_RELEASE`    | Days to retain build artifacts for release builds (e.g., `30`)             |
| `RETENTION_DAYS_PREVIEW`    | Days to retain artifacts for preview/manual builds (e.g., `7`)             |

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
