# BizBalance 📈

**BizBalance** is a comprehensive, offline-first mobile application built with Flutter, designed to help small and medium-sized businesses manage their finances effortlessly. It provides an intuitive interface for tracking income, expenses, budgets, and generating reports—all securely stored on the device.

![License](https://img.shields.io/badge/license-MIT-blue.svg)
![Flutter](https://img.shields.io/badge/Flutter-^3.12.0-02569B?logo=flutter)
![Dart](https://img.shields.io/badge/Dart-^3.0.0-0175C2?logo=dart)

---

## 🌟 Key Features

- **Dashboard Overview:** At-a-glance summary of total income, expenses, and current balance.
- **Ledger Management:** Easily add, edit, and categorize daily business transactions.
- **Custom Budgets:** Set spending limits per category and track your progress visually.
- **Categorization:** Create custom income and expense categories for precise financial tracking.
- **Financial Reports:** Visual charts and breakdowns to analyze spending and revenue patterns.
- **Security:** Built-in PIN lock to protect sensitive financial data.
- **Customization:** Support for Light and Dark themes, and customizable currency symbols.
- **Data Portability:** Export and import JSON backups locally or share them via external apps.
- **100% Offline:** All data is securely stored locally on the device using `shared_preferences`.

---

## 🛠️ Technology Stack

- **Framework:** [Flutter](https://flutter.dev/) (Dart)
- **Local Storage:** `shared_preferences` for offline data persistence
- **File System:** `path_provider`, `file_picker` for backup management
- **Sharing:** `share_plus` to export JSON backups
- **Icons & UI:** `cupertino_icons`, `flutter_launcher_icons`

---

## 🚀 Getting Started

### Prerequisites

Ensure you have the following installed on your machine:
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (^3.12.0 or higher)
- Android Studio or VS Code with Flutter extensions
- A connected physical device or emulator

### Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/yourusername/bizbalance.git
   cd bizbalance
   ```

2. **Fetch dependencies:**
   ```bash
   flutter pub get
   ```

3. **Run the app:**
   ```bash
   flutter run
   ```

---

## 📂 Project Structure

```text
lib/
├── data/
│   └── demo_data.dart          # Dummy data for testing/demo purposes
├── models/
│   ├── budget.dart             # Budget data model
│   ├── category_model.dart     # Category data model
│   └── transaction.dart        # Transaction data model
├── screens/
│   ├── budget_screen.dart      # Budget management UI
│   ├── category_screen.dart    # Category management UI
│   ├── dashboard_screen.dart   # Main dashboard overview
│   ├── ledger_screen.dart      # Transaction history & list
│   ├── pin_lock_screen.dart    # Security PIN entry UI
│   ├── reports_screen.dart     # Charts and financial reporting
│   └── settings_screen.dart    # App configurations & backups
├── services/
│   └── storage_service.dart    # Local data persistence logic
├── widgets/
│   └── transaction_form_dialog.dart # Reusable form for adding/editing records
├── app.dart                    # Main App UI & State Management Setup
└── main.dart                   # Application Entry Point
```

---

## 🛡️ Security & Privacy
BizBalance is designed with privacy in mind. Because it is an offline-first app, **no financial data is sent to external servers**. Everything is stored directly on your device. Users can also enable a **4-digit PIN lock** for an additional layer of local security.

---

## 🤝 Contributing
Contributions, issues, and feature requests are welcome! 
1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

##  Screen shots
<img width="300"  alt="Screenshot_1781333349" src="https://github.com/user-attachments/assets/dca03121-386c-4a53-a851-0f635f5797f3" />
<img width="300"  alt="Screenshot_1781333353" src="https://github.com/user-attachments/assets/2fec9492-cd03-4c44-8eee-bd14eb21f4ea" />
<img width="300" alt="Screenshot_1781333358" src="https://github.com/user-attachments/assets/d23d7ffc-b9bf-472a-8f4b-7b72d446fc42" />
<img width="300" alt="Screenshot_1781333365" src="https://github.com/user-attachments/assets/b19e366a-0b8f-46ff-b1a2-53ae8814dc5c" />
<img width="300" alt="Screenshot_1781333369" src="https://github.com/user-attachments/assets/d981d86a-f4a2-4a78-b9a6-3323785f34f8" />
<img width="300"  alt="Screenshot_1781333371" src="https://github.com/user-attachments/assets/bd725a4e-f12d-46f5-a921-d073cf276831" />
<img width="300" alt="Screenshot_1781333376" src="https://github.com/user-attachments/assets/a04f221b-a004-4829-922d-458111bd84c5" />
<img width="300"  alt="Screenshot_1781333386" src="https://github.com/user-attachments/assets/a4594870-409c-4685-92d6-e026509e2f06" />
<img width="300" alt="Screenshot_1781333401" src="https://github.com/user-attachments/assets/03a3dd6e-6c69-4ac2-aa80-0ce50530f893" />









