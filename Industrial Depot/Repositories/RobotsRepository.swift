//
//  RobotsRepository.swift
//  Industrial Depot
//
//  Created by AI Assistant on 02/10/25.
//

import Foundation
import Combine

class RobotsRepository: ObservableObject {
    
    // MARK: - Properties
    @Published var robots: [RobotModel] = []
    @Published var isLoading = false
    @Published var error: String?
    
    // MARK: - Initialization
    init() {
        loadRobots()
    }
    
    // MARK: - Public Methods
    func loadRobots() {
        isLoading = true
        error = nil
        
        // For now, use sample data. Later we'll load from CSV files
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.robots = RobotModel.sampleRobots
            self.isLoading = false
        }
    }
    
    func getRobot(by model: String) -> RobotModel? {
        return robots.first { $0.model == model }
    }
    
    func refresh() {
        loadRobots()
    }
}

class CobotsRepository: ObservableObject {
    
    // MARK: - Properties
    @Published var cobots: [RobotModel] = []
    @Published var isLoading = false
    @Published var error: String?
    
    // MARK: - Initialization
    init() {
        loadCobots()
    }
    
    // MARK: - Public Methods
    func loadCobots() {
        isLoading = true
        error = nil
        
        // For now, use sample data. Later we'll load from CSV files
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.cobots = RobotModel.sampleCobots
            self.isLoading = false
        }
    }
    
    func getCobot(by model: String) -> RobotModel? {
        return cobots.first { $0.model == model }
    }
    
    func refresh() {
        loadCobots()
    }
}
