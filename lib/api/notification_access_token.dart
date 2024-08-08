import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:googleapis_auth/auth_io.dart';

class NotificationAccessToken {
  static String? _token;

  // Generate token only once for an app run
  static Future<String?> get getToken async =>
      _token ?? await _getAccessToken();

  // Get admin bearer token
  static Future<String?> _getAccessToken() async {
    try {
      const fMessagingScope =
          'https://www.googleapis.com/auth/firebase.messaging';

      final client = await clientViaServiceAccount(
        // Replace with your actual JSON credentials or load from a secure source
        ServiceAccountCredentials.fromJson(json.decode(r'''
        {
  "type": "service_account",
  "project_id": "chatting-app-78c46",
  "private_key_id": "621a9f1d426c2182db25a2ff354c03a7402ff41d",
  "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQChudriQJdlHnZm\nDmbjf5RsNA11AtTzvAORQgwNVaYbNx4qNz0MSiA36cCvRHF9935STWbuSqXsIFel\nNUGDH+b/HcNK0J+AVQF4GDWJxGL9l3tHn/ZW+7tsaSf2rCCNCN1cRwzC/slD7Jb9\n1lWsUoGoDWsFY2mvdxqPYVtgZAncdlPc3KJ4Wdf35h1SdqGPcpk04BEr9EjHWPVe\nCR4WZbgN+E+uyB0uTYgQbmWAkKLKPAqc28eONJwR7ATSFAR2nG9twcV/THXb0xrw\nOKhlJB0irnd8U7FyArl3tkBIueQoxb8FI+7/YrBnQiiPbUfpbyQtCdPgbLpCF7CN\nkBSTbLcXAgMBAAECggEAL6djDs33jk02mAXgXWKnambAHF10QEmDR5cNlBRLuLM6\nCThznZ5t9evD4iEpy/NUXo3+KXMHhxdUnBKgNjH9T+kGNZJZnWfu4eNIS0r53D15\njvZckO7mICCwLOg1Qzl8eIdbBE4tIf2h1DQG1JsPJ2Skx1auuow+4EbQtQtlOHeR\nSavQ0rO0NLgfBWITZn5LEYKj0bidCs9wjFxoFeZq0hz7/1GyunEVOh9duqOBCycd\nUtFruLlzikLZ0v5LO8MqBSa0EzUNUEI95yj0XtPg5r0O4977lh4xb4HLfdeN3swY\nQa+XHIo0E5zCpkAYRIjlMoyms/x9SvaXDNTW04XZKQKBgQDX0AzdoN3ZaCVjmEkb\n12trTh4A+epmGXNw05IvNlMMBPUZwfiTG+tIvu4Tq5d+ZItg8y/p/DEs3+P9T8li\nPVBSOT1sdwim8CNU45cszZ15yBEUU6Su4xClyEhtklwcsI8giarlwUfJLDZFOkgS\nKKWUwx81LitZyAQCmmGji3q8MwKBgQC/13O4nLlEnhedAa7iTy9W8lyNadSOkr2O\nq/A2cbDoWJu6OQpsyTIyOzV5bfqXY+zDJJ4IGI2lJ2u7Vor6igZ6xEa25A8lUtsp\nH+GjXWfA6+U688qGWucbNK6l+dDWfBkYf/ShhT/k/iJUAEeGUaQdFQXK87N8nWTt\n+WMTPDG1jQKBgF2nE246GQv3fgIyW8eRPDRcufiCe43DDa2wooeKc4+LtzFuU4jD\nXN88u+QdWqimyTVRU0GfB1gJ8M5EiYfwQ6Lq5BTlswN+wlZcTYZL1EK852yCv7yF\nHPxUZdnm4cIxfGsKUvdRYO2UGhkAqbX3naNo6WoSlw1nFxZqGGT4alKxAoGAO4Nw\nP+ZGx1WwB6IdCdH84qE/OxOIwE4fhiIq3Aj7E6lhbi0B4eusqc6acThAFDUInyU9\n7U8IqiKHlk9rv/uPtQgs09H+LNr+aEyeqBpy9HN54ob83h9XMKZwQ8czFUbcVjBj\nyLPYtYZtSdfoWG/9VJRP/r0JgnAlfnnuVWpIFYUCgYEAy5UcQtUbjmavd4BD5YM1\ncyDZmofUSnMJl9rxFE0Q6tg9MOldrnxNw2BYtmGwFwCxaDkt7iwa8/SmvyLRvPu8\n/5wQcGb7M/SCxeEnD7YbHL6MK+31TDlaEwhbLFHQ0msEwqxdruHZ3qhoUS5oOqs/\nilyA6mrRxgQl7g66dnx5z5o=\n-----END PRIVATE KEY-----\n",
  "client_email": "firebase-adminsdk-xcui1@chatting-app-78c46.iam.gserviceaccount.com",
  "client_id": "109491771734881989518",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token",
  "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
  "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-xcui1%40chatting-app-78c46.iam.gserviceaccount.com",
  "universe_domain": "googleapis.com"
}

        ''')),
        [fMessagingScope],
      );

      _token = client.credentials.accessToken.data;
      print('Server Key: $_token');

      return _token;
    } catch (e) {
      log('$e');
      return null;
    }
  }

  // Send push notification using FCM
  static Future<void> sendPushNotification({
    required String toToken,
    required Map<String, dynamic> data,
  }) async {
    final accessToken = await getToken;
    if (accessToken == null) {
      print('Failed to get access token.');
      return;
    }

    final url = 'https://fcm.googleapis.com/fcm/send';
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken',
    };

    final body = json.encode({
      'to': toToken,
      'data': data,
      'priority': 'high',
    });

    final response =
        await http.post(Uri.parse(url), headers: headers, body: body);

    if (response.statusCode == 200) {
      print('Notification sent successfully.');
    } else {
      print('Failed to send notification: ${response.statusCode}');
      print('Response body: ${response.body}');
    }
  }
}
