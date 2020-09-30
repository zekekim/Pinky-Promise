//
//  GroupInfoPage.swift
//  Accountable
//
//  Created by Ezekiel Kim on 9/29/20.
//

import SwiftUI

struct GroupInfoPage: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var model:GroupListModel
    var body: some View {
        VStack(spacing:0) {
            ZStack {
                Text("group info")
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
        }
        .onAppear(perform: {
            model.fetchGroup()
        })
    }
}

struct GroupInfoPage_Previews: PreviewProvider {
    static var previews: some View {
        GroupInfoPage()
    }
}
