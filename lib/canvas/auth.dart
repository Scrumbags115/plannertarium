import 'package:http/http.dart' as http;
import 'package:oauth2/oauth2.dart' as oauth2;

Future<void> main() async {
  final credentials = await authenticate();
  final client = http.Client();
  
  try {
    // Use the authenticated client to make API requests
    final response = await client.get(
        Uri.parse('https://your-canvas-instance/api/v1/courses'),
        headers: {'Authorization': 'Bearer ${credentials.accessToken}'},
    );

    if (response.statusCode == 200) {
      print('API Response: ${response.body}');
    } else {
      print('API Error: ${response.statusCode}');
      print('API Response: ${response.body}');
    }
  } finally {
    client.close();
  }
}

Future<oauth2.Credentials> authenticate() async {
  final authorizationEndpoint =
      Uri.parse('https://your-canvas-instance/login/oauth2/auth');
  final tokenEndpoint =
      Uri.parse('https://your-canvas-instance/login/oauth2/token');
  final redirectUrl = Uri.parse('http://localhost:8080'); // Change this to your redirect URL
  final clientId = 'your-client-id';
  final clientSecret = 'your-client-secret';

  final grant = oauth2.AuthorizationCodeGrant(
    clientId,
    authorizationEndpoint,
    tokenEndpoint,
    secret: clientSecret,
  );

  // Redirect the user to the Canvas authorization page
  final authorizationUrl = grant.getAuthorizationUrl(redirectUrl);
  print('Please go to the following URL and grant access:');
  print(authorizationUrl);

  // Get the authorization response from the user
  final responseUrl = // ... obtain the response URL from the user

  // Extract the authorization code
  final code = Uri.parse(responseUrl).queryParameters['code'];

  // Obtain the OAuth2 token
  return await grant.handleAuthorizationResponse({'code': code});
}
