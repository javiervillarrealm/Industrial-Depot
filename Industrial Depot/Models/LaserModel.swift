//
//  LaserModel.swift
//  Industrial Depot
//
//  Created by AI Assistant on 02/10/25.
//

import Foundation

struct LaserParameter: Identifiable, Codable {
    let id = UUID()
    let material: String
    let thickness: Double
    let parameters: [String: String]
    
    enum CodingKeys: String, CodingKey {
        case material, thickness, parameters
    }
}

struct LaserCutParam: Identifiable, Codable {
    let id: String
    let material: String
    let thickness: Double
    let power: Double?
    let speed: Double?
    let gas: String?
    let collimation: Double?
    let otherParams: [String: String]
    
    enum CodingKeys: String, CodingKey {
        case id, material, thickness, power, speed, gas, collimation
        case otherParams = "other_params"
    }
}

struct LaserPerfParam: Identifiable, Codable {
    let id: String
    let material: String
    let thickness: Double
    let power: Double?
    let speed: Double?
    let gas: String?
    let otherParams: [String: String]
    
    enum CodingKeys: String, CodingKey {
        case id, material, thickness, power, speed, gas
        case otherParams = "other_params"
    }
}
