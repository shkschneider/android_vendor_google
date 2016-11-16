#
# Copyright 2016 ShkMod
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

PRODUCT_PROPERTY_OVERRIDES += ro.com.google.clientidbase=android-google

PRODUCT_PROPERTY_OVERRIDES += keyguard.no_require_sim=true
PRODUCT_PROPERTY_OVERRIDES += ro.url.legal=http://www.google.com/intl/%s/mobile/android/basic/phone-legal.html
PRODUCT_PROPERTY_OVERRIDES += ro.url.legal.android_privacy=http://www.google.com/intl/%s/mobile/android/basic/privacy.html
PRODUCT_PROPERTY_OVERRIDES += ro.com.android.wifi-watchlist=GoogleGuest
PRODUCT_PROPERTY_OVERRIDES += ro.setupwizard.enterprise_mode=1
PRODUCT_PROPERTY_OVERRIDES += ro.com.android.dateformat=MM-dd-yyyy
PRODUCT_PROPERTY_OVERRIDES += ro.com.android.dataroaming=false

ifeq ($(TARGET_SUPPORTS_64_BIT_APPS),true)
PRODUCT_COPY_FILES += vendor/google/prebuilt/system/lib64/libjni_latinime.so:system/lib64/libjni_latinime.so
else
PRODUCT_COPY_FILES += vendor/google/prebuilt/system/lib/libjni_latinime.so:system/lib/libjni_latinime.so
endif
PRODUCT_COPY_FILES += vendor/google/prebuilt/system/etc/resolv.conf:system/etc/resolv.conf

PRODUCT_PACKAGE_OVERLAYS += vendor/google/overlay

# EOF
