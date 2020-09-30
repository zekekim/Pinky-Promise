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
    @Published var email = ""
    @Published var fcmToken = ""
    @Published var currentGroup = ""
    @Published var currentGroupName = ""
    @Published var currentGroupDesc = ""
    @Published var currentGroupGoals: [String:String] = [:]
    @Published var currentGroupInvites: [String] = []
    @Published var currentLastUpdated: Date = Date()
    @Published var currentCompleted: [String] = []
    @Published var groups: [String] = []
    @Published var groupNames: [String] = []
    @Published var groupDescs: [String] = []
    @Published var invites: [String] = []
    @Published var currentParticipants: [String] = []
    @Published var currentTapped: [String:Bool] = [:]
    

    func fetch() {
        if Auth.auth().currentUser != nil {
          // User is signed in.
            self.groups = []
            self.groupNames = []
            self.groupDescs = []
            self.invites = []
            
            
            let docRef = db.collection("users").document(user!.email!)
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
                            var components = DateComponents()
                            components.hour = 0
                            components.minute = 0
                            components.second = 0
                            components.nanosecond = 0
                            let date = Calendar.current.date(from: components) ?? Date()
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
        let docRef = db.collection("groups").document(currentGroup)
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
                    self.currentGroupDesc = groupDB.groupDescription
                    self.currentLastUpdated = groupDB.lastUpdated
                    self.currentGroupGoals = groupDB.goals ?? [:]
                    self.currentGroupInvites = groupDB.invites ?? []
                    self.currentParticipants = groupDB.participants ?? []
                    self.currentCompleted = groupDB.completed ?? []
                    self.currentLastUpdated = groupDB.lastUpdated
                    self.currentTapped = groupDB.tapped ?? [:]
                    var components = DateComponents()
                    components.hour = 0
                    components.minute = 0
                    components.second = 0
                    components.nanosecond = 0
                    let date = Calendar.current.date(from: components) ?? Date()
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
    func fetchUser() {
        let docRef = db.collection("users").document(email)
        docRef.getDocument { (document, error) in
            let result = Result {
                try document?.data(as: User.self)
            }
            switch result {
            case .success(let userDB):
                if let userDB = userDB {
                    // A `City` value was successfully initialized from the DocumentSnapshot.
                    self.fcmToken = userDB.fcmtoken
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
    let lastUpdated: Date
    let participants: [String]?
    let invites: [String]?
    let goals: [String:String]?
    let tapped: [String:Bool]?
    let completed: [String]?

    enum CodingKeys: String, CodingKey {
        case groupName
        case groupDescription
        case admin
        case lastUpdated
        case invites
        case participants
        case goals
        case tapped
        case completed
    }
}
