//
//  InviteList.swift
//  Accountable
//
//  Created by Ezekiel Kim on 8/4/20.
//

import SwiftUI

struct InviteList: View {
    @Environment(\.presentationMode) var presentationMode

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
                            })
                        Spacer()
                    }
                }
                .frame(maxWidth:.infinity)
                Divider()
                Spacer()
            }
            .accentColor(.blue)
            .navigationBarHidden(true)
            .navigationBarTitle("")
            .padding(.top, 40)
            .edgesIgnoringSafeArea([.top, .bottom])
        }
    }
}

struct InviteList_Previews: PreviewProvider {
    static var previews: some View {
        InviteList()
    }
}
