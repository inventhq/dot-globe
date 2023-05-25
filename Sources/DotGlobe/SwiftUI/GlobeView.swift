//
//  SwiftUIView.swift
//  
//
//  Created by Demirhan Mehmet Atabey on 25.05.2023.
//

import SwiftUI

@available(iOS 13.0, *)
private struct GlobeViewControllerRepresentable: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> GlobeViewController {
        let globeController = GlobeViewController(earthRadius: 0.5)

        return globeController
    }
    
    func updateUIViewController(_ uiViewController: GlobeViewController, context: Context) {
        // update later
    }
}

@available(iOS 13.0, *)
public struct GlobeView: View {
    public init() {
        
    }
    public var body: some View {
        GlobeViewControllerRepresentable()
    }
}
