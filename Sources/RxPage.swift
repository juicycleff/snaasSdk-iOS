//
//  Page.swift
//  Tapglue
//
//  Created by John Nilsen on 9/13/16.
//  Copyright © 2016 Tapglue. All rights reserved.
//

import RxSwift
import ObjectMapper

open class RxPage<T> {
    open var data: [T] {
        get {
            return feed.flatten()
        }
    }
    open var previous: Observable<RxPage<T>> {
        get {
            return generatePreviousObservable()
        }
    }
    
    fileprivate var feed: FlattenableFeed<T>
    fileprivate var prevPointer: String?
    var payload: [String: AnyObject]?

    init(feed: FlattenableFeed<T>, previousPointer: String?) {
        self.feed = feed
        self.prevPointer = previousPointer
    }
    
    func generatePreviousObservable() -> Observable<RxPage<T>> {
        guard let prevPointer = prevPointer else {
            return Observable.just(RxPage<T>(feed: FlattenableFeed<T>(), previousPointer: nil))
        }
        var request: URLRequest
        if let payload = payload {
            request = Router.postOnURL(prevPointer, payload: payload)
        } else {
            request = Router.getOnURL(prevPointer)
        }
        
        return Http().execute(request).map { (newFeed: [String:Any]) in
            let feed = self.feed.newCopy(json: newFeed)
            let page = RxPage<T>(feed: feed!, previousPointer: feed!.page?.before)
            page.payload = self.payload
            return page
        }
    }
}
