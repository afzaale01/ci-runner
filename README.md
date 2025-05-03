# 🚀 Unity CI/CD Pipeline

**Robust GitHub Actions workflows for Unity projects. Automates testing, multi-platform builds, and GitHub Releases with modular, reusable design.**

![CI](https://github.com/Avalin/CI-CD-Unity-Test-Project/actions/workflows/ci-cd-pipeline.yml/badge.svg)
![License](https://img.shields.io/github/license/Avalin/CI-CD-Unity-Test-Project?color=blue)
![Unity](https://img.shields.io/badge/unity-2022.3%2B-black?logo=unity)
![Latest Release](https://img.shields.io/github/v/release/Avalin/Unity-CI-Templates)

## 🌐 WebGL Demo

See a live WebGL build deployed using this CI/CD pipeline:

➡️ [**Play the Demo**](https://avalin.github.io/Unity-CI-Templates/)

> Deployed via GitHub Pages using the `gh-pages` deploy target.


## 🧠 Getting Started

1. Clone this repo or copy the `ci-cd-full.yml` workflow into your Unity project.
2. Set your required secrets and repository variables.
3. Ready-up a PR or create a Git tag to trigger the pipeline!

> ⚠️ Currently tested deploy targets: `gh-pages` (WebGL only). Others are implemented but not yet fully verified. Contributions welcome!

---

## 📌 Features

| Feature                        | Description |
|-------------------------------|-------------|
| 🧪 **Test Detection**            | Auto-detects and runs EditMode & PlayMode tests. |
| 🛠️ **Cross-Platform Builds**     | Android, iOS, WebGL, macOS, Windows, and Linux supported. |
| 📦 **Release Deployment**        | Automatically creates GitHub Releases on tag push. |
| 🧹 **Modular Design**            | Fully split into reusable `workflow_call` templates. |
| ⚡ **Parallel Matrix Builds**     | Parallel jobs across macOS and Ubuntu runners. |
| 🔐 **Secure License Activation** | Unity `.ulf` license securely injected during CI. |
| 🗃️ **LFS & Cache**               | Optional Git LFS + caching of Unity `Library` and `Packages/`. |
| 🎛️ **Manual Dispatch**          | Manually trigger preview builds with JSON platform control. |
| 🚀 **Deploy**                | Upload builds to external platforms like itch.io, TestFlight, or custom servers |
| 📣 **Notifications**         | Discord/Slack webhook support |
| 🔍 **Static Analysis**       | C# linters or Unity analyzers |

</details>

## Supported Targets

- 🔗 [itch.io Setup Guide](https://itch.io/docs/butler/)
- 🔗 [Steam Setup Guide](https://partner.steamgames.com/doc/sdk/uploading)
- 🔗 [Firebase Setup Guide](https://firebase.google.com/docs/hosting)

## ⚠ Current Limitations

While the pipeline is production-ready and modular, some deploy integrations are still marked as **experimental**:

- 🚧 **Deploy targets like Steam, TestFlight, App Center**  
  These are implemented but have not yet been fully validated in live release pipelines.

- 🔗 **External platforms may require manual setup**  
  Some targets (like itch.io, Firebase, S3) require correctly configured secrets and accounts - be sure to test deploy flows in a safe sandbox environment before pushing to production.

- 🧪 **Unity version compatibility**  
  Currently optimized for Unity 2022.3+, but older versions may work with minor adjustments.

> **Contributions and testing feedback are welcome!**  
> If you successfully validate additional targets or add new ones, please consider opening a PR to improve support for the community.

---

## 📐 Architecture Overview
```text
[ Dispatcher ]
    ↓
[ Metadata Preparation ]
    ↓
[ CI/CD Pipeline ]
    ├── 🧪 Tests (EditMode + PlayMode)
    ├── 🛠️ Build (matrix by platform)
    ├── 📦 Release (GitHub Releases for tags/RCs)
    ├── 🌍 Deploy (gh-pages, itch.io, etc.)
    └── 🔔 Notify (Discord, Slack)
```



## 🗂️ Repository Structure

### 🧠 Main Workflows

| File | Purpose |
|------|---------|
| [`ci-cd-dispatcher.yml`](.github/workflows/ci-cd-dispatcher.yml) | Entry-point dispatcher: validates inputs, prepares metadata, and triggers the full CI/CD pipeline |
| [`ci-cd-pipeline.yml`](.github/workflows/ci-cd-pipeline.yml) | Full pipeline: test, build, release, deploy & notify |

### 🤩 Modular Reusable Templates

| File | Purpose |
|------|---------|
| `step-0-analyze.yml`          | Runs static analysis using `dotnet format` |
| `step-1-test.yml`             | Detects and runs Unity tests |
| `step-2-build.yml`            | Builds for multiple platforms |
| `step-3-release.yml`          | Publishes GitHub releases |
| `step-4-deploy.yml`           | Deploys to platforms like itch.io, S3, Steam, etc. |
| `step-5-notify.yml`           | Sends Discord, Slack, and Teams notifications |
| `unity-tests-detection.yml`   | Detects if EditMode / PlayMode tests exist |
| `unity-tests-runner.yml`      | Runs Unity tests for specified mode |
| `unity-license-uploader.yml`  | Uploads Unity `.ulf` license |
| `target-platforms-filter.yml` | Filters platforms into macOS/Ubuntu |
| `build-version-generator.yml` | Auto-generates timestamp or tag-based versioning |

---

## 🔐 Secrets Setup

Can be found under:

`Settings → Secrets and variables → Actions → Secrets`

| Secret Name      | Required | Description |
|------------------|-------------|-------------|
| `CICD_PAT`       | ✅ | A Personal Access Token with 'repo' and 'workflow' permissions |
| `UNITY_EMAIL`    | ✅ | Unity account email |
| `UNITY_PASSWORD` | ✅ | Unity account password |
| `UNITY_LICENSE`  | ✅ | Raw `.ulf` license contents |
| `DISCORD_WEBHOOK` | ❌ | Discord Webhook URL for optional CI notifications |
| `SLACK_WEBHOOK`  | ❌ | Slack Webhook URL for optional CI notifications |

### 🔐 Deployment Target Secrets

These are the required secrets for each optional deploy target, only include if needed:

| Target       | Required Secrets                                                                 |
|--------------|------------------------------------------------------------------------------------|
| `itch.io`    | `DEPLOY_API_KEY`, `ITCH_USERNAME`, `ITCH_PROJECT`                                |
| `testflight` | `APPSTORE_API_KEY_ID`, `APPSTORE_API_ISSUER_ID`, `APPSTORE_API_PRIVATE_KEY`      |
| `steam`      | `STEAM_USERNAME`, `STEAM_PASSWORD`, `STEAM_APP_ID`                               |

---

## ⚙️ Repository Variables

They can be found under:

`Settings → Secrets and variables → Actions → Variables`

| Variable Name               | Required | Description                                                              |
|----------------------------|----------|--------------------------------------------------------------------------|
| `DEPLOY_TARGETS`            | ✅        | Deployment targets (JSON array, example below)                           |
| `TARGET_PLATFORMS`          | ✅        | Target build platforms (JSON array, example below)                       |
| `PROJECT_NAME`              | ✅        | Name of the Unity project                                                |
| `EXCLUDE_UNITY_TESTS`       | ❌        | Exclude tests from pipeline (`true`/`false`)                             |
| `FORCE_COMBINE_ARTIFACTS`   | ❌        | Combine all builds into one artifact (e.g. for internal QA or archiving) |
| `RETENTION_DAYS_PREVIEW`    | ❌        | Days to retain preview builds (default is `7`)                           |
| `RETENTION_DAYS_RC`         | ❌        | Days to retain release candidate builds (default is `14`)                |
| `RETENTION_DAYS_RELEASE`    | ❌        | Days to retain release builds (default is `30`)                          |
| `TIMEOUT_TESTS_IN_MINUTES`  | ❌        | Test timeout per job in minutes (default is `15`)                        |
| `TIMEOUT_BUILD_IN_MINUTES`  | ❌        | Build timeout per job in minutes (default is `30`)                       |
| `UNITY_TESTS_EDITMODE_PATH` | ❌        | Path to EditMode tests (default is `Assets/Tests/Editor`)                |
| `UNITY_TESTS_PLAYMODE_PATH` | ❌        | Path to PlayMode tests (default is `Assets/Tests/PlayMode`)              |
| `UNITY_VERSION`             | ❌        | Unity version (e.g. `auto` or `2022.3.13f1`)                             |
| `USE_GIT_LFS`               | ❌        | Use Git LFS (`true`/`false`)                                             |

#### ⚙️ Repository JSON Variable Examples

| Variable Name               | Full JSON strings |
|-----------------------------|-------------|
| `DEPLOY_TARGETS`  | ["itch.io", "appcenter", "firebase", "s3", "gh-pages", "steam", "discord", "testflight", "custom-server"]  
| `TARGET_PLATFORMS`  | ["Android", "WebGL", "StandaloneLinux64", "StandaloneWindows", "StandaloneWindows64", "StandaloneOSX", "iOS"]

---

## 🚦 Trigger Matrix

| Trigger                  | Runs                                 |
|--------------------------|---------------------------------------|
| `pull_request`           | 🧪 Runs tests only (EditMode / PlayMode) |
| `push` with `v*.*.*` tag | 🧪 + 🛠️ + 📦 Full test, build, and release |
| `workflow_dispatch`      | 🧪 + 🛠️ Manual preview build (inputs used) |

---

## 🧪 Dispatch Example

Run a preview build with selected platforms:

```json
{
  "buildType": "preview",
  "targetPlatforms": "[\"Android\", \"WebGL\"]"
}
```

---

## 📦 Artifact Naming Convention

Artifacts are named using the following structure for easy traceability:

```
{projectName}-{version}-{targetPlatform}
```

### 📁 Examples

```
MyGame-manual-main-WebGL
MyGame-PR-0001-WebGL
MyGame-v1.2.3-StandaloneWindows64
```

---

## ✅ Recommended Flow

1. 🔀 **Open a Pull Request**  
   Trigger unit tests (EditMode + PlayMode) for early validation.

2. 🧪 **Tests Pass & PR Approved**  
   Merge to your `main` or release branch.

3. 🎼 **Create Git Tag (e.g. `v1.2.3`)**  
   Triggers full CI: tests → builds → GitHub release.

```bash
git tag v1.2.3
git push origin v1.2.3
```

4. 🚀 **Artifacts uploaded to GitHub Releases**  
   Your builds are now downloadable, versioned, and public (or private).

---

## 🙌 Credits

Crafted with ❤️ by [Avalin](https://github.com/Avalin)  
Powered by GitHub Actions + Unity + Tears.

PRs welcome!

