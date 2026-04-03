# Mandal Variety

> A comprehensive local grocery and daily essentials delivery application built with Flutter.

[![Flutter Version](https://img.shields.io/badge/Flutter-SDK-blue.svg)](https://flutter.dev)
[![Architecture](https://img.shields.io/badge/Architecture-MVVM-orange.svg)]()
[![Platform](https://img.shields.io/badge/Platform-iOS%20%7C%20Android-green.svg)]()

## About The Project

**Mandal Variety** is a modern, feature-rich mobile commerce application tailored for seamless local grocery and daily essentials delivery. Built using a highly scalable **MVVM** pattern, it offers a robust user experience featuring real-time location tracking, dynamic theming, a comprehensive cart system, and specialized secured access protocols for age-restricted products.

## Core Features

- **Complete E-Commerce Flow**: Browse products, manage Cart, build a Wishlist, intuitive Checkout, and real-time Orders tracking.
- **Location Intelligence**: Automatic address tracking and geolocation services utilizing `geolocator` and `geocoding` workflows to deliver precisely to the user's doorstep.
- **Secure Authentication**: Polished user onboarding, login, and profile management flows.
- **Specialized Access Control**: A dedicated `TobaccoAccessCoordinator` and configured policies directly baked-in to safely manage age-restricted product purchasing limits and disclosures.
- **Persistent Local Storage**: Powered by the ultra-fast `Hive` NoSQL offline database.
- **Responsive & Themed UI**: Adaptive Light/Dark mode and highly responsive custom layout engines (`MediaQueryHelper`). Includes built-in `device_preview` capabilities to easily scale UI logic across any imaginary screen bounds.
- **Legal & Support**: Beautifully integrated views for Contact Us, FAQs, T&C, Privacy Policy, Age Restriction, and Cancellation algorithms.

## Tech Stack & Packages

- **Local Database**: `hive` & `hive_flutter`
- **Location Services**: `geocoding` & `geolocator`
- **Responsive Validations**: `device_preview`
- **General Utilites**: `url_launcher`, `video_player`, `package_info_plus`

## Project Architecture

The application rigorously follows the **MVVM (Model-View-ViewModel)** architectural pattern intertwined with an internal Coordinator/Service layer for handling core application states and singletons across scopes.