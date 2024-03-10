//
//  ObjectAPIResponseObjects.swift
//  HarvardArtMuseums
//
//  Created by Jonathan Holland on 3/9/24.
//

import Foundation

// MARK: - ObjectAPIResponse
struct ObjectAPIResponse: Codable {
	let info: RecordsResponseInfo
	let records: [ObjectRecord]
}

// MARK: - Info
struct RecordsResponseInfo: Codable {
	let totalrecordsperquery, totalrecords, pages, page: Int
	let next: String
	let responsetime: String
}

// MARK: - Record
struct ObjectRecord: Codable, Hashable, Identifiable {
	let id: Int
	
	let accessionyear: Int?
	let century: String?
	let classification: String?
	let colors: [ObjectColor]?
	let contextualtextcount: Int?
	let copyright: String?
	let creditline: String?
	let culture: String?
	let dated: String?
	let dateoflastpageview: String?
	let dateoffirstpageview: String?
	let description: String?
	let groupcount: Int?
	let imagecount: Int?
	let images: [ObjectImage]?
	let lastupdate: String?
	let medium: String?
	let mediacount: Int?
	let people: [Person]?
	let period: String?
	let primaryimageurl: String?
	let provenance: String?
	let publicationcount: Int?
	let objectnumber: String?
	let rank: Int?
	let technique: String?
	let title: String
	let totalpageviews: Int?
	let url: String
}

// MARK: - Person
struct Person: Codable, Hashable {
	let birthplace: String?
	let name: String
	let personPrefix: String?
	let personid: Int
	let role: String
	let displayorder: Int
	let culture, displaydate, deathplace: String?
	let displayname: String
	
	enum CodingKeys: String, CodingKey {
		case birthplace, name
		case personPrefix = "prefix"
		case personid, role, displayorder, culture, displaydate, deathplace, displayname
	}
}

struct ObjectImage: Codable, Hashable {
	let date: String?
	let copyright: String?
	let imageid: Int?
	let idsid: Int?
	let format: String?
	let description: String?
	let technique: String?
	let renditionnumber: String?
	let displayorder: Int
	let baseimageurl: String
	let alttext: String?
	let width: Int
	let publiccaption: String?
	let iiifbaseuri: String?
	let height: Int
}

struct ObjectColor: Codable, Hashable {
	let color: String
	let css3: String
	let hue: String
	let percent: Double
	let spectrum: String
}
