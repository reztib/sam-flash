# Project To-Do List

## 1. Script Base & Security
- DONE 19Aug2026 Implement strict mode using `set -o errexit`, `set -o nounset`, and `set -o pipefail`.
- DONE 19Aug2026 Replace `which adb` with the POSIX-compliant `command -v adb` to check the binary path.

## 2. Terminal Output & UI
- DONE 19Aug2026 Move hardcoded color codes into variables.
- Create logging functions for INFO, WARN, and ERROR that include timestamps and corresponding colors.

## 3. Device & Package Validation
- Verify device connections and count connected devices.
- Trigger a warning and print device names if more than one device is connected (and print the device name in any case).
- Check if a package is actually installed on the device before attempting actions.

## 4. Performance & Error Handling
- Optimize array searching to avoid spawning a subprocess via `grep` for every lookup.
- Use an if-statement during uninstallation to prevent `errexit` from aborting the script on failed packages.

## 5. List Management (Planned for Multiple Updates)
- Fetch and read lists from UAD (Universal Android Debloater).
- Display available lists with options and prompt the user to select one.
- Implement an option to import and read custom JSON lists.

## 6. Summary & Reporting
- Track uninstallation results during the script execution.
- Print a final summary listing all successfully uninstalled packages and all failed attempts.

## 7. Implementation Difficulty & Time Estimation

### 🟢 Low Difficulty (Quick Wins)
* **1. Script Base & Security**
  * Effort: **Very Low** (~5 mins)
  * Logic: Adding `set` flags and replacing `which` with `command -v`.
* **2. Color Variables & 4. Errexit Protection**
  * Effort: **Low** (~10 mins)
  * Logic: Defining variables like `RED='\e[1;31m'` and adding `|| true` to `pm uninstall`.

### 🟡 Medium Difficulty (Requires Bash Logic)
* **2. Logging & Color Check**
  * Effort: **Medium** (~20 mins)
  * Logic: Writing functions with `date` formatting and checking `tput colors`.
* **3. Device Validation & 6. Summary Reporting**
  * Effort: **Medium** (~30 mins)
  * Logic: Parsing `adb devices` with `awk`/`wc` and populating dynamic Bash arrays for tracking success/failure.

### 🔴 High Difficulty (Complex & Time-Consuming)
* **4. Performance Optimization**
  * Effort: **High** (~45 mins)
  * Logic: Replacing `grep` with Bash associative arrays (`declare -A`) to speed up bulk scanning.
* **5. List Management (UAD & JSON Parsing)**
  * Effort: **Very High** (Several hours / Multiple updates)
  * Logic: Requires integrating external dependencies like `curl` and `jq` since native Bash cannot easily parse JSON files or handle complex interactive menus.
