//
//  FileRenamerApp.swift
//  FileRenamer
//
//  Created by Charles Zhang on 2024/8/2.
//

import SwiftUI

@main
struct FileRenamerApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @State private var presets: [Preset] = []
    var body: some Scene {
        WindowGroup {
            ContentView()
                     .onAppear {
                         presets = PresetService.shared.loadPresets()
                     }
        }
        .commands {
            CommandGroup(replacing: .appSettings) {
                Button("Open Config File") {
                    appDelegate.openConfigFile()
                }.keyboardShortcut("o", modifiers: [.command])
                
                Button("Select Directory") {
                    appDelegate.selectDirectory()
                }.keyboardShortcut("d", modifiers: [.command])
                
                Button("Rename Files") {
                    appDelegate.renameFiles()
                }.keyboardShortcut("r", modifiers: [.command])
            }
        }
    }
}
