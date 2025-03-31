### 🔧 CI/CD Setup Instructions

This repo includes:
- Modular GitHub workflows for Unity test automation.
- Automatic detection of EditMode and PlayMode tests.
- Smart Unity license activation via shared artifact.
- Optional Git LFS + cache optimizations.
- Customizable Unity version support.

### 📂 Workflow Files

- `.github/workflows/step_1_unity_tests.yml` – Entry point
- `.github/workflows/detect-unity-tests.yml` – Detects test files
- `.github/workflows/upload-unity-license.yml` – Activates and uploads license
- `.github/workflows/unity-test-runner.yml` – Runs Unity tests

### 🧩 Reusability Notes

All workflows are reusable and configurable using `workflow_call` inputs.

#### 1. Enable GitHub Token Write Permissions

To allow GitHub Actions to push changes or access workflows with write access:

1. Go to your repository:  
   **Settings → Actions → General → Workflow permissions**
2. Under **Workflow permissions**, select:  
   ✅ **Read and write permissions**

---

#### 2. Add Required Repository Secrets

Set the following secrets in your repository:

**Location:**  
`Settings → Secrets and variables → Actions → New repository secret`

| Secret Name       | Description |
|-------------------|-------------|
| `UNITY_USERNAME`  | E-mail address used to log in to Unity |
| `UNITY_PASSWORD`  | Password for your Unity account |
| `UNITY_LICENSE`   | Contents of your `.ulf` license file (e.g., located at `C:/ProgramData/Unity` on Windows) |

---

![Unity Tests](https://github.com/Avalin/CI-CD-Unity-Test-Project/actions/workflows/step_1_unity_tests.yml/badge.svg)
