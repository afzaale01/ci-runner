### 🔧 CI/CD Setup Instructions

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

#### 3. Enable Code Coverage in Unity

1. Open Unity.
2. Go to **Window → Package Manager**
3. Search for **Code Coverage** and install the package.
4. Then go to **Window → Analysis → Code Coverage**
5. In the Code Coverage window, enable:  
   ✅ **Enable Code Coverage**
   ✅ **Generate HTML Report** *(for viewing results in the browser)*
- ✅ Generate Additional Metrics *(optional but recommended)*

#### 3. Enable Code Coverage in Unity

1. Open Unity.
2. Go to **Window → Package Manager**.
3. Search for **Code Coverage** and install the package.
4. Then go to **Window → Analysis → Code Coverage**.
5. In the Code Coverage window, enable the following:
   - ✅ **Enable Code Coverage**
   - ✅ **Generate HTML Report** *(for viewing results in the browser)*
   - ✅ **Generate Additional Metrics** *(optional but recommended)*

---

**Why "Additional Metrics"?**

Without it:  
- 📏 **Line Coverage** = Did this line run?

With it:  
- 🔧 **Method Coverage** = Did this function run?  
- 🧱 **Class Coverage** = Did any function in this class run?  
- 📦 **Assembly Coverage** = How much of this code module was tested?

➡️ Enables deeper insight into what your tests actually cover.

---

6. Optionally configure:
   - **Output directory:** Defaults to `ProjectRoot/CodeCoverage` or under `TestResults`
   - **Assembly filters:** You can limit coverage to just your main codebase if needed

