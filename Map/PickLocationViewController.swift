//
//  PickLocationViewController.swift
//  student
//
//  Created by Hien Ho on 12/16/19.
//

import UIKit
import MapKit
import CoreLocation

protocol PickLocationViewControllerDelegate: class {
    func didPickLocation(placeMark: CLPlacemark?, address: String?)
}

class PickLocationViewController: BaseViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var addressLabel: UILabel!
    
    @IBOutlet weak var addressContainerView: UIView!
    
    fileprivate let locationManager = CLLocationManager()
    fileprivate let regionInMeters: Double = 2000
    fileprivate var previousLocation: CLLocation?
    
    weak var delegate: PickLocationViewControllerDelegate?
    
    fileprivate var firstTimeReceiveUserLocation = true
    
    fileprivate var placeMark: CLPlacemark? {
        didSet {
            guard let placeMark = placeMark else {
                address = nil
                addressLabel.text = ""
                return
            }
            if (addressContainerView.isHidden){
                addressContainerView.isHidden = false
            }
            updateAddress(placeMark: placeMark)
        }
    }
    
    fileprivate var address: String?
    
    var initLocation: CLLocationCoordinate2D?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkLocationServices()
        setupStartLocationIfNeeded()
        
    }
    
    override func setupView() {
        isHideLargeTitle = true
        createNaviRightButton(withTitle: "Save")
        super.setupView()
    }
    
    override func didTapNaviRightButton(sender: AnyObject) {
        print("Save press")
        delegate?.didPickLocation(placeMark: placeMark, address: address)
        self.navigationController?.popViewController(animated: true)
    }
    
    fileprivate func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    
    fileprivate func centerViewOnUserLocation() {
        if let location = locationManager.location?.coordinate {
            // get Place Mark for first time we receive user location (if no init location)
            if (firstTimeReceiveUserLocation && initLocation == nil) {
                centerALocation(location)
                getNewPlaceMark(location: getCenterLocation(for: mapView))
            }
            firstTimeReceiveUserLocation = false
        }
    }
    
    fileprivate func centerALocation(_ coordinate: CLLocationCoordinate2D) {
        let region = MKCoordinateRegion.init(center: coordinate, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
        mapView.setRegion(region, animated: true)
    }
    
    fileprivate func checkLocationServices() {
        if CLLocationManager.locationServicesEnabled() {
            setupLocationManager()
            checkLocationAuthorization()
        } else {
            // Show alert letting the user know they have to turn this on.
        }
    }
    
    fileprivate func setupStartLocationIfNeeded() {
        guard let location = initLocation else {
            return
        }
        previousLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
        getNewPlaceMark(location:previousLocation!)
        centerALocation(location)
    }
    
    fileprivate func checkLocationAuthorization() {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse:
            startTackingUserLocation()
        case .denied:
            // Show alert instructing them how to turn on permissions
            break
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            // Show an alert letting them know what's up
            break
        case .authorizedAlways:
            break
        default:
            break
        }
    }
    
    fileprivate func startTackingUserLocation() {
        mapView.showsUserLocation = true
        centerViewOnUserLocation()
        locationManager.startUpdatingLocation()
        previousLocation = getCenterLocation(for: mapView)
    }
    
    fileprivate func getCenterLocation(for mapView: MKMapView) -> CLLocation {
        let latitude = mapView.centerCoordinate.latitude
        let longitude = mapView.centerCoordinate.longitude
        
        return CLLocation(latitude: latitude, longitude: longitude)
    }
    
    // MARK: Update Address by CLPlacemark
    fileprivate func updateAddress(placeMark: CLPlacemark) {
        var address = ""
        
        let streetNumber = placeMark.subThoroughfare
        let streetName   = placeMark.thoroughfare
        let province     = placeMark.subLocality
        let city         = placeMark.administrativeArea
        
        var listInfor: [String] = []
        
        if let streetNumber = streetNumber {
            listInfor.append(streetNumber)
        }
        
        if let streetName = streetName {
            listInfor.append(streetName)
        }
        
        if let province = province {
            listInfor.append(province)
        }
        
        if let city = city {
            listInfor.append(city)
        }
        
        address = listInfor.joined(separator: ", ")
        
        addressLabel.text = address
        self.address = address
    }
    
    func searchAddress(address: String) {
        //Create the search request
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = address
        
        let activeSearch = MKLocalSearch(request: searchRequest)
        
        activeSearch.start { [weak self] (response, error) in
            guard let self = self else { return }
            guard let location = response?.boundingRegion.center , error == nil else {
                return
            }
            // Remove annotations
            let annotations = self.mapView.annotations
            self.mapView.removeAnnotations(annotations)
            self.centerALocation(location)
        }
    }
    
    func markALocation(title: String, location: CLLocationCoordinate2D) {
        // Create annotation
        let annotation = MKPointAnnotation()
        annotation.title = title
        annotation.coordinate = location
        self.mapView.addAnnotation(annotation)
    }
}

// MARK: LocationManager Delegate
extension PickLocationViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAuthorization()
    }
}

// MARK: MKMapView Delegate
extension PickLocationViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let center = getCenterLocation(for: mapView)
        guard let previousLocation = self.previousLocation else { return }
        guard center.distance(from: previousLocation) > 50 else { return }
        self.previousLocation = center
        getNewPlaceMark(location: center)
    }
    
    fileprivate func getNewPlaceMark(location: CLLocation ) {
        let geoCoder = CLGeocoder()
        geoCoder.reverseGeocodeLocation(location) { [weak self] (placemarks, error) in
            guard let self = self else { return }
            if let _ = error {
                self.placeMark = nil
                self.addressContainerView.isHidden = true
                return
            }
            guard let placemark = placemarks?.first else {
                self.placeMark = nil
                self.addressContainerView.isHidden = true
                return
            }
            self.placeMark = placemark
        }
    }
}

// MARK: Delegate
extension PickLocationViewController {
    func didPickLocation(placeMark: CLPlacemark?, address: String?) {}
}
