import Cocoa
import Combine

typealias KEYVAL = (key: String, value: Any)

class ViewController: NSViewController {
    var storage = Set<AnyCancellable>()
    var bundle: BundleID!
    var searchString: String = ""
    var selectedKeysSubject = PassthroughSubject<[String], Never>()

    @IBOutlet var tableView: NSTableView!
    var source = [KEYVAL]()
    var filteredSource = [KEYVAL]()

    @IBAction func searchAction(_ sender: NSSearchField) {
        searchString  = sender.stringValue
    }

    @IBAction func pinItems(_ sender: Any) {
        let selectedKeys = tableView.selectedRowIndexes.map {
            filteredSource[$0].key
        }
        selectedKeysSubject.send(selectedKeys)
    }

    @IBAction func reload(_ sender: Any) {
        bundle.reload()
        source = bundle.list
        filteredSource = source
        tableView.reloadData()
    }
}

extension ViewController: NSTableViewDataSource, NSTableViewDelegate {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return filteredSource.count
    }

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        if tableColumn?.identifier.rawValue == "key" {
            let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "cell1"), owner: nil) as! NSTableCellView
            cell.textField!.stringValue = filteredSource[row].key
            return cell
        } else {
            let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "cell1"), owner: nil) as! NSTableCellView
            let val = filteredSource[row].value
            cell.textField!.stringValue = "\(val)"
            return cell
        }
    }

    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        30
    }
}
