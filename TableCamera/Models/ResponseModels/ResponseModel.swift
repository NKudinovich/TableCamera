//
//  ResponceModel.swift
//  TableCamera
//
//  Created by Nikita Kudinovich on 14.01.24.
//

import Foundation

struct ResponseModel: Decodable {
    let page, pageSize, totalPages, totalElements: Int
    let content: [Content]
}

struct Content: Decodable {
    let id: Int
    let name: String
    let image: String?
}
