import Cocoa
import Combine

typealias KEYVAL = (key: String, value: Any)
enum FilterType: Int { case containing, matchingWord, startsWith }

struct Search: Equatable {
    let type: FilterType
    let search: String
}

class ViewController: NSViewController {
    var storage = Set<AnyCancellable>()
    @IBOutlet var pinnedTableView: NSTableView!
    @IBOutlet var tableView: NSTableView!

    var source = [KEYVAL]() {
        didSet { filteredSource = source }
    }

    var filteredSource = [KEYVAL]() {
        didSet {
            tableView.reloadData()
        }
    }

    var pinnedKeys = [String]() {
        didSet {
            pinnedTableView.reloadData()
        }
    }

    @Published var searchString: String = ""
    @Published var type: FilterType = .containing


    var bundleId: String = "" {
        didSet {
            print("Bundleid \(bundleId)")
            guard bundleId.isEmpty == false else { return }
            let grr = NSHomeDirectory().appending("/Library/Containers/\(bundleId)/Data/Library/Preferences/\(bundleId).plist")
            let url1 = URL(fileURLWithPath: grr)
            let dict = NSDictionary(contentsOf: url1) as! [String : Any]

            source = dict.reduce([KEYVAL]()) { (res, t) -> [KEYVAL] in
                res + [(key: t.key, value: t.value)]
            }
        }
    }

    @IBAction func clearPinnedItems(_ sender: Any) {
        pinnedKeys.removeAll()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        Publishers.CombineLatest($searchString, $type)
            .sink { [weak self] (s, t) in
                guard let self = self else { return }
                if s.isEmpty { self.filteredSource = self.source; return }
                self.filteredSource = self.source.filter { (k,v) in
                    switch t {
                    case .containing: return k.lowercased().contains(s.lowercased())
                    case .matchingWord: return k.lowercased() == s.lowercased()
                    case .startsWith: return k.lowercased().hasPrefix(s.lowercased())
                    }
                }
        }.store(in: &self.storage)

    }

    @IBAction func searchAction(_ sender: NSSearchField) {
        searchString  = sender.stringValue
    }

    @IBAction func filterType(_ sender: NSPopUpButton) {
        type = FilterType(rawValue: sender.indexOfSelectedItem)!
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
