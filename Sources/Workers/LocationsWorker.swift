//
//  LocationManager.swift
//  ZamzamKit
//
//  Created by Basem Emara on 3/6/17.
//  Copyright © 2017 Zamzam. All rights reserved.
//

import CoreLocation

public class LocationsWorker: NSObject, LocationsWorkerType, CLLocationManagerDelegate {

    /// Internal Core Location manager
    private lazy var manager = CLLocationManager().with {
        $0.desiredAccuracy ?= self.desiredAccuracy
        $0.distanceFilter ?= self.distanceFilter
    
        #if os(iOS)
        $0.activityType ?= self.activityType
        #endif
    
        $0.delegate = self
    }
    
    /// Default location manager options
    private let desiredAccuracy: CLLocationAccuracy?
    private let distanceFilter: Double?
    private let activityType: CLActivityType?
    
    public required init(
        desiredAccuracy: CLLocationAccuracy? = nil,
        distanceFilter: Double? = nil,
        activityType: CLActivityType? = nil) {
            // Assign values to location manager options
            self.desiredAccuracy = desiredAccuracy
            self.distanceFilter = distanceFilter
            self.activityType = activityType
        
            super.init()
    }
    
    /// Subscribes to receive new data when available
    private var didUpdateLocationsSingle = SynchronizedArray<LocationHandler>()
    private var didChangeAuthorizationSingle = SynchronizedArray<AuthorizationHandler>()
    private var didUpdateLocations = SynchronizedArray<Observer<LocationHandler>>()
    private var didChangeAuthorization = SynchronizedArray<Observer<AuthorizationHandler>>()
    
    #if os(iOS)
    private var didUpdateHeading = SynchronizedArray<Observer<HeadingHandler>>()
    #endif
    
    deinit {
        // Empty task queues of references
        didUpdateLocationsSingle.removeAll()
        didChangeAuthorizationSingle.removeAll()
        didUpdateLocations.removeAll()
        didChangeAuthorization.removeAll()
        
        #if os(iOS)
        didUpdateHeading.removeAll()
        #endif
    }
}

// MARK: - Location manager observers

public extension LocationsWorker {

    func addObserver(_ observer: Observer<LocationHandler>) {
        didUpdateLocations += observer
    }

    func removeObserver(_ observer: Observer<LocationHandler>) {
        didUpdateLocations -= observer
    }

    func addObserver(_ observer: Observer<AuthorizationHandler>) {
        didChangeAuthorization += observer
    }

    func removeObserver(_ observer: Observer<AuthorizationHandler>) {
        didChangeAuthorization -= observer
    }

    #if os(iOS)
    func addObserver(_ observer: Observer<HeadingHandler>) {
        didUpdateHeading += observer
    }
    
    func removeObserver(_ observer: Observer<HeadingHandler>) {
        didUpdateHeading -= observer
    }
    #endif
    
    func removeObservers(with prefix: String) {
        let prefix = prefix + "."
    
        didUpdateLocations.remove(where: { $0.id.hasPrefix(prefix) })
        didChangeAuthorization.remove(where: { $0.id.hasPrefix(prefix) })
        
        #if os(iOS)
        didUpdateHeading.remove(where: { $0.id.hasPrefix(prefix) })
        #endif
    }

}

// MARK: - CLLocationManagerDelegate functions

public extension LocationsWorker {

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        // Trigger and empty queues
        didUpdateLocations.forEach { $0.handler(location) }
        didUpdateLocationsSingle.removeAll { $0.forEach { $0(location) } }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        guard status != .notDetermined else { return }
        
        // Trigger and empty queues
        didChangeAuthorization.forEach { $0.handler(isAuthorized) }
        didChangeAuthorizationSingle.removeAll { $0.forEach { $0(self.isAuthorized) } }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // TODO: Injectable logger
        debugPrint(error)
    }
}

// MARK: - CLLocationManager wrappers

public extension LocationsWorker {
    
    var isAuthorized: Bool {
        return CLLocationManager.isAuthorized
    }
    
    func isAuthorized(for type: LocationAuthorizationType) -> Bool {
        guard CLLocationManager.locationServicesEnabled() else { return false }
        return (type == .whenInUse && CLLocationManager.authorizationStatus() == .authorizedWhenInUse)
            || (type == .always && CLLocationManager.authorizationStatus() == .authorizedAlways)
    }
    
    var location: CLLocation? {
        return manager.location
    }
    
    func startUpdatingLocation(enableBackground: Bool) {
        #if os(iOS)
        manager.allowsBackgroundLocationUpdates = enableBackground
        
        // From Apple docs: a pause to location updates ends access to location changes
        // until the app is launched again and able to restart those updates. If you do not
        // wish location updates to stop entirely, consider disabling this property.
        manager.pausesLocationUpdatesAutomatically = false
        #endif
        
        manager.startUpdatingLocation()
    }
    
    /// Stops the generation of location updates.
    func stopUpdatingLocation() {
        #if os(iOS)
        manager.allowsBackgroundLocationUpdates = false
        manager.pausesLocationUpdatesAutomatically = true
        #endif
        
        manager.stopUpdatingLocation()
    }
}

// MARK: - Single requests

public extension LocationsWorker {

    func requestAuthorization(for type: LocationAuthorizationType, startUpdatingLocation: Bool, completion: AuthorizationHandler?) {
        // Handle authorized and exit
        guard !isAuthorized(for: type) else {
            if startUpdatingLocation { self.startUpdatingLocation() }
            completion?(true)
            return
        }
        
        // Request appropiate authorization before exit
        defer {
            switch type {
            case .whenInUse: manager.requestWhenInUseAuthorization()
            case .always: manager.requestAlwaysAuthorization()
            }
        }
        
        // Handle mismatched allowed and exit
        guard !isAuthorized else {
            if startUpdatingLocation { self.startUpdatingLocation() }
            
            // Process callback in case authorization dialog not launched by OS
            // since user will be notified first time only and ignored subsequently
            completion?(false)
            return
        }
        
        if startUpdatingLocation {
            didChangeAuthorizationSingle += { _ in self.startUpdatingLocation() }
        }
        
        // Handle denied and exit
        guard CLLocationManager.authorizationStatus() == .notDetermined else {
            completion?(false)
            return
        }
        
        if let completion = completion {
            didChangeAuthorizationSingle += completion
        }
    }
    
    func requestLocation(completion: @escaping LocationHandler) {
        didUpdateLocationsSingle += completion
        manager.requestLocation()
    }
}

#if os(iOS)
public extension LocationsWorker {
    
    /// A Boolean value indicating whether the app wants to receive location updates when suspended.
    var allowsBackgroundLocationUpdates: Bool {
        get { return manager.allowsBackgroundLocationUpdates }
        set { manager.allowsBackgroundLocationUpdates = newValue }
    }
    
    var heading: CLHeading? {
        return manager.heading
    }
    
    func startMonitoringSignificantLocationChanges() {
        manager.allowsBackgroundLocationUpdates = true
        manager.pausesLocationUpdatesAutomatically = true
        manager.startMonitoringSignificantLocationChanges()
    }
    
    func stopMonitoringSignificantLocationChanges() {
        manager.allowsBackgroundLocationUpdates = false
        manager.stopMonitoringSignificantLocationChanges()
    }
    
    func startUpdatingHeading() {
        manager.startUpdatingHeading()
    }
    
    func stopUpdatingHeading() {
        manager.stopUpdatingHeading()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        didUpdateHeading.forEach { $0.handler(newHeading) }
    }
}
#endif
