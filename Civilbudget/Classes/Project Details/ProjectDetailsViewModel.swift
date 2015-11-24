//
//  ProjectDetailsViewModel.swift
//  Civilbudget
//
//  Created by Max Odnovolyk on 11/21/15.
//  Copyright © 2015 Build Apps. All rights reserved.
//

import Foundation
import Bond

class ProjectDetailsViewModel: NSObject {
    static let dateFormatter: NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "dd-MM-YYYY"
        return formatter
    }()
    
    var project: Project! {
        didSet {
            updateFields()
        }
    }
    
    let pictureURL = Observable<NSURL?>(nil)
    let title = Observable<String>("")
    let fullDescription = Observable<String>("")
    let supportedBy = Observable<String>("")
    let createdAt = Observable<String>("")
    
    init(project: Project? = nil) {
        super.init()
        
        if let project = project {
            self.project = project
            updateFields()
        }
    }
    
    func updateFields() {
        pictureURL.value = NSURL(string: project.picture ?? "")
        title.value = project.title
        fullDescription.value = project.description
        supportedBy.value = "\(project.likes ?? 0)"
        if let createdDate = project.createdAt {
            createdAt.value = self.dynamicType.dateFormatter.stringFromDate(createdDate)
        }
    }
}