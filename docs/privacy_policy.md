# Privacy Policy

**App Name:** Lyfuber
**Effective Date:** July 18, 2026
**Last Updated:** July 18, 2026
**Company:** Lyfuber
**Contact Email:** support@gogodriver.us
**Website:** https://gogodriver.us
**Tutorial Video:** https://www.youtube.com/watch?v=7aZo_K3nI84

---

## Table of Contents

1. [Introduction](#1-introduction)
2. [Who This Policy Applies To](#2-who-this-policy-applies-to)
3. [Information We Collect](#3-information-we-collect)
4. [How We Collect Your Information](#4-how-we-collect-your-information)
5. [How We Use Your Information](#5-how-we-use-your-information)
6. [Location Data — Full Disclosure](#6-location-data--full-disclosure)
7. [Camera and Photo Library Access](#7-camera-and-photo-library-access)
8. [Audio and Device Storage](#8-audio-and-device-storage)
9. [How We Share Your Information](#9-how-we-share-your-information)
10. [Third-Party SDKs and Services](#10-third-party-sdks-and-services)
11. [Account Deletion and Your Data](#11-account-deletion-and-your-data)
12. [Data Retention Periods](#12-data-retention-periods)
13. [Data Security](#13-data-security)
14. [Push Notifications](#14-push-notifications)
15. [Local Storage on Your Device](#15-local-storage-on-your-device)
16. [Children's Privacy](#16-childrens-privacy)
17. [Your Privacy Rights and Choices](#17-your-privacy-rights-and-choices)
18. [International Data Transfers](#18-international-data-transfers)
19. [App Store and Play Store Data Disclosures](#19-app-store-and-play-store-data-disclosures)
20. [California Residents — CCPA / CPRA](#20-california-residents--ccpa--cpra)
21. [European Residents — GDPR](#21-european-residents--gdpr)
22. [Changes to This Policy](#22-changes-to-this-policy)
23. [Contact Us](#23-contact-us)

---

## 1. Introduction

Lyfuber ("we," "us," or "our") is committed to protecting your privacy. This Privacy Policy explains exactly what personal data we collect, why we collect it, how we use and protect it, who we share it with, how long we keep it, and what rights you have over it.

This policy applies whenever you use the **Lyfuber** mobile application ("App") on Android or iOS, or interact with any of our related backend services (collectively, the "Platform").

By creating an account or using the Platform, you confirm that you have read and understood this Privacy Policy. If you do not agree, please do not use the App.

This Privacy Policy must be read together with our Terms and Conditions.

---

## 2. Who This Policy Applies To

This policy covers all users of the Lyfuber Platform:

- **Riders** — users who request and pay for transportation services
- **Drivers** — users who offer and provide transportation services
- **Applicants** — users who have registered but are pending Driver document approval

It covers data collected through:
- The Lyfuber mobile App (Android and iOS)
- Our backend API at https://api.gogodriver.us
- Real-time Socket.IO WebSocket communication
- In-app WebView pages (e.g., payment gateway)
- Firebase Cloud Messaging (FCM) infrastructure
- Google Maps and Google Directions API integrations

---

## 3. Information We Collect

### 3.1 Information You Provide Directly

**Account Registration (all users):**
- Full legal name
- Email address (used for OTP verification and login)
- Phone number
- Password (stored as a hashed value — never in plaintext)
- Gender
- Date of birth
- Bio / About Me
- Home or default address

**Profile:**
- Profile photograph (selected from camera or photo library)

**Driver Verification Documents:**
- Driver's license photograph (front and back)
- Vehicle registration certificate image
- Vehicle insurance document image
- Vehicle photographs (exterior and interior)
- Vehicle details: make, model, year, license plate number, seat count, registration expiry date

**Financial Data:**
- Bank account details for Driver earnings withdrawals (bank name, account holder name, account number, bank code, country)
- Payment card information — processed entirely by our PCI-DSS compliant third-party payment processor. We do not store your card number, CVV, or expiry date on our servers.
- In-app wallet balance and transaction history

**User-Generated Content:**
- Post-ride star ratings and written reviews for Drivers
- Safety and incident reports submitted through the App
- Customer support messages and correspondence

### 3.2 Information Collected Automatically

**Precise GPS Location:**
- Real-time GPS coordinates (latitude and longitude) during active ride sessions
- Driver GPS coordinates while online and during active rides
- Pickup and drop-off GPS coordinates for each completed ride

**Device and Technical Data:**
- Unique device identifier (Device ID)
- Device operating system name and version (Android / iOS)
- App version number
- Firebase Cloud Messaging (FCM) token
- IP address at the time of API requests
- App session activity logs
- Crash reports and diagnostic error data

**Ride and Transaction Data:**
- Pickup and destination addresses
- GPS route traced during each ride
- Ride start time, end time, and total duration
- Distance traveled
- Fare amount charged per ride
- Cancellation events and cancellation rate
- Tip amounts sent and received

**Behavioral and Usage Data:**
- Full ride history (all completed trips)
- Payment and wallet transaction history
- Favorite Drivers list
- Driver online/offline status change history
- Ratings given and received
- In-app notification interaction logs

---

## 4. How We Collect Your Information

| Method | Data Collected |
|---|---|
| Registration and profile forms | Name, email, phone, password, DOB, gender, address, bio |
| Photo and file uploads | Profile photo, Driver license images, vehicle photos |
| Device GPS sensor | Real-time location coordinates during rides |
| Android foreground location service | Continuous GPS stream during active ride sessions |
| Socket.IO real-time WebSocket | Location updates, ride events, status changes |
| HTTPS REST API calls | All data exchanged between the App and our server |
| Firebase Core SDK | FCM token, Firebase app instance ID |
| SharedPreferences / local storage | Auth tokens, cached user profile, app settings |
| In-app WebView | Payment page interactions (processed by payment provider) |
| Crash and diagnostic logging | App errors, stack traces, session diagnostics |

---

## 5. How We Use Your Information

### 5.1 Providing Core Services
- Creating and managing user accounts with OTP email verification
- Matching Riders with nearby available Drivers using real-time GPS
- Displaying interactive maps, live Driver locations, and ride routes
- Processing ride bookings, Driver acceptances, ride status updates, and completions
- Calculating fares based on GPS-measured trip distance
- Processing in-app wallet top-ups, ride payments, tips, and Driver withdrawal requests
- Enabling Driver document submission, review, and approval

### 5.2 Safety and Security
- Verifying Driver licenses, vehicle registration, and insurance before approval
- Detecting and preventing fraudulent account activity and Platform abuse
- Investigating safety reports, complaints, and ride incidents
- Maintaining ride records for dispute resolution and safety investigations
- Authenticating all sessions using JWT tokens and OTP email verification

### 5.3 Communication
- Sending ride status push notifications (requested, accepted, en route, started, completed)
- Delivering wallet and payment confirmation notifications
- Sending account security alerts (password changes, unusual login activity)
- Responding to support requests
- Sending service-essential emails: OTP codes, password resets, policy change notices

### 5.4 Platform Improvement
- Analyzing aggregated, anonymized usage data to improve App features and performance
- Monitoring server reliability and App stability
- Diagnosing and resolving technical issues using crash reports

### 5.5 Legal Compliance
- Retaining financial and ride records as required by applicable law
- Responding to valid legal requests, court orders, and regulatory inquiries
- Enforcing our Terms and Conditions

---

## 6. Location Data — Full Disclosure

Location is the most sensitive data category in the Lyfuber App. The following is a complete and transparent disclosure of our location data practices.

### 6.1 Why Precise Location Is Necessary

Lyfuber cannot function without precise GPS access. Location is required to:
- Display your position on the map for pickup placement
- Find and match Drivers in your area
- Show Riders their Driver's live position during a ride
- Measure trip distance for accurate fare calculation
- Provide turn-by-turn navigation routes for Drivers
- Verify that rides were completed at the correct destination

Network-based (coarse) location is insufficient for these purposes.

### 6.2 Android — Foreground Location Service

On Android, the App uses a **foreground location service** during active ride sessions. In compliance with Google Play's User Data Policy and Android platform requirements:

- A **persistent, non-dismissable notification** is displayed on the user's device for the entire duration the foreground service is running
- The notification explicitly states that location is being collected, per Android's mandatory disclosure requirement for foreground location services
- The service is declared in the `AndroidManifest.xml` with `android:foregroundServiceType="location"`
- The App holds `FOREGROUND_SERVICE`, `FOREGROUND_SERVICE_LOCATION`, `ACCESS_FINE_LOCATION`, and `ACCESS_COARSE_LOCATION` permissions
- GPS is streamed approximately every 5–10 seconds while the service is active
- **The foreground service starts only when a ride becomes active and stops automatically when the ride ends (completed or cancelled)**

### 6.3 No Background Tracking Outside Rides

**We do not collect your location outside of active ride sessions.** There is no passive or silent background location tracking at any other time. Location collection is strictly scoped to active in-progress ride sessions only.

### 6.4 iOS — Location Permission

On iOS, the App requests **"When In Use"** location permission for Riders during active sessions. Drivers who wish to receive ride requests while the App is in the background may be asked to grant **"Always On"** location permission so their availability can be broadcast to nearby Riders.

All iOS location permission requests display Apple's standard permission dialog with a clear usage description that is fully consistent with the disclosures in this policy. The permission purpose strings in `Info.plist` match this policy.

### 6.5 Driver Location Sharing

When a Driver goes online, their GPS coordinates are periodically sent to our server and made visible to Riders on the nearby map. When matched, the Driver's live GPS position is shared exclusively with the matched Rider for the duration of the trip. No other party sees this data.

### 6.6 Location Data Transmission

All GPS data is transmitted over encrypted channels:
- HTTPS / TLS (REST API calls)
- WSS — WebSocket Secure (Socket.IO real-time stream)

### 6.7 Revoking Location Access

You may revoke location permissions at any time in your device Settings. Revoking location will disable core features. You can re-grant access at any time through Settings.

---

## 7. Camera and Photo Library Access

The App requests camera and photo library access only in the following specific, user-initiated contexts:

| Purpose | Users Affected | Permission |
|---|---|---|
| Upload profile photo | All users | Camera or Photo Library |
| Submit driver's license image | Drivers only | Camera or Photo Library |
| Submit vehicle registration image | Drivers only | Camera or Photo Library |
| Submit vehicle insurance image | Drivers only | Camera or Photo Library |
| Upload vehicle exterior / interior photos | Drivers only | Camera or Photo Library |

**What we do NOT do:**
- Access the camera or photo library at any time other than when you initiate an upload
- Scan, process, or transmit any media other than what you explicitly select
- Perform facial recognition, biometric analysis, or any AI processing on uploaded images
- Access your full photo library or media roll — only the specific file you select is accessed

Uploaded photos are transmitted over HTTPS to our server and stored only for their stated purpose: profile display or Driver document verification.

---

## 8. Audio and Device Storage

### 8.1 Audio

The App uses your device's audio output to play notification alert sounds — for example, an incoming ride request tone for Drivers.

**We do not access, record, or transmit any audio from your device's microphone.** Microphone permission is not requested by this App.

### 8.2 Device Storage

The App reads from and writes to device storage for:
- Caching map tile assets for faster offline rendering
- Temporarily storing profile images for display performance
- Saving local diagnostic log files (not transmitted without user action)

---

## 9. How We Share Your Information

We do not sell, rent, or trade your personal information to any third party for their own use.

### 9.1 Between Riders and Drivers During a Ride

To fulfill a matched trip, the following limited data is visible to each party:

**The Rider can see:**
- Driver's first name and profile photo
- Vehicle make, model, and license plate number
- Driver's real-time GPS location on the map
- Driver's average rating

**The Driver can see:**
- Rider's first name and profile photo
- Pickup and destination locations
- Rider's rating (if previously rated)

Phone numbers, email addresses, and full home addresses are never directly exposed between users.

### 9.2 With Our Service Providers

We share data with trusted vendors who act on our behalf solely to operate the Platform:

| Provider | Data Shared | Purpose |
|---|---|---|
| Google LLC (Maps, Firebase) | GPS coordinates, FCM token, map interactions | Mapping, routing, push notifications |
| Third-Party Payment Processor | Card data (handled directly), transaction amounts | Wallet top-ups, payment card processing |
| Cloud Hosting / Infrastructure | Encrypted app data | Server storage and compute |
| Crash and Diagnostics Tool | Device info, stack traces, error logs | App stability and bug resolution |

All service providers are contractually bound to process your data only for the purposes we specify and not for their own commercial use.

### 9.3 For Legal and Safety Purposes

We may disclose personal data when we have a good-faith belief it is necessary to:
- Comply with applicable law, court order, or valid government request
- Protect the rights, property, or safety of Lyfuber, our users, or the public
- Detect, investigate, or prevent fraud, security threats, or policy violations

### 9.4 Business Transfers

In a merger, acquisition, or asset sale, user data may be transferred. We will notify affected users via in-app notice or email if their data will be governed by a materially different privacy policy.

### 9.5 With Your Consent

We may share your data with other parties only when you have explicitly authorized us to do so.

---

## 10. Third-Party SDKs and Services

The following third-party SDKs and services are used in the Lyfuber App. Each may process certain data as described:

| SDK / Service | Provider | Purpose | Data Processed |
|---|---|---|---|
| Google Maps Flutter SDK | Google LLC | Interactive map display | Device location, map interactions |
| Google Directions API | Google LLC | Route and polyline calculation | Trip origin/destination coordinates |
| Google Geocoding API | Google LLC | Coordinates to readable address | GPS coordinates |
| Firebase Cloud Messaging | Google LLC | Push notification delivery | FCM device token, notification payload |
| Firebase Core | Google LLC | Firebase SDK initialization | Firebase app instance ID |
| Firebase Crashlytics | Google LLC | Crash reporting and diagnostics | Device model, OS version, stack traces |
| Socket.IO (Lyfuber server) | Lyfuber | Real-time ride events and live location | User ID, GPS data, ride status |
| Geolocator (Flutter plugin) | Open source | Reading device GPS | GPS coordinates |
| Flutter Foreground Task | Open source | Foreground location service (Android) | GPS coordinates |
| Flutter Compass | Open source | Device heading for map marker direction | Device orientation sensor |
| Image Picker (Flutter plugin) | Open source | Photo selection for upload | Camera and photo library access |
| WebView Flutter | Open source | In-app payment gateway pages | Payment page content (handled by processor) |
| Shared Preferences (Flutter) | Open source | Local device storage | Auth tokens, user preferences |
| Flutter Local Notifications | Open source | Foreground push notification display | Notification content |
| Permission Handler (Flutter) | Open source | Runtime permission requests | Permission status only |
| Audioplayers (Flutter plugin) | Open source | In-app audio alert playback | Audio output only — no recording |

Google services are additionally governed by:
- [Google Privacy Policy](https://policies.google.com/privacy)
- [Google Maps Platform Terms](https://cloud.google.com/maps-platform/terms)
- [Firebase Terms of Service](https://firebase.google.com/terms)

---

## 11. Account Deletion and Your Data

### 11.1 How to Delete Your Account

You have the right to permanently delete your Lyfuber account at any time through either of these methods:

**Method 1 — In-App (Recommended):**
Open the App → Go to **Settings** → Tap **Delete Account** → Confirm in the dialog

**Method 2 — Email Request:**
Send an email to support@gogodriver.us with the subject line:
`Account Deletion Request`
Include the email address associated with your account.

Both methods are available 24/7. Email requests are processed within 5 business days.

### 11.2 What Gets Deleted

After your deletion request is confirmed:

| Data | What Happens | Timeline |
|---|---|---|
| Account profile (name, email, phone, DOB, gender, bio, address) | Permanently deleted | Within 90 days |
| Profile photograph | Permanently deleted | Within 90 days |
| Location history tied to your account | Permanently deleted | Within 90 days |
| Behavioral and preference data | Permanently deleted | Within 90 days |
| FCM push notification token | Deregistered | Immediately |
| Active authentication sessions / JWT tokens | Invalidated | Immediately |
| Wallet balance (if not withdrawn) | Forfeited | At time of deletion |

**Note:** Any remaining wallet balance should be withdrawn before initiating deletion. Active rides must be completed or cancelled prior to account deletion.

### 11.3 Data Retained After Deletion

Certain records are retained after deletion as required by law or legitimate business necessity. This retained data is never used for marketing or profiling:

| Data | Reason for Retention | Retention Period |
|---|---|---|
| Ride records (dates, distances, fares) | Financial compliance and legal obligation | Up to 7 years |
| Payment and transaction records | Financial regulations | Up to 7 years |
| Safety and incident reports | Legal investigations | Up to 5 years |
| Driver verification documents | Transport regulatory compliance | 1 year post-deactivation |
| Customer support correspondence | Dispute resolution | Up to 3 years |

### 11.4 Deletion Is Permanent

Account deletion is irreversible. A deleted account cannot be restored or reactivated. To use Lyfuber again after deletion, you must register a new account.

---

## 12. Data Retention Periods

| Data Category | Retention Period |
|---|---|
| Account and profile data | Duration of active account + up to 90 days post-deletion |
| Ride history | Up to 3 years |
| Payment and transaction records | Up to 7 years (financial regulations) |
| Driver verification documents | Active period + 1 year post-deactivation |
| Precise GPS location data | Not stored beyond the associated active ride session |
| Safety and incident reports | Up to 5 years |
| Support messages | Up to 3 years |
| Crash logs and diagnostics | Up to 12 months |
| FCM push tokens | Until account deletion or system token refresh |

When retention periods expire, data is securely and permanently deleted or irreversibly anonymized.

---

## 13. Data Security

We apply the following technical and organizational security measures:

- **Encryption in transit:** All App-to-server communications use HTTPS/TLS encryption. Real-time Socket.IO streams use WSS (WebSocket Secure).
- **Password security:** User passwords are processed through a strong one-way hashing algorithm before storage. Plaintext passwords are never stored.
- **JWT session tokens:** All sessions are authenticated with signed, scoped JWT tokens that expire automatically.
- **OTP verification:** Account activation and password resets require email OTP confirmation before any change takes effect.
- **Payment security:** Payment card data is handled exclusively by our PCI-DSS compliant third-party processor. Lyfuber never handles or stores raw card numbers, CVV codes, or expiry dates.
- **Access control:** Access to user data on our production servers is restricted to verified authorized personnel with a legitimate business need.
- **API authentication:** Every API endpoint requires a valid JWT token. Unauthenticated requests are rejected with an error response.

Despite these safeguards, no digital system is completely immune to security risk. If we become aware of a data breach that materially affects your rights, we will notify affected users and relevant regulatory authorities as required by applicable law.

---

## 14. Push Notifications

We deliver push notifications using Firebase Cloud Messaging (FCM). At account registration, your device's FCM token is registered with our server and linked to your account.

**We send notifications for:**
- Ride requests (for Drivers), ride acceptance, Driver en route, ride started, ride completed (for Riders)
- Wallet top-up confirmation, payment receipts, Driver earnings credited
- Driver withdrawal request status updates
- Account security alerts (password changed, unusual login)
- General Platform announcements

**How to manage notifications:**
- **Android:** Settings → Apps → Lyfuber → Notifications
- **iOS:** Settings → Notifications → Lyfuber

Disabling push notifications may cause you to miss time-sensitive ride or safety alerts. Essential security communications (OTP codes, breach alerts) may still arrive via email even with push notifications disabled.

---

## 15. Local Storage on Your Device

The App uses **SharedPreferences** (Android) and equivalent secure local storage (iOS) to store the following data directly on your device:

- JWT authentication token (to keep you logged in between sessions)
- Cached user profile data (to speed up App loading)
- App settings and user preferences
- Temporary map tile and image cache

This data exists only on your device and is not accessible to any third party. You can delete it at any time by clearing the App's cache and data through your device Settings, or by uninstalling the App. Doing so will log you out of your account.

---

## 16. Children's Privacy

The Lyfuber Platform is intended exclusively for users aged **18 and older**. We do not knowingly collect, process, or store personal data from anyone under the age of 18.

If we learn that we have inadvertently collected data from a user under 18, we will delete that data as quickly as possible. If you are a parent or guardian who believes your child has registered on Lyfuber, please contact us immediately at support@gogodriver.us with the subject line `Minor Account Report`. We will investigate and respond within 72 hours.

---

## 17. Your Privacy Rights and Choices

Depending on where you live, you may have some or all of the following rights regarding your personal data:

### 17.1 Right to Access
You can request a summary or full copy of the personal data we hold about you. Profile, ride history, and transaction data are accessible directly in the App. For a complete export, email support@gogodriver.us.

### 17.2 Right to Correction
You can correct inaccurate or outdated personal data. Most profile fields are editable directly in the App. For fields not editable in the App, contact us.

### 17.3 Right to Deletion
You can request permanent deletion of your account and personal data. See Section 11 for full details. Use the in-app **Settings → Delete Account** or email support@gogodriver.us.

### 17.4 Right to Data Portability
You can request a copy of your data in a structured, machine-readable format. Email support@gogodriver.us with subject: `Data Portability Request`.

### 17.5 Right to Restrict Processing
You can request that we limit our processing of your data in certain circumstances, such as while a complaint or investigation is in progress.

### 17.6 Right to Withdraw Consent
Where our processing is based on your consent (e.g., push notifications, location access), you may withdraw consent at any time via your device Settings. Withdrawal may disable certain features.

### 17.7 How to Submit a Request
Email: support@gogodriver.us
We will verify your identity and respond within **30 days**.

---

## 18. International Data Transfers

Your data may be processed and stored on servers outside your country of residence. Our backend API operates under the domain gogodriver.us. Google Maps and Firebase services operate globally across multiple data centers.

We ensure that any cross-border data transfers are protected by appropriate legal safeguards, including standard contractual clauses or equivalent mechanisms as required by applicable data protection law.

By using the Platform, you acknowledge that your data may be transferred internationally as described here.

---

## 19. App Store and Play Store Data Disclosures

### 19.1 Google Play — Data Safety Section

The information declared in the Google Play Store Data Safety section for this App is consistent with this Privacy Policy. The data types declared include:

| Data Type | Collected | Shared | Purpose |
|---|---|---|---|
| Precise location | Yes | Yes (between matched Rider/Driver) | App functionality — core feature |
| Name | Yes | No | App functionality |
| Email address | Yes | No | App functionality, account management |
| Phone number | Yes | No | App functionality |
| User IDs (Device ID) | Yes | No | Analytics, fraud prevention |
| Payment info (via processor) | Yes | No | In-app purchases |
| Photos and videos | Yes | No | App functionality (profile, docs) |
| App interactions and crash logs | Yes | No | Analytics, App performance |
| Financial info (wallet, transactions) | Yes | No | In-app purchases |

All data collected is used for app functionality. No data is collected for tracking across apps or websites owned by other companies, and no data is sold.

### 19.2 Apple App Store — Privacy Nutrition Label

The data disclosed in the Apple App Store Privacy Nutrition Label for this App is consistent with this Privacy Policy. Key disclosures:

- **Data Used to Track You:** None. Lyfuber does not track users across third-party apps or websites.
- **Data Linked to You:** Precise location, contact info (name, email, phone), user content (photos, ratings), identifiers (device ID), usage data, purchase history, financial info.
- **Data Not Linked to You:** Crash data and diagnostic logs.

---

## 20. California Residents — CCPA / CPRA

If you are a California resident, the California Consumer Privacy Act (CCPA), as amended by the California Privacy Rights Act (CPRA), gives you specific rights over your personal information.

### 20.1 Your California Rights

- **Right to Know** — Know what personal information we collect, the sources, our business purpose, and who we share it with
- **Right to Delete** — Request deletion of personal information we have collected (see Section 11)
- **Right to Correct** — Request correction of inaccurate personal information
- **Right to Opt-Out of Sale/Sharing** — Opt out of the sale or sharing of personal information
- **Right to Limit Use of Sensitive Personal Information** — Limit our use of sensitive data (such as precise location) to what is necessary to provide requested services
- **Right to Non-Discrimination** — We will not discriminate against you for exercising any of these rights

### 20.2 We Do Not Sell Your Personal Information

**Lyfuber does not sell personal information to any third party for monetary or other valuable consideration.**

We do not share personal information with third parties for cross-context behavioral advertising.

### 20.3 Global Privacy Control (GPC)

Lyfuber recognizes and honors Global Privacy Control (GPC) signals to the extent required by California law. If your device or browser transmits a GPC opt-out signal, we treat that as a request to opt out of the sale or sharing of your personal information.

### 20.4 Personal Information Collected in the Last 12 Months

| CCPA Category | Examples | Collected |
|---|---|---|
| Identifiers | Name, email, phone number, device ID, IP address | Yes |
| Personal records | Home address, financial account details | Yes |
| Protected classifications | Gender, date of birth | Yes |
| Commercial information | Transaction history, ride history, wallet activity | Yes |
| Precise geolocation data | GPS coordinates during active ride sessions | Yes |
| Sensory / visual data | Profile photos, Driver license images, vehicle photos | Yes |
| Internet or network activity | App session logs, notification interactions, crash data | Yes |
| Inferences | Driver rating average, ride completion rate | Yes |

**Sensitive Personal Information:** Precise geolocation data is used exclusively for ride-matching and navigation — not for advertising, profiling, or any purpose beyond providing the core service.

To exercise your California privacy rights, contact: support@gogodriver.us

---

## 21. European Residents — GDPR

If you are in the European Economic Area (EEA), the United Kingdom, or Switzerland, the General Data Protection Regulation (GDPR) and equivalent national laws govern your personal data.

### 21.1 Data Controller

Lyfuber is the **Data Controller** for all personal data collected through the Platform.
Contact: support@gogodriver.us

### 21.2 Legal Bases for Processing

| Processing Activity | Legal Basis | GDPR Article |
|---|---|---|
| Account creation and authentication | Performance of a contract | Art. 6(1)(b) |
| Ride booking, matching, and fulfillment | Performance of a contract | Art. 6(1)(b) |
| GPS location tracking during rides | Contract performance + Legitimate interests (safety) | Art. 6(1)(b)(f) |
| Payment processing | Performance of a contract | Art. 6(1)(b) |
| Driver document verification | Legal obligation + Contract | Art. 6(1)(b)(c) |
| Push notifications | Consent | Art. 6(1)(a) |
| Fraud detection and account security | Legitimate interests | Art. 6(1)(f) |
| Legal compliance and record-keeping | Legal obligation | Art. 6(1)(c) |
| Platform analytics and crash reporting | Legitimate interests | Art. 6(1)(f) |

### 21.3 Your GDPR Rights

Beyond the rights in Section 17, you also have the right to:
- Object to processing based on legitimate interests
- Not be subject to solely automated decisions that significantly affect you
- Lodge a complaint with your national data protection supervisory authority (DPA) if you believe your data has been mishandled

### 21.4 Data Retention

See Section 12 for all retention periods. We do not retain personal data for longer than is necessary for the stated purpose or as required by applicable law.

---

## 22. Changes to This Policy

We may update this Privacy Policy when our data practices change, when we add new features, when laws change, or for other business reasons. When we make material changes we will:

- Display a prominent notice within the App
- Send a push notification or email to users
- Update the "Last Updated" date at the top of this document

Your continued use of the Platform after an updated policy takes effect means you accept the changes. If you do not accept an updated policy, stop using the App and delete your account.

---

## 23. Contact Us

**Lyfuber Privacy Team**
Email: support@gogodriver.us
Website: https://gogodriver.us

**Account deletion:** Email subject `Account Deletion Request`
**Data access or export:** Email subject `Data Access Request`
**Data correction:** Email subject `Data Correction Request`
**GDPR complaints:** Email subject `GDPR Complaint`
**CCPA requests:** Email subject `CCPA Privacy Request`

We respond to all verified privacy requests within **30 days**.

---

*Privacy Policy last updated: July 18, 2026*
*By using the Lyfuber App you confirm you have read and understood this Privacy Policy.*
