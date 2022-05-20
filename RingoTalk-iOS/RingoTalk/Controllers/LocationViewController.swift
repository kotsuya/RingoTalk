//
//  LocationViewController.swift
//  RingoTalk
//
//  Created by Yoo on 2022/05/11.
//

import UIKit
import CoreLocation
import MapKit

enum LocationViewType {
    case viewer
    case editer
}

class LocationViewController: UIViewController {

    public var completion: ((CLLocationCoordinate2D) -> Void)?
    private var coordinates: CLLocationCoordinate2D?
    private var viewType: LocationViewType = .viewer
    private let map: MKMapView = {
        let map = MKMapView()
        return map
    }()
        
    init(coordinates: CLLocationCoordinate2D?, viewType: LocationViewType) {
        self.coordinates = coordinates
        self.viewType = viewType
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        map.frame = view.bounds
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        tabBarController?.tabBar.isHidden = false
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        view.addSubview(map)
        
        if let coordinates = self.coordinates {
            let pin = MKPointAnnotation()
            pin.coordinate = coordinates
            map.addAnnotation(pin)
            
            let latitudinalMeters: CLLocationDistance = 100
            let longitudinalMeters: CLLocationDistance = 100
            let region = MKCoordinateRegion(center: coordinates,
                                            latitudinalMeters: latitudinalMeters,
                                            longitudinalMeters: longitudinalMeters)
            map.setRegion(region, animated: false)
        }
        
        switch viewType {
        case .editer:
            let sendButton = UIBarButtonItem(title: "Send".localized,
                                             style: .done,
                                             target: self,
                                             action: #selector(tappedSendButton))
            navigationItem.rightBarButtonItem = sendButton
            
            map.isUserInteractionEnabled = true
            let gesture = UITapGestureRecognizer(target: self,
                                                 action: #selector(tappedMap))
            gesture.numberOfTapsRequired = 1
            gesture.numberOfTouchesRequired = 1
            map.addGestureRecognizer(gesture)
        case .viewer:
            break
        }
    }
    
    @objc private func tappedMap(_ gesture: UITapGestureRecognizer) {
        let locationInView = gesture.location(in: map)
        let coordinates = map.convert(locationInView, toCoordinateFrom: map)
        self.coordinates = coordinates
        
        for annotation in map.annotations {
            map.removeAnnotation(annotation)
        }
        
        // drop a pin on that location
        let pin = MKPointAnnotation()
        pin.coordinate = coordinates
        map.addAnnotation(pin)
    }
    
    @objc private func tappedSendButton() {
        guard let coordinates = coordinates else { return }
        navigationController?.popViewController(animated: true)
        completion?(coordinates)
    }
}
