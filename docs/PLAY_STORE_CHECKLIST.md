# Play Store publishing checklist (Wallhaven AutoBG)

Step-by-step to get `wallhaven-autobg_<version>_android.aab` published on
Google Play under your developer account.

## 0) Accounts you already have
- [x] Google Play Developer account ($25 one-time)
- [x] AdMob account

## 1) Generate the upload keystore (one-time)
1. Run the workflow **"Build and release"** with the input
   `generate_keystore = true` (Actions tab → run it).
2. Download the artifact `android-upload-keystore` → `wallhaven-upload.jks`.
3. Encode it: `certutil -encode wallhaven-upload.jks keystore.b64` (Windows)
   and copy the content **without** the BEGIN/END lines.
4. In the repo: Settings → Secrets and variables → Actions → New secret:
   - `ANDROID_KEYSTORE_BASE64` = the base64 content
   - `ANDROID_KEYSTORE_PASSWORD` = the password you used
5. **Keep the .jks file safe** (back it up). Losing it means losing the
   ability to update the app under the same key (Play can reset with an
   app signing key reset request, but avoid it).

## 2) AdMob → real IDs
1. In AdMob: Apps → Add app (Android) → copy the **App ID**
   (`ca-app-pub-XXXXX~XXXXX`).
2. Create a **Banner** ad unit → copy its ID (`ca-app-pub-XXXXX/XXXXX`).
3. Replace both in the repo:
   - `lib/config/ads.dart` (both constants)
   - `android/app/src/main/AndroidManifest.xml` (the APPLICATION_ID meta-data)
4. Commit and tag a new release. Until you replace them, the app shows
   Google's **test ads** (safe for development).

> ⚠ Policy: ads are hidden automatically while NSFW content is unlocked.
> Do not remove that guard — AdMob forbids ads next to explicit content.

## 3) Privacy policy URL
- The repo has `PRIVACY_POLICY.md`. Host it (GitHub Pages: Settings → Pages,
  or link to the raw file) and use that URL in the Play Console.

## 4) Play Console → Create the app
1. All apps → Create app:
   - Name: `Wallhaven AutoBG`
   - Default language: Spanish or English
   - App or game: **App**, Free or paid
2. Store listing:
   - **App icon** 512×512 PNG (`assets/icon.png` already works)
   - **Feature graphic** 1024×500
   - **Screenshots** (min 2, phone): use the gallery/settings screenshots
     from `assets/screenshots/` (retake from an Android device/emulator)
   - Short + full description
3. App content:
   - **Privacy policy**: the URL from step 3.
   - **Ads**: yes, contains ads.
   - **Data safety**: declare:
     - Data collected: Device or other IDs, App interactions, Advertising data
     - Purpose: Advertising or marketing
     - Not shared / optional encryption in transit: yes
   - **Content rating** (IARC): answer honestly — the app fetches content
     from the internet; note NSFW is opt-in via the user's own API key.
   - Target audience: 18+ (adult content possible).
4. **Release**: Production → upload the signed `.aab`
   (`wallhaven-autobg_<version>_android.aab` from Releases — it is signed
   with your upload keystore when the secrets are set).
5. Complete the declaration that the app was built with Play App Signing
   (recommended: let Play manage the app signing key).

## 5) Review
- Google reviews the app (usually 1-7 days). Wallhaven-style wallpaper
  clients exist on Play; keep NSFW behind the user's own API key (the
  default behavior) and the ads guard active.
- If rejected for "adult content", re-review the data safety answers and
  make sure the default search cannot return NSFW without the user's key.
