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




struct GroupsList_Previews: PreviewProvider {
    static var previews: some View {
        GroupsList()
    }
}
