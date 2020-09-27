//
//  HomePage.swift
//  Accountable
//
//  Created by Ezekiel Kim on 7/6/20.
//

import SwiftUI
import Foundation
import Firebase
import FirebaseFirestoreSwift

struct GroupsList: View {
    let db = Firestore.firestore()
    var user:FirebaseAuth.User?
    @State var index = 0
    @State var currentGroup = ""
    @State var currentGroupName = ""
    @State private var offset = CGSize.zero
    @State var presentNewGroupPage = false
    @State var navigation : Int?
    @EnvironmentObject var model: GroupListModel

    var body: some View {
        NavigationView {
            ZStack {
                NavigationLink(destination: SettingsPage(), tag: 1, selection: $navigation) {
                    EmptyView()
                }
                NavigationLink(destination: GroupPage(groupName:currentGroupName, groupID: currentGroup).environmentObject(model), tag: 2, selection: $navigation) {
                    EmptyView()
                }
                VStack(spacing: 0) {
                    ZStack {
                        Text("ur groups")
                            .padding()
                            .font(.title)
                            .foregroundColor(.blue)
                        HStack {
                            Image(systemName: "gear")
                                .imageScale(.large)
                                .foregroundColor(/*@START_MENU_TOKEN@*/.blue/*@END_MENU_TOKEN@*/)
                                .padding(.leading,30)
                                .onTapGesture(count: /*@START_MENU_TOKEN@*/1/*@END_MENU_TOKEN@*/, perform: {
                                    navigation = 1
                                })
                            Spacer()
                            if(model.invites.count != 0){
                                ZStack {
                                    Image(systemName: "circle")
                                        .imageScale(.large)
                                        .foregroundColor(.blue)
                                    Text("\(model.invites.count)")
                                        .font(.caption)
                                        .foregroundColor(/*@START_MENU_TOKEN@*/.blue/*@END_MENU_TOKEN@*/)
                                }
                                .padding(.trailing,20)
                            }
                        }
                    }
                    Divider()
                    ScrollView {
                        List() {
                            ForEach(model.groupNames, id: \.self) { group in
                                GroupRow(groupName: group)
                                    .padding(.top, 10)
                                    .onTapGesture {
                                        index = model.groupNames.firstIndex(of: group)!
                                        currentGroup = model.groups[index]
                                        model.currentGroup = currentGroup
                                        currentGroupName = group
                                        navigation = 2
                                    }
                            }
                        }
                        
                        Spacer()
                        Button(action: {
                            withAnimation {
                                presentNewGroupPage.toggle()
                            }
                        }, label: {
                            HStack {
                                Image(systemName: "plus.circle")
                                    .imageScale(.large)
                                    .padding(5)
                                    .foregroundColor(.gray)
                                    
                                Text("create a new group")
                                    .foregroundColor(.gray)
                                    .padding(.trailing, 5)
                            }
                        })
                        .sheet(isPresented: $presentNewGroupPage, content: {
                            NewGroupPage().environmentObject(model)
                        })
                        .padding()
                        Spacer()
                    }
                    .frame(maxHeight:.infinity)
                }
                
                .padding(.top, 40)
                .edgesIgnoringSafeArea([.top, .bottom])
            }
            .animation(.easeInOut)
            .accentColor(.blue)
            .navigationBarTitle("")
            .navigationBarHidden(true)
            .navigationBarBackButtonHidden(true)
            
        }
        .onAppear(perform: {
            model.fetch()
        })
        .navigationBarHidden(true)
        .navigationBarTitle("")
        .edgesIgnoringSafeArea([.top, .bottom])
        .navigationBarBackButtonHidden(true)
    }

    
}

public class GroupListModel: ObservableObject {
    var user = Auth.auth().currentUser
    var email = ""
    var firstName = ""
    var lastName = ""
    var groupName = ""
    var groupDesc = ""
    let db = Firestore.firestore()
    @Published var currentGroup = ""
    @Published var currentGroupName = ""
    @Published var currentGroupDesc = ""
    @Published var currentGroupGoals: [String:String] = [:]
    @Published var currentGroupInvites: [String] = []
    @Published var groups: [String] = []
    @Published var groupNames: [String] = []
    @Published var groupDescs: [String] = []
    @Published var invites: [String] = []
    @Published var currentParticipants: [String] = []

    func fetch() {
        if Auth.auth().currentUser != nil {
          // User is signed in.
            self.groups = []
            self.groupNames = []
            self.groupDescs = []
            self.invites = []
            
            let docRef = db.collection("users").document(user!.uid)
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
                                        print("\(groupDB)")
                                        self.groupNames.append(self.groupName)
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
                    self.currentGroupGoals = groupDB.goals ?? [:]
                    self.currentGroupInvites = groupDB.invites ?? []
                    self.currentParticipants = groupDB.participants ?? []
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
    

    enum CodingKeys: String, CodingKey {
        case firstName
        case lastName
        case uid
        case groups
        case invites
        
    }
}

public struct Group: Codable {

    let groupName: String
    let groupDescription: String
    let participants: [String]?
    let invites: [String]?
    let goals: [String:String]?
    let tapped: [String:Bool]?
    let completed: [String:Bool]?

    enum CodingKeys: String, CodingKey {
        case groupName
        case groupDescription
        case invites
        case participants
        case goals
        case tapped
        case completed
    }
}


struct GroupsList_Previews: PreviewProvider {
    static var previews: some View {
        GroupsList()
    }
}
