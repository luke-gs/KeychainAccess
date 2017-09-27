//
//  FileLogger.swift
//  Pods
//
//  Created by QHMW64 on 4/9/17.
//
//

import Foundation

public enum LogFilePolicy {
    case multiple
    case single

    func fileName() -> String {
        switch self {
        case .multiple: return "networkLogs.txt"
        case .single: return Date().wrap(dateFormatter: DateFormatter.accurateDate) + ".txt"
        }
    }
}

public struct FileLoggerConfigurations {
    public let savePolicy: LogFilePolicy

    public init(savePolicy: LogFilePolicy = .single) {
        self.savePolicy = savePolicy
    }
}

/// Tasked with logging a provided string to files
public struct FileLogger: Loggable {

    private let divider = "-----------------------------------------------------------------------------------"
    public let fileURL: URL
    internal let configurations: FileLoggerConfigurations

    public static let defaultURL: URL = try! FileManager.default.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathComponent("Logs/Network")

    /// ---------------------------------------------------------------------------------------
    /// Designated Init
    ///
    /// - Parameter fileURL: Optional fileURL - If not provided will create a default URL
    /// - Parameter configs: The configurations of the file logger - Default 
    ///             provides single save for logs
    /// ---------------------------------------------------------------------------------------
    public init(fileURL: URL = FileLogger.defaultURL, configs: FileLoggerConfigurations = FileLoggerConfigurations()) {

        self.configurations = configs
        self.fileURL = fileURL

        let fileManager = FileManager.default

        if !fileManager.fileExists(atPath: fileURL.path) {
            do {
                try fileManager.createDirectory(atPath: fileURL.path, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print("Error creating directory.\nCause: \(error)")
            }
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
