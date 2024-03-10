//
//  HarvardArtMuseumsApp.swift
//  HarvardArtMuseums
//
//  Created by Jonathan Holland on 3/7/24.
//

import SwiftUI
import SwiftData

@main
struct HarvardArtMuseumsApp: App {
	@Environment(\.scenePhase) var scenePhase
	
	var app: Application
	
	init() {
		let artworkDataSource = ArtworkList.DataSource()
		let app = Application(artworkListProvider: artworkDataSource)
		self.app = app
	}

    var body: some Scene {
        WindowGroup {
			self.app.view
				.onChange(of: self.scenePhase, self.app.reactToSceneChange(oldScene:newScene:))
        }
    }
}
