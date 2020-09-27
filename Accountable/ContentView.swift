//
//  ContentView.swift
//  Accountable
//
//  Created by Ezekiel Kim on 7/6/20.
//

import SwiftUI

struct ContentView: View {
    @State var navigation: Int?
    var body: some View {
        NavigationView {
            VStack {
                NavigationLink(destination:EmailSignUp(), tag: 1, selection: $navigation) {
                    EmptyView()
                }
                Text("Accountable")
                    .font(.largeTitle)
                    .foregroundColor(Color.blue)
                    .padding()
                Text("Sign Up")
                Button(action: {
                    navigation = 1
                }, label: {
                    Text("Login with Email")
                })
                Button(action: {
                    
                }, label: {
                    Text("Login With Gmail")
                })
                Button(action: {
                    
                }, label: {
                    Text("Login With Facebook")
                })
            }
            .padding()
            .navigationBarTitle("")
            .navigationBarHidden(true)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
