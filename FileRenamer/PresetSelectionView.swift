//
//  PresetSelectionView.swift
//  FileRenamer
//
//  Created by Charles Zhang on 2024/8/4.
//

import Foundation
import SwiftUI

struct PresetSelectionView: View {
    @Binding var presets: [Preset]
    @Binding var isPresented: Bool
    @State private var selectedPreset: String = ""
//    @State private var presets: [String] = ["默认预设", "索尼相机", "大疆无人机", "大疆灵眸"]
//    @State private var presets: [String] = ["Date_Now", "File_Size", "File_SizeBytes", "File_SizeKB", "File_SizeMB", "File_SizeGB", "File_DateCreated", "File_DateModified", "File_FilePath", "File_FileName", "File_BaseName", "File_Extension", "File_FolderName"]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
//            Text("选择预设")
//                .font(.headline)
            
            Text("选择预设")
             List(presets, id: \.name) { preset in
                 Text(preset.name)
             }
            .pickerStyle(MenuPickerStyle())
            .frame(maxWidth: .infinity)
            .padding(.bottom, 10)
            
//            List(presets, id: \.self) { preset in
//                Text(preset)
//            }
//            .frame(height: 200)
            HStack {
                Spacer()
                
                Button(action: {
                    // 添加规则逻辑
//                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("添加规则")
                }
                .padding()
                
                Button(action: {
//                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("关闭")
                }
                .padding()
            }
//            .padding(.top, 10)
//            HStack {
//                Button(action: {
//                    // 确定按钮的逻辑
//                    // 可以根据需要处理 selectedPreset 的值
//                    self.isPresented = false
//                }) {
//                    HStack {
//                        Image(systemName: "checkmark")
//                        Text("确定")
//                    }
//                    .frame(maxWidth: .infinity)
//                }
//                .buttonStyle(BorderlessButtonStyle())
//                .padding()
//                
//                Button(action: {
//                    // 取消按钮的逻辑
//                    self.isPresented = false
//                }) {
//                    HStack {
//                        Image(systemName: "xmark")
//                        Text("取消")
//                    }
//                    .frame(maxWidth: .infinity)
//                }
//                .buttonStyle(BorderlessButtonStyle())
//                .padding()
//            }
            
//            Text("提示：大多数标签\n仅可用于文件而不是文件夹。")
//                .font(.footnote)
//                .foregroundColor(.gray)
        }
        .padding()
        .frame(width: 300)
    }
}

