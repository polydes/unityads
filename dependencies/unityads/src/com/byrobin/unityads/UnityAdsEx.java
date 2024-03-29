/*
 *
 * Created by Robin Schaafsma
 * https://byrobingames.github.io
 * copyright
 */

package com.byrobin.unityads;

import android.app.*;
import android.content.*;
import android.content.Context;
import android.content.SharedPreferences;
import android.os.*;
import android.util.Log;

import android.view.Gravity;
import android.view.animation.Animation;
import android.view.animation.AlphaAnimation;
import android.view.View;
import android.view.ViewGroup.LayoutParams;
import android.widget.LinearLayout;

import org.haxe.extension.Extension;
import org.haxe.lime.HaxeObject;

import com.unity3d.ads.IUnityAdsInitializationListener;
import com.unity3d.ads.IUnityAdsLoadListener;
import com.unity3d.ads.IUnityAdsShowListener;
import com.unity3d.ads.UnityAds;
import com.unity3d.ads.metadata.MetaData;

import com.unity3d.services.banners.IUnityBannerListener;
import com.unity3d.services.banners.UnityBanners;

import java.util.HashSet;
import java.util.Set;

public class UnityAdsEx extends Extension
{
    private static final String TAG = "UnityAdsEx";

    private static UnityAdsEx _self = null;
    private static AdListener adListener = null;
    private static IUnityBannerListener bannerListener = null;
    protected static HaxeObject unityadsCallback;

    //////////////////////////////////////////////////////////////////////////////////////////////////

    private View bannerView;
    private LinearLayout layout;

    private static String appId = null;
    private static MetaData gdprMetaData = null;

    private static boolean initialized = false;
    private static boolean showedVideo = false;
    private static boolean showedRewarded = false;
    private static boolean bannerLoaded = false;
    private static int gravity = Gravity.BOTTOM | Gravity.CENTER_HORIZONTAL;

    private static Set<String> loadedPlacements = new HashSet<>();

    //////////////////////////////////////////////////////////////////////////////////////////////////

    @SuppressWarnings("unused")
    static public void init(HaxeObject cb, final String appId, final boolean testMode, final boolean debugMode)
    {
        unityadsCallback = cb;
        UnityAdsEx.appId = appId;

        if(appId.isEmpty())
        {
            Log.d(TAG, "Failed to initialize because app ID hasn't been set.");
            return;
        }

        Extension.mainActivity.runOnUiThread(() -> {
            Log.d(TAG, "Init UnityAds appId:" + appId);
            UnityAds.setDebugMode(debugMode);
            UnityAds.initialize(mainActivity, appId, testMode, new IUnityAdsInitializationListener()
            {
                @Override
                public void onInitializationComplete()
                {
                    initialized = true;
                }

                @Override
                public void onInitializationFailed(UnityAds.UnityAdsInitializationError error, String message)
                {
                    Log.e(TAG, message);
                }
            });
        });
    }

    @SuppressWarnings("unused")
    static public void loadVideo(final String videoPlacementId)
    {
        if (!initialized)
        {
            Log.d(TAG, "UnityAds isn't initialized yet");
            return;
        }

        showedVideo = true;
        showedRewarded = false;

        loadedPlacements.remove(videoPlacementId);

        Extension.mainActivity.runOnUiThread(() -> UnityAds.load(videoPlacementId, adListener));
    }

    @SuppressWarnings("unused")
    static public void loadRewarded(final String rewardPlacementId)
    {
        if (!initialized)
        {
            Log.d(TAG, "UnityAds isn't initialized yet");
            return;
        }

        showedVideo = false;
        showedRewarded = true;

        loadedPlacements.remove(rewardPlacementId);

        Extension.mainActivity.runOnUiThread(() -> UnityAds.load(rewardPlacementId, adListener));
    }

    @SuppressWarnings("unused")
    static public void showVideo(final String videoPlacementId)
    {
        if (!initialized)
        {
            Log.d(TAG, "UnityAds isn't initialized yet");
            return;
        }

        showedVideo = true;
        showedRewarded = false;
        Log.d(TAG, "Show Video Begin");
        Extension.mainActivity.runOnUiThread(() -> UnityAds.show(mainActivity, videoPlacementId, adListener));
        Log.d(TAG, "Show Video End ");
    }

    @SuppressWarnings("unused")
    static public void showRewarded(final String rewardPlacementId, final String title, final String msg)
    {
        if (!initialized)
        {
            Log.d(TAG, "UnityAds isn't initialized yet");
            return;
        }

        showedVideo = false;
        showedRewarded = true;

        Log.d(TAG, "Show Rewarded Begin");
        Extension.mainActivity.runOnUiThread(() -> {
            if (title.length() > 0)
            {
                Dialog dialog = new AlertDialog.Builder(mainActivity)
                    .setTitle(title)
                    .setMessage(msg)
                    .setPositiveButton("Watch", (dialog1, whichButton) ->
                        UnityAds.show(mainActivity, rewardPlacementId, adListener)
                    )
                    .setNegativeButton("Discard", (dialog1, whichButton) -> {
                            //Do nothing go back to mainActivity
                    })
                    .create();

                dialog.show();
            }
            else
            {
                UnityAds.show(mainActivity, rewardPlacementId, adListener);
            }
        });
        Log.d(TAG, "Show Rewarded End ");
    }

    @Deprecated
    @SuppressWarnings("unused")
    public static boolean canShowUnityAds(final String placementId)
    {
        return loadedPlacements.contains(placementId);
    }

    @SuppressWarnings("unused")
    public static boolean isSupportedUnityAds()
    {
        return UnityAds.isSupported();
    }

    @SuppressWarnings("unused")
    static public void showBanner(final String bannerPlacementId)
    {
        if (!initialized)
        {
            Log.d(TAG, "UnityAds isn't initialized yet");
            return;
        }

        Extension.mainActivity.runOnUiThread(() -> {
            if (bannerLoaded)
            {
                _self.bannerView.setVisibility(View.VISIBLE);

                Animation animation1 = new AlphaAnimation(0.0f, 1.0f);
                animation1.setDuration(1000);
                _self.layout.startAnimation(animation1);

                unityadsCallback.call("onBannerShow", new Object[]{});
            }
            else
            {
                UnityBanners.setBannerListener(bannerListener);
                UnityBanners.loadBanner(mainActivity, bannerPlacementId);
            }
        });
    }

    @SuppressWarnings("unused")
    static public void hideBanner()
    {
        if (!initialized)
        {
            Log.d(TAG, "UnityAds isn't initialized yet");
            return;
        }

        if (bannerLoaded)
        {
            Extension.mainActivity.runOnUiThread(() -> {
                Animation animation1 = new AlphaAnimation(1.0f, 0.0f);
                animation1.setDuration(1000);
                _self.layout.startAnimation(animation1);

                final Handler handler = new Handler();
                handler.postDelayed(() -> {
                    _self.bannerView.setVisibility(View.GONE);

                    unityadsCallback.call("onBannerHide", new Object[]{});
                }, 1000);
            });
        }
    }

    @SuppressWarnings("unused")
    static public void destroyBanner()
    {
        if (!initialized)
        {
            Log.d(TAG, "UnityAds isn't initialized yet");
            return;
        }

        Extension.mainActivity.runOnUiThread(UnityBanners::destroy);
    }

    static public void moveBanner(final String position)
    {
        if (!initialized)
        {
            Log.d(TAG, "UnityAds isn't initialized yet");
            return;
        }

        Extension.mainActivity.runOnUiThread(() -> {
            if (position.equals("TOP"))
            {
                if (_self.bannerView == null)
                {
                    UnityAdsEx.gravity = Gravity.TOP | Gravity.CENTER_HORIZONTAL;
                }
                else
                {
                    UnityAdsEx.gravity = Gravity.TOP | Gravity.CENTER_HORIZONTAL;
                    _self.layout.setGravity(gravity);
                }
            }
            else
            {
                if (_self.bannerView == null)
                {
                    UnityAdsEx.gravity = Gravity.BOTTOM | Gravity.CENTER_HORIZONTAL;
                }
                else
                {
                    UnityAdsEx.gravity = Gravity.BOTTOM | Gravity.CENTER_HORIZONTAL;
                    _self.layout.setGravity(gravity);
                }
            }
        });
    }

    @SuppressWarnings("unused")
    static public void setUsersConsent(final boolean isGranted)
    {
        if (gdprMetaData == null)
        {
            gdprMetaData = new MetaData(mainActivity);
        }

        if (gdprMetaData.hasData())
        {
            gdprMetaData.clearData();
        }

        gdprMetaData.set("gdpr.consent", isGranted);
        gdprMetaData.commit();

        SharedPreferences.Editor editor = mainActivity.getPreferences(Context.MODE_PRIVATE).edit();
        if (editor == null)
        {
            Log.d(TAG, "UnityAdsEx Failed to write user consent to preferences");
            return;
        }

        editor.putBoolean("gdpr_consent_unityads", isGranted);
        boolean committed = editor.commit();

        if (!committed)
        {
            Log.d(TAG, "UnityAdsEx Failed to write user consent to preferences");
        }
    }

    @SuppressWarnings("unused")
    public static boolean getUsersConsent()
    {
        SharedPreferences prefs = mainActivity.getPreferences(Context.MODE_PRIVATE);
        if (prefs == null)
        {
            Log.i(TAG, "UnityAdsEx Failed to read user content preference data");
            return false;
        }

        final boolean isGranted = prefs.getBoolean("gdpr_consent_unityads", false);

        Log.d(TAG, "UnityAdsEx get userConsent is: " + isGranted);

        return isGranted;
    }

    //////////////////////////////////////////////////////////////////////////////////////////////////

    private static class AdListener implements IUnityAdsLoadListener, IUnityAdsShowListener
    {
        @Override
        public void onUnityAdsAdLoaded(String placementId)
        {
            Log.d(TAG, "Fetch Completed ");
            loadedPlacements.add(placementId);
            if (showedVideo)
            {
                unityadsCallback.call("onVideoDidFetch", new Object[]{});
            }
            else if (showedRewarded)
            {
                unityadsCallback.call("onRewardedDidFetch", new Object[]{});
            }
        }

        @Override
        public void onUnityAdsFailedToLoad(String placementId, UnityAds.UnityAdsLoadError error, String message)
        {
            Log.d(TAG, "Fetch Failed: " + message);
            loadedPlacements.remove(placementId);
            if (showedVideo)
            {
                unityadsCallback.call("onVideoFailedToFetch", new Object[]{});
            }
            else if (showedRewarded)
            {
                unityadsCallback.call("onRewardedFailedToFetch", new Object[]{});
            }
        }

        @Override
        public void onUnityAdsShowFailure(String placementId, UnityAds.UnityAdsShowError error, String message)
        {
            Log.e(TAG, message);
            loadedPlacements.remove(placementId);
            if (showedVideo)
            {
                unityadsCallback.call("onVideoFailedToShow", new Object[]{});
            }
            else if (showedRewarded)
            {
                unityadsCallback.call("onRewardedFailedToShow", new Object[]{});
            }
        }

        @Override
        public void onUnityAdsShowStart(String placementId)
        {
            if (showedVideo)
            {
                unityadsCallback.call("onVideoDidShow", new Object[]{});
            }
            else if (showedRewarded)
            {
                unityadsCallback.call("onRewardedDidShow", new Object[]{});
            }
        }

        @Override
        public void onUnityAdsShowClick(String placementId)
        {
            if (showedVideo)
            {
                unityadsCallback.call("onVideoDidClick", new Object[]{});
            }
            else if (showedRewarded)
            {
                unityadsCallback.call("onRewardedDidClick", new Object[]{});
            }
        }

        @Override
        public void onUnityAdsShowComplete(String placementId, UnityAds.UnityAdsShowCompletionState state)
        {
            loadedPlacements.remove(placementId);
            switch (state)
            {
                case SKIPPED:
                    if (showedVideo)
                    {
                        unityadsCallback.call("onVideoSkipped", new Object[]{});
                    }
                    else if (showedRewarded)
                    {
                        unityadsCallback.call("onRewardedSkipped", new Object[]{});
                    }
                    break;
                case COMPLETED:
                    if (showedVideo)
                    {
                        unityadsCallback.call("onVideoCompleted", new Object[]{});
                    }
                    else if (showedRewarded)
                    {
                        unityadsCallback.call("onRewardedCompleted", new Object[]{});
                    }
                    break;
            }
        }
    }

    private static class BannerListener implements IUnityBannerListener
    {
        @Override
        public void onUnityBannerLoaded(String placementId, View view)
        {
            _self.bannerView = view;
            _self.layout = new LinearLayout(mainActivity);
            _self.layout.setGravity(Gravity.BOTTOM);

            mainActivity.addContentView(_self.layout, new LayoutParams(LayoutParams.FILL_PARENT, LayoutParams.FILL_PARENT));
            _self.layout.addView(_self.bannerView);
            _self.layout.bringToFront();

            moveBanner("BOTTOM");
            _self.bannerView.setVisibility(View.VISIBLE);

            UnityAdsEx.bannerLoaded = true;
        }

        @Override
        public void onUnityBannerUnloaded(String placementId)
        {
            UnityAdsEx.bannerLoaded = false;
            _self.bannerView.setVisibility(View.GONE);
            _self.bannerView = null;
        }

        @Override
        public void onUnityBannerShow(String placementId)
        {
            unityadsCallback.call("onBannerShow", new Object[]{});
        }

        @Override
        public void onUnityBannerClick(String placementId)
        {
            unityadsCallback.call("onBannerClick", new Object[]{});
        }

        @Override
        public void onUnityBannerHide(String placementId)
        {
            unityadsCallback.call("onBannerHide", new Object[]{});
        }

        @Override
        public void onUnityBannerError(String message)
        {
            UnityAdsEx.bannerLoaded = false;
            unityadsCallback.call("onBannerError", new Object[]{});
        }
    }

    //////////////////////////////////////////////////////////////////////////////////////////////////

    public void onCreate(Bundle savedInstanceState)
    {
        super.onCreate(savedInstanceState);
        _self = this;
        adListener = new AdListener();
        bannerListener = new BannerListener();
    }

    public void onResume()
    {
        super.onResume();
    }
}
