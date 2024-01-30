import 'package:http/http.dart' as http;

class WebhookHandler {
  static Future<void> handleSpatieWebhook() async {
    final response = await http.post(
      Uri.parse("a"),
      body: {
        'event': 'my_event',
      },
    );

    if (response.statusCode == 200) {
      // Handle successful webhook notification
      print('Webhook notification handled successfully');
    } else {
      // Handle error
      print('Failed to handle webhook notification');
    }
  }
}
