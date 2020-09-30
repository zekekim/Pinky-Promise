//
//  EmailLogin.swift
//  Accountable
//
//  Created by Ezekiel Kim on 7/6/20.
//

import SwiftUI
import Firebase

struct EmailLogin: View {
    @State var email = ""
    @State var password = ""
    @State var unfilledError = false
    @State var loginError = false
    @State var errorMessage = ""
    @State var isLoading = false
    @State var navigation: Int?
    @EnvironmentObject var glistModel:GroupListModel
    let db = Firestore.firestore()
    var body: some View {
        NavigationView {
            ZStack {
                if(isLoading) {
                    ProgressView()
                }
                NavigationLink(
                    destination: GroupsList().environmentObject(glistModel),
                    tag: 1, selection: $navigation) {
                        EmptyView()
                    }
                NavigationLink(
                    destination: EmailSignUp().environmentObject(glistModel),
                    tag: 2, selection: $navigation) {
                        EmptyView()
                    }
                VStack(spacing: 15) {
                    
                    Text("Accountable")
                        .font(.largeTitle)
                        .foregroundColor(.blue)
                        .padding()
                    HStack {
                        Image(systemName: "envelope")
                            .foregroundColor(.gray)
                            .frame(width: 30, height: 30)
                        TextField("email"
                                  , text: $email)
                            .autocapitalization(/*@START_MENU_TOKEN@*/.none/*@END_MENU_TOKEN@*/)
                    }
                    .padding(10)
                    .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.gray, lineWidth: 1)
                            )
                        
                    HStack {
                        Image(systemName: "lock")
                            .foregroundColor(.gray)
                            .frame(width:30, height: 30)
                        SecureField("password", text: $password)
                    }
                    .padding(10)
                    .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.gray, lineWidth: 1)
                            )
                    .padding(.bottom)
                    Button(action: {
                        isLoading = true
                        DispatchQueue.main.async {
                            Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
                                if error != nil {
                                    print(error!.localizedDescription)
                                    loginError = true
                                    errorMessage =  error!.localizedDescription
                                    isLoading = false
                                    
                                    return
                                }
                                if(authResult != nil) {
                                    db.collection("users").document(authResult!.user.email!).setData([
                                        "fcmtoken": "\(Messaging.messaging().fcmToken!)"
                                    
                                    ], merge: true) { err in
                                        if let err = err {
                                            print("Error writing document: \(err)")
                                        } else {
                                            isLoading = false
                                            navigation = 1
                                        }
                                    }
                                } else {
                                    return
                                }
                            }
                        }
                    }, label: {
                        Text("Login")
                            .padding()
                            .frame(maxWidth: .infinity)
                            .foregroundColor(Color.white)
                            .background((email == "" || password == "") ? Color.gray: Color.blue)
                            .cornerRadius(20)
                            

                    })
                    .disabled(email == "" || password == "")
                    .padding(.bottom)
                    if (unfilledError || loginError) {
                        HStack {
                            Image(systemName:
                                "exclamationmark.triangle")
                                .foregroundColor(.red)
                                .frame(width: 30, height: 25)
                            if(unfilledError) {
                                Text("Please fill in all the required fields.")
                                    .foregroundColor(.red)
                            }
                            if (loginError) {
                                Text(errorMessage)
                                    .foregroundColor(.red)
                            }
                        }
                        .padding(.bottom)
                    }
                    Button(action: {
                        navigation = 2
                    }, label: {
                        Text("don't have an account? Sign up here.")
                            .foregroundColor(.gray)
                            .font(.caption)
                    })
                }
                .padding()
                .navigationBarHidden(true)
                .navigationBarTitle("")
                .edgesIgnoringSafeArea([.top, .bottom])
                .disabled(isLoading)
                .blur(radius: isLoading ? 3 : 0)
            }
            .navigationBarHidden(true)
            .navigationBarTitle("")
            .edgesIgnoringSafeArea([.top, .bottom])
            .navigationBarBackButtonHidden(true)
        }
        .navigationBarHidden(true)
        .navigationBarTitle("")
        .edgesIgnoringSafeArea([.top, .bottom])
        .navigationBarBackButtonHidden(true)
    }
    
}

struct EmailLogin_Previews: PreviewProvider {
    static var previews: some View {
        EmailLogin()
    }
}
