//
//  AddRuleView.swift
//  FileRenamer
//
//  Created by Charles Zhang on 2024/8/3.
//

import SwiftUI



struct RadioButton: View {
    @Binding var isSelected: Bool
    var label: String
    
    var body: some View {
        HStack {
            Circle()
                .strokeBorder(Color.black, lineWidth: 1)
                .background(Circle().fill(isSelected ? Color.black : Color.white))
                .frame(width: 16, height: 16)
                .onTapGesture {
                    isSelected.toggle()
                }
            Text(label)
                .onTapGesture {
                    isSelected.toggle()
                }
        }
    }
}

struct RadioButtonField: View {
    let id: String
    let label: String
    let isMarked: Bool
    let callback: (String) -> ()
    
    var body: some View {
        HStack(alignment: .center) {
            Image(systemName: self.isMarked ? "largecircle.fill.circle" : "circle")
                .foregroundColor(.primary) // 使用系统颜色
            
            Text(label)
                .font(.system(size: 14))
                .foregroundColor(.primary) // 使用系统颜色
        }
        .onTapGesture {
            self.callback(self.id)
        }
        .frame(height: 18)
    }
}

struct EditRuleView: View {
    @Binding var selectedRule: String
    @Environment(\.presentationMode) var presentationMode
    @State private var rules: [String] = ["插入", "删除", "移除", "替换", "重排", "扩展名", "去除", "大小写", "序列化", "随机化", "填充", "日期格式转换", "正则", "用户输入"]
    
    var body: some View {
        VStack {
            HStack {
                List(rules, id: \.self) { rule in
                    Text(rule)
                        .onTapGesture {
                            selectedRule = rule
                        }
                }
                .frame(width: 120)
                .padding(.top, 10)
                
                Spacer()
                VStack{
                    
                    ConfigurationView(selectedRule: $selectedRule)
                        .frame(width: 400)
                        .padding(.top, 10)
                    
                    HStack {
                        Spacer()
                        
                        Button(action: {
                            // 添加规则逻辑
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            Text("添加规则")
                        }
                        .padding()
                        
                        Button(action: {
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            Text("关闭")
                        }
                        .padding()
                    }
                    .padding(.top, 10)
                }
            }
            
        }
        .frame(width: 600, height: 400)
    }
}


