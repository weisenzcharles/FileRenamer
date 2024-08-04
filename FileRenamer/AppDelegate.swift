//
//  AppDelegate.swift
//  FileRenamer
//
//  Created by Charles Zhang on 2024/8/2.
//

import Foundation
import SwiftUI
import AppKit

class AppDelegate: NSObject, NSApplicationDelegate, ObservableObject {
    var window: NSWindow!
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        if let window = NSApp.windows.first {
            self.window = window
            window.title = ""
            window.setContentSize(NSSize(width: 800, height: 600))
            window.titleVisibility = .hidden
            window.titlebarAppearsTransparent = true
            window.styleMask.insert(.fullSizeContentView)
        }
        setupMenus()
    }
    @Published var renameRules = [RenameRule]()
    @Published var renameStatuses = [FileRenameStatus]()
    @Published var directoryURL: URL?
    @Published var configURL: URL?
    
    
    var totalFiles: Int {
        renameStatuses.count
    }
    
    var totalFileSize: String {
        let totalSize = renameStatuses.reduce(into: 0) { $0 + ($1.fileSize ?? 0) }
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB, .useGB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: Int64(totalSize))
    }
    
    var currentPresetName: String {
        // 假设有一个属性来存储当前使用的预设名称
        return "默认预设" // 替换为实际的预设名称
    }
    
    private func setupMenus() {
        let menu = NSMenu(title: "FileRenamer")
        let fileMenu = NSMenuItem(title: "File", action: nil, keyEquivalent: "")
        let fileSubMenu = NSMenu(title: "File")
        
        let openConfigMenuItem = NSMenuItem(title: "Open Config File", action: #selector(openConfigFile), keyEquivalent: "o")
        openConfigMenuItem.target = self
        fileSubMenu.addItem(openConfigMenuItem)
        
        let selectDirMenuItem = NSMenuItem(title: "Select Directory", action: #selector(selectDirectory), keyEquivalent: "d")
        selectDirMenuItem.target = self
        fileSubMenu.addItem(selectDirMenuItem)
        
        let renameFilesMenuItem = NSMenuItem(title: "Rename Files", action: #selector(renameFiles), keyEquivalent: "r")
        renameFilesMenuItem.target = self
        fileSubMenu.addItem(renameFilesMenuItem)
        
        fileMenu.submenu = fileSubMenu
        menu.addItem(fileMenu)
        NSApplication.shared.mainMenu = menu
    }
    
    @objc public func openConfigFile() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.init(filenameExtension: "rc")!]
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        
        if panel.runModal() == .OK {
            self.configURL = panel.url
            if let url = configURL {
                let parser = ConfigParser()
                self.renameRules = parser.parseConfigFile(at: url)
            }
        }
    }
    
    @objc public func selectDirectory() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        
        if panel.runModal() == .OK {
            self.directoryURL = panel.url
            updateFileList()
        }
    }
    
    private func updateFileList() {
        guard let directoryURL = directoryURL else { return }
        // Assuming FileRenamer is a class that takes a URL and returns file statuses
        let renamer = FileRenamer()
        self.renameStatuses = renamer.getFileStatuses(at: directoryURL)
    }
    
    @objc public func renameFiles() {
        if let directoryURL = directoryURL, !renameRules.isEmpty {
            let renamer = FileRenamer()
            self.renameStatuses = renamer.renameFiles(at: directoryURL, using: renameRules)
        }
    }
    
    func addFiles(urls: [URL]) {
        // 实现添加文件逻辑
        for url in urls {
            let status = FileRenameStatus(fileName: url.lastPathComponent,  newFileName: "",status: "Pending")
            renameStatuses.append(status)
        }
    }
    
    func addFolder(url: URL) {
        // 实现添加文件夹逻辑
        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil)
            addFiles(urls: fileURLs)
        } catch {
            print("无法读取文件夹内容: \(error.localizedDescription)")
        }
    }
    
    
    // 添加预览重命名方法
    func previewRenames() {
        for (index, status) in renameStatuses.enumerated() {
            var newFileName = status.fileName
            for rule in renameRules where rule.checked {
                newFileName = applyRule(rule, to: newFileName)
            }
            renameStatuses[index].newFileName = newFileName
        }
    }
    
    // 根据规则应用重命名逻辑
     private func applyRule(_ rule: RenameRule, to fileName: String) -> String {
         // 这里实现规则的应用逻辑
         // 根据你的规则格式和逻辑更新文件名
         // 这是一个示例，具体实现根据你的需求
         switch rule.type {
         case "Insert":
             // 示例：在文件名的指定位置插入文本
             guard let insertPosition = rule.position, let insertText = rule.insertText else { return fileName }
             var newFileName = fileName
             if insertPosition < newFileName.count {
                 newFileName.insert(contentsOf: insertText, at: newFileName.index(newFileName.startIndex, offsetBy: insertPosition))
             } else {
                 newFileName.append(insertText)
             }
             return newFileName
         default:
             return fileName
         }
     }
    
    func performRenames() {
        // 实现重命名逻辑
        for index in renameStatuses.indices {
            // 示例重命名逻辑
            renameStatuses[index].status = "Renamed"
        }
    }
    
    func removeRules(ids: Set<RenameRule.ID>) {
        renameRules.removeAll { ids.contains($0.id) }
    }
    
    func removeAllRules() {
        renameRules.removeAll()
    }
}
