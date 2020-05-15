import Cocoa
import Combine

typealias KEYVAL = (key: String, value: Any)

class ViewController: NSViewController {
    var storage = Set<AnyCancellable>()
    @IBOutlet var pinnedTableView: NSTableView!
    @IBOutlet var tableView: NSTableView!

    var filteredSource = [KEYVAL]() {
        didSet {
            //Maintains the selection across the reloadData
            let selectedKeys = tableView.selectedRowIndexes.map { filteredSource[$0].key }
            tableView.reloadData()
            var newIndexSet = IndexSet()
            for (i, f) in filteredSource.enumerated() {
                if selectedKeys.contains(f.key) {
                    newIndexSet.insert(i)
                }
            }
            tableView.selectRowIndexes(newIndexSet, byExtendingSelection: true)
        }
    }

    var pinnedKeys = [String]() {
        didSet {
            pinnedTableView.reloadData()
        }
    }

    @Published var source = [KEYVAL]()
    @Published var searchString: String = ""

    var bundleId: String = "" {
        didSet {
            print("Bundleid \(bundleId)")
            updateInfoFromFile()
        }
    }

    func updateInfoFromFile() {
        guard bundleId.isEmpty == false else { return }
        let grr = NSHomeDirectory().appending("/Library/Containers/\(bundleId)/Data/Library/Preferences/\(bundleId).plist")
        let url = URL(fileURLWithPath: grr)
        guard let dict = NSDictionary(contentsOf: url) as? [String : Any] else { return }

        source = dict.reduce([KEYVAL]()) { (res, t) -> [KEYVAL] in
            res + [(key: t.key, value: t.value)]
        }.sorted(by: { (a, b) -> Bool in
            a.key < b.key
        })
    }

    @IBAction func clearPinnedItems(_ sender: Any) {
        pinnedKeys.removeAll()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        Publishers.CombineLatest($source, $searchString)
            .sink { [unowned self] (source, searchString) in
                if searchString.isEmpty {
                    self.filteredSource = source
                } else {
                    self.filteredSource = source.filter { (k,v) in
                        k.lowercased().contains(searchString.lowercased())
                    }
                }
        }.store(in: &self.storage)

        Timer.publish(every: 0.5, on: .main, in: .default)
            .autoconnect()
            .sink { _ in self.updateInfoFromFile() }
            .store(in: &self.storage)
    }

    @IBAction func searchAction(_ sender: NSSearchField) {
        searchString  = sender.stringValue
    }

    @IBAction func pinItems(_ sender: Any) {
        pinnedKeys += tableView.selectedRowIndexes.map { filteredSource[$0].key }
    }
}

extension ViewController: NSTableViewDataSource, NSTableViewDelegate {
    func numberOfRows(in tableView: NSTableView) -> Int {
        if tableView === pinnedTableView {
            return pinnedKeys.count
        }
        return filteredSource.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        if tableView === pinnedTableView {
            if tableColumn?.identifier.rawValue == "key" {
                let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "cell1"), owner: nil) as! NSTableCellView
                cell.textField?.stringValue = pinnedKeys[row]
                return cell
            } else {
                let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "cell1"), owner: nil) as! NSTableCellView
                let val = filteredSource[row].value
                cell.textField?.stringValue = "\(val)"
                return cell
            }
        } else {
            if tableColumn?.identifier.rawValue == "key" {
                let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "cell1"), owner: nil) as! NSTableCellView
                cell.textField?.stringValue = filteredSource[row].key
                return cell
            } else {
                let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "cell1"), owner: nil) as! NSTableCellView
                let val = filteredSource[row].value
                cell.textField?.stringValue = "\(val)"
                return cell
            }
        }
    }

    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        30
    }
}
