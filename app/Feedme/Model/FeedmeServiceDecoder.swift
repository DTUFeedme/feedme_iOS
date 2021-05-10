//
//  FeedmeNetworkServiceDecoder.swift
//  Feedme
//
//  Created by Christian Hjelmslund on 13/05/2019.
//  Copyright © 2019 Christian Hjelmslund. All rights reserved.
//

import Foundation

class FeedmeNetworkServiceDecoder {
 
    func decodeFetchAnsweredQuestion(data: Data?) -> [AnsweredQuestion] {
        
        guard let data = data else { return [] }
        
        do {
            let answeredQuestions = try JSONDecoder().decode([AnsweredQuestion].self, from: data)
            return answeredQuestions
        } catch let jsonErr {
            print("Error serializing json decodeFetchAnsweredQuestions:", jsonErr)
            return []
        }
    }

    func decodeFetchQuestions(data: Data?) -> [Question] {
        guard let data = data else { return [] }
        
        do {
            let questions = try JSONDecoder().decode([Question].self, from: data)
            return questions
        } catch let jsonErr {
            print("Error serializing json decodeFetchQuestions:", jsonErr)
            return []
        }
    }
    
    func decodeFetchBeacons(data: Data?) -> [Beacon] {
        guard let data = data else { return [] }
        
        do {
            let beacons = try JSONDecoder().decode([Beacon].self, from: data)
            return beacons
        } catch let jsonErr {
            print("Error serializing json decodeFetchBeacons:", jsonErr)
            return []
        }
    }
    
    func decodeFetchBuildings(data: Data?) -> [Building] {
        guard let data = data else { return [] }
        do {
            let buildings = try JSONDecoder().decode([Building].self, from: data)
            return buildings
        } catch let jsonErr {
            print("Error serializing json decodeFetchBuildings:", jsonErr)
            return []
        }
    }
    
    func decodeToken(data: Data?) -> String? {
        
        guard let data = data else { return nil }
        do {
            let token = try JSONDecoder().decode(Token.self, from: data)
            return token.token
        } catch let jsonErr {
            print("Error serializing json decodeToken:", jsonErr)
            return nil
        }
    }
    
    func decodeRefreshToken(data: Data?) -> String? {
        guard let data = data else { return nil }
        do {
            let refreshToken = try JSONDecoder().decode(RefreshToken.self, from: data)
            return refreshToken.refreshToken
        } catch let jsonErr {
            print("Error serializing json decodeToken:", jsonErr)
            return nil
        }
    }
    
    func decodeFetchFeedback(data: Data?) -> [AnsweredFeedback] {
        guard let data = data else { return [] }
        do {
            let feedback = try JSONDecoder().decode([AnsweredFeedback].self, from: data)
            return feedback
        } catch let jsonErr {
            print("Error serializing json decodeFetchFeedback:", jsonErr)
            return []
        }
    }
    
    func decodePostRoom(data: Data?) -> String? {
        guard let data = data else { return nil }
        do {
            let room = try JSONDecoder().decode(Room.self, from: data)
            return room._id
        } catch let jsonErr {
            print("Error serializing json decodePostRoom:", jsonErr)
            return nil
        }
    }
    
    func decodePostSignalMap(data: Data?) -> SignalmapWithRoom? {
        guard let data = data else { return nil }
        do {
            let signalMap = try JSONDecoder().decode(SignalmapWithRoom.self, from: data)
            return signalMap
        } catch let jsonErr {
            print("Error serializing json decodePostSignalMap:", jsonErr)
            return nil
        }
    }
}
