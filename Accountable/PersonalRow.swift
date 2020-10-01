//
//  PersonalRow.swift
//  Accountable
//
//  Created by Ezekiel Kim on 9/30/20.
//

import SwiftUI
import Firebase
import FirebaseFirestoreSwift

struct PersonalRow: View {
    var groupName: String
    var groupID: String
    var user = Auth.auth().currentUser
    let db = Firestore.firestore()
    @State var edited = false
    @State var name: String = ""
    @State var oldGoal: String = ""
    @State var goal: String = ""
    @State var completed: Bool = false
    @State var daysForgotten: Int = 0
    @EnvironmentObject var model:GroupListModel
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                TextField("tap to edit", text: $goal, onEditingChanged: { (isChanged) in
                    if isChanged {
                        edited = true
                    } else if !isChanged {
                        edited = false
                        oldGoal = goal
                    }
                })
                    .foregroundColor(.blue)
                    .font(.headline)
                HStack {
                    Text("user")
                        .foregroundColor(.gray)
                        .font(.caption)
                    Spacer()
                    if(edited){
                        Image(systemName: "checkmark")
                            .foregroundColor(.green)
                            .imageScale(.medium)
                            .onTapGesture(perform: {
                                addGoal()
                            })
                        Image(systemName: "xmark")
                            .foregroundColor(.red)
                            .imageScale(.medium)
                        Spacer()
                    }
                }
            }
            Image(systemName: completed ? "checkmark.circle.fill" : "checkmark.circle")
                .foregroundColor(completed ? .green : .gray)
                .onTapGesture(perform: {
                    completed.toggle()
                    completeGoal()
                })
        }
        .onAppear(perform: {
            model.email = user!.email!
            model.fetchUser()
            if(model.currentCompleted.contains(user!.email!)) {
                completed = true
            }
            if (model.currentGroupGoals[user!.email!] != nil) {
                goal = model.currentGroupGoals[user!.email!] ?? ""
            }
        })
        .padding()
    }
    func completeGoal() {
//        if (completed == true) {
//            db.collection("groups").document(groupID).updateData([
//                "completed": FieldValue.arrayUnion([user!.email!])
//            ]) { err in
//                if let err = err {
//                    print("Error writing document: \(err)")
//                } else {
//                    print("Group Document successfully written!")
//                }
//            }
//        } else if (completed == false) {
//            db.collection("groups").document(groupID).updateData([
//                "completed": FieldValue.arrayRemove([user!.email!])
//            ]) { err in
//                if let err = err {
//                    print("Error writing document: \(err)")
//                } else {
//                    print("Group Document successfully written!")
//                }
//            }
//        }
//        model.fetchGroup()
    }
    func addGoal() {
//        if(model.currentGroupGoals[user!.email!] != nil) {
//            db.collection("groups").document(groupID).updateData([
//                "goals": FieldValue.arrayRemove([[user!.email!]]),
//                "goals": FieldValue.arrayUnion([[user!.email! : goal]])
//            ]) { err in
//                if let err = err {
//                    print("Error writing document: \(err)")
//                } else {
//                    print("addedGoal successfully written!")
//                }
//            }
//            model.fetchGroup()
//        } else {
//            db.collection("groups").document(groupID).updateData([
//                "goals": FieldValue.arrayUnion([[user!.email! : goal]])
//            ]) { err in
//                if let err = err {
//                    print("Error writing document: \(err)")
//                } else {
//                    print("addedGoal successfully written!")
//                }
//            }
//            model.fetchGroup()
//        }
    }
}

struct PersonalRow_Previews: PreviewProvider {
    static var previews: some View {
        PersonalRow(groupName: "grop", groupID: "")
    }
}
