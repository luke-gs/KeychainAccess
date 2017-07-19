//
//  Lottie.swift
//  MPOLKit
//
//  Created by Pavel Boryseiko on 19/7/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

final class LottieManager {
    public static var spinnerURL: URL {
        return Bundle.mpolKit.url(forResource: "spinner", withExtension: "json", subdirectory: "Lottie")!
    }
}
