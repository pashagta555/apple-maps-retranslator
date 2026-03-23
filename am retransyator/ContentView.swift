//
//  ContentView.swift
//  am retransyator
//
//  Created by pav on 6/29/25.
//

import SwiftUI
import MapKit

struct ContentView: View {
    @ObservedObject var appState: AppState
    @State private var yandexLink: String = ""
    @State private var coordinate: CLLocationCoordinate2D?
    @State private var showAlert = false

    var appleMapsURL: URL? {
        guard let coordinate = coordinate else { return nil }
        return URL(string: "http://maps.apple.com/?ll=\(coordinate.latitude),\(coordinate.longitude)")
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                TextField("Paste yandexmaps:// link", text: $yandexLink)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                Button("Parse & Show Location") {
                    if let coord = extractCoordinates(from: yandexLink) {
                        coordinate = coord
                    } else {
                        showAlert = true
                    }
                }
                .alert(isPresented: $showAlert) {
                    Alert(title: Text("Invalid Link"), message: Text("Could not extract coordinates."), dismissButton: .default(Text("OK")))
                }

                if let coordinate = coordinate {
                    Map(coordinateRegion: .constant(MKCoordinateRegion(
                        center: coordinate,
                        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                    )))
                    .frame(height: 300)
                    .cornerRadius(12)
                    .padding()

                    if let url = appleMapsURL {
                        Button("Open in Apple Maps") {
                            UIApplication.shared.open(url)
                        }
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    }
                    // Add route suggestion button
                    Button("Build Route in Apple Maps") {
                        let routeURL = URL(string: "http://maps.apple.com/?daddr=\(coordinate.latitude),\(coordinate.longitude)&dirflg=d")!
                        UIApplication.shared.open(routeURL)
                    }
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }

                Spacer()
            }
            .navigationTitle("Yandex → Apple Maps")
        }
        .onChange(of: appState.incomingYandexURL) { newURL in
            guard let url = newURL else { return }
            yandexLink = url.absoluteString
            if let coord = extractCoordinates(from: yandexLink) {
                coordinate = coord
            } else {
                showAlert = true
            }
        }
    }

    func extractCoordinates(from link: String) -> CLLocationCoordinate2D? {
        // Example: yandexmaps://maps.yandex.ru/?ll=37.620070,55.753630
        guard let url = URLComponents(string: link) else { return nil }
        if let ll = url.queryItems?.first(where: { $0.name == "ll" })?.value {
            let parts = ll.split(separator: ",")
            if parts.count == 2,
               let lon = Double(parts[0]),
               let lat = Double(parts[1]) {
                return CLLocationCoordinate2D(latitude: lat, longitude: lon)
            }
        }
        // Try to parse from path if not in query
        // Example: yandexmaps://maps.yandex.ru/?pt=37.620070,55.753630
        if let pt = url.queryItems?.first(where: { $0.name == "pt" })?.value {
            let parts = pt.split(separator: ",")
            if parts.count == 2,
               let lon = Double(parts[0]),
               let lat = Double(parts[1]) {
                return CLLocationCoordinate2D(latitude: lat, longitude: lon)
            }
        }
        return nil
    }
}

#Preview {
    ContentView(appState: AppState())
}
