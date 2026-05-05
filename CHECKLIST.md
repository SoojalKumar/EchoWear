# EchoWear TestFlight Setup Checklist

Use this checklist to track your progress from Windows to TestFlight!

---

## ☑️ Pre-Setup

- [ ] I have an Apple ID
- [ ] I have a GitHub account
- [ ] I have an iPhone for testing
- [ ] I have $99 for Apple Developer Program
- [ ] I have read QUICK_START.md

---

## 📱 Part 1: Apple Developer Setup

### Step 1.1: Enroll in Apple Developer Program
- [ ] Go to https://developer.apple.com
- [ ] Click "Account"
- [ ] Enroll in Apple Developer Program ($99/year)
- [ ] Wait for enrollment confirmation (usually instant, can take up to 48h)

### Step 1.2: Create Bundle ID
- [ ] Go to https://developer.apple.com/account
- [ ] Certificates, Identifiers & Profiles
- [ ] Identifiers → + button
- [ ] Select App IDs → Continue
- [ ] Description: `EchoWear`
- [ ] Bundle ID: `com.YOURNAME.echowear` (write yours here: _______________)
- [ ] Enable capability: "Speech Recognition"
- [ ] Enable capability: "Sign in with Apple" ✅ **NEW**
- [ ] Click Continue → Register

### Step 1.3: Create App in App Store Connect
- [ ] Go to https://appstoreconnect.apple.com
- [ ] My Apps → + → New App
- [ ] Platform: iOS
- [ ] Name: `EchoWear`
- [ ] Primary Language: English (US)
- [ ] Bundle ID: Select the one from Step 1.2
- [ ] SKU: `ECHOWEAR001`
- [ ] Click Create

### Step 1.4: Generate Distribution Certificate
**Choose ONE method:**

**Option A: Use MacinCloud (Easiest for Windows)**
- [ ] Sign up at https://macincloud.com ($1 trial)
- [ ] Open Xcode on cloud Mac
- [ ] Xcode → Preferences → Accounts
- [ ] Add your Apple ID
- [ ] Manage Certificates → + → Apple Distribution
- [ ] Export certificate as `.p12`:
  - Right-click certificate → Export
  - Save as `echowear.p12`
  - Set password (write it here: _______________)
  - Download to your Windows machine

**Option B: Use OpenSSL on Windows**
- [ ] Install Git Bash (includes OpenSSL)
- [ ] Generate CSR:
  ```bash
  openssl req -new -newkey rsa:2048 -nodes -keyout echowear.key -out echowear.csr
  ```
- [ ] Go to https://developer.apple.com/account
- [ ] Certificates → + → Apple Distribution → Continue
- [ ] Upload `echowear.csr`
- [ ] Download certificate (`.cer` file)
- [ ] Convert to `.p12`:
  ```bash
  openssl x509 -in echowear.cer -inform DER -out echowear.pem -outform PEM
  openssl pkcs12 -export -inkey echowear.key -in echowear.pem -out echowear.p12
  ```
- [ ] Set password (write it here: _______________)

### Step 1.5: Create Provisioning Profile
- [ ] Go to https://developer.apple.com/account
- [ ] Profiles → + button
- [ ] Select: App Store (under Distribution) → Continue
- [ ] App ID: Select `EchoWear` → Continue
- [ ] Certificate: Select your Distribution certificate → Continue
- [ ] Profile Name: `EchoWear AppStore Profile`
- [ ] Click Generate
- [ ] Download `.mobileprovision` file

### Step 1.6: Get App-Specific Password
- [ ] Go to https://appleid.apple.com
- [ ] Sign in
- [ ] Security section → App-Specific Passwords
- [ ] Click + (Generate)
- [ ] Label: `GitHub Actions`
- [ ] Copy password (write it here: _______________)

### Step 1.7: Note Your Team ID
- [ ] Go to https://developer.apple.com/account
- [ ] Look at top right corner for Team ID
- [ ] Write it here: _______________

---

## 🐙 Part 2: GitHub Setup

### Step 2.1: Create GitHub Repository
- [ ] Go to https://github.com/new
- [ ] Repository name: `echowear`
- [ ] Visibility: Private (or Public)
- [ ] DO NOT initialize with README (we have one)
- [ ] Click Create repository

### Step 2.2: Push Code to GitHub
```bash
cd d:\EchoWear
git init
git add .
git commit -m "Initial commit with TestFlight CI/CD"
git branch -M main
git remote add origin https://github.com/YOURUSERNAME/echowear.git
git push -u origin main
```

- [ ] Run commands above
- [ ] Verify code is on GitHub

---

## 🔐 Part 3: Encode Files & Add Secrets

### Step 3.1: Encode Certificate and Profile
In Git Bash on Windows:
```bash
cd /d/EchoWear
base64 -w 0 echowear.p12 > cert.txt
base64 -w 0 EchoWear_AppStore_Profile.mobileprovision > profile.txt
```

- [ ] Run commands above
- [ ] Verify `cert.txt` and `profile.txt` exist

### Step 3.2: Add Secrets to GitHub
- [ ] Go to: `https://github.com/YOURUSERNAME/echowear/settings/secrets/actions`
- [ ] Click "New repository secret" for each:

| Secret Name | Value | Done? |
|-------------|-------|-------|
| `BUILD_CERTIFICATE_BASE64` | Contents of `cert.txt` | [ ] |
| `P12_PASSWORD` | Password from Step 1.4 | [ ] |
| `BUILD_PROVISION_PROFILE_BASE64` | Contents of `profile.txt` | [ ] |
| `KEYCHAIN_PASSWORD` | Make up: e.g., `actions-keychain-2024` | [ ] |
| `TEAM_ID` | Team ID from Step 1.7 | [ ] |
| `PROVISIONING_PROFILE_NAME` | `EchoWear AppStore Profile` | [ ] |
| `APPLE_ID` | Your Apple ID email | [ ] |
| `APPLE_APP_SPECIFIC_PASSWORD` | Password from Step 1.6 | [ ] |

---

## 🔧 Part 4: Xcode Setup (CRITICAL!)

### Step 4.1: Add Authentication Files to Build Target
**⚠️ MUST BE DONE IN XCODE ON A MAC**

See [XCODE_SETUP_REQUIRED.md](XCODE_SETUP_REQUIRED.md) for detailed instructions.

**Option A: If you have a Mac with Xcode (EASIEST)**
- [ ] Open `EchoWear.xcodeproj` in Xcode
- [ ] Add `AuthenticationManager.swift` to build:
  - Right-click `EchoWearios` folder → "Add Files to EchoWear..."
  - Navigate to `AuthenticationManager.swift`
  - ✅ Check "Add to targets: EchoWearios"
  - Click "Add"
- [ ] Add `ModernSignInView.swift` to build (same steps)
- [ ] Enable "Sign in with Apple" capability:
  - Select project → EchoWearios target
  - Signing & Capabilities tab
  - + Capability → "Sign in with Apple"
- [ ] Build to verify (⌘B) - should succeed with 0 errors
- [ ] Commit and push changes:
  ```bash
  git add .
  git commit -m "Add auth files to build target"
  git push
  ```

**Option B: Use MacinCloud Remote Mac**
- [ ] Sign up at https://macincloud.com ($1 trial)
- [ ] Upload project to cloud Mac
- [ ] Follow Option A steps on remote Mac

**Option C: Let GitHub Actions Handle It (ADVANCED)**
- [ ] Skip this step for now
- [ ] Push code and let me know if build fails
- [ ] I'll create a workflow fix

---

## 🔧 Part 5: Update Project Files

### Step 5.1: Update Bundle ID
- [ ] Open: `d:\EchoWear\EchoWear.xcodeproj\project.pbxproj` in text editor
- [ ] Search for: `PRODUCT_BUNDLE_IDENTIFIER`
- [ ] Replace all instances with your Bundle ID: `com.YOURNAME.echowear`
- [ ] Save file

### Step 5.2: Update Team ID
- [ ] In same file, search for: `DEVELOPMENT_TEAM`
- [ ] Replace empty values with your Team ID
- [ ] Save file

### Step 5.3: Commit Changes
```bash
cd d:\EchoWear
git add .
git commit -m "Update bundle ID and team for TestFlight"
git push
```

- [ ] Run commands above

---

## 🚀 Part 6: Build & Deploy

### Step 6.1: Monitor First Build
- [ ] Go to: `https://github.com/YOURUSERNAME/echowear/actions`
- [ ] Click on the running workflow
- [ ] Wait ~15 minutes for build to complete
- [ ] Check for green checkmarks ✅

### Step 6.2: Troubleshoot (if build fails)
If build fails, check:
- [ ] All GitHub secrets are correct
- [ ] `P12_PASSWORD` matches certificate password
- [ ] Bundle ID matches exactly
- [ ] Team ID is correct
- [ ] Certificate hasn't expired

### Step 6.3: Check App Store Connect
- [ ] Go to https://appstoreconnect.apple.com
- [ ] My Apps → EchoWear
- [ ] Click "TestFlight" tab
- [ ] Wait for build to appear (5-30 mins after upload)
- [ ] Check for "Processing" status

---

## 📲 Part 7: TestFlight Testing

### Step 7.1: Add Test Information
- [ ] In App Store Connect → TestFlight
- [ ] Click on your build
- [ ] Add "What to Test" notes
- [ ] Add Export Compliance info (usually select "No")
- [ ] Click Save

### Step 7.2: Add Yourself as Tester
- [ ] TestFlight → Internal Testing
- [ ] Create group: "Beta Testers"
- [ ] Add yourself by email
- [ ] Enable build for the group

### Step 7.3: Install on iPhone
- [ ] Download **TestFlight** app from App Store
- [ ] Sign in with your Apple ID
- [ ] Check email for invitation
- [ ] Accept invitation in TestFlight app
- [ ] Install EchoWear
- [ ] Test the app!

---

## ✅ Testing Checklist

Once app is installed:

### Authentication Tests
- [ ] App shows modern sign-in screen (not old fake sign-in)
- [ ] Can tap "Sign in with Apple" button
  - [ ] Face ID / Touch ID prompt appears
  - [ ] Successfully signs in
  - [ ] Returns to main app
- [ ] Can sign in with email/password
  - [ ] Enter valid email (e.g., test@example.com)
  - [ ] Enter password (min 6 chars)
  - [ ] Tap "Sign In" → account created + signed in
- [ ] Can sign out
  - [ ] Go to Profile tab
  - [ ] Tap "Sign Out" button
  - [ ] Confirm alert → returns to sign-in screen
- [ ] Auto sign-in works
  - [ ] Sign in, close app completely
  - [ ] Reopen app → automatically signed in (skip sign-in screen)

### Voice Monitoring Tests
- [ ] Can navigate between Home and Profile tabs
- [ ] Can tap "Start Listening" button
- [ ] App requests microphone permission
- [ ] App requests speech recognition permission
- [ ] See "🔴 Live" indicator when listening
- [ ] Can see transcribed text when speaking
- [ ] Says "hello" or "hey" → phone vibrates + keyword badge appears
- [ ] Says your name → phone vibrates + sound plays + keyword badge
- [ ] Listening auto-stops after silence (default 5s)
- [ ] Listening auto-stops after max duration (default 30s)
- [ ] Can manually stop listening
- [ ] Can access Voice Monitor Settings from Profile tab
- [ ] Can change your name in settings
- [ ] Can adjust max duration slider
- [ ] Can adjust silence threshold slider

### Other Features
- [ ] Watch card shows battery (hardcoded 86% is OK)
- [ ] Alert cards are visible
- [ ] Profile shows correct user info (name, email, provider icon)

---

## 🎉 Success!

- [ ] App runs on my iPhone via TestFlight
- [ ] No crashes
- [ ] Speech recognition works
- [ ] Ready to continue development

---

## 📝 Notes & Issues

Write any problems you encounter here:

_______________________________________________________________________________
_______________________________________________________________________________
_______________________________________________________________________________
_______________________________________________________________________________

---

## 🆘 Need Help?

If stuck:
1. Check TESTFLIGHT_SETUP.md for detailed troubleshooting
2. Check GitHub Actions logs for build errors
3. Check App Store Connect Activity tab for upload errors
4. Review all secrets are correct

---

**Good luck! You've got this! 🚀**
