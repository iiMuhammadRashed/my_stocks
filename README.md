# 📈 MyStocks - Flutter Stock Tracker App

> A professional stock tracking application built with Flutter that provides real-time stock data, price alerts, and portfolio management capabilities.

## 📋 Table of Contents
- [Overview](#overview)
- [Features](#features)
- [Screenshots](#screenshots)
- [Tech Stack](#tech-stack)
- [Architecture](#architecture)
- [Setup & Installation](#setup--installation)
- [API Documentation](#api-documentation)
- [Project Structure](#project-structure)
- [Testing](#testing)
- [Known Issues & Limitations](#known-issues--limitations)
- [Future Enhancements](#future-enhancements)

---

## 🎯 Overview

**MyStocks** is a Flutter-based stock tracking application developed as part of a technical assessment. The app allows users to search for stocks, track their favorites, view detailed stock information with interactive charts, and set up price alerts with background notifications.

**Note:** This project was modified from the original requirements - instead of Yahoo Finance API, I integrated **Twelve Data API** for more reliable data access and better documentation.

---

## ✨ Features

### ✅ Implemented Features

#### 🏠 Home Dashboard
- **Real-time Stock Tracking**: Display favorite stocks with live price updates
- **Auto-refresh**: Automatic data refresh every 60 seconds
- **Pull-to-refresh**: Manual refresh capability
- **Color-coded Changes**: Green for price increases, red for decreases
- **Persistent Storage**: Favorites saved locally using Hive database
- **Empty State**: Clean UI when no stocks are tracked

#### 🔍 Stock Search
- **Symbol & Name Search**: Search stocks by ticker symbol or company name
- **Live Search Results**: Real-time search as you type
- **Add to Favorites**: One-tap to add stocks to tracking list
- **Duplicate Prevention**: Smart validation to prevent adding duplicates
- **Visual Feedback**: Success/error snackbars for user actions

#### 📊 Stock Details
- **Comprehensive Data**: Current price, daily high/low, volume, market cap
- **Interactive Chart**: 30-day price history with FL Chart
- **Real-time Updates**: Live price data with auto-refresh
- **Beautiful UI**: Clean, modern design with smooth animations
- **Quick Actions**: Add to favorites directly from details screen

#### 🔔 Price Alerts
- **Custom Thresholds**: Set price alerts for any tracked stock
- **Background Monitoring**: Continuous price checking even when app is closed
- **Local Notifications**: Push notifications when price targets are met
- **Alert Management**: View, edit, and delete active alerts
- **Persistent Alerts**: Alerts saved locally and survive app restarts

#### 🌙 Additional Features
- **Dark/Light Mode**: Full theme support with system preference detection
- **Splash Screen**: Professional app launch experience
- **Error Handling**: Comprehensive error management with user-friendly messages
- **Offline Detection**: Network connectivity monitoring
- **Rate Limiting**: Smart API call management to respect free tier limits

---

## 🖼️ Screenshots

> *Note: Add screenshots of your app here*

```
[Home Screen]  [Search Screen]  [Details Screen]  [Alerts Screen]
```

---

## 🛠️ Tech Stack

### Core Framework
- **Flutter SDK**: `>=3.4.3 <4.0.0`
- **Dart**: Latest stable version

### State Management
- **Provider**: `^6.1.2` - Lightweight and efficient state management

### UI & Design
- **flutter_screenutil**: `^5.9.3` - Responsive UI design
- **google_fonts**: `^6.2.1` - Custom typography
- **fl_chart**: `^0.68.0` - Interactive charts
- **flutter_svg**: `^2.0.10+1` - SVG asset support

### Navigation
- **go_router**: `^14.2.0` - Declarative routing

### Networking
- **dio**: `^5.4.0` - HTTP client
- **retrofit**: `^4.4.1` - Type-safe API client
- **pretty_dio_logger**: `^1.3.1` - Network debugging
- **connectivity_plus**: `^6.0.0` - Network status monitoring
- **http**: `^1.2.2` - Additional HTTP support

### Local Storage
- **hive**: `^2.2.3` - NoSQL database
- **hive_flutter**: `^1.1.0` - Flutter integration
- **path_provider**: `^2.1.5` - File system paths

### Background Tasks & Notifications
- **workmanager**: `^0.9.0+3` - Background task scheduling
- **flutter_local_notifications**: `^17.2.3` - Push notifications

### Utilities
- **uuid**: `^4.5.2` - Unique ID generation

### Development Tools
- **hive_generator**: `^2.0.1` - Code generation for Hive
- **build_runner**: `^2.4.13` - Code generation runner
- **flutter_lints**: `^5.0.0` - Dart linting rules
- **flutter_launcher_icons**: `^0.13.1` - App icon generation

---

## 🏗️ Architecture

The project follows **Clean Architecture** principles with **Feature-First** organization:

```
lib/
├── main.dart                          # App entry point
├── core/                              # Shared resources
│   ├── constants/                     # API & app constants
│   ├── router/                        # Navigation configuration
│   ├── theme/                         # App theming
│   └── utils/                         # Helper utilities
├── features/                          # Feature modules
│   ├── dashboard/                     # Home screen
│   │   ├── data/                      # Data layer
│   │   ├── domain/                    # Business logic
│   │   └── presentation/              # UI layer
│   ├── search_stocks/                 # Stock search
│   ├── stock_details/                 # Details view
│   ├── price_alerts/                  # Alert management
│   ├── splash/                        # Splash screen
│   └── error/                         # Error handling
└── services/                          # Shared services
    └── data/                          # Data services
```

### Design Patterns Used
- **Repository Pattern**: Data abstraction layer
- **Service Pattern**: Business logic separation
- **Provider Pattern**: State management
- **Singleton Pattern**: Service instances

---

## 🚀 Setup & Installation

### Prerequisites
- Flutter SDK (3.4.3 or higher)
- Dart SDK (included with Flutter)
- Android Studio / VS Code
- Android SDK / Xcode (for mobile development)

### Step 1: Clone the Repository
```bash
git clone https://github.com/iiMuhammadRashed/my_stocks.git
cd my_stocks
```

### Step 2: Install Dependencies
```bash
flutter pub get
```

### Step 3: Generate Code
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### Step 4: Configure API Key

The app uses **Twelve Data API**. You can use the included demo API key or get your own:

1. Visit: https://twelvedata.com/
2. Sign up for a free account
3. Copy your API key
4. Update `lib/core/constants/api_constants.dart`:

```dart
static const String apiKey = 'YOUR_API_KEY_HERE';
```

**Note**: The free tier includes:
- 8 API calls per minute
- 800 API calls per day
- Access to real-time and historical data

### Step 5: Run the App
```bash
# For development
flutter run

# For release build
flutter build apk --release  # Android
flutter build ios --release  # iOS
```

---

## 📡 API Documentation

### API Provider: Twelve Data

**Base URL**: `https://api.twelvedata.com`

**Authentication**: API key in query parameters

### Endpoints Used

#### 1. Symbol Search
**Endpoint**: `/symbol_search`

**Purpose**: Search for stocks by symbol or company name

**Request**:
```
GET https://api.twelvedata.com/symbol_search?symbol=AAPL&apikey=YOUR_API_KEY
```

**Response Example**:
```json
{
  "data": [
    {
      "symbol": "AAPL",
      "instrument_name": "Apple Inc",
      "exchange": "NASDAQ",
      "mic_code": "XNAS",
      "exchange_timezone": "America/New_York",
      "instrument_type": "Common Stock",
      "country": "United States",
      "currency": "USD"
    }
  ],
  "status": "ok"
}
```

#### 2. Stock Quote
**Endpoint**: `/quote`

**Purpose**: Get real-time stock data including price, change, volume

**Request**:
```
GET https://api.twelvedata.com/quote?symbol=AAPL&apikey=YOUR_API_KEY
```

**Response Example**:
```json
{
  "symbol": "AAPL",
  "name": "Apple Inc",
  "exchange": "NASDAQ",
  "mic_code": "XNAS",
  "currency": "USD",
  "datetime": "2025-11-07",
  "timestamp": 1699382400,
  "open": "188.32",
  "high": "189.50",
  "low": "186.90",
  "close": "187.45",
  "volume": "52478369",
  "previous_close": "188.01",
  "change": "-0.56",
  "percent_change": "-0.30",
  "average_volume": "54123456",
  "is_market_open": false,
  "fifty_two_week": {
    "low": "164.08",
    "high": "199.62",
    "change": "23.37",
    "change_percent": "14.24"
  }
}
```

#### 3. Batch Quotes
**Endpoint**: `/quote`

**Purpose**: Get multiple stock quotes in one request

**Request**:
```
GET https://api.twelvedata.com/quote?symbol=AAPL,GOOGL,TSLA&apikey=YOUR_API_KEY
```

**Response Example**:
```json
{
  "AAPL": {
    "symbol": "AAPL",
    "name": "Apple Inc",
    "close": "187.45",
    "percent_change": "-0.30",
    ...
  },
  "GOOGL": {
    "symbol": "GOOGL",
    "name": "Alphabet Inc",
    "close": "139.82",
    "percent_change": "1.25",
    ...
  }
}
```

#### 4. Time Series
**Endpoint**: `/time_series`

**Purpose**: Get historical price data for charts

**Request**:
```
GET https://api.twelvedata.com/time_series?symbol=AAPL&interval=1day&outputsize=30&apikey=YOUR_API_KEY
```

**Parameters**:
- `symbol`: Stock ticker (e.g., AAPL)
- `interval`: Time interval (1min, 5min, 15min, 30min, 45min, 1h, 2h, 4h, 1day, 1week, 1month)
- `outputsize`: Number of data points (default: 30)

**Response Example**:
```json
{
  "meta": {
    "symbol": "AAPL",
    "interval": "1day",
    "currency": "USD",
    "exchange_timezone": "America/New_York",
    "exchange": "NASDAQ",
    "mic_code": "XNAS",
    "type": "Common Stock"
  },
  "values": [
    {
      "datetime": "2025-11-07",
      "open": "188.32",
      "high": "189.50",
      "low": "186.90",
      "close": "187.45",
      "volume": "52478369"
    },
    {
      "datetime": "2025-11-06",
      "open": "186.15",
      "high": "188.75",
      "low": "185.80",
      "close": "188.01",
      "volume": "48523147"
    }
  ],
  "status": "ok"
}
```

### Rate Limiting

The app implements smart rate limiting for the free tier:

```dart
// From api_constants.dart
static const int maxCallsPerMinute = 6;  // Conservative limit
```

**Free Tier Limits**:
- 8 API calls per minute
- 800 API calls per day

**Rate Limit Handling**:
- Automatic waiting when limit reached
- Retry mechanism with exponential backoff
- User-friendly error messages

### Error Handling

**Common Error Responses**:

```json
// Rate limit exceeded
{
  "status": "error",
  "message": "You have exceeded the API call limit"
}

// Invalid symbol
{
  "status": "error",
  "message": "Symbol not found"
}

// Invalid API key
{
  "status": "error",
  "message": "Invalid API key"
}
```

---

## 📁 Project Structure

```
my_stocks/
├── android/                           # Android native code
├── ios/                               # iOS native code
├── assets/                            # Static assets
│   └── icon/                          # App icons
├── lib/
│   ├── main.dart                      # App entry point
│   ├── core/
│   │   ├── constants/
│   │   │   └── api_constants.dart     # API configuration
│   │   ├── router/
│   │   │   ├── app_router.dart        # Route configuration
│   │   │   └── route_constants.dart   # Route names
│   │   ├── theme/
│   │   │   ├── app_theme.dart         # Theme definitions
│   │   │   ├── color_manager.dart     # Color palette
│   │   │   └── ThemeProvider.dart     # Theme state management
│   │   └── utils/
│   │       ├── connectivity_service.dart  # Network monitoring
│   │       ├── error_handler.dart     # Error handling
│   │       └── user_manager.dart      # User session
│   ├── features/
│   │   ├── dashboard/
│   │   │   └── presentation/
│   │   │       ├── screens/
│   │   │       │   └── dashboard.dart
│   │   │       └── widgets/
│   │   │           └── stock_card.dart
│   │   ├── search_stocks/
│   │   │   ├── data/
│   │   │   │   ├── models/
│   │   │   │   │   ├── stock_model.dart
│   │   │   │   │   └── stock_model.g.dart
│   │   │   │   ├── repositories/
│   │   │   │   │   └── stock_repository.dart
│   │   │   │   └── services/
│   │   │   │       └── stock_service.dart
│   │   │   ├── presentation/
│   │   │   │   ├── screens/
│   │   │   │   │   └── search_stocks_screen.dart
│   │   │   │   └── widgets/
│   │   │   │       ├── search_bar.dart
│   │   │   │       ├── stock_add_snackbar.dart
│   │   │   │       └── stock_list_item.dart
│   │   │   └── viewmodels/
│   │   │       └── search_stocks_viewmodel.dart
│   │   ├── stock_details/
│   │   │   ├── data/
│   │   │   │   └── services/
│   │   │   │       └── time_series_service.dart
│   │   │   └── presentation/
│   │   │       ├── screens/
│   │   │       │   └── stock_details_screen.dart
│   │   │       ├── viewmodels/
│   │   │       │   └── stock_details_viewmodel.dart
│   │   │       └── widgets/
│   │   │           ├── stock_bottom_actions.dart
│   │   │           ├── stock_chart.dart
│   │   │           └── stock_stats_grid.dart
│   │   ├── price_alerts/
│   │   │   ├── background/
│   │   │   │   └── alert_background_task.dart
│   │   │   ├── data/
│   │   │   │   ├── stock_alert_model.dart
│   │   │   │   └── stock_alert_model.g.dart
│   │   │   └── presentation/
│   │   │       ├── screens/
│   │   │       │   └── StockAlertScreen.dart
│   │   │       └── widgets/
│   │   │           ├── add_alert_button.dart
│   │   │           └── alert_item.dart
│   │   ├── splash/
│   │   │   └── presentation/
│   │   │       └── SplashScreen.dart
│   │   └── error/
│   │       └── presentation/
│   │           └── connection_error_screen.dart
│   └── services/
│       └── data/
│           ├── alert_checker_service.dart
│           ├── hive_alerts_service.dart
│           └── hive_favorites_service.dart
├── test/                              # Unit tests
├── pubspec.yaml                       # Dependencies
└── README.md                          # This file
```

---

## 🧪 Testing

### Run Tests
```bash
flutter test
```

### Test Coverage
```bash
flutter test --coverage
```

### Manual Testing Checklist

- [ ] Search for stocks by symbol (AAPL, GOOGL, TSLA)
- [ ] Add stocks to favorites
- [ ] View stock details with chart
- [ ] Create price alerts
- [ ] Receive notifications when alert triggers
- [ ] Delete alerts
- [ ] Remove stocks from favorites
- [ ] Test pull-to-refresh
- [ ] Test dark/light mode toggle
- [ ] Test with no internet connection
- [ ] Test background task execution
- [ ] Test app restart (data persistence)

---

## ⚠️ Known Issues & Limitations

### API Limitations
- **Free Tier**: Limited to 8 calls/minute and 800 calls/day
- **Rate Limiting**: May experience delays during heavy usage
- **Market Hours**: Some data only updates during trading hours
- **Symbol Coverage**: Not all international stocks available

### Firebase Cloud Messaging
- **Not Implemented**: Original requirement requested FCM for push notifications
- **Current Solution**: Using local notifications with background tasks
- **Reason**: Simplified architecture for demo purposes
- **Impact**: Notifications only work when app is installed (no remote push)

### Background Tasks
- **Android Only**: Background task reliability varies by device manufacturer
- **Battery Optimization**: May be affected by aggressive battery savers
- **iOS Limitations**: Background fetch has strict iOS limitations

### Charts
- **Data Points**: Limited to last 30 days for free tier
- **Real-time**: Chart updates on refresh, not truly real-time
- **Customization**: Basic chart with minimal interaction

---

## 🚀 Future Enhancements

### High Priority
- [ ] Implement Firebase Cloud Messaging for true push notifications
- [ ] Add Firebase Cloud Functions for server-side price monitoring
- [ ] Implement user authentication
- [ ] Add portfolio tracking with buy/sell transactions
- [ ] Support for multiple watchlists

### Medium Priority
- [ ] Add more chart intervals (1h, 1week, 1month)
- [ ] Implement stock comparison feature
- [ ] Add news feed for stocks
- [ ] Support for cryptocurrency tracking
- [ ] Implement advanced filters and sorting

### Nice to Have
- [ ] Social features (share watchlists)
- [ ] Stock screener
- [ ] Technical indicators on charts
- [ ] Export data to CSV
- [ ] Widgets for home screen

---

## 👤 Developer Information

**Developed by**: Shady Nasser  
**GitHub**: [@iiMuhammadRashed](https://github.com/iiMuhammadRashed)  
**Role**: Junior Flutter Developer  
**Purpose**: Technical Assessment Task  
**Date**: November 2025  
**Contact**: shadynaser711@gmail.com

---

## 📝 Original Task Requirements

This project was developed based on the following assessment criteria:

| Area | Requirement | Status |
|------|------------|--------|
| Functionality | Fetch & display real stock data | ✅ Complete |
| Functionality | Auto-refresh every 1 minute | ✅ Complete |
| Functionality | Manual pull-to-refresh | ✅ Complete |
| Functionality | Local data persistence | ✅ Complete |
| UI/UX | Clean, intuitive interface | ✅ Complete |
| UI/UX | Responsive layout | ✅ Complete |
| UI/UX | Color-coded price changes | ✅ Complete |
| Code Quality | Structured & modular | ✅ Complete |
| Code Quality | Flutter best practices | ✅ Complete |
| Push Notifications | FCM integration | ⚠️ Partial (Local only) |
| Push Notifications | Background alerts | ✅ Complete |
| Bonus | Dark/light mode | ✅ Complete |
| Bonus | Splash screen | ✅ Complete |
| Bonus | State management (Provider) | ✅ Complete |
| Bonus | Interactive charts | ✅ Complete |

### Modifications from Original Requirements
1. **API Change**: Used Twelve Data API instead of Yahoo Finance API
   - Reason: Better documentation and reliability
   - Impact: None - same data quality

2. **Simplified Notifications**: Local notifications instead of FCM
   - Reason: Demo simplicity, no backend required
   - Impact: Works for assessment purposes

---

## 📄 License

This project is developed for educational and assessment purposes.

---

## 🙏 Acknowledgments

- **Twelve Data**: For providing excellent stock market API
- **Flutter Team**: For the amazing framework
- **Open Source Community**: For the incredible packages used in this project

---

## 📞 Support

For questions or issues:
1. Check the [Known Issues](#known-issues--limitations) section
2. Review API documentation at https://twelvedata.com/docs
3. Open an issue on [GitHub](https://github.com/iiMuhammadRashed/my_stocks/issues)
4. Contact: shadynaser711@gmail.com

---

**Last Updated**: November 7, 2025  
**Version**: 1.0.0  
**Flutter Version**: 3.4.3+  

---

*Built with ❤️ using Flutter*
