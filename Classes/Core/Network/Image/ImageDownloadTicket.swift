//
//  ImageDownloadTicket.swift
//  MPOLKit
//
//  Created by Herli Halim on 30/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Alamofire

public class ImageDownloadTicket {
    public let ticketID: String
    public let request: Request

    init(ticketID: String, request: Request) {
        self.ticketID = ticketID
        self.request = request
    }
}
