//
//  Project.swift
//  Civilbudget
//
//  Created by Max Odnovolyk on 10/3/15.
//  Copyright © 2015 Build Apps. All rights reserved.
//

import Bond
import Alamofire

struct Project {
    let id: Int
    let title: String
    let description: String
    let shortDescription: String
    let source: String?
    let picture: String?
    let createdAt: String?
    let likes: Int?
    let owner: String?
}

extension Project {
    typealias ProjectResponse = Response<[Project], NSError>
    
    static let allProjects: ObservableArray<Project> = {
        return ObservableArray([])
        }()
    
    static func reloadAllProjects(completionHandler: (ProjectResponse -> Void)? = nil) {
        Alamofire.request(CivilbudgetAPI.Router.GetProjects)
            .responseCollection { (response: ProjectResponse) in
                switch response.result {
                case .Success(let projects):
                    allProjects.array = projects
                case .Failure(let error):
                    log.error(error.localizedDescription)
                }
                completionHandler?(response)
        }
    }
}

extension Project: ResponseObjectSerializable, ResponseCollectionSerializable {
    struct Constants {
        static let maxShortDescriptionLength = 100
    }
    
    init(response: NSHTTPURLResponse, var representation: AnyObject) throws {
        if let projectDictionary = representation.valueForKey("project") as? NSDictionary
            where representation.count == 1 {
            representation = projectDictionary
        }
        
        guard let id = representation.valueForKeyPath("id") as? Int,
            title = representation.valueForKeyPath("title") as? String,
            description = representation.valueForKeyPath("description") as? String
            else {
                let failureReason = "Can't create project without one of mandatory fields: id, title, description"
                throw Error.errorWithCode(.JSONSerializationFailed, failureReason: failureReason)
        }
        
        self.id = id
        self.title = title
        self.description = description
        self.shortDescription = description.substringToIndex(description.startIndex.advancedBy(Constants.maxShortDescriptionLength))
        
        self.source = representation.valueForKeyPath("source") as? String
        self.picture = representation.valueForKeyPath("picture") as? String
        self.createdAt = representation.valueForKeyPath("createdAt") as? String
        self.likes = representation.valueForKeyPath("likes") as? Int
        self.owner = representation.valueForKeyPath("owner") as? String
    }
    
    static func collection(response response: NSHTTPURLResponse, representation: AnyObject) throws -> [Project] {
        guard let representation = representation.valueForKeyPath("projects") as? [[String: AnyObject]] else {
            let failureReason = "Can't cast root JSON collection to Project list"
            throw Error.errorWithCode(.JSONSerializationFailed, failureReason: failureReason)
        }
        
        return representation.flatMap { try! Project(response: response, representation: $0) }
    }
}