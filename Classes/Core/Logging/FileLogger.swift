//
//  FileLogger.swift
//  Pods
//
//  Created by QHMW64 on 4/9/17.
//
//

import Foundation

enum LogFilePolicy {
    case multiple
    case single

    func fileName() -> String {
        switch self {
        case .multiple: return "networkLogs.txt"
        case .single: return Date().wrap(dateFormatter: DateFormatter.accurateDate) + ".txt"
        }
    }
}

struct FileLoggerConfigurations {
    var savePolicy: LogFilePolicy

    init(savePolicy: LogFilePolicy = .single) {
        self.savePolicy = savePolicy
    }
}

/// Tasked with logging a provided string to files
public struct FileLogger: Loggable {

    private let divider = "-----------------------------------------------------------------------------------"
    private let fileURL: URL
    internal let configurations: FileLoggerConfigurations

    /// ---------------------------------------------------------------------------------------
    /// Designated Init
    ///
    /// - Parameter fileURL: Optional fileURL - If not provided will create a default URL
    /// - Parameter configs: The configurations of the file logger - Default 
    ///             provides single save for logs
    /// ---------------------------------------------------------------------------------------
    init(fileURL: URL? = nil, configs: FileLoggerConfigurations = FileLoggerConfigurations()) {

        self.configurations = configs

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

        // Prints out the location of the simulator file for easy debugging
        print(divider + "\n" + "Logging to: \(self.fileURL.path)" + "\n" + divider)
    }

    /// ---------------------------------------------------------------------------------------
    /// FileLogger log
    ///
    /// - Parameter log: The text to be logged to file
    /// ---------------------------------------------------------------------------------------
    public func log(output log: String) {
        DispatchQueue.global(qos: .background).async {
            self.write(text: log)
        }
    }


    /// ---------------------------------------------------------------------------------------
    /// Private function to write a certain text to a specific file
    ///
    /// - Parameter text: The text that will be written to file 
    /// ---------------------------------------------------------------------------------------
    private func write(text: String) {

        // File name based on Date - Accurate to 1000ms
        let fileName: String = configurations.savePolicy.fileName()

        if let handle = FileHandle(forWritingAtPath: fileURL.appendingPathComponent(fileName).path) {
            if let data = text.data(using: .utf8) {
                handle.seekToEndOfFile()
                handle.write(data)
                handle.closeFile()
            }
        } else {
            try? text.data(using: .utf8)?.write(to: fileURL.appendingPathComponent(fileName))
        }
    }
}
