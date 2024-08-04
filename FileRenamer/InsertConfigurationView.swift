//
//  InsertConfigurationView.swift
//  FileRenamer
//
//  Created by Charles Zhang on 2024/8/3.
//

import Foundation
import SwiftUI

struct InsertConfigurationView: View {
    @State private var position: String = "前缀"
    @State private var insertText: String = ""
    @State private var ignoreExtension: Bool = true
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("插入：")
                TextField("插入内容", text: $insertText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                
                Button(action: {
                    // 插入元信息标签的逻辑
                }) {
                    Text("插入元信息标签")
                }
            }
            .padding(.bottom, 10)
            
            Text("位置：")
            
            VStack(alignment: .leading) {
                RadioButtonField(
                    id: "前缀",
                    label: "前缀",
                    isMarked: $position.wrappedValue == "前缀",
                    callback: radioGroupCallback
                )
                RadioButtonField(
                    id: "后缀",
                    label: "后缀",
                    isMarked: $position.wrappedValue == "后缀",
                    callback: radioGroupCallback
                )
                
                HStack {
                    RadioButtonField(
                        id: "位置",
                        label: "位置",
                        isMarked: $position.wrappedValue == "位置",
                        callback: radioGroupCallback
                    )
                    TextField("", value: $position, formatter: NumberFormatter())
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    Toggle("从右到左", isOn: .constant(false))
                }
                HStack {
                    RadioButtonField(
                        id: "到文本前",
                        label: "到文本前",
                        isMarked: $position.wrappedValue == "位置",
                        callback: radioGroupCallback
                    )
                    TextField("", value: $position, formatter: NumberFormatter())
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                }
                HStack {
                    RadioButtonField(
                        id: "到文本后",
                        label: "到文本后",
                        isMarked: $position.wrappedValue == "位置",
                        callback: radioGroupCallback
                    )
                    TextField("", value: $position, formatter: NumberFormatter())
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                RadioButtonField(
                    id: "替换当前名称",
                    label: "替换当前名称",
                    isMarked: $position.wrappedValue == "替换当前名称",
                    callback: radioGroupCallback
                )
                //                RadioButtonField(
                //                    id: "位置",
                //                    label: "位置",
                //                    isMarked: $position.wrappedValue == "位置",
                //                    callback: radioGroupCallback
                //                )
                //                .padding(.bottom, 10)
            }
            
            
            Toggle("忽略扩展名", isOn:  $ignoreExtension)
            
        }
        .padding()
    }
    
    func radioGroupCallback(id: String) {
        position = id
    }
}
