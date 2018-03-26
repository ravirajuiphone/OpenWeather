//
//  LocationManagerTest.swift
//  OpenweatherTests
//
//  Created by Raviraju Vysyaraju on 27/03/2018.
//  Copyright © 2018 Raviraju Vysyaraju. All rights reserved.
//

import XCTest
import CoreLocation
@testable import Openweather
class LocationManagerTest: XCTestCase, Error {
    let locationManagerObj = LocationManager.sharedInstance
    let mockCLLocationManager =  MockCLLocationManager()
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    func testInitLocationManager() {
        
        locationManagerObj.initLocationManager(locManager: mockCLLocationManager)
        XCTAssertEqual(mockCLLocationManager.delegate as! LocationManager, locationManagerObj)
        XCTAssertEqual(mockCLLocationManager.desiredAccuracy, kCLLocationAccuracyNearestTenMeters)
        XCTAssertTrue(mockCLLocationManager.isRequestWhenInUse)
        XCTAssertEqual(mockCLLocationManager.distanceFilter, 500)
        XCTAssertTrue(mockCLLocationManager.isStartUpdatingLocation)
    }
    func testLocationManagedidChangeAuthorization_restricted() {
        locationManagerObj.locationManager(mockCLLocationManager, didChangeAuthorization: .restricted)
        XCTAssertEqual(locationManagerObj.locationStatus, "Restricted Access to location")

    }
    
    func testLocationManagedidChangeAuthorization_denied() {
        locationManagerObj.locationManager(mockCLLocationManager, didChangeAuthorization: .denied)
        XCTAssertEqual(locationManagerObj.locationStatus, "User denied access to location")
    }
    
    func testLocationManagedidChangeAuthorization_notDetermined() {
        locationManagerObj.locationManager(mockCLLocationManager, didChangeAuthorization: .notDetermined)
        XCTAssertEqual(locationManagerObj.locationStatus, "Status not determined")
    }
    
    func testLocationManagedidChangeAuthorization_authorizedWhenInUse() {
        locationManagerObj.locationManager(mockCLLocationManager, didChangeAuthorization: .authorizedWhenInUse)
        XCTAssertEqual(locationManagerObj.locationStatus, "Allowed to location Access")
    }
    
    func testLocationManagedidFailWithError() {
        locationManagerObj.locationManager(mockCLLocationManager, didFailWithError: self)
        XCTAssertTrue(mockCLLocationManager.isStopUpdatingLocation)
        
    }

    class MockCLLocationManager: CLLocationManager {
        var isRequestWhenInUse = false
        override func requestWhenInUseAuthorization() {
            isRequestWhenInUse = true
        }
        var isStartUpdatingLocation = false
        override func startUpdatingLocation() {
            isStartUpdatingLocation = true
        }
        var isStopUpdatingLocation = false
        override func stopUpdatingLocation() {
            isStopUpdatingLocation = true
        }
    }
    
}
