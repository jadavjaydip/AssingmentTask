//
//  PasswordEditAndDeleteView.swift
//  AssignmentTask
//
//  Created by j on 18/09/36.
//

import Foundation
import SwiftUI

// View for editing and deleting a password entry
struct PasswordEditAndDeleteView: View {
    @Environment(\.managedObjectContext) private var viewContext // Core Data context for database operations
    @Environment(\.presentationMode) var presentationMode // Used to dismiss the view
    
    var password: Password // The password entry being edited
    @State var accountType: String = "" // State variable for account type
    @State var username: String = "" // State variable for username
    @State var passwordText: String = "" // State variable for password
    @State private var showPassword = false // State variable to toggle password visibility
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header with a visual divider
            HStack {
                Spacer()
                Text("")
                    .frame(width: 60, height: 5)
                    .background(Color.gray)
                    .clipShape(Capsule())
                Spacer()
            }
            Text("Account Details")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(Color.blue)
            
            // Field for account type
            FiledView(title: "Account Type", text: $accountType)
            // Field for username
            FiledView(title: "UserName", text: $username)
            
            // Password field with toggle for visibility
            VStack(alignment: .leading, spacing: 0) {
                Text("Password")
                    .font(.subheadline)
                    .fontWeight(.regular)
                    .foregroundColor(Color.gray)
                HStack {
                    if showPassword {
                        TextField("Password", text: $passwordText)
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(Color.black)
                    } else {
                        SecureField("Password", text: $passwordText)
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(Color.black)
                    }
                    Button(action: {
                        self.showPassword.toggle() // Toggle password visibility
                    }) {
                        Image(systemName: showPassword ? "eye" : "eye.slash")
                            .renderingMode(.template)
                            .foregroundColor(Color.gray)
                    }
                    .frame(width: 40, height: 40)
                }
                .frame(height: 40)
            }
            
            Spacer()
            
            // Buttons for saving changes or deleting the password
            HStack {
                Button {
                    saveChanges() // Save changes to the password entry
                } label: {
                    Text("Edit")
                        .font(.title3)
                        .foregroundColor(.white)
                        .frame(height: 40)
                        .frame(maxWidth: .infinity)
                        .background(Color.black)
                        .clipShape(Capsule())
                }
                Spacer()
                Button {
                    deletePassword() // Delete the password entry
                } label: {
                    Text("Delete")
                        .font(.title3)
                        .foregroundColor(.white)
                        .frame(height: 40)
                        .frame(maxWidth: .infinity)
                        .background(Color.red)
                        .clipShape(Capsule())
                }
            }
        }
        .padding(10) // Padding around the content
    }
    
    // Function to save changes to the password entry
    private func saveChanges() {
        password.accountType = accountType // Update the account type
        password.username = username // Update the username
        
        // Encrypt the password before saving
        if let encrypted = encryptPassword(password: passwordText) {
            self.passwordText = encrypted
            password.password = self.passwordText // Update the password
        }
        
        do {
            try viewContext.save() // Save changes to Core Data
            presentationMode.wrappedValue.dismiss() // Dismiss the view
        } catch {
            print("Failed to save changes: \(error.localizedDescription)") // Handle save error
        }
    }
    
    // Function to delete the password entry
    private func deletePassword() {
        viewContext.delete(password) // Delete the password from Core Data
        do {
            try viewContext.save() // Save changes to Core Data
            presentationMode.wrappedValue.dismiss() // Dismiss the view
        } catch {
            print("Failed to delete the password: \(error.localizedDescription)") // Handle delete error
        }
    }
}
