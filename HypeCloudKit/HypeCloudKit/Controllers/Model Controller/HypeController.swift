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
    
    func update(_ hype: Hype, completion: @escaping (Result<Hype?, HypeError>) -> Void) {
        // Create a CKRecord from the passed-in Hype
        let record = CKRecord(hype: hype)
        
        // Create an Operation
        let operation = CKModifyRecordsOperation(recordsToSave: [record], recordIDsToDelete: nil)
       
        // Set the properties on the operation
        operation.savePolicy = .changedKeys
        operation.qualityOfService = .userInteractive
        operation.modifyRecordsCompletionBlock = { records, _, error in
            // Handle the optional error
            if let error = error {
                return completion(.failure(.ckError(error)))
            }
            
            guard let record = records?.first,
                let updatedHype = Hype(ckRecord: record)
                else { return completion(.failure(.couldNotUnwrap))}
            
            completion(.success(updatedHype))
        }
        publicDB.add(operation)
    }
    
    func delete(_ hype: Hype, completion: @escaping (Result<Bool, HypeError>) -> Void) {
        
        let operation = CKModifyRecordsOperation(recordsToSave: nil, recordIDsToDelete: [hype.recordID])
        
        operation.savePolicy = .changedKeys
        operation.qualityOfService = .userInteractive
        operation.modifyRecordsCompletionBlock = { records, _, error in
            
            if let error = error {
                return completion(.failure(.ckError(error)))
            }
            
            if records?.count == 0 {
                completion(.success(true))
            } else {
                completion(.failure(.unexpectedRecordsFound))
            }
        }
        publicDB.add(operation)
    }
}
