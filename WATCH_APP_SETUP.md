# ⌚ EchoWear - Apple Watch Setup Guide

Complete step-by-step instructions for adding the Apple Watch app to your Xcode project.

---

## ⚠️ IMPORTANT: Read This First

The Apple Watch app code already exists in your project (`EchoWearWatchApp.swift`), but it's **not integrated into the Xcode project** as a build target. This guide will help you add it properly.

**Why is this needed?**
- The watch files exist on disk but Xcode doesn't know about them
- No watch target = no watch scheme = can't build or run watch app
- Watch app won't be included in TestFlight builds

**Prerequisites:**
- ✅ Mac with macOS 13.0+ (cannot be done on Windows)
- ✅ Xcode 15.0+ installed
- ✅ Apple Developer account (free tier OK for testing)
- ✅ 15-30 minutes of time

---

## 📋 What We'll Do

1. Open project in Xcode
2. Add new watchOS app target
3. Delete generated template files
4. Add our existing watch app code
5. Configure bundle ID and signing
6. Build and test on watch simulator
7. Commit changes

---

## 🚀 Step-by-Step Instructions

### Step 1: Open Project in Xcode

#### Open the Project
```bash
cd /path/to/EchoWear
open EchoWear.xcodeproj
```

Or in Xcode:
- File → Open
- Navigate to `EchoWear.xcodeproj`
- Click "Open"

**✅ Verify:** You should see the project open with EchoWearios target visible.

---

### Step 2: Add New Watch App Target

#### 2.1 Access Target Creation

1. In the left sidebar (Project Navigator), click on **EchoWear** (the blue project icon at the top)
2. You'll see a list of targets in the main editor area
3. At the bottom of the targets list, find and click the **"+"** button

**Where to find it:**
```
Project Navigator (Left) → EchoWear (blue icon)
Main Editor → Targets list → Scroll to bottom → + button
```

#### 2.2 Select Watch App Template

In the template chooser that appears:

1. **Top tabs:** Click **"watchOS"**
2. **Application section:** Select **"App"** (the basic watch app template)
3. Click **"Next"** button (bottom right)

**✅ Verify:** You should see a configuration sheet appear.

#### 2.3 Configure New Target

Fill in the following settings:

| Setting | Value | Notes |
|---------|-------|-------|
| **Product Name** | `EchoWearWatch` | Exact spelling matters! |
| **Team** | Select your Apple Developer team | Or "None" for now |
| **Organization Name** | Your name/company | Can be anything |
| **Organization Identifier** | `com.Arsalan` | Use your bundle ID prefix |
| **Bundle Identifier** | `com.Arsalan.echowear.watchkitapp` | Auto-generated, leave as is |
| **Language** | Swift | Already selected |
| **User Interface** | SwiftUI | Already selected |
| **Include Notification Scene** | ☐ Uncheck this | We don't need it |

**Important:**
- Product Name MUST be exactly `EchoWearWatch` (no spaces, correct capitalization)
- Bundle Identifier should end with `.watchkitapp`

#### 2.4 Choose Location

1. Click **"Finish"**
2. **Important:** When asked where to save:
   - Make sure "Group" shows: `EchoWear`
   - Make sure location shows: `/path/to/EchoWear` (your project folder)
   - Click "Create"

#### 2.5 Activate Scheme

A dialog will appear asking:

**"Activate "EchoWearWatch" scheme?"**

- Click **"Activate"**

**✅ Verify:**
- Look at the scheme selector (top left of Xcode, next to Run/Stop buttons)
- It should now show "EchoWearWatch"
- You should see watchOS simulators in the device list

---

### Step 3: Delete Generated Template Files

Xcode created a bunch of template files we don't need. Let's remove them.

#### 3.1 Find the Generated Watch Folder

In the left sidebar (Project Navigator):
- You should see a new **`EchoWearWatch`** folder
- It has template Swift files that Xcode generated

#### 3.2 Delete Template Files

1. Click on the **`EchoWearWatch`** folder to expand it
2. You'll see files like:
   - `EchoWearWatchApp.swift` (generated template - NOT our code)
   - `ContentView.swift` (template)
   - `Preview Content` folder
   - `Assets.xcassets`
3. **Select ALL Swift files** (but keep `Assets.xcassets`)
4. Right-click → **"Delete"**
5. In the confirmation dialog, choose **"Move to Trash"** (not "Remove Reference")

**What to delete:**
- ✅ Delete: All `.swift` files in the `EchoWearWatch` folder
- ❌ Keep: `Assets.xcassets` folder
- ❌ Keep: The `EchoWearWatch` folder itself

**✅ Verify:** The `EchoWearWatch` folder should now only contain `Assets.xcassets`.

---

### Step 4: Add Our Existing Watch App Code

Now we'll add YOUR watch app code that already exists.

#### 4.1 Locate Existing Watch Code

In Finder (outside Xcode):
1. Open Finder
2. Navigate to: `/path/to/EchoWear/EchoWear/EchoWearWatch/`
3. You should see: `EchoWearWatchApp.swift` (this is YOUR code, not the template)

**Important:** This file exists but Xcode doesn't know about it yet.

#### 4.2 Add File to Xcode Project

Back in Xcode:

1. In the Project Navigator, **right-click** on the **`EchoWearWatch`** folder
2. Select **"Add Files to 'EchoWear'..."**
3. A file browser appears
4. Navigate to: `EchoWear/EchoWear/EchoWearWatch/`
5. **Select**: `EchoWearWatchApp.swift`
6. **CRITICAL:** In the bottom options, check the boxes:
   - ✅ **"Copy items if needed"** = UNCHECKED (file is already in project)
   - ✅ **"Create groups"** = SELECTED (not folder references)
   - ✅ **"Add to targets: EchoWearWatch"** = CHECKED ⬅️ MOST IMPORTANT!
7. Click **"Add"**

**✅ Verify:**
- `EchoWearWatchApp.swift` now appears under `EchoWearWatch` folder in Xcode
- File has a document icon (not gray)
- When you click it, you can see the code

#### 4.3 Verify Build Membership

Double-check the file is in the build:

1. Select `EchoWearWatchApp.swift` in Project Navigator
2. Open **File Inspector** (right sidebar, first tab icon)
3. Scroll to **"Target Membership"** section
4. ✅ Verify: `EchoWearWatch` has a checkmark

If no checkmark:
- Check the box next to `EchoWearWatch`
- ⌘S to save

---

### Step 5: Configure Watch App Settings

#### 5.1 Select Watch Target

1. Click **EchoWear** (blue project icon) in left sidebar
2. In the targets list, select **EchoWearWatch**

#### 5.2 General Tab Settings

In the **General** tab:

| Setting | Value |
|---------|-------|
| **Display Name** | `EchoWear` |
| **Bundle Identifier** | `com.Arsalan.echowear.watchkitapp` |
| **Version** | `1.0` |
| **Build** | `1` |
| **Deployment Target** | watchOS 9.0 (or higher) |

#### 5.3 Signing & Capabilities Tab

1. Click **"Signing & Capabilities"** tab
2. **Automatically manage signing:** ✅ Check this
3. **Team:** Select your Apple Developer team
   - If you see "No accounts", add your Apple ID:
     - Xcode → Settings → Accounts → + → Apple ID
4. **Bundle Identifier:** Should show `com.Arsalan.echowear.watchkitapp`

**Note:** For local testing, automatic signing with a free Apple ID works fine.

#### 5.4 Add Required Capabilities

Our watch app needs microphone and speech recognition.

Still in **Signing & Capabilities** tab:

1. Click **"+ Capability"** button (top left)
2. Type: "Microphone"
   - Hmm, there's no "Microphone" capability (it's automatic)
3. Actually, watchOS apps automatically request permissions via Info.plist

**Skip this step** - permissions are handled in code.

---

### Step 6: Add Info.plist Entries

Watch apps need permission descriptions too.

#### 6.1 Find Watch App Info.plist

The `EchoWearWatch-Info.plist` should have been created. If not:

1. In Project Navigator, expand `EchoWearWatch` folder
2. Look for `Info.plist` or `EchoWearWatch-Info.plist`

If it doesn't exist, create it:
- File → New → File
- iOS → Resource → Property List
- Name: `Info.plist`
- Make sure it's in the `EchoWearWatch` folder

#### 6.2 Add Permission Keys

**Option A: Using Xcode GUI**

1. Select `Info.plist` in EchoWearWatch folder
2. Right-click in the property list → "Add Row"
3. Add these keys:

| Key | Type | Value |
|-----|------|-------|
| `NSMicrophoneUsageDescription` | String | `EchoWear needs microphone access for voice monitoring.` |
| `NSSpeechRecognitionUsageDescription` | String | `EchoWear uses speech recognition to detect keywords and your name.` |

**Option B: Using Source Code**

1. Right-click `Info.plist` → "Open As" → "Source Code"
2. Add inside `<dict>`:

```xml
<key>NSMicrophoneUsageDescription</key>
<string>EchoWear needs microphone access for voice monitoring.</string>
<key>NSSpeechRecognitionUsageDescription</key>
<string>EchoWear uses speech recognition to detect keywords and your name.</string>
```

**✅ Verify:** Both keys appear in the Info.plist.

---

### Step 7: Build the Watch App

Time to test if everything works!

#### 7.1 Select Watch Scheme

1. At the top of Xcode (scheme selector), click the current scheme
2. Select **"EchoWearWatch"**
3. Next to it, select a watch simulator:
   - **Apple Watch Series 9 (45mm)** (recommended)
   - Or any other watch simulator

#### 7.2 Build Only (Check for Errors)

```
Press: ⌘B (Command + B)
```

Watch the build progress at the top of Xcode.

**Expected outcome:** "Build Succeeded" ✅

**If build fails**, see Troubleshooting section below.

#### 7.3 Run on Watch Simulator

```
Press: ⌘R (Command + R)
```

What should happen:
1. Watch Simulator app opens (may take 30-60 seconds)
2. Xcode installs EchoWear on the simulated watch
3. App launches automatically
4. You should see:
   - EchoWear splash screen (1.2 seconds)
   - Sign-in screen with username/password fields
   - "Remember me" checkbox
   - "Sign In" button

**✅ Success!** Your watch app is now integrated!

---

### Step 8: Test Watch App Features

#### 8.1 Test Sign-In

1. In the watch simulator, enter any credentials:
   - Username: `test`
   - Password: `test`
2. Check "Remember me"
3. Tap "Sign In"
4. ✅ Should navigate to main app (Home and Profile tabs)

#### 8.2 Test Voice Monitoring

1. Go to **Home** tab
2. Tap **"Start Listening"** button
3. **Speak into your Mac's microphone**
4. ✅ Should see transcription appear
5. Say "hello" or "hey"
6. ✅ Watch simulator may not vibrate, but you should see keyword detection in logs

#### 8.3 Check Console Logs

Open Debug Area:
```
Press: ⌘⇧Y (Command + Shift + Y)
```

You should see logs like:
```
🎤 Listening started (max 30s, silence threshold 5s)...
[Transcription text appears]
👋 Keyword detected: hello
⏱️ Listening timeout: stopped after 30 seconds
🛑 Stopped listening
```

---

### Step 9: Verify Watch Scheme Appears

The final check:

1. Click on the scheme selector (top of Xcode)
2. ✅ Verify you see:
   - EchoWearios (iOS)
   - **EchoWearWatch** (watchOS) ⬅️ This is new!
   - EchoWear (legacy)

**Success!** The watch scheme now appears in Xcode!

---

### Step 10: Commit Changes

Now that everything works, commit the changes:

```bash
cd /path/to/EchoWear
git add .
git commit -m "Add EchoWearWatch target to Xcode project"
git push origin main
```

This will update your project file with the new watch target.

---

## ✅ Verification Checklist

Once you've completed all steps:

- [ ] EchoWearWatch scheme appears in Xcode scheme selector
- [ ] Can select watch simulators (Apple Watch Series 9, etc.)
- [ ] Build succeeds with 0 errors (⌘B)
- [ ] Can run watch app on simulator (⌘R)
- [ ] Watch app shows splash screen and sign-in
- [ ] Can sign in and see main app
- [ ] Voice monitoring starts when tapping "Start Listening"
- [ ] Can see transcription when speaking into Mac mic
- [ ] Console shows listening logs
- [ ] Changes committed to git

---

## 🐛 Troubleshooting

### Issue: Build Fails with "@main attribute" Error

**Error:**
```
'@main' attribute cannot be applied to this declaration
```

**Solution:**
1. Open `EchoWearWatchApp.swift`
2. Make sure the main app struct has `@main`:
```swift
@main
struct EchoWearWatchApp: App {
    var body: some Scene {
        WindowGroup {
            SplashView()
        }
    }
}
```

---

### Issue: "Cannot find type 'SpeechMonitor' in scope"

**Cause:** Watch app code references classes that exist but aren't being found.

**Solution:**
1. Check that `EchoWearWatchApp.swift` is added to EchoWearWatch target
2. Select the file → File Inspector → Target Membership → Check `EchoWearWatch`

---

### Issue: Watch Scheme Still Not Appearing

**Solutions to try:**

1. **Restart Xcode:**
   ```
   Xcode → Quit Xcode
   Reopen: open EchoWear.xcodeproj
   ```

2. **Check Scheme Management:**
   - Product → Scheme → Manage Schemes
   - Verify `EchoWearWatch` is in the list
   - Make sure "Show" checkbox is checked

3. **Clean and Rebuild:**
   ```
   Product → Clean Build Folder (⌘⇧K)
   Product → Build (⌘B)
   ```

---

### Issue: No Watch Simulators Available

**Solution:**

1. Xcode → Settings (⌘,)
2. Click **"Platforms"** tab
3. Find **watchOS** platform
4. Click **"Get"** or download icon to install watchOS simulator
5. Wait for download to complete
6. Restart Xcode

---

### Issue: Build Succeeds But Watch App Won't Launch

**Solutions:**

1. **Check Bundle Identifier:**
   - Select EchoWearWatch target
   - General tab → Bundle Identifier should be: `com.Arsalan.echowear.watchkitapp`

2. **Check Deployment Target:**
   - General tab → Minimum Deployments → should be watchOS 9.0 or higher
   - Make sure selected simulator matches (don't use watchOS 7 simulator with watchOS 9 target)

---

### Issue: "Signing for 'EchoWearWatch' requires a development team"

**Solution:**

1. Select EchoWearWatch target
2. Signing & Capabilities tab
3. Add your Apple ID:
   - Team dropdown → "Add an Account..."
   - Sign in with Apple ID
4. Select your team from dropdown

---

### Issue: Watch App Has No Icon

**Expected:** This is normal. We haven't added app icons yet.

**To fix later:**
1. Prepare watch app icons (various sizes)
2. Add to `EchoWearWatch/Assets.xcassets`
3. Create AppIcon set

---

## 🎯 What's Next?

### After Watch App is Working

1. **Test on Real Apple Watch:**
   - Pair Apple Watch with your iPhone
   - Run watch app on physical device
   - Test haptic feedback (doesn't work in simulator)

2. **Include in TestFlight Build:**
   - Push changes to GitHub
   - GitHub Actions will automatically build both iOS + Watch apps
   - Both will appear in TestFlight

3. **Deploy to TestFlight:**
   - Follow [QUICK_START.md](QUICK_START.md) for deployment
   - Watch app automatically included with iOS app

---

## 📊 Before vs. After

### Before (Current State)
```
Xcode Schemes:
├── EchoWearios ✅ (iOS)
└── EchoWear ✅ (legacy)

Disk Files:
├── EchoWearios/ ✅ (in project)
└── EchoWearWatch/ ❌ (orphaned - not in project)
```

### After (Fixed)
```
Xcode Schemes:
├── EchoWearios ✅ (iOS)
├── EchoWearWatch ✅ (Watch) ⬅️ NEW!
└── EchoWear ✅ (legacy)

Disk Files:
├── EchoWearios/ ✅ (in project)
└── EchoWearWatch/ ✅ (in project) ⬅️ FIXED!
```

---

## 📝 Summary

You've successfully:
- ✅ Added EchoWearWatch as a proper Xcode target
- ✅ Integrated existing watch app code
- ✅ Configured bundle ID and signing
- ✅ Built and tested on watch simulator
- ✅ Verified watch scheme appears in Xcode

**Your watch app is now fully integrated!**

---

## 🆘 Still Having Issues?

If you're stuck:
1. Check that you're using Xcode 15.0+
2. Verify macOS 13.0+
3. Try cleaning build folder (⌘⇧K) and rebuilding
4. Restart Xcode
5. Check that `EchoWearWatchApp.swift` exists in `EchoWear/EchoWear/EchoWearWatch/`

---

**Good luck! You've got this! 🚀**
