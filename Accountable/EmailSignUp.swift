//
//  EmailLogin.swift
//  Accountable
//
//  Created by Ezekiel Kim on 7/6/20.
//

import SwiftUI
import Firebase

struct EmailSignUp: View {
    @State var firstName = ""
    @State var lastName = ""
    @State var email = ""
    @State var username = ""
    @State var password = ""
    @State var confirmPassword = ""
    @State var isLoading = false
    @State var unfilledError = false
    @State var passwordError = false
    @State var creationError = false
    @State var errorMessage = ""
    @State var navigation: Int?
    @EnvironmentObject var glistmodel: GroupListModel
    let db = Firestore.firestore()
    
    var body: some View {
        NavigationView {
            ZStack {
                NavigationLink(
                    destination: GroupsList().environmentObject(glistmodel),
                    tag: 1, selection: $navigation) {
                        EmptyView()
                    }
                NavigationLink(
                    destination: EmailLogin().environmentObject(glistmodel),
                    tag: 2, selection: $navigation) {
                        EmptyView()
                    }
                VStack(spacing: 15) {
                    
                    Text("accountable")
                        .font(.largeTitle)
                        .foregroundColor(Color.blue)
                        .padding()
                    VStack (spacing: 15) {
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
                        VStack(spacing:0) {
                            HStack {
                                Image(systemName: "person")
                                    .foregroundColor(.gray)
                                    .frame(width: 30, height: 25)
                                TextField("first name"
                                          , text: $firstName)
                                    .autocapitalization(/*@START_MENU_TOKEN@*/.none/*@END_MENU_TOKEN@*/)
                            }
                            .padding(10)
                            Divider()
                            HStack {
                                Image(systemName: "person")
                                    .foregroundColor(.clear)
                                    .frame(width: 30, height: 25)
                                TextField("last name"
                                          , text: $lastName)
                                    .autocapitalization(/*@START_MENU_TOKEN@*/.none/*@END_MENU_TOKEN@*/)
                            }
                            .padding(10)
                        }
                        .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(Color.gray, lineWidth: 1)
                        )
                        
                        
                        VStack(spacing:0) {
                            HStack {
                                Image(systemName: "lock")
                                    .foregroundColor(.gray)
                                    .frame(width:30, height: 20)
                                SecureField("password", text: $password)
                            }
                            .padding(10)
                            HStack {
                                Image(systemName: "lock")
                                    .foregroundColor(.clear)
                                    .frame(width:30, height: 20)
                                SecureField("confirm password", text: $confirmPassword)
                            }
                            .padding(10)
                        }
                        .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(Color.gray, lineWidth: 1)
                                )
                        .padding(.bottom)
                    }
                    Button(action: {
                        if (email == ""  || firstName == "" || lastName == "" || password == "" || confirmPassword == "") {
                            unfilledError = true
                        } else if (password == confirmPassword) {
                            unfilledError = false
                            passwordError = false
                            isLoading = true
                            Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                                if error != nil {
                                    print(error!.localizedDescription)
                                    creationError = true
                                    errorMessage = error!.localizedDescription
                                    return
                                }
                                guard let  authResult = authResult else { return }
                                let firUser = authResult.user
                                let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                                changeRequest?.displayName = "\(firstName) \(lastName)"
                                changeRequest?.commitChanges { (error) in
                                    if error != nil {
                                        print(error!.localizedDescription)
                                    } else {
                                        creationError = false
                                        print("Document successfully written!")
                                        db.collection("users").document(email).setData([
                                            "firstName": firstName,
                                            "lastName": lastName,
                                            "uid": firUser.uid,
                                            "groups": [
                                            ],
                                            "invites": [
                                            ]
                                        ]) { err in
                                            if let err = err {
                                                print("Error writing document: \(err)")
                                            } else {
                                                creationError = false
                                                print("Document successfully written!")
                                                glistmodel.email = email
                                                isLoading = false
                                                navigation = 1
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        else {
                            passwordError = true
                        }
                    }, label: {
                        Text("create new user")
                            .padding()
                            .frame(maxWidth: .infinity)
                            .foregroundColor(Color.white)
                            .background((email == ""  || firstName == "" || lastName == "" || password == "" || confirmPassword == "") ? Color.gray : Color.blue)
                            .cornerRadius(20)
                            

                    })
                        .disabled(email == ""  || firstName == "" || lastName == "" || password == "" || confirmPassword == "")
                        .padding(.bottom)
                    if (unfilledError || passwordError || creationError) {
                        HStack {
                            Image(systemName:
                                "exclamationmark.triangle")
                                .foregroundColor(.red)
                                .frame(width: 30, height: 25)
                            if(unfilledError) {
                                Text("Please fill in all the required fields.")
                                    .foregroundColor(.red)
                            }
                            if (passwordError) {
                                Text("Passwords do not match.")
                                    .foregroundColor(.red)
                            }
                            if (creationError) {
                                Text(errorMessage)
                                    .foregroundColor(.red)
                            }
                        }
                        .padding(.bottom)
                    }
                    Button(action: {
                        navigation = 2
                    }, label: {
                        Text("already have an account? login here.")
                            .foregroundColor(.gray)
                            .font(.caption)
                    })
                }
                .padding()
                .navigationBarHidden(true)
                .navigationBarTitle("")
                .navigationBarBackButtonHidden(true)
                .edgesIgnoringSafeArea([.top, .bottom])
                .disabled(isLoading)
                .blur(radius: isLoading ? 3 : 0)
            }
            if(isLoading) {
                ProgressView()
            }
        }
        .navigationBarHidden(true)
        .navigationBarTitle("")
        .edgesIgnoringSafeArea([.top, .bottom])
        .navigationBarBackButtonHidden(true)
    }
    
}

 

struct EmailSignUp_Previews: PreviewProvider {
    static var previews: some View {
        EmailSignUp()
    }
}
