//
//  HypeController.swift
//  HypeCloudKit
//
//  Created by Jacob LeCheminant on 2/4/20.
//  Copyright © 2020 Jacob LeCheminant. All rights reserved.
//

import Foundation
import CloudKit

class HypeController {
    
    let publicDB = CKContainer.default().publicCloudDatabase
    
    // Singleton
    static let sharedInstance = HypeController()
    
    var hypes: [Hype] = []
    
    // MARK: - CRUD
    
    func saveHype(with bodyText: String, completion: @escaping (Result<Hype?, HypeError>) -> Void) {
        
        let newHype = Hype(body: bodyText)
        
        let hypeRecord = CKRecord(hype: newHype)
        
        publicDB.save(hypeRecord) { (record, error) in
            
            if let error = error {
                return completion(.failure(.ckError(error)))
            }
            
            guard let record = record,
                let savedHype = Hype(ckRecord: record)
                else { return completion(.failure(.couldNotUnwrap)) }
            print("Saved Hype successfully")
            
            completion(.success(savedHype))
        }
    }
    
    func fetchAllHypes(completion: @escaping (Result<[Hype], HypeError>) -> Void) {
        
        let queryAllPredicate = NSPredicate(value: true)
        
        let query = CKQuery(recordType: HypeStrings.recordTypeKey, predicate: queryAllPredicate)
        
        publicDB.perform(query, inZoneWith: nil) { (records, error) in
            if let error = error {
                completion(.failure(.ckError(error)))
            }
            
            guard let records = records else { return completion(.failure(.couldNotUnwrap)) }
            
            let hypes: [Hype] = records.compactMap( { Hype(ckRecord: $0)})
            
            completion(.success(hypes))
        }
        
    }
}
