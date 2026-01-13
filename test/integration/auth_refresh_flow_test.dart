import 'dart:convert';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

void main() {
  const baseUrl = 'http://72.61.163.98/api';
  final client = http.Client();

  tearDownAll(() {
    client.close();
  });

  group('Auth refresh lifecycle', () {
    test('request OTP, verify, refresh with JSON payloads', () async {
      final phone = _generateTestPhone();

      final otpRequestResponse = await client.post(
        Uri.parse('$baseUrl/auth/phone/otp/request'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phone': phone}),
      );

      expect(otpRequestResponse.statusCode, 200,
          reason: 'OTP request should succeed for $phone');
      final otpRequestJson = jsonDecode(otpRequestResponse.body) as Map<String, dynamic>;
      expect(otpRequestJson['ok'], isTrue);

      final verifyResponse = await client.post(
        Uri.parse('$baseUrl/auth/phone/otp/verify'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phone': phone, 'otp': '1234'}),
      );

      expect(verifyResponse.statusCode, 200, reason: 'OTP verify should succeed');
      final verifyJson = jsonDecode(verifyResponse.body) as Map<String, dynamic>;
      final accessToken = verifyJson['access_token'] as String? ?? '';
      final refreshToken = verifyJson['refresh_token'] as String? ?? '';

      expect(accessToken.isNotEmpty, isTrue, reason: 'access_token should be present');
      expect(refreshToken.isNotEmpty, isTrue, reason: 'refresh_token should be present');

      final refreshResponse = await client.post(
        Uri.parse('$baseUrl/auth/refresh'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refresh_token': refreshToken}),
      );

      expect(refreshResponse.statusCode, 200,
          reason: 'Refresh with refresh_token field should return 200');
      final refreshJson = jsonDecode(refreshResponse.body) as Map<String, dynamic>;
      expect(refreshJson['access_token'], isNotEmpty);
      expect(refreshJson['refresh_token'], isNotEmpty);

      final legacyRefreshResponse = await client.post(
        Uri.parse('$baseUrl/auth/refresh'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'token': refreshToken}),
      );

      expect(legacyRefreshResponse.statusCode, 200,
          reason: 'Refresh with legacy token key should still work');
      final legacyRefreshJson = jsonDecode(legacyRefreshResponse.body) as Map<String, dynamic>;
      expect(legacyRefreshJson['access_token'], isNotEmpty);
      expect(legacyRefreshJson['refresh_token'], isNotEmpty);
    });
  });
}

String _generateTestPhone() {
  final random = Random.secure();
  final suffix = random.nextInt(900000) + 100000; // 6 digits to avoid collisions
  return '+1000$suffix';
}



