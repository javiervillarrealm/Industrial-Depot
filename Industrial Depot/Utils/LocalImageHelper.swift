//
//  LocalImageHelper.swift
//  Industrial Depot
//
//  Created by AI Assistant on 02/10/25.
//

import Foundation
import SwiftUI

struct LocalImageHelper {
    
    // MARK: - Available Images
    private static let availableRobotImages = [
        "SR25A-20:1.80",
        "SR25A-20-1.80",
        "SR25A-20-1_80",
        "SR25A-20_1_80",
        "SR25A-20",
        "SR25A",
        "SR25A-20-180",
        "SR25A-20_180",
        "SR210-120:3.05",
        "SR210A-210:2.65",
        "SR210A-210:3.05-DW",
        "SR25A-12:2.01",
        "SR500A-360:2.83",
        "SR50A-50:2.15",
        "SN7A-7:0.90"
    ]
    
    private static let availableCobotImages = [
        "GCR3-618",
        "GCR5-910",
        "GCR7-910",
        "GCR10-1300",
        "GCR12-1300",
        "GCR16-960",
        "GCR16-2000",
        "GCR20-1400",
        "GCR25-1800",
        "GCR30-1100"
    ]
    
    // MARK: - Public Methods
    static func getLocalImagePath(for model: String, type: String) -> String? {
        let availableImages = type.lowercased() == "cobot" ? availableCobotImages : availableRobotImages
        
        // Try to find a matching image file
        for filename in availableImages {
            if isLikelyMatch(model: model, filename: filename) {
                return filename
            }
        }
        return nil
    }
    
    static func getLaserImagePath() -> String {
        return "laser_machine"
    }
    
    static func getImageName(for model: String, type: String) -> String? {
        return getLocalImagePath(for: model, type: type)
    }
    
    // MARK: - Private Methods
    private static func normalizeModelForFilename(_ model: String) -> Set<String> {
        let normalized = model.lowercased()
            .replacingOccurrences(of: "/", with: "-")
            .replacingOccurrences(of: " ", with: "-")
            .replacingOccurrences(of: "_", with: "-")
        
        var variations = Set<String>()
        variations.insert(normalized)
        variations.insert(normalized.replacingOccurrences(of: "-", with: ""))
        variations.insert(normalized.replacingOccurrences(of: "-", with: "_"))
        variations.insert(normalized.replacingOccurrences(of: "-", with: " "))
        
        return variations
    }
    
    private static func isLikelyMatch(model: String, filename: String) -> Bool {
        let normalizedModelVariations = normalizeModelForFilename(model)
        let normalizedFilename = filename.lowercased()
        
        // Direct exact match
        if normalizedModelVariations.contains(normalizedFilename) {
            return true
        }
        
        // Check if any model variation matches the filename
        for modelVariation in normalizedModelVariations {
            if modelVariation == normalizedFilename {
                return true
            }
        }
        
        // If the filename contains the model name
        let modelSlug = model.lowercased()
            .replacingOccurrences(of: "/", with: "-")
            .replacingOccurrences(of: " ", with: "-")
            .replacingOccurrences(of: "_", with: "-")
        
        if normalizedFilename.contains(modelSlug) {
            return true
        }
        
        return false
    }
}
