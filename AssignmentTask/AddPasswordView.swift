//
//  AddPasswordView.swift
//  AssignmentTask
//
//  Created by j on 18/09/36.
//

import SwiftUI
import CoreData

// View for adding a new password entry
struct AddPasswordView: View {
    @Environment(\.managedObjectContext) private var viewContext // Core Data context for saving the new password
    @Environment(\.presentationMode) var presentationMode // Used to dismiss the view

    @State private var accountType = "" // State variable for the account type
    @State private var username = "" // State variable for the username
    @State private var password = "" // State variable for the password
    
    @State private var errorMessage: String = "" // State variable for storing error messages
    @State private var isShowError: Bool = false // State variable for showing error alerts
    
    var body: some View {
        VStack(spacing: 25) {
            // A visual divider
            Text("")
                .frame(width: 60, height: 5, alignment: .center)
                .background(Color.gray)
                .clipShape(Capsule())
            
            // Custom text fields for input
            CustomTextFiledView(placeholder: "Account Type", text: $accountType)
            CustomTextFiledView(placeholder: "Username/Email", text: $username)
            CustomTextFiledView(placeholder: "Password", text: $password)
            
            // Button to add a new password entry
            Button {
                savePassword() // Trigger the save operation
            } label: {
                Text("Add New Account")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(height: 40)
                    .frame(maxWidth: .infinity)
                    .background(Color.black)
                    .clipShape(Capsule())
            }
            .padding(.top)
            
            Spacer()
        }
        .padding(10)
        .alert(isPresented: $isShowError) { // Display error messages
            Alert(title: Text("Password Tracker"), message: Text(errorMessage), dismissButton: .default(Text("Ok")))
        }
    }
    
    // Function to save the new password entry
    private func savePassword() {
        // Check if all fields are filled
        if !accountType.isEmpty && !username.isEmpty && !password.isEmpty {
            
            // Check for duplicate entries
            if !isDublicateEntry(accountname: accountType, username: username) {
                // Create a new Password entity
                let newPassword = Password(context: viewContext)
                newPassword.accountType = accountType
                newPassword.username = username
                
                // Encrypt the password
                if let encrypted = encryptPassword(password: password) {
                    self.password = encrypted
                    newPassword.password = encrypted
                } else {
                    self.errorMessage = "Failed to encrypt the password."
                    self.isShowError = true
                    return
                }
                
                do {
                    // Save the new entry to Core Data
                    try viewContext.save()
                    presentationMode.wrappedValue.dismiss() // Dismiss the view
                } catch {
                    self.errorMessage = "Failed to save the password: \(error.localizedDescription)"
                    self.isShowError = true
                }
            } else {
                self.errorMessage = "An entry for this app and username already exists."
                self.isShowError = true
            }
        } else {
            self.errorMessage = "All fields must be filled."
            self.isShowError = true
        }
    }
    
    // Function to check for duplicate entries
    private func isDublicateEntry(accountname: String, username: String) -> Bool {
        let fetchRequest: NSFetchRequest<Password> = Password.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "accountType == %@ AND username == %@", accountname, username)
        
        do {
            let result = try viewContext.fetch(fetchRequest)
            return !result.isEmpty
        } catch {
            self.errorMessage = error.localizedDescription
            self.isShowError = true
            return false
        }
    }
}
