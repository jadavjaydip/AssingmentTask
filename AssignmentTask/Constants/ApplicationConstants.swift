//
//  ApplicationConstants.swift
//  AssignmentTask
//
//  Created by j on 11/09/24.
//

import Foundation
import CryptoKit


let key = SymmetricKey(size: .bits256) // Generate a 256-bit AES key

// Encrypt password using AES
func encryptPassword(password: String) -> String? {
    guard let data = password.data(using: .utf8) else { return nil }
    
    do {
        let sealedBox = try AES.GCM.seal(data, using: key)
        return sealedBox.combined?.base64EncodedString() // Return encrypted password in Base64
    } catch {
        print("Encryption failed: \(error)")
        return nil
    }
}

// Decrypt password using AES
func decryptPassword(encryptedText: String) -> String? {
    guard let combinedData = Data(base64Encoded: encryptedText) else { return nil }
    
    do {
        let sealedBox = try AES.GCM.SealedBox(combined: combinedData)
        let decryptedData = try AES.GCM.open(sealedBox, using: key)
        return String(data: decryptedData, encoding: .utf8) // Convert decrypted data back to string
    } catch {
        print("Decryption failed: \(error)")
        return nil
    }
}
