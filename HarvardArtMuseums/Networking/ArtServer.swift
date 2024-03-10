//
//  ArtServer.swift
//  HarvardArtMuseums
//
//  Created by Jonathan Holland on 3/7/24.
//

import Foundation
import ComposableArchitecturePattern
import OSLog

actor ArtServer<API: ServerAPI>: Server {
	init(environments: [ServerEnvironment], currentEnvironment: ServerEnvironment?, additionalHTTPHeaders: [String : String]? = nil, supportedAPIs: [API] = [], logActivity: LogActivity = .all) {
		self.environments = environments
		self.currentEnvironment = currentEnvironment
		self.additionalHTTPHeaders = additionalHTTPHeaders
		self.apis = supportedAPIs
		self.logActivity = logActivity
	}
	
	var environments: [ServerEnvironment]
	
	var additionalHTTPHeaders: [String : String]?
	
	var blockAllAPIsNotSupported: Bool = true
	
	var requestsBeingProcessed = Set<UUID>()
	
	var currentEnvironment: ServerEnvironment?
	
	var apis: [API]
	
	var logActivity: LogActivity
	
	var logger: Logger {
		return Logger(subsystem: "ArtServer", category: "HarvardArtMuseums")
	}
	
	func fetchMuseumArt<T: Codable>() async throws -> T {
		guard let api = self.apis.first(where: { $0.supports(T.self) }) else {
			throw ServerAPIError.badRequest(description: "Unable to find supporting api", error: nil)
		}
		
		let response: T = try await self.get(api)
		return response
	}
}
