# 0.5.0 (2026-05-27)

- Fixes for Stencyl 4.2.0

# 0.4.1 (2023-12-04)

- Add namespace declaration to fix Android builds with Stencyl b12043

# 0.4.0 (2022-10-10)

- Add blocks to load ads, which must be used before showing ads.
- Added more video/rewarded ad display states (loaded, failed to load, failed to show, clicked).

# 0.3.0 (2022-09-25)

- Update UnityAds SDK to 4.3.0
- Fix forced orientation switching bug after ads on iOS

# 0.2.5 (2022-05-06)

- Removed dependency on byrobingames extension manager. iOS framework is now retrieved through CocoaPods.

# 0.2.4 (2021-12-28)

- Fix build error on iOS.

# 0.2.3 (2021-08-05)

- Updated Unity Ads SDK to 3.7.5.
- [android] Fix build error due to android repository settings.

# 0.2.2 (2021-04-19)

- [ios] Fixed SKAdNetwork settings
- [ios] Improved autobuild of extension binaries
- [ios] Minor updates to fix deprecation warnings
- [ios] Fixed banner size and position on certain devices.

# 0.2.0 (2021-03-20)

- Update to Unity Ads SDK 3.5.1 to fix Android 11 and iOS 14 issues.

# 0.1.6 (2021-01-21)

- Fix minsdk android publishing error with recent gradle android versions.

# 0.1.5 (2021-01-16)

- Fix: gradle build error.
- Fix: Don't try to build iOS binaries unless building game for iOS.

# 0.1.4 (2019-09-29)

- Update SDK to iOS: 3.2.0 Android: 3.2.0
- Android fix issue `READ_PHONE_STATE`

# 0.1.3 (2019-01-07)

- Added a "get consent block" to get the consent programmatically.

# 0.1.2 (2019-01-05)

- Added a "set consent block" to set the consent programmatically.

# 0.1.1 (2018-12-26)

- Update SDK to iOS: 3.0.0 Android: 3.0.0
- Add Banner Support Fix Android Stencyl 3.5

# 0.1.0 (2017-05-16)

- Update SDK to iOS: 2.1.0 Android: 2.1.0
- Tested for Stencyl 3.5
- Required byRobin Toolset Extension Manager

# 0.0.9 (2017-03-19)

- Updated to use with Heyzap Extension 2.9
- Update SDK to iOS: 2.0.8 Android: 2.0.8
- Added Android Gradle support for openfl4

# 0.0.8 (2016-11-18)

- Updated for use with Heyzap Extension 2.7

# 0.0.7 (2016-10-06)

- Fix: Android export/publish game

# 0.0.6 (2016-10-02)

- Updated iOS and Android SDK to 2.0.4
- Removed Set Placement ID block, this is not required in SDK 2.0.4
- Added placementid in Can Show Ads block.
- Verion 0.0.5 of byRobin Extension Manager is needed.

# 0.0.5 (2016-05-04)

- Added canShowad