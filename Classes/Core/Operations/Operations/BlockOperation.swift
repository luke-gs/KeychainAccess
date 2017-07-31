//
//  BlockOperation.swift
//  Pods
//
//  Created by Megan Efron on 31/7/17.
//
//

import Foundation


/// `BlockOperation` is a subclass of `Foundation.Operation` which allows you to manually
/// mark the operation as finished.
///
/// You can initalize a `BlockOperation` with a block of type `(finished () -> ()) -> ()`,
/// where you can call `finished()` within the executing block to mark the operation as
/// complete and all that operation and KVO magic will start executing any dependencies
/// on the same queue when this happens.
///
/// e.g.
/**
 ```
let blockOperation = MPOLKit.BlockOperation({ (finished) in
    let alertController = UIAlertController(title: "Alert", message: "When I tap OK, this operation will finish.", preferredStyle: .alert)
    controller.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (alert) in
        // When executing the finished block, the operation will be marked as finished
        finished()
    }))
    loginViewController.present(controller, animated: true, completion: nil)
})
OperationQueue.main.addOperation(blockOp)
``` 
 */
open class BlockOperation: Foundation.Operation {
    
    /// The block type that `BlockOperation` accepts and executes.
    public typealias ExecutionBlock = (_ finished: @escaping () -> Void) -> Void
    
    // MARK: - Properties
    
    /// The block to be executed as an operation, with the finished block passed in as a parameter.
    ///
    /// - Important: You must call finished() at some point within this block otherwise
    ///   the operation will never be marked as finished and any dependencies in the queue
    ///   will not run.
    private let block: ExecutionBlock
    
    /// An internal flag to handle the isExecuting state of the operation.
    private var running: Bool = false {
        willSet {
            willChangeValue(forKey: "isExecuting")
        } didSet {
            didChangeValue(forKey: "isExecuting")
        }
    }
    
    /// An internal flag to handle the isFinished state of the operation.
    private var done: Bool = false {
        willSet {
            willChangeValue(forKey: "isFinished")
        } didSet {
            didChangeValue(forKey: "isFinished")
        }
    }

    /// Init with execution block.
    public required init(_ block: @escaping ExecutionBlock) {
        self.block = block
        super.init()
    }
    
    
    // MARK: - Override Functions
    
    override open func start() {
        guard !isCancelled else {
            self.done = true
            return
        }
        Thread.detachNewThreadSelector(#selector(main), toTarget: self, with: nil)
        self.running = true
    }
    
    override open func main() {
        block({ [unowned self] in
            self.done = true
        })
    }
    
    open override var isExecuting: Bool {
        return running
    }
    
    open override var isFinished: Bool {
        return done
    }
    
    open override var isConcurrent: Bool {
        return true
    }
}
