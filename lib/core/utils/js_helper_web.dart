import 'dart:js' as js;

void requestNotificationPermission() {
  try {
    js.context.callMethod('requestNotificationPermission');
  } catch (e) {
    // ignore or print
  }
}

void playNotificationSound() {
  try {
    js.context.callMethod('playNotificationSound');
  } catch (e) {
    // ignore or print
  }
}

void showBrowserNotification(String title, String body, String url) {
  try {
    js.context.callMethod('showBrowserNotification', [
      title,
      js.JsObject.jsify({
        'body': body,
        'icon': 'favicon.png',
        'data': {'url': url}
      })
    ]);
  } catch (e) {
    // ignore or print
  }
}
