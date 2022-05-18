//
//  LocationManager.swift
//  Message
//
//  Created by Yoo on 2022/05/15.
//

import Foundation
import CoreLocation

class LocationManager: NSObject, CLLocationManagerDelegate {
    
    static let shared = LocationManager()
    
    var locationManager: CLLocationManager?
    var currentLocation: CLLocationCoordinate2D?
    
    private override init() {
        super.init()
        
        requestLocationAccess()
    }
    
    func requestLocationAccess() {
        if locationManager == nil {
            locationManager = CLLocationManager()
            locationManager!.delegate = self
            locationManager!.desiredAccuracy = kCLLocationAccuracyBest
            locationManager!.requestWhenInUseAuthorization()
        } else {
            print("We have aleady location manager")
        }
    }
    
    func startUpdating() {
        guard let locationManager = locationManager else { return }
        locationManager.startUpdatingLocation()
    }
    
    func stopUpdating() {
        guard let locationManager = locationManager else { return }
        locationManager.stopUpdatingLocation()
    }
    
    // MARK: - Delegate function
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = locations.last!.coordinate
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("failed to get location", error.localizedDescription)
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if manager.authorizationStatus == .notDetermined {
            locationManager?.requestWhenInUseAuthorization()
        }
    }
}
