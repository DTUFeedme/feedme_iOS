//
//  NetworkService.swift
//  Climify
//
//  Created by Christian Hjelmslund on 07/03/2019.
//  Copyright © 2019 Christian Hjelmslund. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire

class NetworkService: NSObject {

    let fetchQuestionsUrl = "http://localhost:3000/api/questions"
    let initUserUrl = "http://localhost:3000/api/users"
    let feedbackUrl = "http://localhost:3000/api/feedback"
    
    var questions: [Question] = []
 
    
    func getQuestions(completionHandler: @escaping (_ questions: [Question]) -> Void) {
        
        
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
                        if let questionName = element.1["name"].string, let id = element.1["_id"].string {
                            let question = Question(questionID: id, question: questionName)
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

        AF.request(initUserUrl, method: .post).responseJSON{ response in

            switch response.result {
            case .success(let value) :
               if let id = JSON(value)["_id"].string {
               print(id)
               UserDefaults.standard.set(id, forKey: "userID")
               }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func postFeedback(feedback: Feedback){
    
            var json: [String : Any] = [:]
            json["roomId"] = feedback.roomID
            json["userId"] = feedback.userID

            var questions: [[String: String]] = []

            for elements in feedback.answers {
                var dict: [String: String] = [:]

                dict["_id"] = elements.questionID
                dict["answer"] = elements.answer
                questions.append(dict)
            }
            json["questions"] = questions
            
            AF.request(feedbackUrl, method: .post, parameters: json, encoding: JSONEncoding.default)
                .responseString { response in
                    print(response)
            }
    }
}
