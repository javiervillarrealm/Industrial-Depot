//
//  RobotModel.swift
//  Industrial Depot
//
//  Created by AI Assistant on 02/10/25.
//

import Foundation

struct RobotModel: Identifiable, Codable {
    let id = UUID()
    let model: String
    let imageUrl: String?
    let fields: [String: String]
    
    enum CodingKeys: String, CodingKey {
        case model, imageUrl, fields
    }
}

// MARK: - Sample Data
extension RobotModel {
    static let sampleRobots = [
        RobotModel(
            model: "SR25A-20/1.80",
            imageUrl: "SR25A-20:1.80",
            fields: [
                "Payload_kg": "20",
                "Reach_mm": "1803",
                "DOF": "6",
                "Repeatability_mm": "0.05",
                "Controller": "SRC M5",
                "Body_Weight_kg": "250"
            ]
        ),
        RobotModel(
            model: "SR50A-50/2.15",
            imageUrl: "SR50A-50:2.15",
            fields: [
                "Payload_kg": "50",
                "Reach_mm": "2158",
                "DOF": "6",
                "Repeatability_mm": "0.05",
                "Controller": "SRC E5",
                "Body_Weight_kg": "530"
            ]
        ),
        RobotModel(
            model: "SR25A-12/2.01",
            imageUrl: "SR25A-12:2.01",
            fields: [
                "Payload_kg": "12",
                "Reach_mm": "2010",
                "DOF": "6",
                "Repeatability_mm": "0.02",
                "Controller": "SRC E5",
                "Body_Weight_kg": "250"
            ]
        ),
        RobotModel(
            model: "SR210-120/3.05",
            imageUrl: "SR210-120:3.05",
            fields: [
                "Payload_kg": "120",
                "Reach_mm": "3050",
                "DOF": "6",
                "Repeatability_mm": "0.05",
                "Controller": "SRC E5",
                "Body_Weight_kg": "1200"
            ]
        ),
        RobotModel(
            model: "SR210A-210/2.65",
            imageUrl: "SR210A-210:2.65",
            fields: [
                "Payload_kg": "210",
                "Reach_mm": "2650",
                "DOF": "6",
                "Repeatability_mm": "0.05",
                "Controller": "SRC E5",
                "Body_Weight_kg": "1200"
            ]
        ),
        RobotModel(
            model: "SR210A-210/3.05-DW",
            imageUrl: "SR210A-210:3.05-DW",
            fields: [
                "Payload_kg": "210",
                "Reach_mm": "3050",
                "DOF": "6",
                "Repeatability_mm": "0.05",
                "Controller": "SRC E5",
                "Body_Weight_kg": "1200"
            ]
        ),
        RobotModel(
            model: "SR500A-360/2.83",
            imageUrl: "SR500A-360:2.83",
            fields: [
                "Payload_kg": "360",
                "Reach_mm": "2830",
                "DOF": "6",
                "Repeatability_mm": "0.05",
                "Controller": "SRC E5",
                "Body_Weight_kg": "2000"
            ]
        ),
        RobotModel(
            model: "SN7A-7/0.90",
            imageUrl: "SN7A-7:0.90",
            fields: [
                "Payload_kg": "7",
                "Reach_mm": "906",
                "DOF": "6",
                "Repeatability_mm": "0.02",
                "Controller": "SRC C5",
                "Body_Weight_kg": "49"
            ]
        )
    ]
    
    static let sampleCobots = [
        RobotModel(
            model: "GCR3-618",
            imageUrl: "GCR3-618",
            fields: [
                "Payload_kg": "3",
                "Reach_mm": "618",
                "DOF": "6",
                "Repeatability_mm": "0.02",
                "Controller": "DC15S",
                "Body_Weight_kg": "13"
            ]
        ),
        RobotModel(
            model: "GCR5-910",
            imageUrl: "GCR5-910",
            fields: [
                "Payload_kg": "5",
                "Reach_mm": "910",
                "DOF": "6",
                "Repeatability_mm": "0.02",
                "Controller": "DC15S",
                "Body_Weight_kg": "22"
            ]
        ),
        RobotModel(
            model: "GCR7-910",
            imageUrl: "GCR7-910",
            fields: [
                "Payload_kg": "7",
                "Reach_mm": "910",
                "DOF": "6",
                "Repeatability_mm": "0.02",
                "Controller": "DC15S",
                "Body_Weight_kg": "22"
            ]
        ),
        RobotModel(
            model: "GCR10-1300",
            imageUrl: "GCR10-1300",
            fields: [
                "Payload_kg": "10",
                "Reach_mm": "1300",
                "DOF": "6",
                "Repeatability_mm": "0.03",
                "Controller": "DC15S",
                "Body_Weight_kg": "37.8"
            ]
        ),
        RobotModel(
            model: "GCR12-1300",
            imageUrl: "GCR12-1300",
            fields: [
                "Payload_kg": "12",
                "Reach_mm": "1300",
                "DOF": "6",
                "Repeatability_mm": "0.03",
                "Controller": "DC15S",
                "Body_Weight_kg": "37.8"
            ]
        ),
        RobotModel(
            model: "GCR16-960",
            imageUrl: "GCR16-960",
            fields: [
                "Payload_kg": "16",
                "Reach_mm": "960",
                "DOF": "6",
                "Repeatability_mm": "0.03",
                "Controller": "DC15S",
                "Body_Weight_kg": "37.8"
            ]
        ),
        RobotModel(
            model: "GCR16-2000",
            imageUrl: "GCR16-2000",
            fields: [
                "Payload_kg": "16",
                "Reach_mm": "2000",
                "DOF": "6",
                "Repeatability_mm": "0.03",
                "Controller": "DC15S",
                "Body_Weight_kg": "37.8"
            ]
        ),
        RobotModel(
            model: "GCR20-1400",
            imageUrl: "GCR20-1400",
            fields: [
                "Payload_kg": "20",
                "Reach_mm": "1400",
                "DOF": "6",
                "Repeatability_mm": "0.03",
                "Controller": "DC15S",
                "Body_Weight_kg": "37.8"
            ]
        ),
        RobotModel(
            model: "GCR25-1800",
            imageUrl: "GRC25-1800",
            fields: [
                "Payload_kg": "25",
                "Reach_mm": "1800",
                "DOF": "6",
                "Repeatability_mm": "0.03",
                "Controller": "DC15S",
                "Body_Weight_kg": "37.8"
            ]
        ),
        RobotModel(
            model: "GCR30-1100",
            imageUrl: "GCR30-1100",
            fields: [
                "Payload_kg": "30",
                "Reach_mm": "1100",
                "DOF": "6",
                "Repeatability_mm": "0.03",
                "Controller": "DC15S",
                "Body_Weight_kg": "37.8"
            ]
        )
    ]
}
