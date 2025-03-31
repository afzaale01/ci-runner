### 🔧 CI/CD Setup Instructions

# ✅ Unity CI/CD Test Workflow (Modular + Reusable)

This project uses **modular GitHub Actions** to automatically run Unity EditMode and PlayMode tests on push/PRs. It includes:

- 🧪 Test detection
- ♻️ License activation
- 📊 Test runner (with Git LFS & Unity cache support)

---

## 📁 File Structure

```text
.github/
└── workflows/
    ├── detect-unity-tests.yml
    ├── upload-unity-license.yml
    ├── unity-test-runner.yml
    └── step-1-unity-tests.yml
```

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
