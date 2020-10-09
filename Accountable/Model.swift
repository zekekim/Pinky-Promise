//
//  Model.swift
//  Accountable
//
//  Created by Ezekiel Kim on 9/28/20.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

public class GroupListModel: ObservableObject {
    var user = Auth.auth().currentUser
    var firstName = ""
    var lastName = ""
    var groupName = ""
    var groupDesc = ""
    let db = Firestore.firestore()
    @Published var ifAdmin = false
    @Published var email = ""
    @Published var fcmToken = ""
    @Published var currentGroup = ""
    @Published var currentGroupName = ""
    @Published var currentGroupDesc = ""
    @Published var currentGroupGoals: [String:String] = [:]
    @Published var currentGroupInvites: [String] = []
    @Published var currentLastUpdated: String = ""
    @Published var currentCompleted: [String] = []
    @Published var groups: [String] = []
    @Published var groupNames: [String] = []
    @Published var groupDescs: [String] = []
    @Published var invites: [String] = []
    @Published var inviteNames: [String] = []
    @Published var currentParticipants: [String] = []
    @Published var currentTapped: [String] = []
    

    func fetch() {

            if Auth.auth().currentUser != nil {
              // User is signed in.
                self.groups = []
                self.groupNames = []
                self.groupDescs = []
                self.invites = []
                
                
                let docRef = self.db.collection("users").document(self.user!.email ?? self.email)
                docRef.getDocument { (document, error) in
                    let result = Result {
                        try document?.data(as: User.self)
                    }
                    switch result {
                    case .success(let userDB):
                        if let userDB = userDB {
                            // A `City` value was successfully initialized from the DocumentSnapshot.
                            self.firstName = userDB.firstName ?? ""
                            self.lastName = userDB.lastName ?? ""
                            self.groups = userDB.groups ?? []
                            print(self.groups)
                            self.invites = userDB.invites ?? []
                            print("\(userDB)")
                            self.groups.forEach {
                                let today = Date()
                                let formatter = DateFormatter()
                                formatter.dateStyle = .short
                                let date = formatter.string(from: today)
                                let groupID = $0
                                print($0)
                                let docRef = self.db.collection("groups").document($0)
                                docRef.getDocument { (document, error) in
                                    let result = Result {
                                        try document?.data(as: Group.self)
                                    }
                                    switch result {
                                    case .success(let groupDB):
                                        if let groupDB = groupDB {
                                            // A `City` value was successfully initialized from the DocumentSnapshot.
                                            print(groupDB.groupName)
                                            self.groupName = groupDB.groupName
                                            self.groupDesc = groupDB.groupDescription
                                            self.currentLastUpdated = groupDB.lastUpdated
                                            print("\(groupDB)")
                                            self.groupNames.append(self.groupName)
                                            if (date != self.currentLastUpdated) {
                                                self.db.collection("groups").document(groupID).updateData([
                                                    "completed" : FieldValue.delete(),
                                                    "lastUpdated" : date
                                                ]) { err in
                                                    if let err = err {
                                                        print("Error writing document: \(err)")
                                                    } else {
                                                        print("Group Document successfully written!")
                                                        self.fetchGroup()
                                                    }
                                                }
                                            }
                                        } else {
                                            // A nil value was successfully initialized from the DocumentSnapshot,
                                            // or the DocumentSnapshot was nil.
                                            print("Document does not exist")
                                        }
                                    case .failure(let error):
                                        // A `City` value could not be initialized from the DocumentSnapshot.
                                        print("Error decoding: \(error)")
                                    }
                                }
                            }
                        } else {
                            // A nil value was successfully initialized from the DocumentSnapshot,
                            // or the DocumentSnapshot was nil.
                            print("Document does not exist")
                        }
                    case .failure(let error):
                        // A `City` value could not be initialized from the DocumentSnapshot.
                        print("Error decoding: \(error)")
                    }
                }
                
            } else {
              // No user is signed in.
              // ...
            }
    }
    func fetchGroup() {
        DispatchQueue.main.async {
            let docRef = self.db.collection("groups").document(self.currentGroup)
            docRef.getDocument { (document, error) in
                let result = Result {
                    try document?.data(as: Group.self)
                }
                switch result {
                case .success(let groupDB):
                    if let groupDB = groupDB {
                        // A `City` value was successfully initialized from the DocumentSnapshot.
                        print(groupDB.groupName)
                        self.currentGroupName = groupDB.groupName
                        if(self.user!.email! == groupDB.admin) {
                            self.ifAdmin = true
                        } else {
                            self.ifAdmin = false
                        }
                        self.currentGroupDesc = groupDB.groupDescription
                        self.currentLastUpdated = groupDB.lastUpdated
                        self.currentGroupInvites = groupDB.invites ?? []
                        self.currentParticipants = groupDB.participants ?? []
                        self.currentCompleted = groupDB.completed ?? []
                        self.currentLastUpdated = groupDB.lastUpdated
                        self.currentTapped = groupDB.tapped ?? []
                        let today = Date()
                        let formatter = DateFormatter()
                        formatter.dateStyle = .short
                        let date = formatter.string(from: today)
                        if (date != self.currentLastUpdated) {
                            self.db.collection("groups").document(self.currentGroup).updateData([
                                "completed" : FieldValue.delete(),
                                "lastUpdated" : date
                            ]) { err in
                                if let err = err {
                                    print("Error writing document: \(err)")
                                } else {
                                    print("Group Document successfully written!")
                                    self.fetchGroup()
                                }
                            }
                        }
                    } else {
                        // A nil value was successfully initialized from the DocumentSnapshot,
                        // or the DocumentSnapshot was nil.
                        print("Document does not exist")
                    }
                case .failure(let error):
                    // A `City` value could not be initialized from the DocumentSnapshot.
                    print("Error decoding: \(error)")
                }
            }
        }
            
    }
    func fetchUser() {
        DispatchQueue.main.async {
            let docRef = self.db.collection("users").document(self.email)
                docRef.getDocument { (document, error) in
                    let result = Result {
                        try document?.data(as: User.self)
                    }
                    switch result {
                    case .success(let userDB):
                        if let userDB = userDB {
                            // A `City` value was successfully initialized from the DocumentSnapshot.
                            self.fcmToken = userDB.fcmtoken
                            self.invites = userDB.invites ?? []
                        } else {
                            // A nil value was successfully initialized from the DocumentSnapshot,
                            // or the DocumentSnapshot was nil.
                            print("Document does not exist")
                        }
                    case .failure(let error):
                        // A `City` value could not be initialized from the DocumentSnapshot.
                        print("Error decoding: \(error)")
                }
            }
        }
    }
    func getInvites() {
    DispatchQueue.main.async {
            self.inviteNames = []
            self.invites.forEach { invite in
                print(invite)
                let docRef = self.db.collection("groups").document(invite)
                docRef.getDocument { (document, error) in
                    let result = Result {
                        try document?.data(as: Group.self)
                    }
                    switch result {
                    case .success(let groupDB):
                        if let groupDB = groupDB {
                            // A `City` value was successfully initialized from the DocumentSnapshot.
                            if(!self.inviteNames.contains(groupDB.groupName)) {
                                self.inviteNames.append(groupDB.groupName)
                            }
                        } else {
                            // A nil value was successfully initialized from the DocumentSnapshot,
                            // or the DocumentSnapshot was nil.
                            let docRef = self.db.collection("users").document(self.user!.email!)
                            docRef.updateData([
                                "invites" : FieldValue.arrayRemove([invite])
                            ]) { err in
                                if let err = err {
                                    print("Error writing document: \(err)")
                                } else {
                                    print("Group Document successfully written!")
                                }
                            }
                            print("Document does not exist")
                        }
                    case .failure(let error):
                        // A `City` value could not be initialized from the DocumentSnapshot.
                        print("Error decoding: \(error)")
                    }
                }
            }
        }
    }
    func getGoals(groupID: String) {
        DispatchQueue.main.async {
            let docRef = self.db.collection("groups").document(groupID)
            docRef.getDocument{ (document, error) in
                if let err = error {
                            print(err.localizedDescription)
                            return
                        }
                
                guard let document = document else { return }

                guard let dict = document.data() else { return }
                
                self.currentGroupGoals = dict["goals"] as! [String:String]
            }
        }
    }
}



public struct User: Codable {

    let firstName: String?
    let lastName: String?
    let uid: String?
    let groups: [String]?
    let invites: [String]?
    let fcmtoken: String
    

    enum CodingKeys: String, CodingKey {
        case firstName
        case lastName
        case uid
        case groups
        case invites
        case fcmtoken
        
    }
}

public struct Group: Codable {

    let groupName: String
    let groupDescription: String
    let admin: String
    let lastUpdated: String
    let participants: [String]?
    let invites: [String]?
    let tapped: [String]?
    let completed: [String]?

    enum CodingKeys: String, CodingKey {
        case groupName
        case groupDescription
        case admin
        case lastUpdated
        case invites
        case participants
        case tapped
        case completed
    }
}
