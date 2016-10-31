#!/usr/bin/env bash
#
# Copyright 2016 ShkMod
#
# From <http://android.stackexchange.com/a/140828>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# colors
bd=$(tput bold)
ok=$(tput setaf 2)
wn=$(tput setaf 3)
ko=$(tput setaf 1)
rz=$(tput sgr0)

# commands
command -v adb >/dev/null 2>&1 || { echo "$ko[ adb ]$rz" >&2 && exit 1 ; }
command -v curl >/dev/null 2>&1 || { echo "$ko[ curl ]$rz" >&2 && exit 1 ; }
command -v unzip >/dev/null 2>&1 || { echo "$ko[ unzip ]$rz" >&2 && exit 1 ; }
command -v lzip >/dev/null 2>&1 || { echo "$ko[ lzip ]$rz" >&2 && exit 1 ; }
command -v tar >/dev/null 2>&1 || { echo "$ko[ tar ]$rz" >&2 && exit 1 ; }

# release
[ ! -f "build/core/version_defaults.mk" ] && echo "$ko[ build/core/version_defaults.mk ]$rz" >&2 && exit 1
release=$(egrep "^\s*PLATFORM_VERSION :=" "build/core/version_defaults.mk" 2>/dev/null \
                 | awk '{print $NF}' | sort -n | tail -1 | cut -c1-3)
[ -z "$release" ] && echo "$ko[ release ]$rz" >&2 && exit 1

# device
device=$(adb devices | egrep '^emulator-[0-9]+' | awk '{print $1}' | head -1)
[ -z "$device" ] && echo "$ko[ emulator ]$rz" >&2 && exit 1
echo "$device"
adb -s $device remount >/dev/null
[ $? -ne 0 ] && echo "$ko[ remount ]$rz" >&2 && exit 1

# zip
rm -rf "/tmp/gapps/"
mkdir "/tmp/gapps/"
cd "/tmp/gapps/"
uri=$(curl -s https://github.com/opengapps/x86_64/releases/ \
             | egrep "href=\"/opengapps/x86_64/releases/download/[0-9]{8}/open_gapps-x86_64-${release}-pico-[0-9]{8}.zip\"" \
             | cut -d'"' -f2 | head -1)
[ -z "$uri" ] && echo "$ko[ uri ]$rz" >&2 && exit 1
url="https://github.com/$uri"
echo "$(basename "$url")"
curl --location --progress-bar "$url" --output "/tmp/gapps/gapps.zip"
[ ! -f "gapps.zip" ] && echo "$ko[ curl ]$rz" >&2 && exit 1

# zip2apk
function ex() {
    unzip -p "gapps.zip" "Core/$1.tar.lz" > "gapps_$2.tar.lz"
    [ ! -f "gapps_$2.tar.lz" ] && echo "$ko[ unzip ]$rz" >&2 && exit 1
    lzip -d "gapps_$2.tar.lz"
    [ ! -f "gapps_$2.tar" ] && echo "$ko[ lzip ]$rz" >&2 && exit 1
    tar -xf "gapps_$2.tar"
    [ ! -d "$1" ] && echo "$ko[ tar ]$rz" >&2 && exit 1
    rm -f "gapps_$2.tar" >/dev/null
    rm -f "gapps_$2.tar.lz" >/dev/null
    find "/tmp/gapps/$1/nodpi/priv-app/" -type f -name "*.apk" 2>/dev/null
}

# APKs
apk=$(ex "gmscore-x86_64" "PrebuiltGmsCore")
echo "(1/4) $(basename "$apk")"
adb -s $device push "$apk" "/system/priv-app/" || \
    { echo "$ko[ device $device ]$rz" >&2 && exit 1 ; }
apk=$(ex "gsfcore-all" "GoogleServicesFramework")
echo "(2/4) $(basename "$apk")"
adb -s $device push "$apk" "/system/priv-app/" || \
    { echo "$ko[ device $device ]$rz" >&2 && exit 1 ; }
apk=$(ex "gsflogin-all" "GoogleLoginService")
echo "(3/4) $(basename "$apk")"
adb -s $device push "$apk" "/system/priv-app/" || \
    { echo "$ko[ device $device ]$rz" >&2 && exit 1 ; }
apk=$(ex "vending-all" "Phonesky")
echo "(4/4) $(basename "$apk")"
adb -s $device push "$apk" "/system/priv-app/" || \
    { echo "$ko[ device $device ]$rz" >&2 && exit 1 ; }

# restart
adb -s $device shell stop || \
    { echo "$ko[ device $device ]$rz" >&2 && exit 1 ; }
adb -s $device shell start || \
    { echo "$ko[ adb ]$rz" >&2 && exit 1 ; }

# cleanup
cd - >/dev/null
rm -rf "/tmp/gapps" > /dev/null

# info
echo "$ok[ adb -s $device shell am start -a android.settings.APPLICATION_DETAILS_SETTINGS package:com.google.android.gms ]$rz"
echo "$ok[ adb -s $device shell am start -a android.settings.APPLICATION_DETAILS_SETTINGS package:com.android.vending ]$rz"

exit 0

# EOF
