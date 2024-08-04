//
//  FileRenamer.swift
//  FileRenamer
//
//  Created by Charles Zhang on 2024/8/2.
//

import Foundation

class FileRenamer {
//    // 文件状态模型
//       struct FileStatus {
//           var fileName: String
//           var newFileName: String?
//           var status: String
//           var errorMessage: String?
//       }
       
       func getFileStatuses(at directoryURL: URL) -> [FileRenameStatus] {
           var fileStatuses: [FileRenameStatus] = []
           
           do {
               let fileManager = FileManager.default
               let files = try fileManager.contentsOfDirectory(at: directoryURL, includingPropertiesForKeys: nil)
               
               for fileURL in files {
                   if fileURL.hasDirectoryPath {
                       continue // 忽略子目录
                   }
                   
                   let fileName = fileURL.lastPathComponent
                   let status = FileRenameStatus(fileName: fileName, newFileName: "", status: "未处理", errorMessage: "")
                   fileStatuses.append(status)
               }
           } catch {
               print("读取目录时出错: \(error)")
           }
           
           return fileStatuses
       }
       
    
    
    func renameFiles(at directory: URL, using rules: [RenameRule]) -> [FileRenameStatus] {
        let fileManager = FileManager.default
        let keys: [URLResourceKey] = [.nameKey, .isDirectoryKey]
        var renameStatuses = [FileRenameStatus]()
        
        if let fileURLs = try? fileManager.contentsOfDirectory(at: directory, includingPropertiesForKeys: keys) {
            for fileURL in fileURLs {
                guard let resourceValues = try? fileURL.resourceValues(forKeys: Set(keys)),
                      let isDirectory = resourceValues.isDirectory, !isDirectory,
                      let fileName = resourceValues.name else {
                    continue
                }
                
                var newFileName = fileName
                var errorMessage: String?
                for rule in rules {
                    if rule.marked {
                        let previousFileName = newFileName
                        newFileName = applyRule(rule, to: newFileName)
                        if newFileName.isEmpty || newFileName == previousFileName {
                            errorMessage = "Failed to apply rule: \(rule.ruleID)"
                            break
                        }
                    }
                }
                
                let status: String
                if newFileName != fileName && errorMessage == nil {
                    let newFileURL = directory.appendingPathComponent(newFileName)
                    do {
                        try fileManager.moveItem(at: fileURL, to: newFileURL)
                        status = "Renamed"
                    } catch {
                        status = "Error"
                        errorMessage = error.localizedDescription
                    }
                } else {
                    status = errorMessage == nil ? "No Change" : "Error"
                }
                
                let renameStatus = FileRenameStatus(
                    fileName: fileName,
                    newFileName: newFileName,
                    status: status,
                    errorMessage: errorMessage
                )
                renameStatuses.append(renameStatus)
            }
        }
        return renameStatuses
    }
    
    private func applyRule(_ rule: RenameRule, to fileName: String) -> String {
        var newFileName = fileName
        
        switch rule.ruleID {
        case "Delete":
            newFileName = applyDeleteRule(rule, to: newFileName)
        case "Insert":
            newFileName = applyInsertRule(rule, to: newFileName)
        default:
            break
        }
        
        return newFileName
    }
    
    private func applyDeleteRule(_ rule: RenameRule, to fileName: String) -> String {
        guard let fromPosition = Int(rule.config["FROMPOSITION"] ?? "0"),
              let untilCount = Int(rule.config["UNTILCOUNT"] ?? "0"),
              let fromDelimiter = rule.config["FROMDELIMITER"],
              let untilDelimiter = rule.config["UNTILDELIMITER"],
              let deleteCurrentName = Int(rule.config["DELETECURRENTNAME"] ?? "0"),
              let rightToLeft = Int(rule.config["RIGHTTOLEFT"] ?? "0"),
              let skipExtension = Int(rule.config["SKIPEXTENSION"] ?? "0"),
              let leaveDelimiter = Int(rule.config["LEAVEDELIMITER"] ?? "0") else {
            return fileName
        }
        
        var newFileName = fileName
        
        if skipExtension == 1, let fileExtension = newFileName.split(separator: ".").last {
            newFileName = String(newFileName.dropLast(fileExtension.count + 1))
        }
        
        if rightToLeft == 1 {
            newFileName = String(newFileName.reversed())
        }
        
        let fromIndex: String.Index
        if fromDelimiter.isEmpty {
            fromIndex = newFileName.index(newFileName.startIndex, offsetBy: fromPosition, limitedBy: newFileName.endIndex) ?? newFileName.startIndex
        } else {
            if let range = newFileName.range(of: fromDelimiter) {
                fromIndex = range.upperBound
            } else {
                fromIndex = newFileName.startIndex
            }
        }
        
        let toIndex: String.Index
        if untilDelimiter.isEmpty {
            toIndex = newFileName.index(fromIndex, offsetBy: untilCount, limitedBy: newFileName.endIndex) ?? newFileName.endIndex
        } else {
            if let range = newFileName.range(of: untilDelimiter, options: .backwards) {
                toIndex = range.lowerBound
            } else {
                toIndex = newFileName.endIndex
            }
        }
        
        if fromIndex < toIndex {
            let substringRange = fromIndex..<toIndex
            newFileName.removeSubrange(substringRange)
        }
        
        if rightToLeft == 1 {
            newFileName = String(newFileName.reversed())
        }
        
        if leaveDelimiter == 1 {
            if fromDelimiter.isEmpty == false {
                newFileName.insert(contentsOf: fromDelimiter, at: newFileName.startIndex)
            }
            if untilDelimiter.isEmpty == false {
                newFileName.append(untilDelimiter)
            }
        }
        
        if deleteCurrentName == 1 {
            newFileName = ""
        }
        
        if skipExtension == 1, let fileExtension = fileName.split(separator: ".").last {
            newFileName += ".\(fileExtension)"
        }
        
        return newFileName
    }
    
    private func applyInsertRule(_ rule: RenameRule, to fileName: String) -> String {
        guard let text = rule.config["TEXT"],
              let wherePosition = Int(rule.config["WHERE"] ?? "0"),
              let position = Int(rule.config["POSITION"] ?? "0"),
              let insertAfterText = rule.config["INSERTAFTERTEXT"],
              let insertBeforeText = rule.config["INSERTBEFORETEXT"],
              let rightToLeft = Int(rule.config["RIGHTTOLEFT"] ?? "0"),
              let skipExtension = Int(rule.config["SKIPEXTENSION"] ?? "0") else {
            return fileName
        }
        
        var newFileName = fileName
        
        if skipExtension == 1, let fileExtension = newFileName.split(separator: ".").last {
            newFileName = String(newFileName.dropLast(fileExtension.count + 1))
        }
        
        if rightToLeft == 1 {
            newFileName = String(newFileName.reversed())
        }
        
        let insertIndex: String.Index
        if insertAfterText.isEmpty && insertBeforeText.isEmpty {
            insertIndex = newFileName.index(newFileName.startIndex, offsetBy: position, limitedBy: newFileName.endIndex) ?? newFileName.startIndex
        } else if let range = newFileName.range(of: insertAfterText) {
            insertIndex = range.upperBound
        } else if let range = newFileName.range(of: insertBeforeText) {
            insertIndex = range.lowerBound
        } else {
            insertIndex = newFileName.startIndex
        }
        
        newFileName.insert(contentsOf: text, at: insertIndex)
        
        if rightToLeft == 1 {
            newFileName = String(newFileName.reversed())
        }
        
        if skipExtension == 1, let fileExtension = fileName.split(separator: ".").last {
            newFileName += ".\(fileExtension)"
        }
        
        return newFileName
    }
}

