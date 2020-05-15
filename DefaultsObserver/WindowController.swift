import Cocoa
import Combine

class WindowController: NSWindowController {
    var storage = Set<AnyCancellable>()

    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        if let newBundleVC = segue.destinationController as? NewBundleViewController {
            let vc = self.contentViewController as! ViewController
            newBundleVC.sub
                .assign(to: \.bundleId, on: vc)
                .store(in: &self.storage)
        }
    }
}
