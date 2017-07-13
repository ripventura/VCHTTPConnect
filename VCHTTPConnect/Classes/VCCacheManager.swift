//
//  VCCacheManager.swift
//  Pods
//
//  Created by Vitor Cesco on 13/07/17.
//
//

import UIKit
import VCSwiftToolkit

let sharedCacheManager: VCCacheManager = VCCacheManager()

/** Stores and retrieves data from local storage. */
open class VCCacheManager {
    public enum CacheType: String {
        case dictionary = "Dictionary"
        case array = "Array"
        case string = "String"
        case imageJPG = "ImageJPG"
        case imagePNG = "ImagePNG"
    }
    
    init() {
        self.prepareCacheStructure()
    }
    
    /** Caches content locally */
    open func cache(type: CacheType, content: Any, key: String) -> Void {
        switch type {
        case .dictionary:
            if let content = content as? NSDictionary {
                return VCFileManager.writeDictionary(dictionary: content,
                                                     fileName: key,
                                                     fileExtension: self.fileExtension(type: type),
                                                     directory: .library,
                                                     customFolder: self.cacheFolderName(type: type),
                                                     replaceExisting: true)
            }
        case .array:
            if let content = content as? NSArray {
                return VCFileManager.writeArray(array: content,
                                                fileName: key,
                                                fileExtension: self.fileExtension(type: type),
                                                directory: .library,
                                                customFolder: self.cacheFolderName(type: type),
                                                replaceExisting: true)
            }
        case .string:
            if let content = content as? String {
                return VCFileManager.writeString(string: content,
                                                 fileName: key,
                                                 fileExtension: self.fileExtension(type: type),
                                                 directory: .library,
                                                 customFolder: self.cacheFolderName(type: type),
                                                 replaceExisting: true)
            }
        case .imageJPG, .imagePNG:
            if let content = content as? UIImage {
                if type == .imageJPG {
                    return VCFileManager.writeImage(image: content,
                                                    imageFormat: .JPG,
                                                    fileName: key,
                                                    fileExtension: self.fileExtension(type: type),
                                                    directory: .library,
                                                    customFolder: self.cacheFolderName(type: type),
                                                    replaceExisting: true)
                }
                else if type == .imagePNG {
                    return VCFileManager.writeImage(image: content,
                                                    imageFormat: .PNG,
                                                    fileName: key,
                                                    fileExtension: self.fileExtension(type: type),
                                                    directory: .library,
                                                    customFolder: self.cacheFolderName(type: type),
                                                    replaceExisting: true)
                }
            }
        }
        print("-- Cache Failed --\nInvalid Content for Type: " + type.rawValue)
    }
    
    /** Retireves a local cache */
    open func retrieve(type: CacheType, key: String) -> Any {
        switch type {
        case .dictionary:
            return VCFileManager.readDictionary(fileName: key,
                                                fileExtension: self.fileExtension(type: type),
                                                directory: .library,
                                                customFolder: self.cacheFolderName(type: type)) as Any
        case .array:
            return VCFileManager.readArray(fileName: key,
                                           fileExtension: self.fileExtension(type: type),
                                           directory: .library,
                                           customFolder: self.cacheFolderName(type: type)) as Any
        case .string:
            return VCFileManager.readString(fileName: key,
                                            fileExtension: self.fileExtension(type: type),
                                            directory: .library,
                                            customFolder: self.cacheFolderName(type: type)) as Any
        case .imagePNG, .imageJPG:
            return VCFileManager.readImage(fileName: key,
                                           fileExtension: self.fileExtension(type: type),
                                           directory: .library,
                                           customFolder: self.cacheFolderName(type: type)) as Any
        }
    }
    
    // MARK: - Internal
    
    internal func prepareCacheStructure() -> Void {
        _ = VCFileManager.createFolderInDirectory(directory: .library,
                                                  folderName: self.cacheFolderName())
        
        
        _ = VCFileManager.createFolderInDirectory(directory: .library,
                                                  folderName: self.cacheFolderName(type: .dictionary))
        _ = VCFileManager.createFolderInDirectory(directory: .library,
                                                  folderName: self.cacheFolderName(type: .array))
        _ = VCFileManager.createFolderInDirectory(directory: .library,
                                                  folderName: self.cacheFolderName(type: .string))
        _ = VCFileManager.createFolderInDirectory(directory: .library,
                                                  folderName: self.cacheFolderName(type: .imageJPG))
        _ = VCFileManager.createFolderInDirectory(directory: .library,
                                                  folderName: self.cacheFolderName(type: .imagePNG))
    }
    
    internal func cacheFolderName() -> String {
        return "VCCachedContent"
    }
    
    internal func cacheFolderName(type: CacheType) -> String {
        return self.cacheFolderName() + "/" + type.rawValue
    }
    
    internal func fileExtension(type: CacheType) -> String {
        switch type {
        case .dictionary, .array:
            return "plist"
        case .string:
            return "txt"
        case .imageJPG:
            return VCFileManager.ImageFormat.JPG.rawValue
        case .imagePNG:
            return VCFileManager.ImageFormat.PNG.rawValue
        }
    }
}
