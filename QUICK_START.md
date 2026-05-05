# EchoWear - Quick Start (Windows to TestFlight)

## What You Need (Checklist)

- [ ] Apple Developer Account ($99/year) - https://developer.apple.com
- [ ] GitHub Account (free) - https://github.com
- [ ] iPhone for testing
- [ ] 30 minutes of setup time

---

## 6-Step Setup

### ⚠️ Step 0: Xcode Setup (CRITICAL - 5 mins)
**⚠️ MUST BE DONE FIRST IN XCODE ON A MAC**

See [XCODE_SETUP_REQUIRED.md](XCODE_SETUP_REQUIRED.md) for detailed instructions.

**Quick Steps**:
1. Open `EchoWear.xcodeproj` in Xcode (use MacinCloud if needed)
2. Add `AuthenticationManager.swift` to build target
3. Add `ModernSignInView.swift` to build target
4. Enable "Sign in with Apple" capability
5. Build to verify (⌘B) - should succeed with 0 errors
6. Commit and push changes

**Why?** These authentication files exist but aren't in the build target yet.

---

### 📱 Step 1: Apple Setup (10 mins)
1. **Create Bundle ID**:
   - Go to https://developer.apple.com/account
   - Identifiers → + → App IDs
   - Bundle ID: `com.YOURNAME.echowear`
   - ✅ Enable "Speech Recognition"
   - ✅ Enable "Sign in with Apple" ⬅️ **NEW**

2. **Create App**:
   - Go to https://appstoreconnect.apple.com
   - My Apps → + → New App
   - Name: EchoWear
   - Use Bundle ID from above

3. **Get Certificates** (EASIEST METHOD):
   - Use https://macincloud.com ($1 trial)
   - Or borrow a Mac for 15 minutes
   - In Xcode: Preferences → Accounts → Manage Certificates → + → Apple Distribution
   - Export certificate as `.p12` (set a password!)

4. **Create Provisioning Profile**:
   - developer.apple.com → Profiles → + → App Store
   - Select your app → Download `.mobileprovision`

5. **Get App-Specific Password**:
   - https://appleid.apple.com → Security
   - Generate password, label it "GitHub"

---

### 🐙 Step 2: Push to GitHub (5 mins)
```bash
cd d:\EchoWear
git init
git add .
git commit -m "Initial commit"
git branch -M main

# Create repo on GitHub, then:
git remote add origin https://github.com/YOURUSERNAME/echowear.git
git push -u origin main
```

---

### 🔐 Step 3: Add Secrets to GitHub (10 mins)

Go to: `github.com/YOURUSERNAME/echowear` → Settings → Secrets → New secret

**Encode files first (Git Bash on Windows)**:
```bash
base64 -w 0 echowear.p12 > cert.txt
base64 -w 0 profile.mobileprovision > profile.txt
```

| Secret Name | Value |
|-------------|-------|
| `BUILD_CERTIFICATE_BASE64` | Contents of `cert.txt` |
| `P12_PASSWORD` | Password you set for `.p12` |
| `BUILD_PROVISION_PROFILE_BASE64` | Contents of `profile.txt` |
| `KEYCHAIN_PASSWORD` | Make up any password |
| `TEAM_ID` | Find at developer.apple.com (top right) |
| `PROVISIONING_PROFILE_NAME` | Name you gave the profile |
| `APPLE_ID` | Your Apple ID email |
| `APPLE_APP_SPECIFIC_PASSWORD` | From Step 1.5 |

---

### 🔧 Step 4: Update Bundle ID (3 mins)

Edit `d:\EchoWear\EchoWear.xcodeproj\project.pbxproj`:

Find and replace:
- `PRODUCT_BUNDLE_IDENTIFIER = com.example.app;` → `PRODUCT_BUNDLE_IDENTIFIER = com.YOURNAME.echowear;`
- `DEVELOPMENT_TEAM = "";` → `DEVELOPMENT_TEAM = "YOUR_TEAM_ID";`

```bash
git add .
git commit -m "Update bundle ID"
git push
```

---

### 🚀 Step 5: Watch the Magic (15 mins)

1. Go to `github.com/YOURUSERNAME/echowear/actions`
2. Watch the build run
3. After ~15 minutes, check App Store Connect
4. Your app is in TestFlight!

---

## Install on iPhone

1. Download **TestFlight** app from App Store
2. In App Store Connect, add yourself as a tester
3. Accept email invitation
4. Install EchoWear from TestFlight

---

## What's New

### Version 3.0 - Authentication Update
- ✅ **Real Authentication** - Apple Sign In + Email/Password
- ✅ **Modern Sign-In UI** - Beautiful gradient design
- ✅ **Session Persistence** - Auto sign-in on app restart
- ✅ **Password Security** - SHA-256 hashing
- ✅ **Google Sign In UI** - Ready (simulated, needs SDK)

### Bug Fixes
- ✅ Fixed missing AudioToolbox import
- ✅ Removed dead code (old SignInView)
- ✅ Deleted duplicate EchoWearApp.swift
- ✅ Added permission descriptions (app was crashing)
- ✅ Fixed `SpeechListener` → `SpeechRecognizer` (wouldn't compile)
- ✅ Fixed function scope errors
- ✅ Added error handling for speech recognition
- ✅ Fixed memory leaks with `[weak self]`
- ✅ Properly deactivate audio session

### Smart Voice Monitoring
- ✅ Custom name detection with alerts
- ✅ Timer-based auto-stop (10-120s)
- ✅ Silence detection (3-20s)
- ✅ Enhanced keywords (hello, hey, help, emergency + name)
- ✅ Live indicator + keyword badges
- ✅ Voice Monitor Settings screen

See [FEATURES.md](FEATURES.md) for complete feature list.

---

## Costs

- **Apple Developer**: $99/year
- **GitHub Actions**: Free (10 min/month) then $0.08/min
- **Total**: ~$100/year

---

## Common Issues

**"Cannot find type 'AuthenticationManager' in scope"**
→ Auth files not in build target - complete Step 0 (Xcode setup)

**"No identity found"**
→ Regenerate certificate, re-encode, update `BUILD_CERTIFICATE_BASE64`

**"Invalid provisioning profile"**
→ Ensure profile includes your distribution certificate

**"Upload failed"**
→ Check `APPLE_APP_SPECIFIC_PASSWORD` is correct

**"Sign in with Apple not working in TestFlight"**
→ Enable "Sign in with Apple" capability in Xcode (Step 0)
→ Enable in Bundle ID on developer.apple.com

---

## Documentation Files

- **[XCODE_SETUP_REQUIRED.md](XCODE_SETUP_REQUIRED.md)** - Critical Xcode setup (do this first!)
- **[QUICK_START.md](QUICK_START.md)** - This file (5-step guide)
- **[TESTFLIGHT_SETUP.md](TESTFLIGHT_SETUP.md)** - Detailed TestFlight setup
- **[CHECKLIST.md](CHECKLIST.md)** - Complete setup checklist
- **[AUTHENTICATION_SETUP.md](AUTHENTICATION_SETUP.md)** - Auth system guide
- **[FEATURES.md](FEATURES.md)** - All app features
- **[CODE_REVIEW_FIXES.md](CODE_REVIEW_FIXES.md)** - Bug fixes details
- **[CHANGES.md](CHANGES.md)** - Complete changelog
- `.github/workflows/build-and-deploy.yml` - CI/CD workflow

---

**Ready?** Start with Step 0 (Xcode setup), then Step 1! 🎉

---

## Testing on TestFlight

Once installed, test these features:

### Authentication
- Sign in with Apple (Face ID/Touch ID)
- Sign in with email/password
- Sign out and auto sign-in

### Voice Monitoring
- Start listening → see "🔴 Live" indicator
- Speak "hello" or "hey" → vibration + badge
- Speak your name → vibration + sound + badge
- Watch auto-stop after silence (5s default)
- Access Voice Monitor Settings
- Adjust timers and name

See [CHECKLIST.md](CHECKLIST.md) for complete testing checklist.
