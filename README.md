# DimGo POS Application

## Overview
A full-stack Point of Sale (POS) application for "DimGo" (Dimsum & Es Teh), built with **Flutter** (Frontend) and **PHP/MySQL** (Backend).

## Features
-   **Dashboard**: Overview of stock value, total products, and low stock alerts.
-   **POS System**: Cart functionality, product search, and transaction processing.
-   **Inventory Management**: Add, Update, and Delete products.
-   **Reports**: View transaction history.

## Getting Started

### 1. Backend Setup
1. Copy the contents of `backend_files/` (or `scratch/dimgo_backend`) to your XAMPP `htdocs/dimgo_backend` directory.
   2. Import `database.sql` into your MySQL server (create database `dimgo_db`).
3. Verify connection at `http://localhost/dimgo_backend/connect.php`.

### 2. Mobile App Setup
1. Open this project in Android Studio.
2. Run `flutter pub get`.
3. Configure `API_URL` in `lib/services/api_service.dart` if testing on a real device (default is `10.0.2.2` for Emulator).
4. Run on Android Emulator.

## Technologies
-   **Flutter**: UI, Provider (State Mgmt), HTTP.
-   **PHP**: Native API endpoints.
-   **MySQL**: Relational database.
