lclass ApiConstants {
  // CJ Dropshipping API Credentials
  static const String cjApiKey = "CJ6047878@api@fb0e9a894e54406eb844fd63efc4efec";
  
  // CJ API 2.0 Base URL
  static const String baseUrl = "https://developers.cjdropshipping.com/api2.0/v1";

  // ==========================================================
  // STRIPE PERMANENT ONE-SWITCH CONFIGURATION
  // ভবিষ্যতে লাইভ হলে শুধু false কে true করে দেবেন
  // ==========================================================
  static const bool isStripeLive = false;

  // আপনার দেওয়া আসল Test (Sandbox) Keys:
  static const String _stripeTestPublishableKey = "pk_test_51UagPFFHBvHsFU6kZuSe8P86tXHqV4bz75lqEoFus7mpmmftUcfZZLGB2lwXasOHHbO4oLxbaMA7BnFPXtM9j6xH00Y8Y7haF0";
  static const String _stripeTestSecretKey = "sk_test_51UagPFFHBvHsFU6kUplwdRfl8ONTGy1Gp8Rjlhbm2uq9Xm9CZkRTwVFEg5UlTXjKIzICcRIeA18J2I5qMqtafn7H00HsO5shzS";

  // Live Keys — ভবিষ্যতে লাইভ হলে বসাবেন:
  static const String _stripeLivePublishableKey = "pk_live_আপনার_লাইভ_কি";
  static const String _stripeLiveSecretKey = "sk_live_আপনার_লাইভ_সিক্রেট_কি";

  // Auto-Switch Getters (অ্যাপের আর কোথাও হাত দিতে হবে না)
  static String get activeStripePublishableKey =>
      isStripeLive ? _stripeLivePublishableKey : _stripeTestPublishableKey;

  static String get activeStripeSecretKey =>
      isStripeLive ? _stripeLiveSecretKey : _stripeTestSecretKey;

  // Endpoints
  static const String getAccessTokenUrl = "$baseUrl/authentication/getAccessToken";
  static const String productListUrl = "$baseUrl/product/list";
  static const String productDetailsUrl = "$baseUrl/product/query";
  static const String categoryListUrl = "$baseUrl/product/getCategory";

  // App Global Settings
  static const String appName = "PrimeMarket";
  static const String defaultCurrency = "USD";
  static const double usdToBdtRate = 120.0;
}
