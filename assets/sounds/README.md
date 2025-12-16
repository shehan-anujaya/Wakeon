# Alarm Sounds

## Current Status
The app currently uses **Text-to-Speech (TTS)** and **vibration** for alerts since no audio file is present. This works perfectly!

## To Add Custom Alarm Sound (Optional)

If you want a traditional alarm sound, add a file named `alarm.mp3` to this folder.

### Free Alarm Sound Sources:

1. **Freesound** - https://freesound.org/
   - Search: "alarm", "siren", "warning"
   - License: Look for CC0 (public domain)

2. **Zapsplat** - https://www.zapsplat.com/
   - Free alarm/alert sounds
   - Requires free account

3. **Pixabay** - https://pixabay.com/sound-effects/
   - Search: "alarm clock", "emergency alarm"
   - All CC0 license

### Recommended Sound Characteristics:
- Format: MP3
- Duration: 3-5 seconds (will loop)
- Volume: Normalized/loud
- Type: Urgent alarm/siren/beep pattern

### Example Search Terms:
- "car alarm"
- "emergency siren"
- "wake up alarm"
- "warning beep"
- "alert sound"

## Alternative: Record Your Own

Use a voice recording app to say:
"Wake up! Stay alert! Wake up!"

Save as MP3 and name it `alarm.mp3`

## How It Works:

When `alarm.mp3` exists:
- ✓ Vibration
- ✓ TTS voice alert
- ✓ Audio file loops

When `alarm.mp3` is missing:
- ✓ Vibration (enhanced pattern)
- ✓ TTS voice alert (repeated 2x)
- ⚠ No audio file (but still effective!)
