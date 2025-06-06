//
//  LocalStorage.swift
//  iOSapp
//
//  Created by 瑞太智联 on 2025/6/6.
//

import Foundation

class LocalStorage {
    static let shared = LocalStorage()
    private let fileManager = FileManager.default
    
    /// 缓存目录路径
    private lazy var cacheDirectory: URL = {
        let urls = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)
        return urls[0].appendingPathComponent("PersistentCache")
    }()
    
    private init() {
        createCacheDirectory()
    }
    
    /// 创建缓存目录
    private func createCacheDirectory() {
        guard !fileManager.fileExists(atPath: cacheDirectory.path) else { return }
        try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
        
        // 禁止备份到iCloud (确保不影响审核)
        var resourceURL = URL(fileURLWithPath: cacheDirectory.path)
        var resourceValues = URLResourceValues()
        resourceValues.isExcludedFromBackup = true
        try? resourceURL.setResourceValues(resourceValues)
    }
    
    /// 保存数据
    func save<T: Encodable>(_ object: T, forKey key: String, expiry: Date? = nil) {
        let fileURL = cacheDirectory.appendingPathComponent(key)
        let metadata = CacheMetadata(expiryDate: expiry, data: object)
        
        do {
            let data = try JSONEncoder().encode(metadata)
            try data.write(to: fileURL, options: .atomic)
        } catch {
            print("缓存写入失败: \(error)")
        }
    }
    
    /// 读取数据
    func load<T: Decodable>(forKey key: String, type: T.Type) -> T? {
        let fileURL = cacheDirectory.appendingPathComponent(key)
        guard fileManager.fileExists(atPath: fileURL.path) else { return nil }
        
        do {
            let data = try Data(contentsOf: fileURL)
            let metadata = try JSONDecoder().decode(CacheMetadata2<T>.self, from: data)
            
            // 检查过期时间
            if let expiry = metadata.expiryDate, expiry < Date() {
                remove(forKey: key) // 自动清理过期项目
                return nil
            }
            return metadata.data
        } catch {
            print("缓存读取失败: \(error)")
            return nil
        }
    }
    
    /// 删除缓存
    func remove(forKey key: String) {
        let fileURL = cacheDirectory.appendingPathComponent(key)
        try? fileManager.removeItem(at: fileURL)
    }
    
    /// 清除所有缓存 (按需使用)
    func clearAll() {
        try? fileManager.removeItem(at: cacheDirectory)
        createCacheDirectory()
    }
}

// 支持过期时间的缓存包装器
struct CacheMetadata<T: Encodable>: Encodable {
    let expiryDate: Date?
    let data: T
}

struct CacheMetadata2<T: Decodable>: Decodable {
    let expiryDate: Date?
    let data: T
}

// 使用示例
struct KVData: Codable {
    let key: String
    let value: String
}

//// 写入缓存 (有效期7天)
//let profile = UserProfile(name: "John", id: 123)
//let expiry = Calendar.current.date(byAdding: .day, value: 7, to: Date())
//LocalStorage.shared.save(profile, forKey: "user_profile", expiry: expiry)
//
//// 读取缓存
//if let cached = LocalStorage.shared.load(forKey: "user_profile", type: UserProfile.self) {
//    print("读取缓存: \(cached.name)")
//}
