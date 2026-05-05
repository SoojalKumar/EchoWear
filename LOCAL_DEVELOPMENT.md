# 🖥️ EchoWear - Local Development Guide (Xcode)

Complete step-by-step instructions for running EchoWear on your Mac with Xcode.

---

## ✅ Prerequisites

Before starting, ensure you have:
- [ ] macOS 13.0 or later
- [ ] Xcode 15.0 or later installed
- [ ] An Apple ID (free tier works for local development)
- [ ] iPhone/iPad for testing (or use Simulator)

---

## 📦 Step 1: Get the Project Files

### Option A: If You Have the Project Locally
```bash
# Navigate to your project directory
cd /path/to/EchoWear

# Verify files exist
ls -la
```

### Option B: Clone from GitHub
```bash
# Clone repository
git clone https://github.com/YOURUSERNAME/echowear.git
cd echowear

# Verify clone was successful
ls -la
```

---

## 🔧 Step 2: Add Authentication Files to Build Target

**⚠️ CRITICAL STEP - App won't compile without this!**

### 2.1 Open Project in Xcode
```bash
# From project directory, open Xcode project
open EchoWear.xcodeproj
```

Alternatively:
- Open Xcode app
- File → Open
- Navigate to `EchoWear.xcodeproj`
- Click "Open"

### 2.2 Add AuthenticationManager.swift

1. **Locate the file in Finder:**
   - In Xcode, right-click on `EchoWearios` folder in left sidebar
   - Select "Show in Finder"
   - You should see `AuthenticationManager.swift` in the folder

2. **Add to build target:**
   - In Xcode left sidebar, right-click on `EchoWearios` folder
   - Select **"Add Files to 'EchoWear'..."**
   - Navigate to: `EchoWear/EchoWearios/AuthenticationManager.swift`
   - **IMPORTANT:** Check ✅ **"Add to targets: EchoWearios"**
   - Click **"Add"**

3. **Verify it was added:**
   - Click on project name (EchoWear) in left sidebar
   - Select **EchoWearios** target
   - Go to **Build Phases** tab
   - Expand **"Compile Sources"**
   - Verify `AuthenticationManager.swift` is in the list

### 2.3 Add ModernSignInView.swift

Repeat the same steps for `ModernSignInView.swift`:
1. Right-click `EchoWearios` folder → "Add Files to 'EchoWear'..."
2. Navigate to: `EchoWear/EchoWearios/ModernSignInView.swift`
3. **Check ✅ "Add to targets: EchoWearios"**
4. Click "Add"
5. Verify in Build Phases → Compile Sources

---

## 🔐 Step 3: Configure Code Signing

### 3.1 Select Your Team

1. Click on **EchoWear** project in left sidebar
2. Select **EchoWearios** target
3. Go to **Signing & Capabilities** tab
4. Under "Team", select your Apple ID account
   - If no team appears, click "Add Account..." and sign in with your Apple ID
5. Xcode will automatically manage signing

### 3.2 Update Bundle Identifier (Optional)

If you see signing errors:
1. In **Signing & Capabilities** tab
2. Change **Bundle Identifier** to something unique:
   ```
   com.YOURNAME.echowear
   ```
   (Replace YOURNAME with your name or username)

---

## ✨ Step 4: Enable "Sign in with Apple" Capability

**Required for Apple Sign In to work!**

1. Still in **Signing & Capabilities** tab
2. Click **+ Capability** button (top left)
3. Search for **"Sign in with Apple"**
4. Double-click to add it
5. You should see "Sign in with Apple" appear in the capabilities list

---

## 🔨 Step 5: Build the Project

### 5.1 Select Target Device

At the top of Xcode, next to the Run/Stop buttons:
- Click on the device selector (shows "Any iOS Device" or current device)
- Choose one:
  - **iPhone 15 Pro** (Simulator) - for testing without a physical device
  - **Your iPhone** - if connected via USB

### 5.2 Build the Project

**Option A: Using Keyboard Shortcut**
```
Press: ⌘B (Command + B)
```

**Option B: Using Menu**
- Product → Build

**Option C: Using Toolbar**
- Click the **Play** button (▶️) at top left

### 5.3 Wait for Build to Complete

- Watch the progress bar at top of Xcode window
- Build time: ~30 seconds (first build), ~5-10 seconds (subsequent builds)
- **Success:** You'll see "Build Succeeded" in the status bar
- **Failure:** Red errors will appear in the left sidebar

### 5.4 Troubleshooting Build Errors

**Error: "Cannot find type 'AuthenticationManager' in scope"**
- ✅ **Solution:** Go back to Step 2 and add auth files to build target

**Error: "No signing certificate"**
- ✅ **Solution:** Go to Signing & Capabilities → Select your team

**Error: "Failed to register bundle identifier"**
- ✅ **Solution:** Change Bundle Identifier to something unique

---

## 🚀 Step 6: Run on Simulator

### 6.1 Select Simulator
```
Top toolbar → Device selector → Choose "iPhone 15 Pro"
```

### 6.2 Run the App
```
Press: ⌘R (Command + R)
```

Or click the **Play** button (▶️)

### 6.3 Wait for Simulator to Launch

1. Simulator app will open (may take 30-60 seconds first time)
2. Xcode will install the app on simulator
3. App will launch automatically

### 6.4 Test the App

You should see:
1. **Splash screen** (1.2 seconds)
2. **Sign-in screen** with:
   - "Sign in with Apple" button (black)
   - "Continue with Google" button (white)
   - Email/Password form

---

## 📱 Step 7: Run on Real iPhone/iPad

### 7.1 Connect Your Device
1. Connect iPhone/iPad to Mac via USB cable
2. Unlock your device
3. If prompted, tap **"Trust This Computer"** on device
4. Enter device passcode

### 7.2 Select Your Device
```
Top toolbar → Device selector → Choose your iPhone/iPad
```

### 7.3 Run the App
```
Press: ⌘R (Command + R)
```

### 7.4 First-Time Setup on Device

If this is your first time running an app from this Apple ID:
1. On your iPhone/iPad, go to **Settings**
2. **General** → **VPN & Device Management**
3. Find your Apple ID email
4. Tap **"Trust [Your Apple ID]"**
5. Tap **"Trust"** in confirmation dialog
6. Go back to Xcode and run again (⌘R)

### 7.5 Grant Permissions

When app launches, you'll be prompted:
1. **Microphone Access** → Tap "Allow"
2. **Speech Recognition** → Tap "OK"

---

## 🧪 Step 8: Test Features

### Test Authentication

**Apple Sign In (ONLY works on real device, NOT simulator):**
1. Tap "Sign in with Apple"
2. Face ID / Touch ID prompt
3. Sign in with Apple ID
4. ✅ Should return to main app

**Email/Password:**
1. Enter email: `test@example.com`
2. Enter password: `password123`
3. Tap "Sign In"
4. ✅ Account created + signed in

**Sign Out:**
1. Go to Profile tab
2. Tap "Sign Out" button
3. Confirm
4. ✅ Returns to sign-in screen

### Test Voice Monitoring

1. **Sign in** (if not already)
2. Go to **Home** tab
3. Tap **"Start Listening"** button
4. **Grant permissions** if prompted
5. You should see:
   - 🔴 **"Live"** indicator appears
   - Text transcription as you speak
6. Try saying **"hello"** or **"hey"**
   - ✅ Phone should vibrate
   - ✅ Keyword badge appears (👋 hello)
7. Try saying your name (default: "Soojal")
   - ✅ Phone vibrates
   - ✅ Sound plays
   - ✅ Name badge appears (👤 Soojal)
8. Stop speaking for 5 seconds
   - ✅ Should auto-stop (silence detection)

### Test Settings

1. Go to **Profile** tab
2. Tap **"Voice Monitor Settings"**
3. Change your name
4. Adjust sliders:
   - Max Duration: 10s - 120s
   - Silence Threshold: 3s - 20s
5. Tap **"Done"**
6. ✅ Settings saved

---

## 🐛 Step 9: Debug Mode (Optional)

### View Console Logs

1. While app is running, open **Console**
2. View → Debug Area → Show Debug Area (⌘⇧Y)
3. You'll see detailed logs:
   ```
   🎤 Listening started (max 30s, silence threshold 5s)...
   👋 Keyword detected: hello
   🤫 Silence detected: stopping after 5 seconds
   🛑 Stopped listening
   ```

### Set Breakpoints

1. Click on line number in code (blue arrow appears)
2. Run app (⌘R)
3. When that line executes, app pauses
4. Inspect variables in Debug Area

---

## 🔄 Step 10: Making Changes

### Edit Code
1. Make changes in Xcode editor
2. Save (⌘S)
3. Build and run (⌘R)
4. Xcode automatically rebuilds changed files

### Hot Tips:
- **⌘B** = Build only (check for errors)
- **⌘R** = Build + Run
- **⌘.** = Stop running app
- **⌘⇧K** = Clean build folder (if issues)

---

## 📝 Step 11: Commit Your Changes (After Testing)

After adding files to build target:

```bash
# Check what changed
git status

# Stage all changes
git add .

# Commit with message
git commit -m "Add authentication files to build target"

# Push to GitHub (optional)
git push origin main
```

---

## ❓ Common Issues & Solutions

### Issue: "Build Failed" with Many Errors
**Solution:**
```bash
# Clean build folder
In Xcode: Product → Clean Build Folder (⌘⇧K)
# Then rebuild (⌘B)
```

### Issue: "Simulator Not Responding"
**Solution:**
```bash
# Reset simulator
Device → Erase All Content and Settings...
# Or restart simulator: Device → Restart
```

### Issue: "App Crashes on Launch"
**Solution:**
1. Check Console logs (⌘⇧Y)
2. Look for error messages
3. Common causes:
   - Missing permissions in Info.plist ✅ Already fixed
   - Build target issues ✅ Fixed in Step 2

### Issue: "Cannot Find AuthenticationManager"
**Solution:**
1. Go to Step 2 and verify files are in build target
2. Check Build Phases → Compile Sources
3. Both files should be listed there

### Issue: "Apple Sign In Not Working"
**Expected:** Apple Sign In only works on **real devices**, not simulator
- Use Email/Password on simulator
- Use Apple Sign In on real iPhone/iPad

---

## 🎯 Quick Command Reference

```bash
# Open project
open EchoWear.xcodeproj

# Build
⌘B

# Build and Run
⌘R

# Stop
⌘.

# Clean build
⌘⇧K

# Show/Hide Debug Area
⌘⇧Y

# Show/Hide Navigator
⌘0

# Show/Hide Inspector
⌘⌥0
```

---

## 🚀 Next Steps After Local Testing

Once everything works locally:

1. **Commit changes:**
   ```bash
   git add .
   git commit -m "Configure for local development"
   git push
   ```

2. **Deploy to TestFlight** (optional):
   - Follow [QUICK_START.md](QUICK_START.md)
   - Test on multiple devices
   - Share with beta testers

3. **Continue development:**
   - Add new features
   - Fix bugs
   - Test locally first
   - Then push to GitHub

---

## 📚 Additional Resources

- **Xcode Shortcuts:** Help → Keyboard Shortcuts
- **Apple Developer Docs:** https://developer.apple.com/documentation/
- **SwiftUI Tutorials:** https://developer.apple.com/tutorials/swiftui
- **Speech Framework:** https://developer.apple.com/documentation/speech

---

## ✅ Checklist: First Time Setup

- [ ] Xcode 15.0+ installed
- [ ] Project opened in Xcode
- [ ] AuthenticationManager.swift added to build target
- [ ] ModernSignInView.swift added to build target
- [ ] Team selected in Signing & Capabilities
- [ ] "Sign in with Apple" capability added
- [ ] Build succeeded (⌘B)
- [ ] App runs on Simulator (⌘R)
- [ ] App runs on real device (⌘R)
- [ ] All features tested
- [ ] Changes committed to git

---

**🎉 Congratulations! You're now running EchoWear locally in Xcode!**

For deployment to TestFlight, see [QUICK_START.md](QUICK_START.md).
