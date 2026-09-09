# NeuraAster Android

NeuraAster is an Android-only Flutter AI client using the supplied NeuraAster logo and a dark, assistant-style interface.

## Important design note

This project intentionally does **not** ship Google's proprietary branding or a deceptive 1:1 copy of the Gemini product. It recreates the interaction patterns requested (model picker, drawer, live voice/camera, rich media, code actions) under the NeuraAster identity.

## Requirements

- Flutter 3.44+ / Dart 3.12+
- Android SDK 24+
- A reachable NeuraAster FastAPI backend at:
  `https://breach-fog-list.ngrok-free.dev`

The latest package choices used here require a current Flutter/Dart toolchain.

## Backend contract

### POST /api/chat

Request:
```json
{
  "prompt": "Hello",
  "model": "3.1 Pro"
}
```

Vision mode additionally sends:
```json
{
  "prompt": "What is this?",
  "model": "3.1 Pro",
  "image_base64": "<base64 jpeg>"
}
```

Response:
```json
{
  "type": "text",
  "reply": "Hello!",
  "media_url": null
}
```

Supported `type`: `text`, `image`, `audio`, `video`.

### POST /api/tts

Request:
```json
{
  "text": "Hello from NeuraAster",
  "gender": "female"
}
```

The client supports either:
1. raw audio bytes, or
2. JSON containing `media_url`.

### GET /api/clear

Clears remote chat history.

## Build

From this directory:

```bash
flutter pub get
flutter run
```

For a release APK:

```bash
flutter build apk --release
```

Output is normally under:
`build/app/outputs/flutter-apk/release/`

## Android permissions

The manifest requests:
- Internet
- Camera
- Microphone

Media gallery saving is handled by the gallery plugins and scoped storage rules; code files are stored inside the app's Documents/NeuraAster directory.

## Production checklist

Before publishing:
- Put the API behind your own stable HTTPS domain instead of a temporary ngrok hostname.
- Add authentication/rate limiting to the FastAPI service.
- Add certificate/network hardening appropriate for your deployment.
- Add crash reporting and privacy/terms screens.
- Verify your backend accepts `image_base64` for vision requests.
