+++
[extra]
	blurb = "Unity Ads SDK integration, including video ads, rewarded ads, and banner ads."
+++

This extension provides integration with the [Unity Ads](https://unityads.unity3d.com) SDK for iOS and Android.

Features:
- ✔ Video ads
- ✔ Rewarded video ads
- ✔ Banner ads

**GDPR Compliance** <br/>
UnityAds will automatically present users with an opportunity to opt-out of targeted advertising. See [https://unityads.unity3d.com/help/legal/gdpr](https://unityads.unity3d.com/help/legal/gdpr)

It is also possible to set the consent programmatically, using the set consent to YES/NO block (see documentation and block section).

## Documentation and Block Examples

**Step 1**: If you don’t have an account, create one at [https://operate.dashboard.unity3d.com](https://operate.dashboard.unity3d.com)

**Step 2:** Create a project and add your platfom (iOS/Andoid)

**Step 3:** Open Project and get your Game id of the Platform you work with.
![unityadspoject](https://byrobingames.github.io/img/unityads/unityadspoject.png)

Fill your Game id in the Toolset Manager<br/>
![unityadsgameid](https://byrobingames.github.io/img/unityads/unityadsgameid.png)

**Step 4:** Use the initialize UniAds block in when created event of your first (loading)scene.<br/>
![initializeUnityAds](https://byrobingames.github.io/img/unityads/unityadsinitialize.png)

If your game is not live yet, enable Testads in the Toolset Manager, don’t forget to disable Testads when your uploading your game to the store.<br/>
![unityadstestmode](https://byrobingames.github.io/img/unityads/unityadstestmode.png)

**Step 5:** Open the Platform you work with (iOS or Android) and get your <strong>Integration Id</strong> of the placements your added.<br/>
In this example i use iOS platform:<br/>
The Integration Id of Ad Placement Video is <strong>video</strong><br/>
The Integration Id of Ad Placement Rewarded Video is <strong>rewardedVideo</strong>,<br/>
<span style="color:red;">make sure you have enabled the Rewarded Video. </span>

**Step 6:** Show Video with placement id.<br/>
Show Unityads Video with placement id block,<br/>
![unityadsshowvideo](https://byrobingames.github.io/img/unityads/unityadsshowvideo.png)

**Step 7:** Show Rewarded Video.
Show Unityads Rewarded Video with placement id block,<br/>
Create and Alert title and Message that ask the player if he wants to watch the Rewarded Video or not. If Alert title is empty no Alert box will show.<br/>
![unityadsshowrewarded](https://byrobingames.github.io/img/unityads/unityadsshowrewarded.png)

**Step 8:** Can Show Ads
Check if ads with placement id can be show , it return true when it can show and false if ads cannot be show.<br/>
![unityadscanshow](https://byrobingames.github.io/img/unityads/unityadscanshow.png)

**Step 9:** Callbacks<br/>
![unityadscallbacks](https://byrobingames.github.io/img/unityads/unityadscallbacks.png)<br/>
Use the callback blocks in an Updated event in an if statement.<br/>
– did show<br/>
– is completed<br/>
– is skipped (Video only, Rewarded cannot be skipped)

### Banner Support

**Show Banner with PlacementId**<br/>
![unityshowbanner](https://byrobingames.github.io/img/unityads/unityshowbanner.png)<br/>
Show the banner, by defeault at the bottom.

<hr/>

**Hide Banner**<br/>
![unityhidebanner](https://byrobingames.github.io/img/unityads/unityhidebanner.png)<br/>
Hide the banner.

<hr/>

**Move Banner**<br/>
![unitymovebanner](https://byrobingames.github.io/img/unityads/unitymovebanner.png)<br/>
Move the banner to top or back to bottom.

<hr/>

**Banner Callbacks**<br/>
![unitybannercallbacks](https://byrobingames.github.io/img/unityads/unitybannercallbacks.png)<br/>

### Button Example:

Video ad:<br/>
![unityadsexamplevideobutton](https://byrobingames.github.io/img/unityads/unityadsexamplevideobutton.png)

Rewarded ad:<br/>
![unityadsexamplerewardedbutton](https://byrobingames.github.io/img/unityads/unityadsexamplerewardedbutton.png)

<hr/>


### Set/Get Consent value (for Europe users only)

**Set Consent** <br/>
![setconsent](https://byrobingames.github.io/img/unityads/unityadssetconsent.png)<br/>
This block is optional for UnityAds.<br/>
But if you want to set the consent programmatically you can use this block.<br/>
YES: Yes, i agree to personalized experience.<br/>
NO: No, I do not want personalized experience.<br/>
Go to  [https://unityads.unity3d.com/help/legal/gdpr](https://unityads.unity3d.com/help/legal/gdpr) for more information.<br/>

**Get Consent** <br/>
![setconsent](https://byrobingames.github.io/img/unityads/unityadsgetconsented.png)<br/>
Return true(YES) if consent is set to YES and return false(NO) when consent is set to NO.

If you want to check if a user is in Europe, you can use the **"User is in Continetn: Europe"** boolean block from [https://byrobingames.github.io](https://byrobingames.github.io)