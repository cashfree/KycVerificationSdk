# KycVerificationSdk

The `KycVerificationSdk` is a Swift-based SDK designed to streamline the KYC (Know Your Customer) verification process. It provides a seamless integration for developers to implement KYC workflows, including video KYC, secure sharing, and user verification, with minimal effort

---

## Features

- **KYC Verification**: Easily integrate KYC workflows into your app.
- **Secure Sharing**: Enable secure sharing of user data with session-based authentication.
- **Permissions Management**: Automatically handle camera, microphone, and location permissions.
- **Calendar Integration**: Add KYC-related events to the user's calendar.
- **Customizable UI**: Use pre-built views or customize them to match your app's design.

---

## Requirements

- **iOS Version**: iOS 13.0 or later
- **Swift Version**: Swift 5.0 or later
- **Xcode Version**: Xcode 14.0 or later

---

## Installation

### Swift Package Manager (SPM)

1. Open your Xcode project.
2. Go to **File > Add Packages**.
3. Enter the repository URL for the SDK.
4. Select the version and add the package to your project.

---

## Permissions

The SDK requires the following permissions to function properly. Add these keys to your app's `Info.plist` file:

```xml
<key>NSCameraUsageDescription</key>
<string>We need access to your camera for KYC verification</string>

<key>NSMicrophoneUsageDescription</key>
<string>We need access to your microphone for video KYC verification</string>

<key>NSLocationWhenInUseUsageDescription</key>
<string>We need your location to enhance security and verify your session</string>
```



### Sample integration

```
import UIKit
import KycVerificationSdk

class ViewController: UIViewController,VerificationResponseDelegate, CFSecureShareResponseDelegate {
  
    
    @IBOutlet weak var kycUrl: UITextField!
    
    @IBOutlet weak var token: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // Add tap gesture to dismiss keyboard when touching outside
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @IBAction func onVerifyPress(_ sender: UIButton) {
        
        guard let kycUrl = kycUrl.text, !kycUrl.isEmpty else {
            showErrorAlert(title: "Error", message: "KYC URL cannot be empty")
            return
        }

         let accessTokentwo = token.text ?? ""
        
        do{
            
            let kycService = CFVerificationService.getInstance()
            try kycService.doVerification(kycUrl, self, self, accessTokentwo)
                                          
        }catch let e{
            
            let error = e as! VerificationError
            print(error)
            
        }
    }
    
    func onVerificationCompletion(verificationResponse: KycVerificationSdk.CFVerificationResponse) {
        if verificationResponse.status == "SUCCESS" {
            showErrorAlert(title:"Success",message: "Verification Succes")
        }else{
            showErrorAlert(title:"Error",message: "Verification failed please try again")
        }
    }
    
    func onErrorResponse(errorReponse: KycVerificationSdk.CFErrorResponse) {
        showErrorAlert(title:"Error",message: errorReponse.message ?? "")
    }
    
    func showErrorAlert(title:String,message: String) {
        if let presentedVC = self.presentedViewController {
            presentedVC.dismiss(animated: true) { [weak self] in
                self?.presentAlert(title:title,message: message)
            }
        } else {
            presentAlert(title:title,message: message)
        }
        
    }
    private func presentAlert(title:String,message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func onVerification(_ verificationResponse: KycVerificationSdk.CFSecureShareResponse) {
        showErrorAlert(title:"sendVaultVerificationResponse",message: verificationResponse.verificationId ?? "N/A")
    }
    
    func onVerificationError(_ errorResponse: KycVerificationSdk.CFSecureShareErrorResponse) {
        showErrorAlert(title:"Success",message: errorResponse.status ?? "N/A")
    }
    
    func onUserDrop(_ userDropResponse: KycVerificationSdk.CFUserDropResponse) {
        showErrorAlert(title:"Success",message: userDropResponse.verificationId ?? "N/A")
    }
    
    
    func onVkycCloseResponse(verificationResponse: KycVerificationSdk.CFVKycCloseResponse) {
        showErrorAlert(title:"onVkycCloseResponse",message: "N/A")
    }


}
```