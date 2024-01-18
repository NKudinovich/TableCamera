//
//  NetworkService.swift
//  TableCamera
//
//  Created by Nikita Kudinovich on 14.01.24.
//

import UIKit

final class NetworkService {
    
    private let host = "https://junior.balinasoft.com"
    private let myFIO = "Kudinovich Nikita Andreevich"
    
    func loadData(page: Int, completionHanlder: @escaping (ResponseModel?, Error?) -> Void) {
       //URL
        guard
            let url = URL(string: host + "/api/v2/photo/type?page=\(page)")
        else { return }
        
        //Request
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        //URLSession
        let session = URLSession.shared
        
        let task = session.dataTask(with: request) { responseData, response, error in
            if let error = error {
                print(error.localizedDescription)
            } else if let responseData = responseData {
                let data = try? JSONDecoder().decode(ResponseModel.self, 
                                                     from: responseData)
                completionHanlder(data, nil)
            }
        }
        task.resume()
    }
    
    func uploadData(id: Int, image: UIImage, completion: @escaping () -> Void) {
        //URL
        guard
            let url = URL(string: host + "/api/v2/photo")
        else { return }
        
        //Request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        //Create boundary
        let boundary = generateBoundaryString()
        request.setValue("multipart/form-data; boundary=\(boundary)",
                         forHTTPHeaderField: "Content-Type")
        
        //Create request body
        let body = NSMutableData()
        
        //FIO
        body.appendString(string: "--\(boundary)\r\n")
        body.appendString(string: "Content-Disposition: form-data; name=\"name\"\r\n\r\n")
        body.appendString(string: "\(myFIO)\r\n")
        
        //Selected ID
        body.appendString(string: "--\(boundary)\r\n")
        body.appendString(string: "Content-Disposition: form-data; name=\"typeId\"\r\n\r\n")
        body.appendString(string: "\(id)\r\n")
        
        //Image
        body.appendString(string: "--\(boundary)\r\n")
        body.appendString(string: "Content-Disposition: form-data; name=\"photo\"; filename=\"image.jpg\"\r\n")
        body.appendString(string: "Content-Type: image/png\r\n\r\n")
        
        if let imageData = image.pngData() {
            body.append(imageData)
        }
        
        body.appendString(string: "\r\n")
        
        //Body end
        body.appendString(string: "--\(boundary)--\r\n")
        
        request.httpBody = body as Data
        
        //URLSession
        let session = URLSession.shared
        
        let task = session.dataTask(with: request) { responseData, response, error in
            if let error = error {
                print(error.localizedDescription)
            } else if let responseData = responseData {
                let responseString = String(data: responseData, encoding: .utf8)
                completion()
                print("Response: \(responseString ?? "*Error*")")
            }
        }
        task.resume()
    }
    
    func generateBoundaryString() -> String {
        return "Boundary-\(UUID().uuidString)"
    }
    
}

extension NSMutableData {
    func appendString(string: String) {
        if let data = string.data(using: String.Encoding.utf8,
                                  allowLossyConversion: true) {
            append(data)
        }
    }
}


