//
//  ObjectAPI.swift
//  HarvardArtMuseums
//
//  Created by Jonathan Holland on 3/9/24.
//

import Foundation
import ComposableArchitecturePattern

struct ObjectAPI: ServerAPI {
	init(environment: ServerEnvironment?, path: String, headers: [String: String]?, queries: [URLQueryItem]?, supportedHTTPMethods: [HTTPMethod], supportedReturnObjects: [Codable.Type]?, timeoutInterval: TimeInterval) {
		self.environment = environment
		self.path = path
		self.headers = headers
		self.queries = queries
		self.supportedHTTPMethods = supportedHTTPMethods
		self.supportedReturnObjects = supportedReturnObjects
		self.timeoutInterval = timeoutInterval
	}
	
	static func == (lhs: ObjectAPI, rhs: ObjectAPI) -> Bool {
		return lhs.id == rhs.id
	}
	
	let id = UUID()
	
	var environment: ComposableArchitecturePattern.ServerEnvironment?
	
	var headers: [String : String]?
	
	var body: Data?
	
	var path: String
	
	var queries: [URLQueryItem]?
	
	var supportedHTTPMethods: [HTTPMethod]
	
	var supportedReturnObjects: [Codable.Type]?
	
	var timeoutInterval: TimeInterval = 100
	
	func supports<T>(_ object: T.Type) -> Bool where T: Codable {
		T.self == ObjectAPIResponse.self
	}
}
