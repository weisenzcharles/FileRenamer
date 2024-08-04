//
//  PresetService.swift
//  FileRenamer
//
//  Created by Charles Zhang on 2024/8/4.
//

import Foundation



struct Preset: Codable {
    let name: String
    let rules: [RenameRule]
    
}

class PresetService {
    
    static let shared = PresetService()

    private init() {}


    func savePresets(presets: [Preset]) {
        let tempDir = FileManager.default.temporaryDirectory
        let presetsURL = tempDir.appendingPathComponent("presets.json")

        do {
            let data = try JSONEncoder().encode(presets)
            try data.write(to: presetsURL)
        } catch {
            print("保存预设失败: \(error.localizedDescription)")
        }
    }

    func loadPresets() -> [Preset] {
        let tempDir = FileManager.default.temporaryDirectory
        let presetsURL = tempDir.appendingPathComponent("presets.json")

        do {
            let data = try Data(contentsOf: presetsURL)
            let presets = try JSONDecoder().decode([Preset].self, from: data)
            return presets
        } catch {
            print("加载预设失败: \(error.localizedDescription)")
            return []
        }
    }
}
