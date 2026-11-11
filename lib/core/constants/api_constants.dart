class ApiConstants {
  // CJ Dropshipping API Credentials
  static const String cjApiKey = "CJ6047878@api@fb0e9a894e54406eb844fd63efc4efec";
  
  // CJ API 2.0 Base URL
  static const String baseUrl = "https://developers.cjdropshipping.com/api2.0/v1";

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
