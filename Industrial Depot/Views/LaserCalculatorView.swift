//
//  LaserCalculatorView.swift
//  Industrial Depot
//
//  Created by AI Assistant on 02/10/25.
//

import SwiftUI
import UIKit

struct LaserCalculatorView: View {
    @EnvironmentObject var laserRepository: LaserDataRepository
    @State private var selectedMaterial: String = ""
    @State private var thicknessText: String = ""
    @State private var cutResult: LaserCutParam?
    @State private var perfResult: LaserPerfParam?
    @State private var resultMessage: String?
    @State private var isCalculating = false
    @State private var availableMaterials: [String] = []
    @State private var materialMapping: [String: String] = [:] // Spanish -> English mapping
    
    private func loadMaterials() {
        let rawMaterials = laserRepository.getAvailableMaterials()
        availableMaterials = rawMaterials.map { ParameterTranslator.translateMaterialName($0) }
        
        // Create mapping from Spanish to English names
        materialMapping = Dictionary(uniqueKeysWithValues: zip(availableMaterials, rawMaterials))
        
        // Set initial selection if none is set
        if selectedMaterial.isEmpty && !availableMaterials.isEmpty {
            selectedMaterial = availableMaterials[0]
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Material Selection
                VStack(alignment: .leading, spacing: 8) {
                    Text("Material")
                        .font(.headline)
                    
                    if !availableMaterials.isEmpty {
                        Picker("Seleccionar Material", selection: $selectedMaterial) {
                            ForEach(availableMaterials, id: \.self) { material in
                                Text(material).tag(material)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color(.systemGray6))
                        )
                    } else {
                        Text("Cargando materiales...")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color(.systemGray6))
                            )
                    }
                }
                
                // Thickness Input
                VStack(alignment: .leading, spacing: 8) {
                    Text("Grosor (mm)")
                        .font(.headline)
                    
                    TextField("Ingrese el grosor en mm", text: $thicknessText)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                // Calculate Button
                Button(action: calculateParameters) {
                    HStack {
                        if isCalculating {
                            ProgressView()
                                .scaleEffect(0.8)
                        }
                        Text("Obtener Recomendación")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .disabled(selectedMaterial.isEmpty || thicknessText.isEmpty || isCalculating)
                
                // Results
                if let message = resultMessage {
                    VStack {
                        Text(message)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color(.systemGray6))
                            )
                    }
                }
                
                if let cut = cutResult {
                    ResultCard(title: "Parámetros de Corte", data: cut)
                }
                
                // Contact Section
                VStack(spacing: 12) {
                    Text("¿Necesita una cotización o asesoría?")
                        .font(.body)
                        .multilineTextAlignment(.center)
                    
                    VStack(spacing: 8) {
                        Text("Industrial Metal Systems")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        HStack(spacing: 12) {
                            Button(action: {
                                if let url = URL(string: "mailto:javier.villarreal@industrialms.com") {
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
                                if let url = URL(string: "https://industrialms.com") {
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
        .navigationTitle("Calculadora Láser")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            loadMaterials()
        }
    }
    
    private func calculateParameters() {
        guard let thickness = Double(thicknessText) else {
            resultMessage = "Por favor ingrese un grosor válido."
            return
        }
        
        guard !selectedMaterial.isEmpty && availableMaterials.contains(selectedMaterial) else {
            resultMessage = "Por favor seleccione un material válido."
            return
        }
        
        isCalculating = true
        resultMessage = nil
        cutResult = nil
        perfResult = nil
        
        // Add timeout protection
        let timeoutTask = DispatchWorkItem {
            if isCalculating {
                resultMessage = "Tiempo de espera agotado. Por favor intente nuevamente."
                isCalculating = false
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 10.0, execute: timeoutTask)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            timeoutTask.cancel() // Cancel timeout if calculation completes
            
            // Get the English material name for searching in CSV
            let englishMaterial = materialMapping[selectedMaterial] ?? selectedMaterial
            print("Searching for material: '\(englishMaterial)' with thickness: \(thickness)")
            
            // Find only cutting parameters (hide perforation parameters)
            if let cut = laserRepository.findCutParams(for: englishMaterial, thickness: thickness) {
                print("Found cut parameters: \(cut.id)")
                cutResult = cut
            } else {
                print("No cut parameters found for \(englishMaterial) \(thickness)mm")
            }
            
            // Don't search for perforation parameters - only show cutting results
            perfResult = nil
            
            if cutResult == nil {
                resultMessage = "No hay entrada en la tabla para este material/grosor. Por favor contacte a Industrial Metal Systems."
            }
            
            isCalculating = false
        }
    }
}

struct ResultCard: View {
    let title: String
    let data: Any
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
            
            Divider()
            
            if let cutParam = data as? LaserCutParam {
                VStack(alignment: .leading, spacing: 4) {
                    // Modelo Recomendado
                    HStack {
                        Text("Modelo Recomendado")
                        Spacer()
                        Text(niceModel(cutParam.id))
                    }
                    
                    // Show all parameters from otherParams with simple translation (excluding Serie)
                    ForEach(Array(cutParam.otherParams.keys.sorted()), id: \.self) { key in
                        if let value = cutParam.otherParams[key], key != "series" {
                            HStack {
                                Text(translateParameter(key))
                                Spacer()
                                Text(value)
                            }
                        }
                    }
                    
                    // Show main parameters
                    if let power = cutParam.power {
                        HStack {
                            Text("Potencia (W)")
                            Spacer()
                            Text("\(Int(power))")
                        }
                    }
                    
                    if let speed = cutParam.speed {
                        HStack {
                            Text("Velocidad (m/min)")
                            Spacer()
                            Text(String(format: "%.1f", speed))
                        }
                    }
                    
                    if let gas = cutParam.gas {
                        HStack {
                            Text("Gas")
                            Spacer()
                            Text(gas)
                        }
                    }
                    
                    if let collimation = cutParam.collimation {
                        HStack {
                            Text("Colimación (mm)")
                            Spacer()
                            Text("\(Int(collimation))")
                        }
                    }
                    
                    HStack {
                        Text("Grosor (mm)")
                        Spacer()
                        Text(String(format: "%.1f", cutParam.thickness))
                    }
                }
            } else if let perfParam = data as? LaserPerfParam {
                VStack(alignment: .leading, spacing: 4) {
                    // Modelo Recomendado
                    HStack {
                        Text("Modelo Recomendado")
                        Spacer()
                        Text(niceModel(perfParam.id))
                    }
                    
                    // Show all parameters from otherParams with simple translation (excluding Serie)
                    ForEach(Array(perfParam.otherParams.keys.sorted()), id: \.self) { key in
                        if let value = perfParam.otherParams[key], key != "series" {
                            HStack {
                                Text(translateParameter(key))
                                Spacer()
                                Text(value)
                            }
                        }
                    }
                    
                    // Show main parameters
                    if let power = perfParam.power {
                        HStack {
                            Text("Potencia (W)")
                            Spacer()
                            Text("\(Int(power))")
                        }
                    }
                    
                    if let speed = perfParam.speed {
                        HStack {
                            Text("Velocidad (m/min)")
                            Spacer()
                            Text(String(format: "%.1f", speed))
                        }
                    }
                    
                    if let gas = perfParam.gas {
                        HStack {
                            Text("Gas")
                            Spacer()
                            Text(gas)
                        }
                    }
                    
                    HStack {
                        Text("Grosor (mm)")
                        Spacer()
                        Text(String(format: "%.1f", perfParam.thickness))
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(.systemGray6))
        )
    }
    
    private func niceModel(_ id: String) -> String {
        // Format the model ID nicely like Android
        if id.contains("MFSC-1500X") {
            return "MFSC-1500X"
        } else if id.contains("MFSC-1000X") {
            return "MFSC-1000X"
        }
        return id
    }
    
    private func prettyValue(_ value: String) -> String {
        // Format values nicely like Android
        if let doubleValue = Double(value) {
            if doubleValue == floor(doubleValue) {
                return "\(Int(doubleValue))"
            } else {
                return String(format: "%.1f", doubleValue)
            }
        }
        return value
    }
    
    // Simple parameter translation function to avoid freezing
    private func translateParameter(_ key: String) -> String {
        switch key {
        case "series": return "Serie"
        case "fiber_core_um": return "Núcleo de fibra (μm)"
        case "collimation_mm": return "Colimación (mm)"
        case "focus_lens_mm": return "Lente de enfoque (mm)"
        case "pressure_bar": return "Presión (bar)"
        case "nozzle_diameter_mm": return "Diámetro de boquilla (mm)"
        case "nozzle_type": return "Tipo de boquilla"
        case "focus_offset_mm": return "Desplazamiento de enfoque (mm)"
        case "cutting_height_mm": return "Altura de corte (mm)"
        case "stage": return "Etapa"
        case "duty_percent": return "Ciclo de trabajo (%)"
        case "frequency_hz": return "Frecuencia (Hz)"
        case "nozzle_height_mm": return "Altura de boquilla (mm)"
        case "air_pressure_bar": return "Presión de aire (bar)"
        case "perforation_time_ms": return "Tiempo de perforación (ms)"
        case "stop_blow_ms": return "Tiempo de parada de soplado (ms)"
        default: return key
        }
    }
}


#Preview {
    NavigationView {
        LaserCalculatorView()
            .environmentObject(LaserDataRepository())
    }
}
