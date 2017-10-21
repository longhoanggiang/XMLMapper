//
//  Dictionary+XMLParser.swift
//  XMLMapper
//
//  Created by Giorgos Charitakis on 19/10/2017.
//

import Foundation

extension Dictionary {
    static func with(parser: XMLParser) -> [String: Any]? {
        return XMLObjectParser.shared.dictionary(with: parser)
    }
    
    static func with(data: Data) -> [String: Any]? {
        return XMLObjectParser.shared.dictionary(withData: data)
    }
    
    static func with(string: String) -> [String: Any]? {
        return XMLObjectParser.shared.dictionary(withString: string)
    }
    
    static func with(filePath: String) -> [String: Any]? {
        return XMLObjectParser.shared.dictionary(withFile: filePath)
    }
    
    var attributes: [String: String]? {
        let dictionary = self as? [String: Any]
        if let attributes = dictionary?[XMLParserConstant.Key.attributes] {
            return attributes as? [String: String]
        } else {
            var filteredDict = dictionary
            let filteredKeys = [XMLParserConstant.Key.comments, XMLParserConstant.Key.text, XMLParserConstant.Key.nodeName]
            filteredKeys.forEach({ filteredDict?.removeValue(forKey: $0) })
            filteredDict?.keys.forEach({ (key: String) in
                filteredDict?.removeValue(forKey: key)
                if key.hasPrefix(XMLParserConstant.attributePrefix) {
                    filteredDict?[key.substring(from: XMLParserConstant.attributePrefix.endIndex)] = dictionary?[key]
                }
            })
            return filteredDict as? [String: String]
        }
    }
    
    var childNodes: [String: Any]? {
        var filteredDict = self as? [String: Any]
        let filteredKeys = [XMLParserConstant.Key.attributes, XMLParserConstant.Key.comments, XMLParserConstant.Key.text, XMLParserConstant.Key.nodeName]
        filteredKeys.forEach({ filteredDict?.removeValue(forKey: $0) })
        filteredDict?.keys.forEach({ (key: String) in
            if key.hasPrefix(XMLParserConstant.attributePrefix) {
                filteredDict?.removeValue(forKey: key)
            }
        })
        return filteredDict
    }
    
    var comments: [String]? {
        return (self as [AnyHashable: Any])[XMLParserConstant.Key.comments] as? [String]
    }
    
    var nodeName: String? {
        return (self as [AnyHashable: Any])[XMLParserConstant.Key.nodeName] as? String
    }
    
    var innerText: String? {
        let text = (self as [AnyHashable: Any])[XMLParserConstant.Key.text]
        if let stringArray = text as? [String] {
            return stringArray.joined(separator: "\n")
        }
        return text as? String
    }
    
    var innerXML: String {
        var nodes: [String] = []
        
        comments?.forEach({ (comment: String) in
            nodes.append(String(format: "<!--%@-->", comment.xmlEncodedString))
        })
        
        childNodes?.forEach({ (childNode:(key: String, value: Any)) in
            if let xmlStringNode = XMLParserHelper.xmlString(forNode: childNode.value, withNodeName: childNode.key) {
                nodes.append(xmlStringNode)
            }
        })
        
        if let text = innerText {
            nodes.append(text)
        }
        
        return nodes.joined(separator: "\n")
    }
    
    var xmlString: String {
        if self.count == 1 && nodeName == nil {
            return innerXML
        } else {
            return XMLParserHelper.xmlString(forNode: self, withNodeName: nodeName ?? "root") ?? ""
        }
    }
}