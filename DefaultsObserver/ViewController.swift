import Cocoa

class ViewController: NSViewController {
    @IBOutlet var pinnedTableView: NSTableView!
    @IBOutlet var tableView: NSTableView!

    var bundleId: String? = "com.kaunteya.lexi" {
        didSet {
            userDefaults = UserDefaults(suiteName: bundleId!)!.dictionaryRepresentation()
            keys = userDefaults.keys.map { String($0) }
            tableView.reloadData()
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        bundleId = "com.kaunteya.lexi"
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        tableView.enclosingScrollView?.isFindBarVisible = true
    }
    var userDefaults: [String : Any]!
    var keys: [String]!
}

extension ViewController: NSTableViewDataSource, NSTableViewDelegate {
    func numberOfRows(in tableView: NSTableView) -> Int {
        keys.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        if tableColumn?.identifier.rawValue == "key" {
            let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "cell1"), owner: nil) as! NSTableCellView
            cell.textField?.stringValue = keys[row]
            return cell
        }
        return nil
    }
}

