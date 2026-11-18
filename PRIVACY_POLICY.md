# Privacy Policy — Wallhaven AutoBG

Last updated: 2026-11-18

## Overview

Wallhaven AutoBG is an open-source client for wallhaven.cc that searches, downloads and applies desktop wallpapers. This policy explains what data the app handles. **The app does not have user accounts and does not collect personal information on its own servers.**

## Data the app handles

### 1. Locally stored data (stays on your device)
- Saved search configuration, API key, language, download folder, preferences.
- Downloaded wallpaper files and the history of applied wallpapers.
- This data is stored in the app's private storage and is removed when you uninstall the app.

### 2. Network requests to wallhaven.cc
- The app calls the public wallhaven.cc API to search and download wallpapers.
- Requests are subject to wallhaven.cc's own privacy policy and terms.
- If you configure an API key, it is sent to wallhaven.cc with each request (it is never sent anywhere else).

### 3. Advertising (Android only)
- The Android version displays ads served by Google AdMob.
- Google may use device identifiers and app interaction data to serve and measure ads, as described in Google's Privacy & Terms (https://policies.google.com/technologies/ads).
- You can opt out of personalized ads in your device settings (Settings → Google → Ads).

## Permissions (Android)
- `INTERNET` — download wallpapers and talk to the API.
- `SET_WALLPAPER` — apply the downloaded wallpaper.
- `FOREGROUND_SERVICE` / `POST_NOTIFICATIONS` — keep the automatic rotation running with a persistent notification while the app is closed.

## Children

The app is not directed at children under 13 and its content may include adult-oriented material (only when unlocked with the user's own API key).

## Changes

Updates to this policy will be published in this repository.

## Contact

Open an issue at https://github.com/ascerx/Wallhaven-AutoBG/issues
