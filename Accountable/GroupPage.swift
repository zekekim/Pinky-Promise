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
    @State var newUserEmail = ""
    @State var showNewUser = true
    var body: some View {
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
                List {
                    
                }
                if(showNewUser) {
                    HStack {
                        TextField("email", text: $newUserEmail)
                    }
                    .padding()
                }
                Divider()
                Button(action: {
                    withAnimation {
                    }
                }, label: {
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
                        }
                        if(!showNewUser ) {
                            Text("add a new user")
                                .foregroundColor(.gray)
                                .padding(.trailing, 5)
                        }
                        
                    }
                })
                .padding()
            }
        }
        .navigationBarHidden(true)
        .navigationBarTitle("")
        .navigationBarBackButtonHidden(true)
    }
    func inviteParticipants() {
        model.email = newUserEmail
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
                        withAnimation {
                            showNewUser.toggle()
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
