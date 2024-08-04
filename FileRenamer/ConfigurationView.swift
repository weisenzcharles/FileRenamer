//
//  ConfigurationView.swift
//  FileRenamer
//
//  Created by Charles Zhang on 2024/8/3.
//

import Foundation
import SwiftUI

struct ConfigurationView: View {
    @Binding var selectedRule: String
    
    var body: some View {
        GroupBox(label: Text("配置：").padding(.bottom,10).padding(.leading, -10) ) {
            VStack(alignment: .leading) {
                
                if selectedRule == "插入" {
                    InsertConfigurationView()
                } else if selectedRule == "删除" {
                    DeleteConfigurationView()
                } else {
                    Text("未实现的规则：\(selectedRule)")
                }
            }
            .frame(width: 400,height: 270)
        }
        .frame(width: 400,height: 290)
        .frame(minWidth: 400, minHeight: 290)
        .padding(.top, 10)
    }
}
