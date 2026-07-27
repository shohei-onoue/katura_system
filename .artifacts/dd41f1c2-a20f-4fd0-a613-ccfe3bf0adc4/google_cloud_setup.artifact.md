# Google Cloud Console API Key Configuration

The error "This API key is not authorized to use this service or API" means your API key exists but doesn't have permission to use the specific Google Maps services requested by the app.

Please follow these steps in the [Google Cloud Console](https://console.cloud.google.com/) to resolve this.

## 1. Enable Required APIs

Ensure the following APIs are **Enabled** for your project:

- [ ] **Geocoding API** (Required for converting addresses to coordinates)
- [ ] **Places API** (Required for address suggestions)
- [ ] **Maps SDK for Android** (Required for displaying the map on Android)
- [ ] **Maps SDK for iOS** (Required for displaying the map on iOS)

> [!TIP]
> Google Cloud Consoleの上部検索バーでそれぞれの名前を検索し、「有効にする」ボタンをクリックしてください。

## 2. Check API Key Restrictions

If you have enabled the APIs but still see the error, check the **API restrictions** on your key:

1.  Go to **APIs & Services** > **Credentials**.
2.  Click on your API key (the one ending in `...UOF3P4_Y`).
3.  Scroll down to **API restrictions**.
4.  If **"Restrict key"** is selected, ensure all the APIs listed above are checked in the dropdown.
5.  If you want to keep it simple during development, you can temporarily select **"Don't restrict key"**, but remember to restrict it before releasing the app.

## 3. Application Restrictions (Optional but recommended)

Ensure the Android package name matches exactly:
- **Package name**: `com.katura.katura_system`

## Why this is happening
The app is currently trying to use the **Geocoding API** to get coordinates for the facility search we just implemented. Since this API might not be allowed for your current key, Google is denying the request.
