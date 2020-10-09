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
                                model.getGoals(groupID: groupID)
                                model.fetch()
                            })
                        Spacer()
                    }
                }
                Divider()
                ScrollView {
                    ForEach(model.currentParticipants, id:
                                    \.self) { participant in
                        if(participant != user!.email!) {
                            UserRow(groupName: groupName, groupID: groupID, email: participant).environmentObject(model)
                            Divider()
                        } else {
                            PersonalRow(groupName: groupName, groupID: groupID).environmentObject(model)
                            Divider()
                        }
                    }
                    if(showNewUser) {
                        HStack {
                            TextField("email", text: $newUserEmail, onCommit: {
                                inviteParticipants()
                            })
                            Spacer()
                            if(showNewUser) {
                                Image(systemName: "xmark")
                                    .imageScale(.small)
                                    .padding(5)
                                    .foregroundColor(newUserEmail != "" ? .red: .gray )
                                    .onTapGesture(count: /*@START_MENU_TOKEN@*/1/*@END_MENU_TOKEN@*/, perform: {
                                        withAnimation {
                                            showNewUser.toggle()
                                            UIApplication.shared.endEditing()
                                        }
                                    })
                            }
                        }
                        .padding()
                        Divider()
                    }

                    HStack {
                        Image(systemName: "plus.circle")
                            .imageScale(.large)
                            .padding(5)
                            .foregroundColor(newUserEmail != "" ? .green: .gray)
                            .onTapGesture(count: /*@START_MENU_TOKEN@*/1/*@END_MENU_TOKEN@*/, perform: {
                                withAnimation {
                                    showNewUser.toggle()
                                }
                            })
                        
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
            .animation(.easeIn)
            .onAppear(perform: {
                model.fetchGroup()
                model.getGoals(groupID: groupID)
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
        db.collection("groups").document(groupID).updateData([
            "invites" : FieldValue.arrayUnion([newUserEmail])
        ]) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Group Document successfully written!")
                db.collection("users").document(newUserEmail).updateData([
                    "invites": FieldValue.arrayUnion([groupID])
                ]) { err in
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
