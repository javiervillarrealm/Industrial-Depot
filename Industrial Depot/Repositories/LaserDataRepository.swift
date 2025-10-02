//
//  LaserDataRepository.swift
//  Industrial Depot
//
//  Created by AI Assistant on 02/10/25.
//

import Foundation
import Combine

class LaserDataRepository: ObservableObject {
    
    // MARK: - Properties
    @Published var cutParams: [LaserCutParam] = []
    @Published var perfParams: [LaserPerfParam] = []
    @Published var isLoading = false
    @Published var error: String?
    
    private var cutParamsCache: [LaserCutParam]?
    private var perfParamsCache: [LaserPerfParam]?
    
    // MARK: - Initialization
    init() {
        loadLaserData()
    }
    
    // MARK: - Public Methods
    func loadLaserData() {
        isLoading = true
        error = nil
        
        // Use sample data instead of CSV to avoid freezing
        DispatchQueue.main.async {
            self.cutParams = LaserDataRepository.sampleCutParams
            self.perfParams = LaserDataRepository.samplePerfParams
            self.isLoading = false
        }
    }
    
    func getAvailableMaterials() -> [String] {
        let materials = Set(cutParams.map { $0.material })
        return Array(materials).sorted()
    }
    
    func findCutParams(for material: String, thickness: Double) -> LaserCutParam? {
        let materialVariations = getMaterialVariations(material)
        
        // Find exact thickness match first
        for param in cutParams {
            let rowMaterial = param.material.lowercased()
            if isMaterialMatch(material: material, rowMaterial: rowMaterial, variations: materialVariations) &&
               abs(param.thickness - thickness) < 0.1 {
                return param
            }
        }
        
        // If no exact match, find closest thickness
        let matchingParams = cutParams.filter { param in
            let rowMaterial = param.material.lowercased()
            return isMaterialMatch(material: material, rowMaterial: rowMaterial, variations: materialVariations)
        }
        
        if let closest = matchingParams.min(by: { abs($0.thickness - thickness) < abs($1.thickness - thickness) }) {
            return closest
        }
        
        return nil
    }
    
    func findPerforationParams(for material: String, thickness: Double) -> LaserPerfParam? {
        let materialVariations = getMaterialVariations(material)
        
        // Find exact thickness match first
        for param in perfParams {
            let rowMaterial = param.material.lowercased()
            if isMaterialMatch(material: material, rowMaterial: rowMaterial, variations: materialVariations) &&
               abs(param.thickness - thickness) < 0.1 {
                return param
            }
        }
        
        // If no exact match, find closest thickness
        let matchingParams = perfParams.filter { param in
            let rowMaterial = param.material.lowercased()
            return isMaterialMatch(material: material, rowMaterial: rowMaterial, variations: materialVariations)
        }
        
        if let closest = matchingParams.min(by: { abs($0.thickness - thickness) < abs($1.thickness - thickness) }) {
            return closest
        }
        
        return nil
    }
    
    func refresh() {
        loadLaserData()
    }
    
    // MARK: - Private Methods
    private func loadCutParams() -> [LaserCutParam] {
        if let cached = cutParamsCache {
            return cached
        }
        
        // Try different paths to find the CSV file
        var csvPath: String?
        
        // Try with Data/ prefix first
        if let path = Bundle.main.path(forResource: "Data/laser_cut_params_subset_with_id", ofType: "csv") {
            csvPath = path
        }
        // Try without Data/ prefix
        else if let path = Bundle.main.path(forResource: "laser_cut_params_subset_with_id", ofType: "csv") {
            csvPath = path
        }
        
        guard let finalPath = csvPath else {
            print("Could not find CSV file at any path")
            return []
        }
        
        guard let csvContent = try? String(contentsOfFile: finalPath, encoding: .utf8) else {
            print("Could not read CSV file content from: \(finalPath)")
            return []
        }
        
        print("Successfully loaded CSV file with \(csvContent.components(separatedBy: .newlines).count) lines")
        
        let lines = csvContent.components(separatedBy: .newlines)
        guard lines.count > 1 else { return [] }
        
        let headers = lines[0].components(separatedBy: ",")
        var params: [LaserCutParam] = []
        
        for i in 1..<lines.count {
            let line = lines[i]
            if line.isEmpty { continue }
            
            let values = parseCSVLine(line)
            if values.count >= headers.count {
                let param = LaserCutParam(
                    id: values[0],
                    material: values[5], // material column
                    thickness: Double(values[6]) ?? 0.0, // thickness_mm
                    power: Double(values[8]) ?? nil, // power_w
                    speed: parseSpeedRange(values[7]), // speed_m_per_min
                    gas: values[9], // gas
                    collimation: Double(values[3]) ?? nil, // collimation_mm
                    otherParams: [
                        "series": values[1],
                        "fiber_core_um": values[2],
                        "collimation_mm": values[3],
                        "focus_lens_mm": values[4],
                        "pressure_bar": values[10],
                        "nozzle_diameter_mm": values[11],
                        "nozzle_type": values[12],
                        "focus_offset_mm": values[13],
                        "cutting_height_mm": values[14],
                        "remark": values[15]
                    ]
                )
                params.append(param)
            }
        }
        
        cutParamsCache = params
        print("Loaded \(params.count) cut parameters")
        let materials = Set(params.map { $0.material })
        print("Available materials: \(materials)")
        return params
    }
    
    private func loadPerforationParams() -> [LaserPerfParam] {
        if let cached = perfParamsCache {
            return cached
        }
        
        // Try different paths to find the perforation CSV file
        var csvPath: String?
        
        // Try with Data/ prefix first
        if let path = Bundle.main.path(forResource: "Data/laser_perforation_params_subset_with_id", ofType: "csv") {
            csvPath = path
        }
        // Try without Data/ prefix
        else if let path = Bundle.main.path(forResource: "laser_perforation_params_subset_with_id", ofType: "csv") {
            csvPath = path
        }
        
        guard let finalPath = csvPath else {
            print("Could not find perforation CSV file at any path")
            return []
        }
        
        guard let csvContent = try? String(contentsOfFile: finalPath, encoding: .utf8) else {
            print("Could not read perforation CSV file content from: \(finalPath)")
            return []
        }
        
        let lines = csvContent.components(separatedBy: .newlines)
        guard lines.count > 1 else { return [] }
        
        let headers = lines[0].components(separatedBy: ",")
        var params: [LaserPerfParam] = []
        
        for i in 1..<lines.count {
            let line = lines[i]
            if line.isEmpty { continue }
            
            let values = parseCSVLine(line)
            if values.count >= headers.count {
                let param = LaserPerfParam(
                    id: values[0],
                    material: values[3], // material column
                    thickness: Double(values[4]) ?? 0.0, // thickness_mm
                    power: Double(values[7]) ?? nil, // power_w
                    speed: nil, // No speed in perforation data
                    gas: values[5], // gas
                    otherParams: [
                        "series": values[1],
                        "fiber_core_um": values[2],
                        "stage": values[6],
                        "duty_percent": values[8],
                        "frequency_hz": values[9],
                        "nozzle_height_mm": values[10],
                        "air_pressure_bar": values[11],
                        "focus_offset_mm": values[12],
                        "perforation_time_ms": values[13],
                        "stop_blow_ms": values[14],
                        "remark": values[15]
                    ]
                )
                params.append(param)
            }
        }
        
        perfParamsCache = params
        return params
    }
    
    private func parseCSVLine(_ line: String) -> [String] {
        var result: [String] = []
        var current = ""
        var inQuotes = false
        
        for char in line {
            if char == "\"" {
                inQuotes.toggle()
            } else if char == "," && !inQuotes {
                result.append(current)
                current = ""
            } else {
                current.append(char)
            }
        }
        result.append(current)
        
        return result
    }
    
    private func parseSpeedRange(_ speedString: String) -> Double? {
        // Handle speed ranges like "1.0-1.3" or "2.0~3.0" by taking the first value
        let cleaned = speedString.replacingOccurrences(of: "~", with: "-")
        if let range = cleaned.range(of: "-") {
            let firstPart = String(cleaned[..<range.lowerBound])
            return Double(firstPart)
        }
        return Double(speedString)
    }
    
    private func getMaterialVariations(_ material: String) -> [String] {
        let normalized = material.lowercased()
        var variations = [normalized]
        
        // Handle specific material variations
        if normalized.contains("aluminum") || normalized.contains("aluminium") {
            variations.append("aluminium alloy")
            variations.append("aluminum alloy")
        }
        
        if normalized.contains("steel") && normalized.contains("carbon") {
            variations.append("carbon steel")
        }
        
        if normalized.contains("steel") && normalized.contains("stainless") {
            variations.append("stainless steel")
        }
        
        return variations
    }
    
    private func isMaterialMatch(material: String, rowMaterial: String, variations: [String]) -> Bool {
        let normalizedMaterial = material.lowercased()
        
        // Handle specific material types
        if normalizedMaterial.contains("mixed gas") {
            return rowMaterial.contains("mixed gas") && rowMaterial.contains("carbon steel")
        }
        
        if normalizedMaterial.contains("o2") && normalizedMaterial.contains("negative") {
            return rowMaterial.contains("o2") && rowMaterial.contains("negative focus")
        }
        
        if normalizedMaterial.contains("o2") {
            return rowMaterial.contains("o2") && !rowMaterial.contains("negative focus")
        }
        
        // For basic materials, use variation matching
        return variations.contains { variation in
            rowMaterial.contains(variation)
        }
    }
}

// MARK: - Sample Data
extension LaserDataRepository {
    static let sampleCutParams = [
        // Aluminum Alloy 6mm example
        LaserCutParam(
            id: "MFSC-1000X_50um_Aluminium Alloy_6mm",
            material: "Aluminium Alloy",
            thickness: 6.0,
            power: 1000,
            speed: 2.0,
            gas: "N2",
            collimation: 50,
            otherParams: [
                "series": "MFSC-1000X",
                "fiber_core_um": "50",
                "collimation_mm": "50",
                "focus_lens_mm": "125",
                "pressure_bar": "23.6",
                "nozzle_diameter_mm": "2",
                "nozzle_type": "Single",
                "focus_offset_mm": "-3.8",
                "cutting_height_mm": "0.2"
            ]
        ),
        // Carbon Steel examples
        LaserCutParam(
            id: "MFSC-1000X_50um_CarbonSteel_6_0mm",
            material: "Carbon Steel",
            thickness: 6.0,
            power: 1.0,
            speed: 1.2,
            gas: "O2",
            collimation: 0.1,
            otherParams: [
                "series": "MFSC-1000X",
                "fiber_core_um": "50",
                "collimation_mm": "0.1",
                "focus_lens_mm": "125",
                "pressure_bar": "0.6",
                "nozzle_diameter_mm": "1.0",
                "nozzle_type": "Single",
                "focus_offset_mm": "6.0",
                "cutting_height_mm": "0.2"
            ]
        ),
        LaserCutParam(
            id: "MFSC-1000X_50um_CarbonSteel_3_0mm",
            material: "Carbon Steel",
            thickness: 3.0,
            power: 1.0,
            speed: 2.5,
            gas: "O2",
            collimation: 0.1,
            otherParams: [
                "series": "MFSC-1000X",
                "fiber_core_um": "50",
                "collimation_mm": "0.1",
                "focus_lens_mm": "125",
                "pressure_bar": "0.6",
                "nozzle_diameter_mm": "1.0",
                "nozzle_type": "Single",
                "focus_offset_mm": "4.0",
                "cutting_height_mm": "0.2"
            ]
        ),
        LaserCutParam(
            id: "MFSC-1000X_50um_CarbonSteel_2_0mm",
            material: "Carbon Steel",
            thickness: 2.0,
            power: 1.0,
            speed: 4.5,
            gas: "O2",
            collimation: 0.1,
            otherParams: [
                "series": "MFSC-1000X",
                "fiber_core_um": "50",
                "collimation_mm": "0.1",
                "focus_lens_mm": "125",
                "pressure_bar": "1.5",
                "nozzle_diameter_mm": "1.0",
                "nozzle_type": "Single",
                "focus_offset_mm": "3.0",
                "cutting_height_mm": "0.2"
            ]
        ),
        LaserCutParam(
            id: "MFSC-1000X_50um_CarbonSteel_4_0mm",
            material: "Carbon Steel",
            thickness: 4.0,
            power: 1.0,
            speed: 2.5,
            gas: "O2",
            collimation: 0.1,
            otherParams: [
                "series": "MFSC-1000X",
                "fiber_core_um": "50",
                "collimation_mm": "0.1",
                "focus_lens_mm": "125",
                "pressure_bar": "0.6",
                "nozzle_diameter_mm": "1.0",
                "nozzle_type": "Single",
                "focus_offset_mm": "4.0",
                "cutting_height_mm": "0.2"
            ]
        ),
        // Carbon Steel (Mixed Gas N2+Air) examples
        LaserCutParam(
            id: "MFSC-1000X_50um_CarbonSteel_MixedGas_0_8mm",
            material: "Carbon Steel (Mixed Gas N2+Air)",
            thickness: 0.8,
            power: 1.0,
            speed: 18.0,
            gas: "N2/Air",
            collimation: 0.1,
            otherParams: [
                "pressure": "11.0",
                "nozzle_diameter": "2.0",
                "focus_offset": "0.0"
            ]
        ),
        LaserCutParam(
            id: "MFSC-1000X_50um_CarbonSteel_MixedGas_1_0mm",
            material: "Carbon Steel (Mixed Gas N2+Air)",
            thickness: 1.0,
            power: 1.0,
            speed: 12.5,
            gas: "N2/Air",
            collimation: 0.1,
            otherParams: [
                "pressure": "11.0",
                "nozzle_diameter": "2.0",
                "focus_offset": "0.0"
            ]
        ),
        LaserCutParam(
            id: "MFSC-1000X_50um_CarbonSteel_MixedGas_2_0mm",
            material: "Carbon Steel (Mixed Gas N2+Air)",
            thickness: 2.0,
            power: 1.0,
            speed: 8.0,
            gas: "N2/Air",
            collimation: 0.1,
            otherParams: [
                "pressure": "11.0",
                "nozzle_diameter": "2.0",
                "focus_offset": "1.0"
            ]
        ),
        LaserCutParam(
            id: "MFSC-1000X_50um_CarbonSteel_MixedGas_3_0mm",
            material: "Carbon Steel (Mixed Gas N2+Air)",
            thickness: 3.0,
            power: 1.0,
            speed: 5.5,
            gas: "N2/Air",
            collimation: 0.1,
            otherParams: [
                "pressure": "11.0",
                "nozzle_diameter": "2.0",
                "focus_offset": "2.0"
            ]
        ),
        LaserCutParam(
            id: "MFSC-1000X_50um_CarbonSteel_MixedGas_4_0mm",
            material: "Carbon Steel (Mixed Gas N2+Air)",
            thickness: 4.0,
            power: 1.0,
            speed: 4.0,
            gas: "N2/Air",
            collimation: 0.1,
            otherParams: [
                "pressure": "11.0",
                "nozzle_diameter": "2.0",
                "focus_offset": "3.0"
            ]
        ),
        LaserCutParam(
            id: "MFSC-1000X_50um_CarbonSteel_MixedGas_6_0mm",
            material: "Carbon Steel (Mixed Gas N2+Air)",
            thickness: 6.0,
            power: 1.0,
            speed: 2.5,
            gas: "N2/Air",
            collimation: 0.1,
            otherParams: [
                "series": "MFSC-1000X",
                "fiber_core_um": "50",
                "collimation_mm": "0.1",
                "focus_lens_mm": "125",
                "pressure_bar": "11.0",
                "nozzle_diameter_mm": "2.0",
                "nozzle_type": "Single",
                "focus_offset_mm": "4.0",
                "cutting_height_mm": "0.2"
            ]
        ),
        // Carbon Steel (O2) examples
        LaserCutParam(
            id: "MFSC-1000X_50um_CarbonSteel_O2_2_0mm",
            material: "Carbon Steel (O2)",
            thickness: 2.0,
            power: 1.0,
            speed: 4.5,
            gas: "O2",
            collimation: 0.1,
            otherParams: [
                "pressure": "1.5",
                "nozzle_diameter": "1.0",
                "focus_offset": "3.0"
            ]
        ),
        LaserCutParam(
            id: "MFSC-1000X_50um_CarbonSteel_O2_4_0mm",
            material: "Carbon Steel (O2)",
            thickness: 4.0,
            power: 1.0,
            speed: 2.5,
            gas: "O2",
            collimation: 0.1,
            otherParams: [
                "pressure": "0.6",
                "nozzle_diameter": "1.0",
                "focus_offset": "4.0"
            ]
        ),
        LaserCutParam(
            id: "MFSC-1000X_50um_CarbonSteel_O2_6_0mm",
            material: "Carbon Steel (O2)",
            thickness: 6.0,
            power: 1.0,
            speed: 1.2,
            gas: "O2",
            collimation: 0.1,
            otherParams: [
                "series": "MFSC-1000X",
                "fiber_core_um": "50",
                "collimation_mm": "0.1",
                "focus_lens_mm": "125",
                "pressure_bar": "0.6",
                "nozzle_diameter_mm": "1.0",
                "nozzle_type": "Single",
                "focus_offset_mm": "6.0",
                "cutting_height_mm": "0.2"
            ]
        ),
        // Stainless Steel examples
        LaserCutParam(
            id: "MFSC-1000X_50um_StainlessSteel_1_0mm",
            material: "Stainless Steel",
            thickness: 1.0,
            power: 1.0,
            speed: 6.0,
            gas: "N2",
            collimation: 0.1,
            otherParams: [
                "pressure": "8.0",
                "nozzle_diameter": "1.0",
                "focus_offset": "1.0"
            ]
        ),
        LaserCutParam(
            id: "MFSC-1000X_50um_StainlessSteel_2_0mm",
            material: "Stainless Steel",
            thickness: 2.0,
            power: 1.0,
            speed: 3.0,
            gas: "N2",
            collimation: 0.1,
            otherParams: [
                "pressure": "8.0",
                "nozzle_diameter": "1.5",
                "focus_offset": "2.0"
            ]
        ),
        LaserCutParam(
            id: "MFSC-1000X_50um_StainlessSteel_3_0mm",
            material: "Stainless Steel",
            thickness: 3.0,
            power: 1.0,
            speed: 2.0,
            gas: "N2",
            collimation: 0.1,
            otherParams: [
                "pressure": "8.0",
                "nozzle_diameter": "1.5",
                "focus_offset": "2.5"
            ]
        ),
        LaserCutParam(
            id: "MFSC-1000X_50um_StainlessSteel_4_0mm",
            material: "Stainless Steel",
            thickness: 4.0,
            power: 1.0,
            speed: 1.5,
            gas: "N2",
            collimation: 0.1,
            otherParams: [
                "pressure": "8.0",
                "nozzle_diameter": "1.5",
                "focus_offset": "3.0"
            ]
        ),
        LaserCutParam(
            id: "MFSC-1000X_50um_StainlessSteel_6_0mm",
            material: "Stainless Steel",
            thickness: 6.0,
            power: 1.0,
            speed: 1.0,
            gas: "N2",
            collimation: 0.1,
            otherParams: [
                "series": "MFSC-1000X",
                "fiber_core_um": "50",
                "collimation_mm": "0.1",
                "focus_lens_mm": "125",
                "pressure_bar": "8.0",
                "nozzle_diameter_mm": "1.5",
                "nozzle_type": "Single",
                "focus_offset_mm": "4.0",
                "cutting_height_mm": "0.2"
            ]
        ),
        // Aluminum Alloy examples
        LaserCutParam(
            id: "MFSC-1000X_50um_AluminumAlloy_1_0mm",
            material: "Aluminium Alloy",
            thickness: 1.0,
            power: 1.0,
            speed: 8.0,
            gas: "N2",
            collimation: 0.1,
            otherParams: [
                "pressure": "10.0",
                "nozzle_diameter": "1.0",
                "focus_offset": "1.0"
            ]
        ),
        LaserCutParam(
            id: "MFSC-1000X_50um_AluminumAlloy_2_0mm",
            material: "Aluminium Alloy",
            thickness: 2.0,
            power: 1.0,
            speed: 4.0,
            gas: "N2",
            collimation: 0.1,
            otherParams: [
                "pressure": "10.0",
                "nozzle_diameter": "1.5",
                "focus_offset": "2.0"
            ]
        ),
        LaserCutParam(
            id: "MFSC-1000X_50um_AluminumAlloy_3_0mm",
            material: "Aluminium Alloy",
            thickness: 3.0,
            power: 1.0,
            speed: 2.5,
            gas: "N2",
            collimation: 0.1,
            otherParams: [
                "pressure": "10.0",
                "nozzle_diameter": "1.5",
                "focus_offset": "2.5"
            ]
        ),
        LaserCutParam(
            id: "MFSC-1000X_50um_AluminumAlloy_4_0mm",
            material: "Aluminium Alloy",
            thickness: 4.0,
            power: 1.0,
            speed: 2.0,
            gas: "N2",
            collimation: 0.1,
            otherParams: [
                "pressure": "10.0",
                "nozzle_diameter": "1.5",
                "focus_offset": "3.0"
            ]
        ),
        LaserCutParam(
            id: "MFSC-1000X_50um_AluminumAlloy_6_0mm",
            material: "Aluminium Alloy",
            thickness: 6.0,
            power: 1.0,
            speed: 1.2,
            gas: "N2",
            collimation: 0.1,
            otherParams: [
                "series": "MFSC-1000X",
                "fiber_core_um": "50",
                "collimation_mm": "0.1",
                "focus_lens_mm": "125",
                "pressure_bar": "10.0",
                "nozzle_diameter_mm": "1.5",
                "nozzle_type": "Single",
                "focus_offset_mm": "4.0",
                "cutting_height_mm": "0.2"
            ]
        ),
        // Brass examples
        LaserCutParam(
            id: "MFSC-1000X_50um_Brass_1_0mm",
            material: "Brass",
            thickness: 1.0,
            power: 1.0,
            speed: 6.0,
            gas: "N2",
            collimation: 0.1,
            otherParams: [
                "series": "MFSC-1000X",
                "fiber_core_um": "50",
                "collimation_mm": "0.1",
                "focus_lens_mm": "125",
                "pressure_bar": "8.0",
                "nozzle_diameter_mm": "1.0",
                "nozzle_type": "Single",
                "focus_offset_mm": "1.0",
                "cutting_height_mm": "0.2"
            ]
        ),
        LaserCutParam(
            id: "MFSC-1000X_50um_Brass_2_0mm",
            material: "Brass",
            thickness: 2.0,
            power: 1.0,
            speed: 3.0,
            gas: "N2",
            collimation: 0.1,
            otherParams: [
                "series": "MFSC-1000X",
                "fiber_core_um": "50",
                "collimation_mm": "0.1",
                "focus_lens_mm": "125",
                "pressure_bar": "8.0",
                "nozzle_diameter_mm": "1.0",
                "nozzle_type": "Single",
                "focus_offset_mm": "2.0",
                "cutting_height_mm": "0.2"
            ]
        ),
        LaserCutParam(
            id: "MFSC-1000X_50um_Brass_3_0mm",
            material: "Brass",
            thickness: 3.0,
            power: 1.0,
            speed: 2.0,
            gas: "N2",
            collimation: 0.1,
            otherParams: [
                "series": "MFSC-1000X",
                "fiber_core_um": "50",
                "collimation_mm": "0.1",
                "focus_lens_mm": "125",
                "pressure_bar": "8.0",
                "nozzle_diameter_mm": "1.0",
                "nozzle_type": "Single",
                "focus_offset_mm": "2.5",
                "cutting_height_mm": "0.2"
            ]
        ),
        LaserCutParam(
            id: "MFSC-1000X_50um_Brass_4_0mm",
            material: "Brass",
            thickness: 4.0,
            power: 1.0,
            speed: 1.5,
            gas: "N2",
            collimation: 0.1,
            otherParams: [
                "series": "MFSC-1000X",
                "fiber_core_um": "50",
                "collimation_mm": "0.1",
                "focus_lens_mm": "125",
                "pressure_bar": "8.0",
                "nozzle_diameter_mm": "1.0",
                "nozzle_type": "Single",
                "focus_offset_mm": "3.0",
                "cutting_height_mm": "0.2"
            ]
        ),
        // Copper examples
        LaserCutParam(
            id: "MFSC-1000X_50um_Copper_1_0mm",
            material: "Copper",
            thickness: 1.0,
            power: 1.0,
            speed: 5.0,
            gas: "N2",
            collimation: 0.1,
            otherParams: [
                "series": "MFSC-1000X",
                "fiber_core_um": "50",
                "collimation_mm": "0.1",
                "focus_lens_mm": "125",
                "pressure_bar": "8.0",
                "nozzle_diameter_mm": "1.0",
                "nozzle_type": "Single",
                "focus_offset_mm": "1.0",
                "cutting_height_mm": "0.2"
            ]
        ),
        LaserCutParam(
            id: "MFSC-1000X_50um_Copper_2_0mm",
            material: "Copper",
            thickness: 2.0,
            power: 1.0,
            speed: 2.5,
            gas: "N2",
            collimation: 0.1,
            otherParams: [
                "series": "MFSC-1000X",
                "fiber_core_um": "50",
                "collimation_mm": "0.1",
                "focus_lens_mm": "125",
                "pressure_bar": "8.0",
                "nozzle_diameter_mm": "1.0",
                "nozzle_type": "Single",
                "focus_offset_mm": "2.0",
                "cutting_height_mm": "0.2"
            ]
        ),
        LaserCutParam(
            id: "MFSC-1000X_50um_Copper_3_0mm",
            material: "Copper",
            thickness: 3.0,
            power: 1.0,
            speed: 1.8,
            gas: "N2",
            collimation: 0.1,
            otherParams: [
                "series": "MFSC-1000X",
                "fiber_core_um": "50",
                "collimation_mm": "0.1",
                "focus_lens_mm": "125",
                "pressure_bar": "8.0",
                "nozzle_diameter_mm": "1.0",
                "nozzle_type": "Single",
                "focus_offset_mm": "2.5",
                "cutting_height_mm": "0.2"
            ]
        ),
        LaserCutParam(
            id: "MFSC-1000X_50um_Copper_4_0mm",
            material: "Copper",
            thickness: 4.0,
            power: 1.0,
            speed: 1.2,
            gas: "N2",
            collimation: 0.1,
            otherParams: [
                "series": "MFSC-1000X",
                "fiber_core_um": "50",
                "collimation_mm": "0.1",
                "focus_lens_mm": "125",
                "pressure_bar": "8.0",
                "nozzle_diameter_mm": "1.0",
                "nozzle_type": "Single",
                "focus_offset_mm": "3.0",
                "cutting_height_mm": "0.2"
            ]
        )
    ]
    
    static let samplePerfParams = [
        // Carbon Steel perforation examples
        LaserPerfParam(
            id: "PERF_CarbonSteel_2mm",
            material: "Carbon Steel",
            thickness: 2.0,
            power: 1.0,
            speed: 1.5,
            gas: "O2",
            otherParams: [
                "pierce_time": "0.3",
                "delay": "0.1"
            ]
        ),
        LaserPerfParam(
            id: "PERF_CarbonSteel_3mm",
            material: "Carbon Steel",
            thickness: 3.0,
            power: 1.0,
            speed: 1.2,
            gas: "O2",
            otherParams: [
                "pierce_time": "0.3",
                "delay": "0.1"
            ]
        ),
        LaserPerfParam(
            id: "PERF_CarbonSteel_4mm",
            material: "Carbon Steel",
            thickness: 4.0,
            power: 1.0,
            speed: 1.0,
            gas: "O2",
            otherParams: [
                "pierce_time": "0.4",
                "delay": "0.2"
            ]
        ),
        LaserPerfParam(
            id: "PERF_CarbonSteel_6mm",
            material: "Carbon Steel",
            thickness: 6.0,
            power: 1.0,
            speed: 0.8,
            gas: "O2",
            otherParams: [
                "pierce_time": "0.5",
                "delay": "0.2"
            ]
        ),
        // Stainless Steel perforation examples
        LaserPerfParam(
            id: "PERF_StainlessSteel_1mm",
            material: "Stainless Steel",
            thickness: 1.0,
            power: 1.0,
            speed: 2.5,
            gas: "N2",
            otherParams: [
                "pierce_time": "0.2",
                "delay": "0.1"
            ]
        ),
        LaserPerfParam(
            id: "PERF_StainlessSteel_2mm",
            material: "Stainless Steel",
            thickness: 2.0,
            power: 1.0,
            speed: 1.5,
            gas: "N2",
            otherParams: [
                "pierce_time": "0.4",
                "delay": "0.1"
            ]
        ),
        LaserPerfParam(
            id: "PERF_StainlessSteel_3mm",
            material: "Stainless Steel",
            thickness: 3.0,
            power: 1.0,
            speed: 1.2,
            gas: "N2",
            otherParams: [
                "pierce_time": "0.5",
                "delay": "0.1"
            ]
        ),
        LaserPerfParam(
            id: "PERF_StainlessSteel_4mm",
            material: "Stainless Steel",
            thickness: 4.0,
            power: 1.0,
            speed: 1.0,
            gas: "N2",
            otherParams: [
                "pierce_time": "0.6",
                "delay": "0.2"
            ]
        ),
        LaserPerfParam(
            id: "PERF_StainlessSteel_6mm",
            material: "Stainless Steel",
            thickness: 6.0,
            power: 1.0,
            speed: 0.8,
            gas: "N2",
            otherParams: [
                "pierce_time": "0.8",
                "delay": "0.2"
            ]
        ),
        // Aluminum Alloy perforation examples
        LaserPerfParam(
            id: "PERF_AluminumAlloy_1mm",
            material: "Aluminium Alloy",
            thickness: 1.0,
            power: 1.0,
            speed: 3.0,
            gas: "N2",
            otherParams: [
                "pierce_time": "0.2",
                "delay": "0.1"
            ]
        ),
        LaserPerfParam(
            id: "PERF_AluminumAlloy_2mm",
            material: "Aluminium Alloy",
            thickness: 2.0,
            power: 1.0,
            speed: 2.0,
            gas: "N2",
            otherParams: [
                "pierce_time": "0.3",
                "delay": "0.1"
            ]
        ),
        LaserPerfParam(
            id: "PERF_AluminumAlloy_3mm",
            material: "Aluminium Alloy",
            thickness: 3.0,
            power: 1.0,
            speed: 1.5,
            gas: "N2",
            otherParams: [
                "pierce_time": "0.4",
                "delay": "0.1"
            ]
        ),
        LaserPerfParam(
            id: "PERF_AluminumAlloy_4mm",
            material: "Aluminium Alloy",
            thickness: 4.0,
            power: 1.0,
            speed: 1.5,
            gas: "N2",
            otherParams: [
                "pierce_time": "0.5",
                "delay": "0.1"
            ]
        ),
        LaserPerfParam(
            id: "PERF_AluminumAlloy_6mm",
            material: "Aluminium Alloy",
            thickness: 6.0,
            power: 1.0,
            speed: 1.0,
            gas: "N2",
            otherParams: [
                "pierce_time": "0.7",
                "delay": "0.2"
            ]
        ),
        // Brass perforation examples
        LaserPerfParam(
            id: "PERF_Brass_1mm",
            material: "Brass",
            thickness: 1.0,
            power: 1.0,
            speed: 3.0,
            gas: "N2",
            otherParams: [
                "pierce_time": "0.2",
                "delay": "0.1"
            ]
        ),
        LaserPerfParam(
            id: "PERF_Brass_2mm",
            material: "Brass",
            thickness: 2.0,
            power: 1.0,
            speed: 2.0,
            gas: "N2",
            otherParams: [
                "pierce_time": "0.3",
                "delay": "0.1"
            ]
        ),
        LaserPerfParam(
            id: "PERF_Brass_3mm",
            material: "Brass",
            thickness: 3.0,
            power: 1.0,
            speed: 1.5,
            gas: "N2",
            otherParams: [
                "pierce_time": "0.4",
                "delay": "0.1"
            ]
        ),
        LaserPerfParam(
            id: "PERF_Brass_4mm",
            material: "Brass",
            thickness: 4.0,
            power: 1.0,
            speed: 1.2,
            gas: "N2",
            otherParams: [
                "pierce_time": "0.5",
                "delay": "0.1"
            ]
        ),
        // Copper perforation examples
        LaserPerfParam(
            id: "PERF_Copper_1mm",
            material: "Copper",
            thickness: 1.0,
            power: 1.0,
            speed: 2.5,
            gas: "N2",
            otherParams: [
                "pierce_time": "0.2",
                "delay": "0.1"
            ]
        ),
        LaserPerfParam(
            id: "PERF_Copper_2mm",
            material: "Copper",
            thickness: 2.0,
            power: 1.0,
            speed: 1.8,
            gas: "N2",
            otherParams: [
                "pierce_time": "0.3",
                "delay": "0.1"
            ]
        ),
        LaserPerfParam(
            id: "PERF_Copper_3mm",
            material: "Copper",
            thickness: 3.0,
            power: 1.0,
            speed: 1.5,
            gas: "N2",
            otherParams: [
                "pierce_time": "0.4",
                "delay": "0.1"
            ]
        ),
        LaserPerfParam(
            id: "PERF_Copper_4mm",
            material: "Copper",
            thickness: 4.0,
            power: 1.0,
            speed: 1.2,
            gas: "N2",
            otherParams: [
                "pierce_time": "0.5",
                "delay": "0.1"
            ]
        )
    ]
}
