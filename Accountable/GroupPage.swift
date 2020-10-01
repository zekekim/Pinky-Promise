//
//  GroupPage.swift
//  Accountable
//
//  Created by Ezekiel Kim on 8/15/20.
//

import SwiftUI
import Firebase
import FirebaseFirestoreSwift

struct GroupPage: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var model:GroupListModel
    var groupName: String
    var groupID: String
    let db = Firestore.firestore()
    let user = Auth.auth().currentUser
    @State var newUserEmail = ""
    @State var showNewUser = false
    var body: some View {
        NavigationView {
            VStack(spacing:0) {
                ZStack {
                    Text(groupName)
                        .padding()
                        .font(.title)
                        .foregroundColor(.blue)
                    HStack {
                        Image(systemName: "chevron.left")
                            .imageScale(.large)
                            .foregroundColor(/*@START_MENU_TOKEN@*/.blue/*@END_MENU_TOKEN@*/)
                            .padding(.leading, 20)
                            .onTapGesture(count: /*@START_MENU_TOKEN@*/1/*@END_MENU_TOKEN@*/, perform: {
                                presentationMode.wrappedValue.dismiss()
                            })
                        Spacer()
                    }
                }
                Divider()
                ScrollView {
                    ForEach(model.currentParticipants, id:
                                    \.self) { participant in
                        if(participant != user!.email!) {
                            UserRow(groupName: groupName, groupID: groupID, email: participant)
                        } else {
                            PersonalRow(groupName: groupName, groupID: groupID)
                        }
                    }
                    if(showNewUser) {
                        HStack {
                            TextField("email", text: $newUserEmail)
                        }
                        .padding()
                        Divider()
                    }

                    HStack {
                        Image(systemName: showNewUser ? "checkmark" : "plus.circle")
                            .imageScale(.large)
                            .padding(5)
                            .foregroundColor(newUserEmail != "" ? .green: .gray)
                            .onTapGesture(count: /*@START_MENU_TOKEN@*/1/*@END_MENU_TOKEN@*/, perform: {
                                if (showNewUser) {
                                    inviteParticipants()
                                } else {
                                    withAnimation {
                                        showNewUser.toggle()
                                    }
                                }
                            })
                        if(showNewUser) {
                            Image(systemName: "xmark")
                                .imageScale(.large)
                                .padding(5)
                                .foregroundColor(newUserEmail != "" ? .red: .gray )
                                .onTapGesture(count: /*@START_MENU_TOKEN@*/1/*@END_MENU_TOKEN@*/, perform: {
                                    withAnimation {
                                        showNewUser.toggle()
                                    }
                                })
                        }
                        if(!showNewUser ) {
                            Text("add a new user")
                                .foregroundColor(.gray)
                                .padding(.trailing, 5)
                                .onTapGesture(count: /*@START_MENU_TOKEN@*/1/*@END_MENU_TOKEN@*/, perform: {
                                    showNewUser.toggle()
                                })
                        }
                    }
                    .padding()
                }
            }
            .onAppear(perform: {
                model.fetchGroup()
            })
            .navigationBarHidden(true)
            .navigationBarTitle("")
            .navigationBarBackButtonHidden(true)
        }
        .navigationBarHidden(true)
        .navigationBarTitle("")
        .navigationBarBackButtonHidden(true)
    }
    func inviteParticipants() {
        model.email = newUserEmail
        model.fetchUser()
        db.collection("groups").document(groupID).setData([
            "invites" : FieldValue.arrayUnion([newUserEmail])
        ], merge: true) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Group Document successfully written!")
                db.collection("users").document(newUserEmail).setData([
                    "invites": FieldValue.arrayUnion([groupID])
                ], merge: true) { err in
                    if let err = err {
                        print("Error writing document: \(err)")
                    } else {
                        print("Group Document successfully written!")
                        db.collection("notifications").document("invites").setData([
                            "\(groupName)": model.fcmToken
                        ], merge: true) { err in
                            if let err = err {
                                print("Error writing document: \(err)")
                            } else {
                                print("Group Document successfully written!")
                                
                            }
                        }
                    }
                }
            }
        }
    }
}

struct GroupPage_Previews: PreviewProvider {
    static var previews: some View {
        GroupPage(groupName: "Kooks", groupID: "")
    }
}
