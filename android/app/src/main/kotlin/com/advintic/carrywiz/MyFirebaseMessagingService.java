
// package com.advintic.carrywiz;

// import android.content.Intent;
// import android.content.SharedPreferences;
// import android.preference.PreferenceManager;
// import android.util.Log;

// import com.google.firebase.iid.FirebaseInstanceId;
// import com.google.firebase.messaging.RemoteMessage;

// import java.io.IOException;

// // import io.flutter.plugins.firebasemessaging.FlutterFirebaseMessagingService;

// /**
//  * NOTE: There can only be one service in each app that receives FCM messages. If multiple
//  * are declared in the Manifest then the first one will be chosen.
//  *
//  * In order to make this Java sample functional, you must remove the following from the Kotlin messaging
//  * service in the AndroidManifest.xml:
//  *
//  * <intent-filter>
//  *   <action android:name="com.google.firebase.MESSAGING_EVENT" />
//  * </intent-filter>
//  */
// public class MyFirebaseMessagingService extends FlutterFirebaseMessagingService {

//   private static final String TAG = "MyFirebaseMsgService";

//   @Override
//   public void onNewToken(String token) {
//     Log.d(TAG, "Refreshed token: " + token);
//     // Access Shared Preferences
//     SharedPreferences preferences = PreferenceManager.getDefaultSharedPreferences(this);
//     SharedPreferences.Editor editor = preferences.edit();

//     // Save to SharedPreferences
//     editor.putString("firebase_token", token);
//     editor.apply();
//     Log.d(TAG, "token saved");
//   }



//   /**
//    * Called when message is received.
//    *
//    * @param remoteMessage Object representing the message received from Firebase Cloud Messaging.
//    */
//   // [START receive_message]

//   // [END receive_message]


//   // [START on_new_token]

//   /**
//    * Called if InstanceID token is updated. This may occur if the security of
//    * the previous token had been compromised. Note that this is called when the InstanceID token
//    * is initially generated so this is where you would retrieve the token.
//    */

//   // [END on_new_token]


//   /**
//    * Handle time allotted to BroadcastReceivers.
//    */
//   private void handleNow() {
//     Log.d(TAG, "Short lived task is done.");
//   }

//   /**
//    * Persist token to third-party servers.
//    *
//    * Modify this method to associate the user's FCM InstanceID token with any server-side account
//    * maintained by your application.
//    *
//    */
//   private String getTokenFromPrefs()
//   {
//     SharedPreferences preferences = PreferenceManager.getDefaultSharedPreferences(this);
//     return preferences.getString("registration_id", null);
//   }

//   private void sendRegistrationToServer(String token) {
//     // TODO: Implement this method to send token to your app server.
//   }


//   private void saveTokenToPrefs(String _token)
//   {
//     // Access Shared Preferences
//     SharedPreferences preferences = PreferenceManager.getDefaultSharedPreferences(this);
//     SharedPreferences.Editor editor = preferences.edit();

//     // Save to SharedPreferences
//     editor.putString("registration_id", _token);
//     editor.apply();
//   }

//   @Override
//   public void onMessageReceived(RemoteMessage remoteMessage) {
//     super.onMessageReceived(remoteMessage);
//     Log.d(TAG, "onMessageReceived called");
//   }


// }