import Cocoa

class BundleIDVC: NSViewController {
    @IBOutlet var bundleTextField: NSTextField!
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        let wc = segue.destinationController as! NSWindowController
        let vc = wc.contentViewController as! PinnedVC
        vc.bundle = BundleID(bundleTextField.stringValue)
        self.view.window?.close()
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        self.view.window?.center()
    }
}
