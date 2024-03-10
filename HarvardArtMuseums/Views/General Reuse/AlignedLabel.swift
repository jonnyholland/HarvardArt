//
//  AlignedLabel.swift
//  HarvardArtMuseums
//
//  Created by Jonathan Holland on 3/9/24.
//

import SwiftUI

struct AlignedLabel<Content: View>: View {
	let key: LocalizedStringKey
	let content: () -> Content
	
	init(_ key: LocalizedStringKey, content: @escaping () -> Content) {
		self.key = key
		self.content = content
	}
	
    var body: some View {
		VStack(alignment: .leading) {
			Text(self.key)
				.foregroundStyle(.secondary)
			self.content()
		}
    }
}

#Preview {
	AlignedLabel("Date") {
		Text(Date().description)
	}
}
