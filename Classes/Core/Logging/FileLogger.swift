//
//  FileLogger.swift
//  Pods
//
//  Created by QHMW64 on 4/9/17.
//
//

import Foundation

public struct FileLogger: Loggable {

    private let divider = "-----------------------------------------------------------------------------------"
    private let fileURL: URL

    init(fileURL: URL? = nil) {

        if let url = fileURL {
            self.fileURL = url
        } else {
            let fileManager = FileManager.default

            let logURL = try! fileManager.url(for: FileManager.SearchPathDirectory.documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathComponent("Logs/Network")
            if !fileManager.fileExists(atPath: logURL.path) {
                do {
                    try fileManager.createDirectory(atPath: logURL.path, withIntermediateDirectories: true, attributes: nil)
                } catch {
                    print("Error creating directory.\nCause: \(error)")
                }
            }
            self.fileURL = logURL
        }
        print(divider + "\n" + "Logging to: \(self.fileURL.path)" + "\n" + divider)
    }

    public func log(output log: String) {
        DispatchQueue.global(qos: .background).async {
            self.write(text: log)
        }
    }

    private func write(text: String) {
        let fileName: String = Date().wrap(dateFormatter: DateFormatter.accurateDate)
        if let handle = FileHandle(forWritingAtPath: fileURL.appendingPathComponent(fileName).path) {
            handle.seekToEndOfFile()
            handle.write(text.data(using: .utf8)!)
            handle.closeFile()
        } else {
            try? text.data(using: .utf8)?.write(to: fileURL.appendingPathComponent(fileName))
        }
    }
}
