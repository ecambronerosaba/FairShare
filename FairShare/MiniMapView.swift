//
//  MiniMapView.swift
//  FairShare
//
//  Created by Esteban Cambronero on 5/22/23.
//

import SwiftUI
import MapKit

struct MapView: UIViewRepresentable {
    let location: String

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        let button = UIButton(type: .infoLight)
        button.addTarget(context.coordinator, action: #selector(Coordinator.openMaps), for: .touchUpInside)
        mapView.addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button.trailingAnchor.constraint(equalTo: mapView.trailingAnchor, constant: -10),
            button.bottomAnchor.constraint(equalTo: mapView.bottomAnchor, constant: -10)
        ])
        return mapView
    }

    func updateUIView(_ view: MKMapView, context: Context) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(location) { placemarks, error in
            if let placemark = placemarks?.first, let location = placemark.location {
                let coordinateRegion = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
                view.setRegion(coordinateRegion, animated: true)
                
                // Add annotation to the map
                let annotation = MKPointAnnotation()
                annotation.coordinate = location.coordinate
                view.addAnnotation(annotation)
            }
        }
    }

    func openMaps() {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(location) { placemarks, error in
            if let placemark = placemarks?.first, let location = placemark.location {
                let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: location.coordinate))
                mapItem.name = self.location
                mapItem.openInMaps(launchOptions: nil)
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject {
        let parent: MapView

        init(_ parent: MapView) {
            self.parent = parent
            super.init()
        }

        @objc func openMaps() {
            parent.openMaps()
        }
    }
}


struct MiniMapView: View {
    let location:String
    var body: some View {
        MapView(location: location)
            .frame(width: 100, height: 100)
            .cornerRadius(10)
    }
}

struct MiniMapView_Previews: PreviewProvider {
    static var previews: some View {
        MiniMapView(location: "1 Infinite Loop, Cupertino, CA")
    }
}
