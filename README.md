# PlantIT — AI-Powered Botanical Companion

![Flutter](https://img.shields.io/badge/Flutter-3.0-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.0-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Firebase](https://img.shields.io/badge/Firebase-Auth%20%26%20Firestore-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)
![Gemini AI](https://img.shields.io/badge/Powered%20By-Google%20Gemini-8E75B2?style=for-the-badge&logo=google&logoColor=white)

> **"Don't just grow plants. Talk to them."**

PlantIT is a modern, intelligent mobile application designed to bridge the gap between novice gardeners and botanical success. Built with **Flutter** and powered by **Google Gemini**, it serves as a plant identifier, care journal, and an interactive AI companion.

## App Overview

PlantIT was developed with a strict **"Foundational First"** philosophy. It avoids heavy, bloated third-party UI libraries in favor of custom-built widgets, Clean Architecture, and direct API integrations.

### Key Features

- **AI Plant Identification:** Snap a photo of any plant, and the app uses Gemini Vision to identify it, returning scientific names, water needs, and edibility data in structured JSON.
- **The "Plant Whisperer":** A unique **Agentic AI** feature where users can chat with their plants. The AI adopts a persona based on the plant's real-time health (e.g., a thirsty cactus will be grumpy).
- **Cloud Sync:** Powered by **Firebase Firestore**, your garden data syncs across devices.
- **Smart Reminders:** Visual "Thirst Indicators" change color dynamically based on the last watering date.
- **Botanical Wiki:** A search engine that generates detailed care guides on the fly for thousands of species without needing a massive local database.

## Tech Stack

- **Frontend:** Flutter (Dart) - Material 3 Design
- **Backend:** Firebase (Authentication & Cloud Firestore)
- **AI Engine:** Google Gemini 2.5 Flash (via `google_generative_ai` SDK)
- **State Management:** Native `setState` & `StreamBuilder` (Keeping it lightweight)
- **Architecture:** Clean Architecture (Separation of UI, Data, and Models)

## Getting Started

To run this project locally, you will need to set up your own Firebase and Gemini keys.

### Prerequisites

- Flutter SDK installed
- A Google Cloud Project (for Gemini API)
- A Firebase Project

### Installation

1.  **Clone the repository**

    ```bash
    git clone [https://github.com/Mr-Haseeb786/plantit.git](https://github.com/Mr-Haseeb786/plantit.git)
    cd plantit
    ```

2.  **Install dependencies**

    ```bash
    flutter pub get
    ```

3.  **Firebase Setup**

    - Create a project on [Firebase Console](https://console.firebase.google.com/).
    - Enable **Authentication** (Email/Password & Google Sign-In).
    - Enable **Cloud Firestore**.
    - Download `google-services.json` and place it in `android/app/`.
    - **Crucial:** Generate your SHA-1 key (`./gradlew signingReport`) and add it to your Firebase Android App settings to enable Google Sign-In.

4.  **Gemini API Setup**

    - Get an API Key from [Google AI Studio](https://aistudio.google.com/).
    - Create a file `lib/core/constants.dart`:
      ```dart
      const String geminiApiKey = "YOUR_API_KEY_HERE";
      ```

5.  **Run the App**
    ```bash
    flutter run
    ```

## Project Structure

```text
lib/
├── core/                  # App constants & Themes
├── data/                  # Services (Firebase, Gemini, Auth)
├── models/                # Data Models (Plant, User)
├── screens/               # UI Pages (Dashboard, Scanner, Chat)
│   ├── auth/              # Login & Signup
│   └── ...
├── widgets/               # Reusable Components (PlantCard)
└── main.dart              # Entry Point
```
