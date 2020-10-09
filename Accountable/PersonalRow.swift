//
//  PersonalRow.swift
//  Accountable
//
//  Created by Ezekiel Kim on 9/30/20.
//
import UIKit
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
    
    init(groupName: String, groupID: String) {
        self.groupName = groupName
        self.groupID = groupID
        
    }
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                HStack {
                    TextField("tap to edit", text: $goal, onCommit: {
                        addGoal()
                    })
                    .padding([.bottom,.top])
                        .foregroundColor(.blue)
                        .font(.title2)
                    if(oldGoal != goal) {
                        Image(systemName: "xmark")
                            .foregroundColor(.red)
                            .imageScale(.small)
                            .onTapGesture(perform: {
                                goal = oldGoal
                                UIApplication.shared.endEditing()
                            })
                            .padding()
                    }
                }
                HStack {
                    Text(user!.displayName ?? "")
                        .foregroundColor(.gray)
                        .font(.headline)
                    Spacer()
                }
            }
            Spacer()
            if(!completed) {
                Image(systemName: model.currentTapped.contains(user!.email!) ? "hand.point.left.fill" : "hand.point.left")
                    .foregroundColor(.gray)
                    .imageScale(.large)
            }
            Image(systemName: completed ? "checkmark.circle.fill" : "checkmark.circle")
                .foregroundColor(completed ? .green : .gray)
                .imageScale(.large)
                .onTapGesture(perform: {
                    completed.toggle()
                    completeGoal()
                })
        }
        .onAppear(perform: {
            model.getGoals(groupID: groupID)
            print(model.currentGroupGoals)
            model.email = user!.email!
            model.fetchUser()
            if(model.currentCompleted.contains(user!.email!)) {
                completed = true
            }
            if (model.currentGroupGoals[user!.email!.replacingOccurrences(of: ".com", with: "")] != nil) {
                goal = model.currentGroupGoals[user!.email!.replacingOccurrences(of: ".com", with: "")]!
                print(model.currentGroupGoals[user!.email!.replacingOccurrences(of: ".com", with: "")]!)
            }
            oldGoal = goal
        })
        .padding()
    }
    func completeGoal() {
        if (completed == true) {
            db.collection("groups").document(groupID).updateData([
                "completed": FieldValue.arrayUnion([user!.email!]),
                "tapped": FieldValue.arrayRemove([user!.email!])
            ]) { err in
                    
                if let err = err {
                    print("Error writing document: \(err)")
                } else {
                    print("Group Document successfully written!")
                }
            }
        } else if (completed == false) {
            db.collection("groups").document(groupID).updateData([
                "completed": FieldValue.arrayRemove([user!.email!])
            ]) { err in
                if let err = err {
                    print("Error writing document: \(err)")
                } else {
                    print("Group Document successfully written!")
                }
            }
        }
        model.fetchGroup()
    }
    func addGoal() {
        let email = user!.email!.replacingOccurrences(of: ".com", with: "")
        db.collection("groups").document(groupID).updateData([
                "goals.\(email)" : goal
        ]) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("addedGoal successfully written!")
            }
        }
        oldGoal = goal
        model.fetchGroup()
    }
}

struct PersonalRow_Previews: PreviewProvider {
    static var previews: some View {
        PersonalRow(groupName: "grop", groupID: "")
    }
}

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
