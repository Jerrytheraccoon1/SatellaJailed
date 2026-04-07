import Jinx
import UIKit

struct Tweak {
    // Tracks if the staff member has logged in successfully
    static var isAuthorized = false

    static func ctor() {
        if isAuthorized {
            // --- Original Satella Hooks (Now Protected) ---
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
                if Preferences.isGesture {
                    WindowHook().hook()
                }
                
                guard !Preferences.isHidden else {
                    return
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    let rootVC: UIViewController? = UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.rootViewController
                    rootVC?.add(SatellaController.shared)
                }
            }
        } else {
            // Wait 2 seconds for the game to load, then ask for the staff key
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                showMaxHostLogin()
            }
        }
    }

    // Displays the "Staff Only" login box
    static func showMaxHostLogin() {
        let alert = UIAlertController(
            title: "MaxHost Management", 
            message: "Please enter your Staff Access Key to enable Giveaway Tools.", 
            preferredStyle: .alert
        )
        
        alert.addTextField { textField in
            textField.placeholder = "Staff Key"
            textField.isSecureTextEntry = true
        }
        
        let loginAction = UIAlertAction(title: "Verify", style: .default) { _ in
            let enteredKey = alert.textFields?.first?.text ?? ""
            checkKeyWithVPS(key: enteredKey)
        }
        
        alert.addAction(loginAction)
        
        // Find the top window to show the alert over CPM
        if let rootVC = UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.rootViewController {
            rootVC.present(alert, animated: true, completion: nil)
        }
    }

    // Pings your Python Dashboard on MaxHost
    static func checkKeyWithVPS(key: String) {
        let urlString = "http://77.90.13.115:5559/verify?key=\(key)"
        guard let url = URL(string: urlString) else { return }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, let responseString = String(data: data, encoding: .utf8) else {
                // If VPS is down, show the login again
                DispatchQueue.main.async { showMaxHostLogin() }
                return
            }
            
            if responseString.contains("AUTHORIZED") {
                DispatchQueue.main.async {
                    self.isAuthorized = true
                    // Re-run the constructor to fire the hooks now that we are logged in
                    self.ctor()
                }
            } else {
                // Wrong key, try again
                DispatchQueue.main.async {
                    showMaxHostLogin()
                }
            }
        }
        task.resume()
    }
}

// Entry point for the dylib injection
@_cdecl("jinx_entry")
func jinxEntry() {
    Tweak.ctor()
}
