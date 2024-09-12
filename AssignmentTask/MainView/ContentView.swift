//
//  ContentView.swift
//  AssignmentTask
//
//  Created by j on 11/09/24.
//

import SwiftUI
import CoreData
import LocalAuthentication


struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext // private var viewContext
     @FetchRequest(
         sortDescriptors: [NSSortDescriptor(keyPath: \Password.accountType, ascending: true)],
         animation: .default
     )
     
     private var passwords: FetchedResults<Password>
     @State private var isAddPassword: Bool = false // Track if the add password sheet should be shown
     @State private var selectedPassword: Password? // Track the selected password for editing/deleting
     @State private var isUnlock = false // Track if the user is authenticated
     @State private var isSetPin = false // Track if the user needs to set a PIN
     @State private var isSecurePinFirst: String = "" // Store the first PIN input
     @State private var isSecurePinSecond: String = "" // Store the second PIN input for confirmation
     @State private var isError:Bool = false // Track if there is an error
     @State private var errorMessage: String = "" // Store the error message
     @State var userPIN = "" // Store the user's PIN
    @State private var isPresentEditSheet:Bool = false

    var body: some View {
      //  NavigationView {
            ZStack(alignment: .bottomTrailing) {
                Color("BG")
                    .ignoresSafeArea()
                if isUnlock {
                    VStack(alignment: .leading,spacing: 20) {
                        Text("Password Manager")
                            .font(.title)
                        
                        Divider().padding(.bottom, 20)
                        
                        ScrollView(showsIndicators: false) {
                            ForEach(passwords) {   password in
                                Button {
                                    self.selectedPassword = password
                                    isPresentEditSheet.toggle()
                                } label: {
                                    HStack(alignment: .center, spacing: 16) {
                                        Text(password.accountType ?? "Unknown")
                                            .font(.headline)
                                            .fontWeight(.bold)
                                            .foregroundColor(.black)
                                        Text("******")
                                            .foregroundColor(Color.gray.opacity(0.4))
                                        Spacer()
                                        Image("ic_rightArrow")
                                        
                                    }
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                }
                                    .frame(height: 50)
                                    .padding(.horizontal, 16)
                                    .background(
                                        RoundedRectangle(cornerRadius: 25, style: .continuous).stroke(Color.gray, lineWidth: 1)).padding(2)
                            }
                            
                        }.padding(.bottom, 40)
                        
                        
                        Spacer()
                    }.padding(.horizontal, 10)
                    
                    Button {
                        self.isAddPassword.toggle()
                    } label: {
                        Text("+")
                            .font(.title)
                            .foregroundColor(.white)
                            .frame(width: 50, height: 50)
                            .background(Color.blue)
                            .cornerRadius(12)
                    }
                    .padding(.trailing, 10)
                }else if isSetPin{
                    setUserPIN
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                        .padding(20)
                }
            }
            
       // }
       
        // MARK: Setup Configration
        .onAppear {
            authenticateWithBiomatrice()
            if let userPin = UserDefaults.standard.string(forKey: "PIN") {
                self.userPIN = userPin
            }
        }
        // MARK: Error Message
        .alert(isPresented: $isError) {
            Alert(title: Text("Password Tracker App"), message: Text(errorMessage), dismissButton: .default(Text("Ok")))
        }
        //MARK: SheetPresent
        .sheet(isPresented: $isAddPassword, content: {
            AddPasswordView()
                .presentationDetents([.height(400)])
                .presentationCornerRadius(24)
        })
        .sheet(isPresented: $isPresentEditSheet) {
            if let password = selectedPassword {
                PasswordEditAndDeleteView(password: password, accountType: password.accountType ?? "", username: password.username ?? "", passwordText: password.password ?? "")
                    .presentationDetents([.height(400)])
                    .presentationCornerRadius(24)
            }
          
        }
    }
    
    //MARK: Password Delete Functionality
    func deletePasswords(offsets: IndexSet) {
        withAnimation {
            offsets.map { passwords[$0] }.forEach(viewContext.delete)
            do {
                try viewContext.save()
            } catch {
                // Handle the Core Data error
                print("Failed to delete the password: \(error.localizedDescription)")
                self.errorMessage = error.localizedDescription
                self.isError = true
            }
        }
    }
    //MARK: Supported Biomatrice Device Condition Check
    private func authenticateWithBiomatrice(){
        let contex = LAContext()
        var error: NSError?
        if contex.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Authentication to unlock"
            contex.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, autheerror in
                DispatchQueue.main.async {
                    if success {
                        // if successs to open password list
                        self.isUnlock = true
                    }else {
                        self.errorMessage = autheerror?.localizedDescription ?? "Unknown"
                        self.isError = true
                    }
                }
            }
        }else {
            self.isSetPin = true
        }
    }
    
    //MARK: AuthenticationWithBiomatric Functionality
    // Fallback authentication method using device passcode
    func authenticationWithOutBioMetric() {
        let localAuthenticationContext = LAContext()
        localAuthenticationContext.localizedFallbackTitle = "Please use your Passcode"
        
        var authorizationError: NSError?
        let reason = "Authentication required to access the app"
        
        if localAuthenticationContext.canEvaluatePolicy(.deviceOwnerAuthentication, error: &authorizationError) {
            localAuthenticationContext.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) { success, evaluateError in
                if success {
                    self.isUnlock = true
                    print("Authenticated successfully!")
                } else {
                    guard let error = evaluateError else {
                        return
                    }
                    self.errorMessage = error.localizedDescription
                    self.isError = true
                    print(error)
                }
            }
        } else {
            guard let error = authorizationError else {
                return
            }
            print(error)
            self.errorMessage = error.localizedDescription
            self.isError = true
        }
    }
    
    //MARK: SetUp UerInput PIN
    private var setUserPIN:some View {
        VStack(spacing: 16) {
            if userPIN.isEmpty {
                Text("Set PIN")
                Text("Please enter secure PIN")
                // OTP view for the first PIN input
                OtpView(otpText: $isSecurePinFirst, activeIndicatorColor: Color.red, inactiveIndicatorColor: Color.black, length: 4) { otp in}
                Text("Please enter confirm PIN")
                // OTP view for the second PIN input for confirmation
                OtpView(otpText: $isSecurePinSecond, activeIndicatorColor: Color.red, inactiveIndicatorColor: Color.black, length: 4) { secondOtp in
                    if ValidationSetupPin() {
                        UserDefaults.standard.setValue(isSecurePinSecond, forKey: "PIN")
                        UserDefaults.standard.synchronize()
                        self.isUnlock = true
                    }
                    
                }
            }else {
                Text("Please enter PIN")
                
                // OTP view for the first PIN input
                OtpView(otpText: $isSecurePinFirst, activeIndicatorColor: Color.red, inactiveIndicatorColor: Color.black, length: 4) { otp in
                    if userPIN == isSecurePinFirst {
                        self.isUnlock = true
                    }else {
                        self.errorMessage = "Please enter valid PIN"
                        self.isError = true
                    }
                    
                }
            }
            
        }
        .padding()
        .background()
        .cornerRadius(8)
        .shadow(color: Color.black.opacity(0.1), radius: 16, x: 1, y: 1)
        
    }
    
    // Validate the PIN setup
    private func ValidationSetupPin() -> Bool {
        if isSecurePinFirst.trimmingCharacters(in: .whitespaces).isEmpty {
            self.errorMessage = "Please Enter PIN"
            self.isError = true
            return false
        }else if isSecurePinSecond.trimmingCharacters(in: .whitespaces).isEmpty {
            self.errorMessage = "Please Re-Enter PIN"
            self.isError = true
            return false
        }else if isSecurePinFirst != isSecurePinSecond {
            self.errorMessage = "PIN and Confirm PIN do not match."
            self.isError = true
            return false
        }
        return true
    }
}


