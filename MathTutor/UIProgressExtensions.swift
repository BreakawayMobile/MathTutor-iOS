//
//  UIProgressExtensions.swift
//  MathTutor
//
//  Created by Joe Radjavitch on 10/10/21.
//  Copyright © 2021 bgs. All rights reserved.
//

import Foundation
import UIKit

extension UIProgressView {
    
    func setIndeterminate(_ isIndeterminate: Bool, inTimer: Timer? = nil) -> Timer? {
        var timer = inTimer
        
        if (isIndeterminate) {
            if timer == nil {
                self.setProgress(0.0, animated: true)
            
                timer = Timer.scheduledTimer(withTimeInterval: 0.075,
                                             repeats: true,
                                             block: { _ in

                    var nextProg = self.progress + 0.1
                    if nextProg > 1.0 {
                        nextProg = 0.0
                    }

                    self.setProgress(nextProg,
                                     animated: !(nextProg == 0.0))
                })
            }
        } else {
            if (timer != nil) {
                timer?.invalidate()
                timer = nil
            }
            
            self.setProgress(0.0,
                             animated: false)
        }
        
        return timer
    }
}
