package cl.json.social;

import android.app.Activity;
import android.content.ActivityNotFoundException;
import android.content.Intent;
import android.support.v4.content.FileProvider;
import android.net.Uri;

import java.io.File;

import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReadableMap;

import cl.json.ShareFile;

public class InstagramStoriesVideoAndStickerImageShare extends SingleShareIntent {

    private static final String PACKAGE = "com.instagram.android";
    private static final String PLAY_STORE_LINK = "market://details?id=com.instagram.android";

    public InstagramStoriesVideoAndStickerImageShare(ReactApplicationContext reactContext) {
        super(reactContext);
        this.setIntent(new Intent("com.instagram.share.ADD_TO_STORY"));
    }

    @Override
    public void open(ReadableMap options) throws ActivityNotFoundException {
        super.open(options);

        if (!options.hasKey("stickerImage") && !options.hasKey("backgroundVideo") && !options.hasKey("backgroundImage")) {
            throw new Error("stickerImage or backgroundVideo or backgroundImage required.");
        }

        Activity activity = this.reactContext.getCurrentActivity();

        String attributionURL = "";
        if (ShareIntent.hasValidKey("attributionURL", options)) {
            attributionURL = options.getString("attributionURL");
        }

        if (options.hasKey("backgroundVideo")) {
            ShareFile backgroundVideoFile = new ShareFile(options.getString("backgroundVideo"), "video/mp4", this.reactContext);
            Uri backgroundVideoUri = backgroundVideoFile.getURI();
            this.getIntent().setDataAndType(backgroundVideoUri, "video/mp4");
        } else if (options.hasKey("backgroundImage")) {
            ShareFile backgroundImageFile = new ShareFile(options.getString("backgroundImage"), "image/jpeg", this.reactContext);
            Uri backgroundImageUri = backgroundImageFile.getURI();
            this.getIntent().setDataAndType(backgroundImageUri, "image/jpeg");
        }

        if (options.hasKey("stickerImage")) {
            ShareFile stickerImageFile = new ShareFile(options.getString("stickerImage"), "image/png", this.reactContext);
            Uri stickerImageUri = stickerImageFile.getURI();
            if (!options.hasKey("backgroundVideo") && !options.hasKey("backgroundImage")) {
                this.getIntent().setType("image/png");
            }
            this.getIntent().putExtra("interactive_asset_uri", stickerImageUri);
            activity.grantUriPermission(getPackage(), stickerImageUri, Intent.FLAG_GRANT_READ_URI_PERMISSION);
        }

        this.getIntent().setFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION);
        this.getIntent().putExtra("content_url", attributionURL);

        if (activity.getPackageManager().resolveActivity(this.getIntent(), 0) != null) {
            activity.startActivityForResult(this.getIntent(), 0);
            TargetChosenReceiver.sendCallback(true, true, this.getIntent().getPackage());
        }
    }

    @Override
    protected String getPackage() {
        return PACKAGE;
    }

    @Override
    protected String getDefaultWebLink() {
        return null;
    }

    @Override
    protected String getPlayStoreLink() {
        return PLAY_STORE_LINK;
    }
}
