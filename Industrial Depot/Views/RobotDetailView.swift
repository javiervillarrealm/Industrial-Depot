//
//  RobotDetailView.swift
//  Industrial Depot
//
//  Created by AI Assistant on 02/10/25.
//

import SwiftUI
import UIKit

struct RobotDetailView: View {
    let robot: RobotModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Robot Image - Centered and larger
                AsyncImage(url: Bundle.main.url(forResource: robot.imageUrl, withExtension: "png")) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } placeholder: {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .overlay(
                            Image(systemName: "photo")
                                .foregroundColor(.gray)
                        )
                }
                .frame(height: 280)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                
                // Robot Model - Centered
                Text(robot.model)
                    .font(.title)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    
                Divider()
                
                // Specifications
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(Array(robot.fields.keys.sorted()), id: \.self) { key in
                        if let value = robot.fields[key] {
                            HStack {
                                Text(translateRobotParameter(key))
                                    .font(.body)
                                Spacer()
                                Text(value)
                                    .font(.body)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
                
                Divider()
                
                // Contact Section - Centered
                VStack(spacing: 12) {
                    Text("¿Necesita una cotización o asesoría?")
                        .font(.body)
                        .multilineTextAlignment(.center)
                    
                    VStack(spacing: 8) {
                        Text("Axiom Robotics")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        HStack(spacing: 12) {
                            Button(action: {
                                if let url = URL(string: "mailto:javiervillam@axiomrobotics.tech") {
                                    UIApplication.shared.open(url)
                                }
                            }) {
                                Text("Correo")
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(Color.blue)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                            
                            Button(action: {
                                if let url = URL(string: "https://axiomrobotics.tech") {
                                    UIApplication.shared.open(url)
                                }
                            }) {
                                Text("Sitio Web")
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(Color.blue)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.systemGray6))
                    )
                }
            }
            .padding()
        }
            .navigationTitle("Detalles")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Atrás") {
                        dismiss()
                    }
                }
            }
    }
    
    // Simple robot parameter translation function to avoid freezing
    private func translateRobotParameter(_ key: String) -> String {
        switch key {
        case "Payload_kg": return "Carga útil (kg)"
        case "Reach_mm": return "Alcance (mm)"
        case "Repeatability_mm": return "Repetibilidad (mm)"
        case "Controller": return "Controlador"
        case "Body_Weight_kg": return "Peso del Equipo (kg)"
        case "Dof": return "GDL"
        case "Max_Speed_mm_s": return "Velocidad Máxima (mm/s)"
        case "Protection_Rating": return "Grado de Protección"
        case "Operating_Temperature_C": return "Temperatura de Operación (°C)"
        case "Storage_Temperature_C": return "Temperatura de Almacenamiento (°C)"
        case "Humidity": return "Humedad"
        case "Power_Consumption_W": return "Consumo de Energía (W)"
        case "Voltage_V": return "Voltaje (V)"
        case "Frequency_Hz": return "Frecuencia (Hz)"
        case "Installation": return "Instalación"
        case "Programming": return "Programación"
        case "Safety": return "Seguridad"
        case "Application": return "Aplicación"
        case "Warranty": return "Garantía"
        case "Certification": return "Certificación"
        default: return key
        }
    }
}

#Preview {
    RobotDetailView(robot: RobotModel.sampleRobots[0])
}
