import Cocoa

let defaults = UserDefaults.standard

class BundleIDVC: NSViewController {
    @IBOutlet var comboBox: NSComboBox!
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        let wc = segue.destinationController as! NSWindowController
        let vc = wc.contentViewController as! PinnedVC
        let id = comboBox.stringValue
        vc.bundle = BundleID(id)
        self.view.window?.close()
        storeBundleIdInUserDefaults(id)
    }

    let userDefaultsKey = "storedBundleIds"

    func storeBundleIdInUserDefaults(_ id: String) {
        defaults.removeObject(forKey: userDefaultsKey)
        var old = defaults.stringArray(forKey: userDefaultsKey) ?? []
        old.append(id)
        old = Array(Set(old)).sorted()
        defaults.set(old, forKey: userDefaultsKey)
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        self.view.window?.center()
    }
}

extension BundleIDVC: NSComboBoxDataSource, NSComboBoxDelegate {
    func numberOfItems(in comboBox: NSComboBox) -> Int {
        defaults.stringArray(forKey: userDefaultsKey)?.count ?? 0
    }

    func comboBox(_ comboBox: NSComboBox, objectValueForItemAt index: Int) -> Any? {
        let all = defaults.stringArray(forKey: userDefaultsKey) ?? []
        return all[index]
    }
}
