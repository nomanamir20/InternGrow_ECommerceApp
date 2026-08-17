# InternGrow — E-Commerce Shopping App

> Task 2 of the InternGrow Mobile Development Internship.
> A complete shopping app built in Flutter, using Riverpod, the DummyJSON REST API,
> Firebase Auth, Firebase Cloud Messaging, and a full cart/checkout/wishlist flow.

🔗 **Live Demo (Web):** [interngrow-ecommerce-app.vercel.app](https://interngrow-ecommerce-app.vercel.app)
📱 **Download APK:** [Latest Release (v1.0.0)](https://github.com/nomanamir20/InternGrow_ECommerceApp/releases/download/v1.0.0/app-release.apk)

---

## ✨ Features

- [x] Product Listing — live product grid pulled from the DummyJSON REST API
- [x] Product Details — image carousel, quantity selector, wishlist toggle, add to cart
- [x] Categories — browse all categories, filter products by category
- [x] Search — debounced live search against the product catalog
- [x] Wishlist — save/remove products, persisted locally across sessions
- [x] Shopping Cart — quantity controls, line totals, persisted locally
- [x] Checkout UI — shipping form + simulated payment gateway UI with a live card preview
- [x] User Profile — account info, stats, dark mode toggle, logout

### Upgrade Features
- [x] API Integration — DummyJSON REST API (products, categories, search)
- [x] Payment Gateway UI — realistic card-entry flow; no real payment is processed
- [x] Push Notifications — Firebase Cloud Messaging, with an in-app banner for foreground messages and native OS notifications when backgrounded
- [x] Order History — every placed order persisted locally with full itemized detail view

---

## 🛠️ Tech Stack

| Category | Choice |
|---|---|
| Framework | Flutter (Dart) |
| State Management | Riverpod |
| Auth | Firebase Authentication |
| Product Data | [DummyJSON](https://dummyjson.com) REST API |
| Navigation | go_router (with a `StatefulShellRoute` bottom-tab shell) |
| HTTP Client | dio |
| Push Notifications | Firebase Cloud Messaging |
| Local Storage | shared_preferences (cart, wishlist, order history, theme) |
| Images | cached_network_image |

---

## 📂 Project Structure

lib/
├── core/
│ ├── theme/ # Colors, ThemeData, Riverpod dark mode provider
│ ├── router/ # go_router config with shell-route bottom nav
│ ├── services/ # ApiService, AuthService, NotificationService
│ └── utils/ # Validators, card input formatters
├── features/
│ ├── auth/ # Login, Sign Up (Firebase Auth)
│ ├── home/ # Product listing + ProductCard widget
│ ├── categories/
│ ├── search/
│ ├── product/ # Product model, details screen, providers
│ ├── wishlist/
│ ├── cart/
│ ├── checkout/ # Checkout form + order confirmation
│ ├── orders/ # Order model, order history
│ ├── profile/
│ └── notifications/ # FCM providers
└── shared/
└── widgets/ # Reusable widgets, splash screen, nav shell

Feature-first structure, consistent with the pattern used across the InternGrow internship's other apps — each domain owns its screens, widgets, models, and Riverpod providers together.

---

## 🚀 Getting Started

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (3.3.0 or higher)
- A Firebase project (free Spark tier is enough)

### Setup

1. Clone the repo
```bash
   git clone https://github.com/nomanamir20/InternGrow_ECommerceApp.git
   cd InternGrow_ECommerceApp
```
2. Install dependencies
```bash
   flutter pub get
```
3. Connect Firebase — enable Email/Password Authentication and Cloud Messaging in the Firebase Console, then add your own `firebase_options.dart`
4. For push notifications on web, add your own Firebase config to `web/firebase-messaging-sw.js` and generate a Web Push certificate (VAPID key) under Project Settings → Cloud Messaging
5. Run
```bash
   flutter run
```

---

## 🧪 Building for Release

**Android APK:**
```bash
flutter build apk --release
```
(requires your own signing configuration — see `android/key.properties.example`)

**Web:**
```bash
flutter build web --release
```

---

## 📌 Status

✅ Complete — all 8 core features and all 4 upgrade features implemented and tested on both Web and Android.

---

## 👤 Author

Built by Noman Amir as part of the InternGrow Mobile Development Internship.