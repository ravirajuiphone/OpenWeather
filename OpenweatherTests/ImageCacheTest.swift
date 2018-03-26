//
//  ImageCacheTest.swift
//  OpenweatherTests
//
//  Created by Raviraju Vysyaraju on 26/03/2018.
//  Copyright © 2018 Raviraju Vysyaraju. All rights reserved.
//

import XCTest

@testable import Openweather
class ImageCacheTest: XCTestCase {
    var imageCache: ImageCache? = nil
    var session: MockSession? = nil
    var task: MockDataTask? = nil
    override func setUp() {
        super.setUp()
        self.session = MockSession()
        self.task = MockDataTask()
        
        self.imageCache = ImageCache(shared: session!, sessionTask: task!)
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        imageCache = nil
        session = nil
        task = nil
    }
    func testImageCacheUrl() {
        let imageCacheObj = ImageCache(shared: session!, sessionTask: task!)
        XCTAssertEqual(imageCacheObj.session, session)
        XCTAssertEqual(imageCacheObj.task, task)
        
    }
    func testRequestImage() {
        
        self.imageCache?.imageFor(uriString: "02n", completionHandler: { (image, error) in
            XCTAssertNotNil(image)
            XCTAssertNotNil(self.task)
        })
       
    }
    
    func testGetCacheData() {
        let image = self.imageCache?.getCacheData(url: "http://openweathermap.org/img/w/02n.png")
        XCTAssertNotNil(image)
    }
    
    typealias MockDataTaskCompletionHandler = (Data?, URLResponse?, NSError?) -> Void
    class MockDataTask: URLSessionDataTask {
        var completionHandler: MockDataTaskCompletionHandler?
        var data: Data?
        var urlResponse: URLResponse?
        var taskError: NSError?
        
        override func resume() {
            completionHandler?(data, urlResponse, taskError)
        }
    }
    
    class MockSession: URLSession {
        var data: Data?
        var urlResponse: URLResponse?
        var taskError: NSError?
        
        typealias Completion = (Data?, URLResponse?, Error?) -> Void
        override func dataTask(with request: URLRequest,
                               completionHandler: @escaping Completion) -> URLSessionDataTask {
            let task = MockDataTask()
            task.completionHandler = completionHandler
            task.data = data
            task.urlResponse = urlResponse
            task.taskError = taskError
            return task
        }
    }
}
