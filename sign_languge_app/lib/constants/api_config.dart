class ApiConfig {
  static const List<String> apiBaseUrls = [
    'http://192.168.73.103:5000',
    'http://172.11.129.38:5000',
    'http://192.168.73.101:5000'
    
    // Thêm IP khác nếu cần
  ];

  static String get defaultBaseUrl => apiBaseUrls.first;
}
