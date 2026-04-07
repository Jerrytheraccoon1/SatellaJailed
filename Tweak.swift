import Jinx
import UIKit

struct Tweak {
    static var isAuthorized = false
    static let prefs = UserDefaults.standard
    static let authKeyName = "MaxHost_Staff_Token"

    static func ctor() {
        // 1. Check if we already have a saved, valid token
        if let savedKey = prefs.string(forKey: authKeyName) {
            checkKeyWithVPS(key: savedKey, autoLogin: true)
            return
        }
        
        // 2. If no key, show the login after the app loads
        showLoginUI()
    }

    static func activateHooks() {
        guard !isAuthorized else { return }
        isAuthorized = true
        
        // --- Original Satella Hooks ---
        CanPayHook().hook()
        DelegateHook().hook()
        TransactionHook().hook()
        
        if Preferences.isPriceZero { ProductHook().hook() }
        if Preferences.isObserver { ObserverHook().hook() }
        if Preferences.isStealth { DyldHook().hook() }
        
        if Preferences.isReceipt {
            ReceiptHook().hook()
            URLHook().hook()
        }
        
        if #available(iOS 15, *) {
            if Preferences.isGesture { WindowHook().hook() }
            guard !Preferences.isHidden else { return }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                let keyWindow = UIApplication.shared.windows.first(where: { $0.isKeyWindow })
                keyWindow?.rootViewController?.add(SatellaController.shared)
            }
        }
    }

    static func showLoginUI() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            let alert = UIAlertController(title: "MaxHost Management", message: "Enter Staff Access Key:", preferredStyle: .alert)
            alert.addTextField { $0.placeholder = "Staff Key"; $0.isSecureTextEntry = true }
            
            alert.addAction(UIAlertAction(title: "Verify", style: .default) { _ in
                let key = alert.textFields?.first?.text ?? ""
                checkKeyWithVPS(key: key, autoLogin: false)
            })
            
            let rootVC = UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.rootViewController
            rootVC?.present(alert, animated: true)
        }
    }

    static func checkKeyWithVPS(key: String, autoLogin: Bool) {
        // Change this to your actual VPS endpoint
        let urlString = "http://77.90.13.115:5559/verify?key=\(key)"
        guard let url = URL(string: urlString) else { return }
        
        var request = URLRequest(url: url)
        request.timeoutInterval = 5.0
        
        URLSession.shared.dataTask(with: request) { data, _, _ in
            guard let data = data, let response = String(data: data, encoding: .utf8), response.contains("AUTHORIZED") else {
                // If it fails and it was an auto-login, wipe the bad key
                if autoLogin { self.prefs.removeObject(forKey: authKeyName) }
                DispatchQueue.main.async { self.showLoginUI() }
                return
            }
            
            // Success: Save key and fire hooks
            self.prefs.set(key, forKey: authKeyName)
            DispatchQueue.main.async {
                self.activateHooks()
            }
        }.resume()
    }
}

@_cdecl("jinx_entry")
func jinxEntry() {
    Tweak.ctor()
}
