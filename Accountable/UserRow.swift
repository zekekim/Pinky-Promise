//
//  UserRow.swift
//  Accountable
//
//  Created by Ezekiel Kim on 8/15/20.
//

import SwiftUI
import Firebase
import FirebaseFirestoreSwift

struct UserRow: View {
    var groupName: String
    var groupID: String
    var user = Auth.auth().currentUser
    var email = ""
    @State var name: String = ""
    @State var goal: String = ""
    @State var completed: Bool = false
    @State var daysForgotten: Int = 0
    @EnvironmentObject var model:GroupListModel
    let db = Firestore.firestore()
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(goal)
                    .foregroundColor(daysForgotten >= 3 ? .red : .black)
                    .font(.subheadline)
                HStack {
                    Text(name)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            Spacer()
            Image(systemName: completed ? "checkmark.circle.fill" : "hand.point.left")
                .foregroundColor(completed ? .green : .blue)
                .onTapGesture(count: /*@START_MENU_TOKEN@*/1/*@END_MENU_TOKEN@*/, perform: {
                    if(!completed) {
                        sendTap()
                    }
                })
                .disabled(model.currentTapped.contains(email))
        }
        .onAppear(perform: {
            DispatchQueue.main.async {
                model.email = email
                model.fetchUser()
                if(model.currentCompleted.contains(email)) {
                    completed = true
                }
                if (model.currentGroupGoals[email] != nil) {
                    goal = model.currentGroupGoals[email] ?? ""
                }
            }
        })
        .padding()
    }
    func sendTap() {
        model.fetchUser()
        db.collection("notifications").document("taps").setData([
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


struct UserRow_Previews: PreviewProvider {
    static var previews: some View {
        UserRow(groupName: "boys", groupID: "", name: "Boy", goal: "Be Boy", completed: true, daysForgotten: 3)
    }
}
