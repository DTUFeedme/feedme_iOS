//
//  NetworkService.swift
//  Climify
//
//  Created by Christian Hjelmslund on 07/03/2019.
//  Copyright © 2019 Christian Hjelmslund. All rights reserved.
//

import UIKit
import SwiftyJSON

class NetworkService: NSObject {

    let fetchQuestionsUrl = "http://localhost:3000/api/questions"
    let initUserUrl = "http://localhost:3000/api/users"
    
    var questions: [String] = []
    
    func getQuestions(completionHandler: @escaping (_ articles: [String]) -> Void) {
        if let url = URL(string: fetchQuestionsUrl){
            let urlRequest = URLRequest(url: url)
            
            let group = DispatchGroup()
            group.enter()
            
            URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
                if error != nil {
                    print(error as Any)
                    group.leave()
                    return
                }
                do {
                    let json = try JSON(data: data!)
                    
                    for element in json {
                        if let question = element.1["name"].string {
                            self.questions.append(question)
                        }
                    }
                } catch let error {
                    print(error)
                }
                group.leave()
                }.resume()
            group.notify(queue: .main) {
                completionHandler(self.questions)
            }
        }
    }
    
    func initUser(){
        if let url = URL(string: initUserUrl) {
            var urlRequest = URLRequest(url: url)
            urlRequest.httpMethod = "POST"
            
            URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
                if error != nil {
                    print(error as Any)
                    return
                }
                do {
                    let json = try JSON(data: data!)
                    print(json["_id"])
                    UserDefaults.standard.set(json["_id"].string, forKey: "userID")
                } catch let error {
                    print(error)
                }
            }.resume()
        }
    }
}
