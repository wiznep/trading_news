# TradeFlash 📱

A modern, concise stock market news application that delivers market updates in 60 words or less. Stay informed with real-time market news, stock updates, and financial insights in a clean, user-friendly interface.

## 🌟 Features

- **Concise News Updates**: Get the essence of market news in 60 words or less
- **Real-time Updates**: Stay current with the latest market movements
- **Smart Categorization**: News automatically categorized by type (stocks, economy, earnings, etc.)
- **Stock Impact Analysis**: Quick insights into how news affects specific stocks
- **Bookmark System**: Save important news for later reference
- **Sentiment Analysis**: Understand market sentiment through AI-powered analysis
- **Adaptive UI**: Beautiful interface that works on all screen sizes
- **Offline Support**: Read saved articles even without internet connection

## 📱 Screenshots

[Add screenshots here]

## 🛠️ Technical Stack

- **Framework**: Flutter
- **State Management**: Provider
- **Local Storage**: Hive
- **Networking**: Dio
- **UI Components**: Material Design
- **Charts**: fl_chart
- **Image Handling**: cached_network_image
- **Environment Variables**: flutter_dotenv

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (>=3.0.0)
- Dart SDK (>=3.0.0)
- Android Studio / Xcode
- Git

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/tradeflash.git
   ```

2. Navigate to the project directory:
   ```bash
   cd tradeflash
   ```

3. Install dependencies:
   ```bash
   flutter pub get
   ```

4. Create a `.env` file in the root directory and add your API keys:
   ```
   NEWS_API_KEY=your_api_key_here
   ```

5. Run the app:
   ```bash
   flutter run
   ```

## 📦 Project Structure

```
lib/
├── data/
│   ├── datasources/
│   │   ├── local/
│   │   └── remote/
│   ├── models/
│   └── repositories/
├── domain/
│   ├── entities/
│   └── repositories/
├── presentation/
│   ├── pages/
│   ├── providers/
│   └── widgets/
└── main.dart
```

## 🎨 UI/UX Features

- **Splash Screen**: Beautiful animated splash screen with app branding
- **News Cards**: Clean, modern cards with essential information
- **Bookmark System**: Easy-to-use bookmark functionality
- **Search**: Powerful search with filters
- **Categories**: Intuitive category navigation
- **Dark/Light Mode**: Support for both themes

## 🔧 Configuration

### Android

The app is configured for Android with:
- Adaptive icons
- Material Design theme
- Minimum SDK version: 21

### iOS

The app is configured for iOS with:
- Custom app icon
- Launch screen
- Minimum iOS version: 12.0

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- All contributors who have helped shape this project
- The open-source community for their invaluable tools and libraries

## 📞 Support

For support, email support@tradeflash.com or open an issue in the repository.

---

Made with ❤️ by [Your Name/Team]
