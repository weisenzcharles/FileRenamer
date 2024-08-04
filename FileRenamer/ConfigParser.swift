//
//  ConfigParser.swift
//  FileRenamer
//
//  Created by Charles Zhang on 2024/8/2.
//

import Foundation


extension String {
    var urlDecoded: String {
        return self.removingPercentEncoding ?? self
    }
}
extension Array where Element == RenameRule {
    func sortedByRuleID() -> [RenameRule] {
        return self.sorted { lhs, rhs in
            let lhsNumber = Int(lhs.ruleID.dropFirst(4)) ?? 0
            let rhsNumber = Int(rhs.ruleID.dropFirst(4)) ?? 0
            return lhsNumber < rhsNumber
        }
    }
}



//struct RenameRule: Codable {
//    let type: String
//    let position: Int
//    let text: String
//    // 添加更多规则属性
//}
//struct RenameRule: Identifiable {
//    let id: UUID
//    var type: RuleType
//    var checked: Bool
//    var insertText: String?
//    var fromPosition: Int?
//    var untilCount: Int?
//    var fromDelimiter: String?
//    var untilDelimiter: String?
//    var deleteCurrentName: Bool?
//    var rightToLeft: Bool?
//    var skipExtension: Bool?
//    var leaveDelimiter: Bool?
//    var comment: String?
//    
//    enum RuleType: String, Codable {
//        case delete = "Delete"
//        case insert = "Insert"
//        // 其他规则类型
//    }
//    
//    init(id: UUID = UUID(), type: RuleType, checked: Bool = true, insertText: String? = nil, fromPosition: Int? = nil, untilCount: Int? = nil, fromDelimiter: String? = nil, untilDelimiter: String? = nil, deleteCurrentName: Bool? = nil, rightToLeft: Bool? = nil, skipExtension: Bool? = nil, leaveDelimiter: Bool? = nil, comment: String? = nil) {
//        self.id = id
//        self.type = type
//        self.checked = checked
//        self.insertText = insertText
//        self.fromPosition = fromPosition
//        self.untilCount = untilCount
//        self.fromDelimiter = fromDelimiter
//        self.untilDelimiter = untilDelimiter
//        self.deleteCurrentName = deleteCurrentName
//        self.rightToLeft = rightToLeft
//        self.skipExtension = skipExtension
//        self.leaveDelimiter = leaveDelimiter
//        self.comment = comment
//    }
//    
//    func description() -> String {
//        switch type {
//        case .delete:
//            return "删除 从位置 \(fromPosition ?? 0) 直到满足计数 \(untilCount ?? 0)（\(rightToLeft == true ? "从右到左" : "从左到右")，\(skipExtension == true ? "忽略扩展名" : "包括扩展名")）"
//        case .insert:
//            return "插入 \(insertText ?? "") 在位置 \(fromPosition ?? 0)（\(skipExtension == true ? "忽略扩展名" : "包括扩展名")）"
//        }
//    }
//    
//    func name() -> String {
//        switch type {
//        case .delete:
//            return "删除"
//        case .insert:
//            return "插入"
//        }
//    }
//}

struct RenameRule: Codable, Identifiable  {
    var id = UUID()
    var ruleID: String
    var config: [String: String]
    var marked: Bool
    var comment: String?
    var checked: Bool = false
    let type: String
    var insertText: String?
    var position: Int?
    
    /*
     获取规则名称
     */
    func name() -> String {
        switch ruleID {
        case "Delete":
            return "删除"
        case "Insert":
            return "插入"
        default:
            return "未知操作"
        }
    }
    
    /// 解码 URL 编码的字符串
    /// - Parameter encodedString: 要解码的 URL 编码字符串
    /// - Returns: 解码后的字符串，如果解码失败，则返回 nil
    func decodeURLEncodedString(_ encodedString: String) -> String? {
        return encodedString.removingPercentEncoding
    }
    
    
    func description() -> String {
            switch ruleID {
            case "Delete":
                let from = config["FROM"] ?? ""
                let until = config["UNTIL"] ?? ""
                let fromPosition = config["FROMPOSITION"] ?? "1"
                let untilCount = config["UNTILCOUNT"] ?? "1"
                let fromDelimiter = config["FROMDELIMITER"] ?? ""
                let untilDelimiter = config["UNTILDELIMITER"] ?? ""
                let deleteCurrentName = config["DELETECURRENTNAME"] ?? ""
                let rightToLeft = config["RIGHTTOLEFT"] == "1" ? "（从右到左）" : ""
                let skipExtension = config["SKIPEXTENSION"] == "1" ? "（忽略扩展名）" : ""
                let leaveDelimiter = config["LEAVEDELIMITER"] ?? ""
                return "删除 从位置 \(fromPosition) 直到满足计数 \(untilCount) \(rightToLeft) \(skipExtension)"
            case "Insert":
                let text = config["TEXT"]?.urlDecoded ?? ""
                let wherePos = config["WHERE"] ?? ""
                let position = config["POSITION"] ?? ""
                let insertAfterText = config["INSERTAFTERTEXT"] ?? ""
                let insertBeforeText = config["INSERTBEFORETEXT"] ?? ""
                let rightToLeft = config["RIGHTTOLEFT"] ?? ""
                let skipExtension = config["SKIPEXTENSION"] == "1" ? "（忽略扩展名）" : ""
                return "插入 '\(text)' 在位置 \(position) \(skipExtension)"
            default:
                return "未知操作"
            }
        }
}

struct FileRenameStatus: Identifiable {
    var id = UUID()
    var fileName: String
    var newFileName: String
    var status: String
    var errorMessage: String?
    var fileSize: Int? // 添加文件大小属性
    var checked: Bool = false
}
class ConfigParser {
    func parseConfigFile(at url: URL) -> [RenameRule] {
        var rules = [RenameRule]()
        var currentRule: RenameRule?
        
        if let content = try? String(contentsOf: url) {
            let lines = content.split(separator: "\n")
            for line in lines {
                if line.hasPrefix("[Rule") {
                    if let rule = currentRule {
                        rules.append(rule)
                    }
                    currentRule = RenameRule(ruleID: "", config: [:], marked: false, comment: nil, type: "")
                } else if line.hasPrefix("ID=") {
                    currentRule?.ruleID = String(line.dropFirst(3))
                } else if line.hasPrefix("Config=") {
                    let configString = String(line.dropFirst(7))
                    let configPairs = configString.split(separator: ";")
                    for pair in configPairs {
                        let keyValue = pair.split(separator: ":")
                        if keyValue.count == 2 {
                            currentRule?.config[String(keyValue[0])] = String(keyValue[1])
                        }
                    }
                } else if line.hasPrefix("Marked=") {
                    currentRule?.marked = (String(line.dropFirst(7)) == "1")
                } else if line.hasPrefix("Comment=") {
                    currentRule?.comment = String(line.dropFirst(8))
                }
            }
            if let rule = currentRule {
                rules.append(rule)
            }
        }
        return rules
    }
}
