import Cocoa
import Combine

class NewBundleViewController: NSViewController {
    @IBOutlet var bundleTextField: NSTextField!

    var sub = PassthroughSubject<String, Never>()

    @IBAction func submit(_ sender: Any) {
        let str = bundleTextField.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
        if str.isEmpty {
            sub.send("com.kaunteya.lexi")
        } else {
            sub.send(str)
        }

        self.dismiss(sender)
    }
}
