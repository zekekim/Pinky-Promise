//
//  InviteList.swift
//  Accountable
//
//  Created by Ezekiel Kim on 8/4/20.
//

import SwiftUI
import Firebase

struct InviteList: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var model:GroupListModel
    let db = Firestore.firestore()
    var user = Auth.auth().currentUser

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                ZStack {
                    Text("invite list")
                        .padding()
                        .font(.title)
                        .foregroundColor(.blue)
                    HStack {
                        Image(systemName: "chevron.left")
                            .imageScale(.large)
                            .foregroundColor(.blue)
                            .padding(.leading,20)
                            .onTapGesture(count: /*@START_MENU_TOKEN@*/1/*@END_MENU_TOKEN@*/, perform: {
                                presentationMode.wrappedValue.dismiss()
                                model.fetch()
                            })
                        Spacer()
                    }
                    
                    
                }
                Divider()
                ScrollView {
                    ForEach(model.inviteNames, id: \.self) { invite in
                        VStack(spacing: 0) {
                            HStack {
                                Text(invite)
                                    .foregroundColor(.gray)
                                    .font(.title2)
                                Spacer()
                                HStack {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.green)
                                        .imageScale(.large)
                                        .onTapGesture(perform: {
                                            accept(groupID: model.invites[model.inviteNames.firstIndex(of: invite)!])
                                        })
                                    Image(systemName: "xmark")
                                        .foregroundColor(.red)
                                        .imageScale(.large)
                                        .onTapGesture(perform: {
                                            deny(groupID: model.invites[model.inviteNames.firstIndex(of: invite)!])
                                        })
                                }
                            }
                            .padding()
                        }
                        Divider()
                    }
                }
                Spacer()
                
            }
            .onAppear(perform: {
                model.getInvites()
            })
            .accentColor(.blue)
            .navigationBarTitle("")
            .navigationBarHidden(true)
            .navigationBarBackButtonHidden(true)
        }
        .accentColor(.blue)
        .navigationBarTitle("")
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
    }
    func accept(groupID: String) {
        db.collection("users").document(user!.email!).updateData([
            "invites": FieldValue.arrayRemove([groupID])
        ]) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Group Document successfully written!")
            }
        }
        db.collection("groups").document(groupID).updateData([
            "invites": FieldValue.arrayRemove([user!.email!]),
            "participants": FieldValue.arrayUnion([user!.email!])
        ]) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Group Document successfully written!")
            }
        }
        model.inviteNames = []
        model.getInvites()
    }
    func deny(groupID: String) {
        db.collection("users").document(user!.email!).updateData([
            "invites": FieldValue.arrayRemove([groupID])
        ]) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Group Document successfully written!")
            }
        }
        db.collection("groups").document(groupID).updateData([
            "invites": FieldValue.arrayRemove([user!.email!]),
        ]) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Group Document successfully written!")
            }
        }
        model.inviteNames = []
        model.getInvites()
    }
}

struct InviteList_Previews: PreviewProvider {
    static var previews: some View {
        InviteList()
    }
}
