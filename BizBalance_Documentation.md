# BizBalance - Professional Software Documentation

## 1. Executive Summary
**BizBalance** is a comprehensive, offline-first mobile application designed specifically for small to medium-sized businesses to manage their daily finances. Built cross-platform using Flutter, the application provides business owners with an intuitive and secure environment to track income, record expenses, manage budgets, and visualize financial health through comprehensive reporting, without requiring an active internet connection.

---

## 2. Technical Architecture

### 2.1 Technology Stack
*   **Frontend Framework:** Flutter (Dart)
*   **State Management:** Stateful Widgets & Lifting State Up (via `app.dart`)
*   **Local Data Persistence:** `shared_preferences` (JSON Serialization)
*   **File System & Backups:** `path_provider`, `file_picker`, `share_plus`
*   **Target Platforms:** Android, iOS (Cross-platform compatibility)

### 2.2 Application Structure (`lib/`)
The source code is organized following a clear separation of concerns:
*   **`models/`**: Contains core data structures (`Transaction`, `CategoryModel`, `Budget`).
*   **`screens/`**: Contains the primary UI views (Dashboard, Ledger, Budgets, Reports, Settings).
*   **`services/`**: Encapsulates business logic and external integrations (`StorageService`).
*   **`widgets/`**: Reusable UI components (e.g., `TransactionFormDialog`).
*   **`data/`**: Static or mock data for demonstration (`demo_data.dart`).

---

## 3. Core Application Functions

### 3.1 Financial Dashboard
The Dashboard serves as the central hub of the application, providing real-time visibility into the business's financial status.
*   **Key Metrics:** Displays Total Income, Total Expenses, and Net Balance.
*   **Quick Actions:** Allows users to rapidly log new transactions via a floating action button.
*   **Overview Charts:** Provides a high-level visual summary of the current month's performance.

### 3.2 Ledger & Transaction Management
The Ledger is the chronological record of all financial activities.
*   **CRUD Operations:** Users can Create, Read, Update, and Delete individual transactions.
*   **Categorization:** Every transaction must be linked to a specific category (e.g., Sales, Utilities, Payroll).
*   **Transaction Details:** Captures amount, date, category, transaction type (Income/Expense), and optional notes/source.

### 3.3 Budgeting System
A proactive financial management tool allowing businesses to set and monitor spending limits.
*   **Category-Specific Limits:** Users can allocate maximum spending limits to specific expense categories.
*   **Progress Tracking:** Visual indicators (progress bars) show how much of the budget has been consumed versus what remains.
*   **Alerting Framework:** Highlights categories that have exceeded their designated budget.

### 3.4 Custom Categories
Flexible categorization to match unique business operations.
*   **Default Categories:** Ships with standard business categories (e.g., 'Office Supplies', 'Revenue').
*   **Customization:** Users can create new custom categories or delete existing ones.
*   **Fallback Handling:** When a category is deleted, associated transactions are automatically re-assigned to generic "Other Income" or "Other Expenses" buckets to maintain data integrity.

### 3.5 Reports and Analytics
Data visualization tools to help owners understand cash flow.
*   **Visual Charts:** Generates graphical representations (Pie charts/Bar graphs) of income vs. expenses.
*   **Breakdowns:** Shows percentage breakdowns of spending by category, identifying areas of high expenditure.

### 3.6 Settings & Configuration
*   **Currency Customization:** Supports changing the base currency symbol (e.g., USD, LKR, EUR).
*   **Theme Engine:** Includes a robust Dark Mode and Light Mode, utilizing a modern, accessibility-friendly color palette.
*   **Database Management:** Options to completely wipe the local database or populate it with demonstration data for training purposes.

---

## 4. Security & Data Integrity

### 4.1 Local-First Privacy
All application data is securely serialized and stored directly within the device's local storage using `shared_preferences`. No data is transmitted to remote servers, ensuring absolute privacy for sensitive business financials.

### 4.2 Application Lock (PIN)
To prevent unauthorized local access, the app features a configurable 4-digit PIN lock. When enabled, this lock screen intercepts application launch and requires authentication before revealing the dashboard.

### 4.3 Data Backup and Restoration
To protect against data loss (e.g., device loss or uninstallation):
*   **JSON Export:** The app can aggregate all transactions, categories, budgets, and settings into a single JSON payload.
*   **Export Handling:** The payload is saved locally and can be shared via the native share sheet (Email, Google Drive, WhatsApp, etc.).
*   **JSON Import:** Users can seamlessly import a backup file to restore their entire financial history and settings state.

---

## 5. Deployment and Build Instructions

To build the project for production, the following standard Flutter toolchain commands are utilized:

**For Android (APK):**
```bash
flutter build apk --release
```

**For Android (App Bundle):**
```bash
flutter build appbundle --release
```

**For iOS:**
```bash
flutter build ios --release
```

## 6. Conclusion
BizBalance delivers a highly responsive, secure, and intuitive financial tracking solution. By leveraging Flutter's cross-platform capabilities and an offline-first architecture, it ensures maximum reliability and privacy for business owners managing their daily operations.
