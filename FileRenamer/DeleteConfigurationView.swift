//
//  DeleteConfigurationView.swift
//  FileRenamer
//
//  Created by Charles Zhang on 2024/8/3.
//

import Foundation
import SwiftUI

struct DeleteConfigurationView: View {
    @State private var insertText: String = ""
    @State private var isInsertMetaTag: Bool = false
    @State private var position: Int = 1
    @State private var isFromRightToLeft: Bool = false
    @State private var ignoreExtension: Bool = true
    @State private var isPositionBefore: Bool = true
    
    var body: some View {
        VStack {
            HStack(alignment: .top)  {
                GroupBox(label: Text("始于：").padding(.bottom,10).padding(.leading, -10) ) {
                    HStack {
                        RadioButtonField(
                            id: "1",
                            label: "位置",
                            isMarked: position == 1,
                            callback: radioGroupCallback
                        )
                        TextField("", value: $position, formatter: NumberFormatter())
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    HStack {
                        RadioButtonField(
                            id: "分隔符",
                            label: "分隔符",
                            isMarked: position == 2,
                            callback: radioGroupCallback
                        )
                        TextField("", value: $position, formatter: NumberFormatter())
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                }
                .frame(width: 180)
                
                GroupBox(label: Text("直到：").padding(.bottom,10).padding(.leading, -10) ) {
                    HStack(alignment: .top) {
                        RadioButtonField(
                            id: "计数",
                            label: "计数",
                            isMarked: position == 2,
                            callback: radioGroupCallback
                        )
                        TextField("", value: $position, formatter: NumberFormatter())
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    HStack(alignment: .top) {
                        RadioButtonField(
                            id: "分隔符",
                            label: "分隔符",
                            isMarked: position == 2,
                            callback: radioGroupCallback
                        )
                        TextField("", value: $position, formatter: NumberFormatter())
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    RadioButtonField(
                        id: "直到末尾",
                        label: "直到末尾",
                        isMarked: position == 2,
                        callback: radioGroupCallback
                    )
                }
                .frame(width: 180)
            }
            
            HStack(alignment: .center) {
                
                 VStack (alignment: .leading){
                    Toggle("删除当前名称", isOn: $ignoreExtension)
            
                    Toggle("从右到左", isOn: $ignoreExtension)
                    
                }
                .padding(.bottom, 10)
                .frame(maxWidth: .infinity, alignment: .leading)
                .frame(width: 180, height: 100)
                Spacer()
                 VStack(alignment: .leading) {
                    Toggle("忽略扩展名", isOn: $ignoreExtension)
             
                    Toggle("禁止移除分隔符", isOn: $ignoreExtension)
                    
                }
                .padding(.bottom, 10)
                .frame(maxWidth: .infinity, alignment: .leading)
                .frame(width: 180, height: 100)
            }
            .padding()
//            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
//        .frame(width: 400,height: 290)
    }
    
    func radioGroupCallback(id: String) {
        if id == "1" {
            position = 1
        } else if id == "2" {
            position = 2
        }
    }
}

