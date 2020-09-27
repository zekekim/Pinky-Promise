//
//  SettingsPage.swift
//  Accountable
//
//  Created by Ezekiel Kim on 8/15/20.
//

import SwiftUI

struct SettingsPage: View {
    @Environment(\.presentationMode) var presentationMode
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                ZStack {
                    Text("settings")
                        .padding()
                        .font(.title)
                        .foregroundColor(.blue)
                    HStack {
                        Image(systemName: "chevron.left")
                            .imageScale(.large)
                            .foregroundColor(/*@START_MENU_TOKEN@*/.blue/*@END_MENU_TOKEN@*/)
                            .padding(.leading, 20)
                            .onTapGesture(count: /*@START_MENU_TOKEN@*/1/*@END_MENU_TOKEN@*/, perform: {
                                presentationMode.wrappedValue.dismiss()
                            })
                        Spacer()
                    }
                }
                Divider()
                Spacer()
            }
            .accentColor(.blue)
            .navigationBarTitle("")
            .navigationBarHidden(true)
        }
        .navigationBarHidden(true)
        .navigationBarTitle("")
        .edgesIgnoringSafeArea([.top, .bottom])
        .navigationBarBackButtonHidden(true)
    }
}

struct SettingsPage_Previews: PreviewProvider {
    static var previews: some View {
        SettingsPage()
    }
}
