//
//  CFKycVerificationService.swift
//  KycVerificationSdk
//
//  Created by Renu Bisht on 25/06/24.
//

import Foundation
import UIKit

@objc
final public class CFVerificationService : NSObject{
    
    static let shared = CFVerificationService()
    
    private override init(){}
    
    static public func getInstance() -> CFVerificationService {
        return CFVerificationService.shared
    }
    
    
    private func buildVerificationURL(from url: String, token: String?) -> String? {
        let mode = (token?.isEmpty ?? true) ? "OTP" : "OTP_LESS"

        var shortCode: String?
        
        // Get shortCode from query parameter
        if url.contains("shortCode=") {
            let parts = url.components(separatedBy: "shortCode=")
            if parts.count > 1 {
                shortCode = parts[1].components(separatedBy: "&")[0]
            }
        }
        // Get shortCode from path (last segment)
        else {
            shortCode = url.components(separatedBy: "/").last
        }
        
        guard let code = shortCode else { return nil }
        
        let baseURL = url.components(separatedBy: "?")[0].components(separatedBy: "/" + code)[0]
        return "\(baseURL)/?shortCode=\(code)&mode=\(mode)"
    }
    
    @objc
    public func doVerification(_ url: String,_ viewController: UIViewController,_ callback: VerificationResponseDelegate,_ accessToken: String? = nil) throws{
        
       
            // 1. Validate base URL
            guard !url.isEmpty else {
                throw VerificationError.URL_MISSING
            }
            
          // 2. Build updated URL with the new function
           guard let updatedUrlString = buildVerificationURL(from: url, token: accessToken) else {
                    throw VerificationError.INVALID_URL
                }

            // 4. Validate final URL
            guard let _ = URL(string: updatedUrlString) else {
                throw VerificationError.INVALID_URL
            }
        
           print(updatedUrlString,"updatedUrlString")

    
        
            guard let navigationController = viewController.navigationController else {
                    throw NSError(domain: "NavigationControllerNotFound", code: 1, userInfo: nil)
                }
            // init(url: String, accessToken: String?, delegate: VerificationResponseDelegate) {
        
           let vc = CFKycVerificationViewController(url: updatedUrlString, accessToken: accessToken,delegate: callback)
      
        
          navigationController.pushViewController(vc, animated: true) 
    }
    
    @objc
       public func openSecureShare(_ sessionId: String,_ environment: Environment, _ viewController: UIViewController, _ callback: CFSecureShareResponseDelegate) throws {
           
           guard !sessionId.isEmpty else {
                   throw VerificationError.SESSION_ID_MISSING
               }
           
           let userVaultVC = UserVaultViewController(sessionId: sessionId,environment: environment, callback: callback)
           
          
           userVaultVC.modalPresentationStyle = .custom
           userVaultVC.transitioningDelegate = userVaultVC
           
           
           viewController.present(userVaultVC, animated: true, completion: nil)
       }
    
    
}
