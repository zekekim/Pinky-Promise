//
//  GroupRow.swift
//  Accountable
//
//  Created by Ezekiel Kim on 8/4/20.
//

import SwiftUI

struct GroupRow: View {
    var groupName: String
    var body: some View {
        HStack {
            Text(groupName)
                .foregroundColor(.gray)
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .frame(maxWidth:.infinity)
        .padding()
    }
}

struct GroupRow_Previews: PreviewProvider {
    static var previews: some View {
        GroupRow(groupName: "Wild Ones")
            .previewLayout(PreviewLayout.sizeThatFits)
            .padding()
    }
}
