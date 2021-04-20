//
//  Dispatch.swift
//  Lightbox
//
//  Created by Matthew Daigle on 6/22/17.
//  Copyright © 2017 bgs. All rights reserved.
//

import Foundation

func onmain(execute: @escaping () -> Void) {
    DispatchQueue.main.async(execute: execute)
}

func delay(seconds: Double, execute: @escaping () -> Void) {
    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(seconds * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: execute)
}

func onmainsync(execute: @escaping () -> Void) {
    if Thread.isMainThread {
        execute()
    }
    else {
        DispatchQueue.main.sync(execute: execute)
    }
}
