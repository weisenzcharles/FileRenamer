//
//  ContentView.swift
//  FileRenamer
//
//  Created by Charles Zhang on 2024/8/2.
//

import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    @EnvironmentObject var appDelegate: AppDelegate
    @State private var selectedFileStatuses: Set<FileRenameStatus.ID> = []
    @State private var selectedRules: Set<RenameRule.ID> = []
    @State private var showingFileImporter = false
    @State private var showingFolderImporter = false
    @State private var showingAddRule = false
    @State private var showingEditRule = false
    @State private var selectedRule: String = "插入"
    @State private var showingPresetSelection = false
    
    @State private var presets: [Preset] = []
    
    var totalFileSize: String {
        let totalSize = appDelegate.renameStatuses.reduce(into: 0) { $0 + ($1.fileSize ?? 0) }
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB, .useGB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: Int64(totalSize))
    }
    
    
    var body: some View {
        VStack {
            GeometryReader { geometry in
                ScrollView([.horizontal, .vertical]) {
                    VStack {
                        Text("规则列表")
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                        
                        let sortedRules = appDelegate.renameRules.sortedByRuleID()
                        
                        Table(sortedRules, selection: $selectedRules) {
                            TableColumn("状态") { rule in
                                Toggle("", isOn: Binding(
                                    get: { rule.checked },
                                    set: { newValue in
                                        if let index = appDelegate.renameRules.firstIndex(where: { $0.id == rule.id }) {
                                            appDelegate.renameRules[index].checked = newValue
                                        }
                                    }
                                ))
                                .labelsHidden()
                            }
                            TableColumn("规则序号") { rule in
                                if let index = sortedRules.firstIndex(where: { $0.id == rule.id }) {
                                    Text("\(index + 1)")
                                }
                            }
                            TableColumn("规则内容") { rule in
                                Text(rule.name())
                            }
                            TableColumn("规则说明") { rule in
                                Text(rule.description())
                            }
                        }
                        .contextMenu {
                            Button(action: addRule) {
                                Text("添加规则")
                            }
                            Button(action: editRule) {
                                Text("编辑规则")
                            }
                            Button(action: removeSelectedRules) {
                                Text("移除规则")
                            }
                            Button(action: removeAllRules) {
                                Text("移除全部规则")
                            }
                            Divider()
                            Button(action: addRule) {
                                Text("上移")
                            }
                            Button(action: editRule) {
                                Text("下移")
                            }
                            Divider()
                            Button(action: selectAllRules) {
                                Text("全选")
                            }
                            Button(action: deselectAllRules) {
                                Text("反选")
                            }
                        }
                        .frame(height: min(200, geometry.size.height * 0.3)) // 设置合适的高度
                        .padding()
                        
                        Text("文件列表")
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                        
                        Table(appDelegate.renameStatuses, selection: $selectedFileStatuses) {
                            TableColumn("状态") { status in
                                Toggle("", isOn: Binding(
                                    get: { status.checked },
                                    set: { newValue in
                                        if let index = appDelegate.renameStatuses.firstIndex(where: { $0.id == status.id }) {
                                            appDelegate.renameStatuses[index].checked = newValue
                                        }
                                    }
                                ))
                                .labelsHidden()
                            }
                            TableColumn("更名状态", value: \.status)
                            TableColumn("文件名称", value: \.fileName)
                            TableColumn("新名称", value: \.newFileName)
                            TableColumn("错误信息") { status in
                                Text(status.errorMessage ?? "")
                            }
                        }
                        .frame(minHeight: min(400, geometry.size.height * 0.6)) // 设置合适的高度
                        .padding()
                    }
                    .frame(minWidth: geometry.size.width, minHeight: geometry.size.height)
                }
            }
            // 状态栏
            HStack {
                Text("文件总数: \(appDelegate.totalFiles)")
                Spacer()
                Text("文件总大小: \(totalFileSize)")
                Spacer()
                Text("当前使用的预设名称: \(appDelegate.currentPresetName)")
            }
            .padding()
            .background(Color.gray.opacity(0.2))
        }
        .frame(minWidth: 1024, minHeight: 768)
        .toolbar {
            ToolbarItemGroup(placement: .principal) {
                HStack {
                    Button(action: {
                        showingFileImporter.toggle()
                    }) {
                        Image(systemName: "rectangle.badge.plus")
                        //                            .resizable()
                        //                            .frame(width: 16, height: 16)
                    }
                    .help("添加文件")
                    .fileImporter(
                        isPresented: $showingFileImporter,
                        allowedContentTypes: [.item],
                        allowsMultipleSelection: true
                    ) { result in
                        // 处理选中的文件
                        switch result {
                        case .success(let urls):
                            appDelegate.addFiles(urls: urls)
                        case .failure(let error):
                            print("选择文件失败: \(error.localizedDescription)")
                        }
                    }
                    
                    Button(action: {
                        showingFolderImporter.toggle()
                    }) {
                        Image(systemName: "folder.badge.plus")
                        //                            .resizable()
                        //                            .frame(width: 16, height: 16)
                    }
                    .help("添加文件夹")
                    .fileImporter(
                        isPresented: $showingFolderImporter,
                        allowedContentTypes: [.folder]
                    ) { result in
                        // 处理选中的文件夹
                        switch result {
                        case .success(let url):
                            appDelegate.addFolder(url: url)
                        case .failure(let error):
                            print("选择文件夹失败: \(error.localizedDescription)")
                        }
                    }
                    Button(action: {
                        showingPresetSelection = true
                    }) {
                        Image(systemName: "filemenu.and.selection")
                    }
                    .sheet(isPresented: $showingPresetSelection) {
                        PresetSelectionView(presets: $presets, isPresented: $showingPresetSelection)
                    }
                    .help("载入预设")
                    Button(action: {
                        appDelegate.previewRenames()
                    }) {
                        Image(systemName: "eye")
                        //                            .resizable()
                        //                            .frame(width: 16, height: 16)
                    }
                    .help("预览")
                    
                    Button(action: {
                        appDelegate.performRenames()
                    }) {
                        Image(systemName: "checkmark.rectangle")
                        //                            .resizable()
                        //                            .frame(width: 16, height: 16)
                    }
                    .help("重命名")
                    Spacer().frame(width: 20)
                    
                }
            }
        }
        .sheet(isPresented: $showingAddRule) {
            // 添加规则的视图
            EditRuleView(selectedRule: $selectedRule)
        }
        .sheet(isPresented: $showingEditRule) {
            // 编辑规则的视图
            EditRuleView(selectedRule: $selectedRule)
        }
        .sheet(isPresented: $showingEditRule) {
            // 编辑规则的视图
            EditRuleView(selectedRule: $selectedRule)
        }
    }
    
    private func addRule() {
        showingAddRule.toggle()
    }
    
    private func editRule() {
        showingEditRule.toggle()
    }
    
    private func removeSelectedRules() {
        appDelegate.removeRules(ids: selectedRules)
    }
    
    private func removeAllRules() {
        appDelegate.removeAllRules()
    }
    
    private func selectAllRules() {
        selectedRules = Set(appDelegate.renameRules.map { $0.id })
    }
    
    private func deselectAllRules() {
        selectedRules.removeAll()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(AppDelegate())
    }
}
