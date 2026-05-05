# EchoWear - TestFlight Setup Guide

This guide will help you set up GitHub Actions to automatically build your iOS app and deploy it to TestFlight from your Windows machine.

## Prerequisites

1. **Apple Developer Account** ($99/year)
   - Sign up at: https://developer.apple.com
   - Enroll in the Apple Developer Program

2. **App Store Connect Account**
   - Access at: https://appstoreconnect.apple.com
   - Use same Apple ID as Developer Account

3. **GitHub Account**
   - Sign up at: https://github.com (free)

---

## Part 1: App Store Connect Setup

### Step 1: Create App Bundle ID
1. Go to https://developer.apple.com/account
2. Click **Certificates, Identifiers & Profiles**
3. Click **Identifiers** → **+** (Add button)
4. Select **App IDs** → Continue
5. Fill in:
   - **Description**: EchoWear
   - **Bundle ID**: `com.yourcompany.echowear` (choose your own)
   - **Capabilities**: Enable "Speech Recognition"
6. Click **Continue** → **Register**

### Step 2: Create App in App Store Connect
1. Go to https://appstoreconnect.apple.com
2. Click **My Apps** → **+** → **New App**
3. Fill in:
   - **Platform**: iOS
   - **Name**: EchoWear
   - **Primary Language**: English (US)
   - **Bundle ID**: Select the one you created above
   - **SKU**: ECHOWEAR001 (any unique identifier)
4. Click **Create**

### Step 3: Create Distribution Certificate
1. Go to https://developer.apple.com/account
2. **Certificates, Identifiers & Profiles** → **Certificates** → **+**
3. Select **Apple Distribution** → Continue
4. **Create CSR on Windows:**
   - You'll need a Mac OR use OpenSSL on Windows
   - **OpenSSL method (Windows)**:
     ```bash
     # Install OpenSSL (via Git Bash or WSL)
     openssl req -new -newkey rsa:2048 -nodes -keyout echowear.key -out echowear.csr
     ```
   - Fill in details when prompted
   - **OR use a Mac/cloud Mac to generate CSR via Keychain Access**
5. Upload the `.csr` file
6. Download the certificate (`.cer` file)
7. Convert to `.p12` format:
   ```bash
   openssl x509 -in echowear.cer -inform DER -out echowear.pem -outform PEM
   openssl pkcs12 -export -inkey echowear.key -in echowear.pem -out echowear.p12
   ```
   - Set a password when prompted (save this!)

### Step 4: Create Provisioning Profile
1. Go to https://developer.apple.com/account
2. **Profiles** → **+** (Add button)
3. Select **App Store** under Distribution → Continue
4. Select your **App ID** (EchoWear) → Continue
5. Select your **Distribution Certificate** → Continue
6. Name it: `EchoWear AppStore Profile`
7. Click **Generate**
8. Download the `.mobileprovision` file

### Step 5: Create App-Specific Password
1. Go to https://appleid.apple.com
2. Sign in with your Apple ID
3. **Security** section → **App-Specific Passwords**
4. Click **+** (Generate)
5. Label it: `GitHub Actions`
6. Copy the password (save it - you can't see it again!)

---

## Part 2: GitHub Setup

### Step 1: Push Code to GitHub
```bash
cd d:\EchoWear
git init
git add .
git commit -m "Initial commit with TestFlight CI/CD"
git branch -M main
git remote add origin https://github.com/YOUR_USERNAME/echowear.git
git push -u origin main
```

### Step 2: Encode Certificates for GitHub Secrets
On Windows (using Git Bash or WSL):
```bash
# Encode certificate
base64 -w 0 echowear.p12 > certificate.txt

# Encode provisioning profile
base64 -w 0 EchoWear_AppStore_Profile.mobileprovision > profile.txt
```

### Step 3: Add GitHub Secrets
1. Go to your GitHub repo: `https://github.com/YOUR_USERNAME/echowear`
2. Click **Settings** → **Secrets and variables** → **Actions**
3. Click **New repository secret**
4. Add these secrets one by one:

| Secret Name | Value | Where to Find |
|-------------|-------|---------------|
| `BUILD_CERTIFICATE_BASE64` | Contents of `certificate.txt` | From Step 2 above |
| `P12_PASSWORD` | Password you set for `.p12` file | From Part 1, Step 3 |
| `BUILD_PROVISION_PROFILE_BASE64` | Contents of `profile.txt` | From Step 2 above |
| `KEYCHAIN_PASSWORD` | Any random password (e.g., `actions-keychain-pass`) | Make one up |
| `TEAM_ID` | Your Apple Team ID | https://developer.apple.com/account (top right) |
| `PROVISIONING_PROFILE_NAME` | `EchoWear AppStore Profile` | Exact name from Part 1, Step 4 |
| `APPLE_ID` | Your Apple ID email | Your Apple account email |
| `APPLE_APP_SPECIFIC_PASSWORD` | App-specific password | From Part 1, Step 5 |

---

## Part 3: Update Project Configuration

### Step 1: Update Bundle ID in Xcode Project
You need to update the project file with your actual Bundle ID. Since you're on Windows, edit the `.pbxproj` file:

1. Open in a text editor: `d:\EchoWear\EchoWear.xcodeproj\project.pbxproj`
2. Search for `PRODUCT_BUNDLE_IDENTIFIER`
3. Replace all instances with your Bundle ID: `com.yourcompany.echowear`
4. Save the file

### Step 2: Update Team ID
In the same `.pbxproj` file:
1. Search for `DEVELOPMENT_TEAM`
2. Replace with your Team ID (from Apple Developer portal)
3. Save the file

---

## Part 4: Trigger Build

### Option 1: Automatic (Push to main)
```bash
git add .
git commit -m "Configure bundle ID and team"
git push
```

### Option 2: Manual Trigger
1. Go to GitHub: `https://github.com/YOUR_USERNAME/echowear`
2. Click **Actions** tab
3. Select **Build and Deploy to TestFlight**
4. Click **Run workflow** → **Run workflow**

---

## Part 5: Monitor Build

1. Go to **Actions** tab on GitHub
2. Click on the running workflow
3. Watch the build progress (takes ~10-15 minutes)
4. If successful, the IPA will be uploaded to TestFlight

---

## Part 6: TestFlight Testing

### 1. Wait for Processing
- After upload, Apple processes the build (~5-30 minutes)
- Check status in App Store Connect

### 2. Add Test Information
1. Go to https://appstoreconnect.apple.com
2. Select **EchoWear** → **TestFlight** tab
3. Click on your build
4. Add **What to Test** notes
5. Add **Export Compliance** info (usually "No" for basic apps)

### 3. Add Testers
1. Click **TestFlight** → **Internal Testing**
2. Create a group (e.g., "Beta Testers")
3. Add testers by email
4. They'll receive an invitation email

### 4. Install TestFlight on iPhone
1. Download **TestFlight** app from App Store
2. Sign in with Apple ID
3. Accept invitation email
4. Install EchoWear

---

## Troubleshooting

### Build Fails: "Code signing error"
- **Solution**: Double-check all GitHub secrets, especially `P12_PASSWORD` and `BUILD_CERTIFICATE_BASE64`

### Build Fails: "No signing certificate"
- **Solution**: Ensure certificate is valid and not expired at https://developer.apple.com/account

### Upload Fails: "Invalid credentials"
- **Solution**: Regenerate App-Specific Password and update `APPLE_APP_SPECIFIC_PASSWORD` secret

### "Profile doesn't include signing certificate"
- **Solution**: Regenerate provisioning profile and include your distribution certificate

### Build succeeds but not in TestFlight
- **Solution**: Check App Store Connect → Activity tab for processing errors

---

## Costs

| Item | Cost |
|------|------|
| Apple Developer Account | $99/year |
| GitHub (free tier) | $0 |
| GitHub Actions (macOS runners) | 10 free minutes/month, then ~$0.08/minute |

**Estimate**: ~$100/year if you keep builds under 10 minutes

---

## Notes

- **First build** may take longer (15-20 minutes)
- **Subsequent builds** are faster (~10 minutes)
- **TestFlight builds** expire after 90 days
- **Max 10,000 external testers** per app
- **Max 100 internal testers** per app

---

## Next Steps

After your first successful TestFlight build:
1. Test the app thoroughly on real iPhone devices
2. Fix any bugs found
3. Push updates to GitHub (auto-builds new TestFlight versions)
4. When ready, submit to App Store for review

---

## Need Help?

- **Apple Developer Forums**: https://developer.apple.com/forums
- **GitHub Actions Docs**: https://docs.github.com/en/actions
- **TestFlight Guide**: https://developer.apple.com/testflight

Good luck! 🚀
