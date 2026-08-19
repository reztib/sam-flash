#!/bin/bash
# ==============================================================================
# This script is used to uninstall bloatware from Samsung tablets. 
# It uses adb to uninstall the packages listed in the package_names array.
# reztib, 18.08.2026
# ==============================================================================

set -o errexit
set -o nounset
set -eou pipefail

# Path to adb in a variable (saves performance)
adbPath=$(command -v adb)

# 1. Check if adb is installed
if [ -z "$adbPath" ]; then
	echo "Error: adb not found. You can install it via your package manager."
	exit 1
fi

# 2. Check if a device is connected and authorized
if [ "$($adbPath get-state 2>/dev/null)" != "device" ]; then
	echo "Error: No device connected or authorized. Please connect your device and allow USB-Debugging."
	exit 1
fi

# ==============================================================================
# LEGAL DISCLAIMER & WARNING
# ==============================================================================
clear
echo -e "\e[1;31m!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\e[0m"
echo -e "\e[1;31m                                  WARNING                                     \e[0m"
echo -e "\e[1;31m!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\e[0m"
echo "This script uninstalls system applications from your Android device via ADB."
echo "Removing the wrong packages can cause system instability, bootloops, or data loss."
echo ""
echo "THE SOFTWARE IS PROVIDED \"AS IS\", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR"
echo "IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,"
echo "FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE"
echo "AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER"
echo "LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,"
echo "OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE"
echo "SOFTWARE."
echo ""
echo -e "\e[1;33mRUN AT YOUR OWN RISK.\e[0m"
echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
echo ""

read -p "Continue? (y/N): " confirm

# Convert input to lowercase to make it robust against "Y"
confirm=$(echo "$confirm" | tr '[:upper:]' '[:lower:]')

if [ "$confirm" != "y" ]; then
	echo "Operation canceled by user. No changes were made."
	exit 0
fi

# 3. Output all installed packages on the device
echo "Scanning installed apps on the device..."
installed_packages=$($adbPath shell pm list packages | cut -d: -f2)

# Predefined list of bloatware packages (can be extended by looking at Universal Android Debloater or similar tools)
package_names=(
	com.sec.android.app.billing
	com.samsung.android.scloud
	com.samsung.android.scpm
	com.samsung.android.app.spage
	com.samsung.android.intellivoiceservice
	com.samsung.android.kidsinstaller
	com.samsung.SMT
	com.sec.android.easyMover.Agent
	com.samsung.android.smartmirroring
	com.samsung.android.app.soundpicker
	com.google.android.tts
	com.samsung.android.stickercenter
	com.google.android.apps.setupwizard.searchselector
	com.samsung.android.video
	com.sec.android.daemonapp
)

# 4. Count and filter packages that are actually installed
found_count=0
packages_to_remove=()

for i in "${package_names[@]}"; do
	if echo "$installed_packages" | grep -q "^$i$"; then
		packages_to_remove+=("$i")
		((found_count++))
	fi
done

# If no matching packages are found, exit early
if [ $found_count -eq 0 ]; then
	echo "No matching bloatware packages found on this device. Nothing to do."
	exit 0
fi

# 5. Interactive confirmation prompt
echo -e "\e[1;32mFound $found_count matching bloatware packages on your device.\e[0m"
read -p "Do you really want to uninstall them? (y/N): " confirm

# Convert input to lowercase to make it robust against "Y"
confirm=$(echo "$confirm" | tr '[:upper:]' '[:lower:]')

if [ "$confirm" != "y" ]; then
	echo "Operation canceled by user. No changes were made."
	exit 0
fi

echo ""
echo "Starting de-bloat process..."

# 6. Uninstall the verified apps
for i in "${packages_to_remove[@]}"
do
	echo "Uninstalling: $i"
	$adbPath shell pm uninstall --user 0 "$i"
done

echo ""
echo "Device successfully debloated."
