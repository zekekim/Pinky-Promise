//
//  NewGroupPage.swift
//  Accountable
//
//  Created by Ezekiel Kim on 8/7/20.
//

import SwiftUI
import Firebase

struct NewGroupPage: View {
    @State var groupName = ""
    @State var groupDesc = ""
    @State var errorMessage = ""
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var model: GroupListModel
    let db = Firestore.firestore()
    let user = Auth.auth().currentUser
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text((groupName.count != 0) ? groupName : "new group")
                    .foregroundColor(/*@START_MENU_TOKEN@*/.blue/*@END_MENU_TOKEN@*/)
                    .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                    .padding()
                Spacer()
            }
            HStack {
                Image(systemName: "person.3")
                    .foregroundColor(.gray)
                    .frame(width:30, height: 30)
                TextField("group name", text: $groupName)
                    .onReceive(groupName.publisher.collect()) {
                            self.groupName = String($0.prefix(25))
                        }
                    .autocapitalization(.none)
            }
            .padding(10)
            .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.gray, lineWidth: 1)
                    )
            .padding()
            HStack {
                Text("characters left: \(25 - groupName.count)")
                    .foregroundColor(.gray)
                    .font(.caption)
                Spacer()
            }
            .padding(.leading)
            HStack {
                TextField("quick group description", text: $groupDesc)
                    .onReceive(groupDesc.publisher.collect()) {
                            self.groupDesc = String($0.prefix(40))
                        }
                    .autocapitalization(/*@START_MENU_TOKEN@*/.none/*@END_MENU_TOKEN@*/)
                .frame(height:30)
            }
            .padding(10)
            .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.gray, lineWidth: 1)
                    )
            .padding()
            HStack {
                Text("characters left: \(40 - groupDesc.count)")
                    .foregroundColor(.gray)
                    .font(.caption)
                Spacer()
            }
            .padding(.leading)
            Button (action: {
                if (groupName == "" && groupDesc == "") {
                    errorMessage = "please enter a group name and description"
                }else if(groupName == "") {
                    errorMessage = "please enter a group name"
                } else if (groupDesc == "") {
                    errorMessage = "please enter a group description"
                } else {
                    addGroup()
                }
            } ,label: {
                Text("create new group")
                    .frame(maxWidth:.infinity)
                    .padding()
                    .foregroundColor(.white)
                    .background(Color.blue)
                    .cornerRadius(15)
            })
            .padding()
            if (errorMessage != "") {
                Text(errorMessage)
                    .foregroundColor(.red)
            }
            Spacer()
        }
        .animation(nil)
        .background(Color.white)
    }
    
    func addGroup() {
        let emptyBoolDict : [String:Bool] = [:]
        let emptyStringDict: [String:String] = [:]
        let groupID = "\(UUID())"
        let today = Date()
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        let date = formatter.string(from: today)
        db.collection("groups").document(groupID).setData([
            "groupName" : groupName,
            "groupDescription": groupDesc,
            "goals": emptyStringDict,
            "tapped": emptyBoolDict,
            "completed": [],
            "admin" : user!.email!,
            "lastUpdated": date,
            "participants": [
                "\(user!.email!)"
            ],
            "invites": []
        
        ]) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Group Document successfully written!")
            }
        }
        db.collection("users").document(user!.email!).setData([
            "groups" : FieldValue.arrayUnion([groupID])
        ], merge: true) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Group Document successfully written!")
            }
        }
        model.fetch()
        presentationMode.wrappedValue.dismiss()
    }
}

struct NewGroupPage_Previews: PreviewProvider {
    static var previews: some View {
        NewGroupPage()
    }
}
