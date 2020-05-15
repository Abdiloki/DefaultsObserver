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

    override func viewDidLoad() {
        super.viewDidLoad()
        Publishers.CombineLatest($searchString, $type)
            .sink { [weak self] (s, t) in
                guard let self = self else { return }
                if s.isEmpty { self.filteredSource = self.source; return }
                self.filteredSource = self.source.filter { (k,v) in
                    k.contains(s)
                }
        }.store(in: &self.storage)

    }

    @IBAction func searchAction(_ sender: NSSearchField) {
        searchString  = sender.stringValue
    }

    @IBAction func filterType(_ sender: NSPopUpButton) {
        type = FilterType(rawValue: sender.indexOfSelectedItem)!
    }
}

extension ViewController: NSTableViewDataSource, NSTableViewDelegate {
    func numberOfRows(in tableView: NSTableView) -> Int {
        filteredSource.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        if tableColumn?.identifier.rawValue == "key" {
            let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "cell1"), owner: nil) as! NSTableCellView
            cell.textField?.stringValue = filteredSource[row].key
            return cell
        } else {
            let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "cell1"), owner: nil) as! NSTableCellView
            let val = filteredSource[row].value as? String ?? ""
            cell.textField?.stringValue = val
            return cell
        }
    }

    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        25
    }
}

extension UInt8 {
    var printableAscii : String {
        switch self {
        case 0..<32:    return "^" + (self + 64).printableAscii
        case 127:       return "^?"
        case 32..<128:  return String(bytes: [self], encoding:.ascii)!
        default:        return "M-" + (self & 127).printableAscii
        }
    }
}

extension Collection where Element == UInt8 {
    var printableAscii : String {
        return self.map { $0.printableAscii } .joined()
    }
}
