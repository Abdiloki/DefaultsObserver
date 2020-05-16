import Cocoa
import Combine

class WindowController: NSWindowController {
    var storage = Set<AnyCancellable>()

    @IBOutlet var middleText: NSTextField!

    override func windowDidLoad() {
        super.windowDidLoad()
        middleText.widthAnchor.constraint(equalToConstant: 300).isActive = true
    }
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        if let newBundleVC = segue.destinationController as? NewBundleViewController {
            let vc = self.contentViewController as! PinnedVC
            newBundleVC.sub
                .map { BundleID($0)}
                .assign(to: \.bundle, on: vc)
                .store(in: &self.storage)
            newBundleVC.sub
                .assign(to: \.stringValue, on: middleText)
                .store(in: &self.storage)
        }
    }
}
