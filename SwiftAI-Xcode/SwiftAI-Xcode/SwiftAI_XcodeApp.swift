import SwiftUI
import UserNotifications

// Define your AppDelegate class for macOS
class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Request notification permission
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            // Handle the response if needed
            DispatchQueue.main.async {
                if granted {
                    print("Notification permission granted.")
                } else {
                    print("Notification permission denied.")
                }
            }
        }
    }
}

@main
struct SwiftAI_XcodeApp: App {
    // Use AppDelegate with your SwiftUI app for macOS
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
