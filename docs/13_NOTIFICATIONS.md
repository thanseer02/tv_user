# Notification helper: a beginner's guide

## What is included

`lib/helpers/notification_helper.dart` owns local Android/iOS banners, permission
requests, cancellation, and tap delivery. `main.dart` initializes it without
prompting the user. Unsupported platforms skip local setup.

`lib/helpers/firebase_notification_helper.dart` adds optional Firebase Cloud
Messaging (FCM) delivery. `lib/helpers/firebase_helper.dart` provides the unified
`FirebaseHelper` (and `FirebaseMessagingHelper`) facade familiar from the MI Taxi
reference project, connecting push setup, token retrieval, permission requests,
and local notification display. **Remote push is not enabled yet:** FairRide has no
Firebase project configuration. The reference application's Firebase settings,
Firestore user collection, topic subscriptions, and ride/chat routing were not
copied. These belong to that application's backend.

A **local notification** is created on this phone. A **push notification** arrives
from a server through FCM. A **payload** is extra data, such as a ride identifier,
that the app can inspect when the passenger taps the banner.

## Show a local notification

Call the helper from a ViewModel action. Explain why notifications are useful
before requesting permission. Replace the example text below with localized
strings in production.

```dart
final notifications = NotificationHelper.instance;
final allowed = await notifications.requestPermission();
if (!allowed) return;

// Standard show (id is optional - generates an automatic unique ID if omitted)
await notifications.show(
  title: 'Ride update',
  body: 'Your driver has arrived.',
  data: {'ride_id': 'example-ride'},
);

// Or convenience method (familiar from MI Taxi reference project)
await notifications.showNotificationWithDefaultSound(
  'Ride update',
  'Your driver has arrived.',
  data: {'ride_id': 'example-ride'},
);
```

This example payload is illustrative, not a backend contract. Specifying an `id`
(e.g. `101`) updates that banner if reused; another ID creates another banner.
`cancel(101)` removes one banner. `cancelAll()` clears all banners. These
methods do not request permission. Plugin failures propagate to the calling
ViewModel for handling. A successful `show` call does not guarantee visibility
if OS settings block it.

## Handle taps after login

The helper never navigates automatically. After authentication and the navigator
are ready, an app/session ViewModel should subscribe and drain queued taps:

```dart
// Store this subscription on the ViewModel; cancel it when the session ends.
subscription = NotificationHelper.instance.notificationTaps.listen(handleTap);
for (final data in NotificationHelper.instance.consumePendingTaps()) {
  handleTap(data);
}
```

`handleTap` is your app-specific method, not an existing helper method. Validate
payload fields, check access to the referenced ride, and use registered named
routes. Do not treat a payload as permission to view a passenger's data.
Only one app-level tap coordinator should own this subscription. Keep it active
for the authenticated session. Taps received without a subscriber are retained
in memory and returned once by `consumePendingTaps()`.

On logout, cancel the subscription, consume/discard pending taps, and clear
banners. Queued taps are not stored permanently. No routing is connected yet
because FairRide's push event contract and destinations have not been supplied.

## Enable Firebase delivery when FairRide configuration is available

1. Configure the **FairRide** Firebase project for the actual Android application
   ID and iOS bundle ID using FlutterFire. Do not copy MI Taxi configuration.
2. Follow Firebase's platform setup, including Android Google Services setup and
   iOS Push Notifications capability, APNs key, and Background Modes / Remote
   notifications. Keep Firebase method swizzling enabled on iOS.
3. Once configuration generates `firebase_options.dart`, add its import and
   Firebase/helper imports to `main.dart`. After Flutter binding initialization,
   initialize Firebase and start the delivery helper before `runApp`:

   ```dart
   await Firebase.initializeApp(
     options: DefaultFirebaseOptions.currentPlatform,
   );
   await NotificationHelper.instance.initialize();
   await FirebaseNotificationHelper.instance.start();
   ```

4. Ask for permission using `FirebaseNotificationHelper.instance.requestPermission()`
   at an appropriate user action. Use this permission method when FCM is enabled;
   there is no need to call both permission methods.
5. Read `getToken()` and subscribe to `tokenChanges` in the authenticated
   ViewModel. On iOS, a null token can mean APNs registration is still pending;
   retry later. Send tokens using a confirmed repository endpoint with
   `.setProgress(this)`. Token upload is deliberately not implemented without
   that API contract. Handle token stream errors and cancel the subscription on
   logout. Unlink the installation on the backend and delete its token as needed.

The packages were already present transitively through other dependencies and
are now declared directly because these helpers import them.

## What happens in each app state

| State | Banner | Tap handling |
| --- | --- | --- |
| App open | FCM listener creates a local banner | Local tap stream |
| App in background, notification payload | Operating system displays it | FCM opened-app listener |
| App closed, notification payload | Operating system displays it | Initial message queued at startup |
| Background data-only message | Background handler creates a local banner if title/body is present | Local tap or launch details |

Data-only background delivery is subject to OS limits and is not guaranteed.
The background handler is a top-level function with `@pragma('vm:entry-point')`
so release builds retain it. It only uses message data and the local plugin;
it does not call Firebase services. If future background work uses Firestore or
other Firebase services, initialize Firebase in that isolate first.

The helper reads `notification.title` / `notification.body`, falling back to
`data.title` and `data.body` / `data.message`. Events without visible text do not
produce a banner. These are display fallbacks, not ride-state business rules.
Image downloads, chat-screen suppression, automatic ride refresh, scheduled
notifications, and notification-history persistence are not implemented.
`stop()` cancels foreground FCM listeners; it does not disable OS delivery.

## Device verification

Run `fvm flutter test test/helpers/notification_helper_test.dart` for payload
validation and tap-queue checks. Then test on Android and iOS devices:

- Grant and deny permission; confirm app startup never prompts unexpectedly.
- Show two IDs, replace one, and cancel one without removing the other.
- Tap while the app is open, backgrounded, and closed; wait until login completes.
- After Firebase setup, send notification-plus-data and data-only messages.
  Confirm one banner per delivery and verify denied permission behavior.
- Test logout and login as another passenger; old pending taps must be cleared.

Android's white notification icon, default FCM channel metadata, and notification
permission are included. Existing Gradle desugaring is retained. iOS registers
its notification-center delegate. No Firebase credentials or APNs configuration
were added. Physical-device delivery and native builds still require validation.

References: [Firebase receive messages](https://firebase.google.com/docs/cloud-messaging/flutter/receive-messages),
[Firebase platform setup](https://firebase.google.com/docs/cloud-messaging/flutter/get-started),
and [local notifications 17.2.4](https://pub.dev/packages/flutter_local_notifications/versions/17.2.4).
