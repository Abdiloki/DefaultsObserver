import Cocoa

struct BundleID {
    let id: String
    private (set) var list: [KEYVAL] = []
    private (set) var dict: [String: Any] = [:]

    init(_ id: String) {
        self.id = id
    }

    mutating func reload() {
        guard id.isEmpty == false else {
            self.list = []
            return
        }

        let path = NSHomeDirectory().appending("/Library/Containers/\(id)/Data/Library/Preferences/\(id).plist")
        let url = URL(fileURLWithPath: path)
        dict = NSDictionary(contentsOf: url) as? [String : Any] ?? [:]

        list = dict.reduce([KEYVAL]()) { (res, t) -> [KEYVAL] in
            res + [(key: t.key, value: t.value)]
        }.sorted(by: { (a, b) -> Bool in
            a.key < b.key
        })
    }

    subscript(_ key: String) -> Any? {
        list.first { key == $0.key }
    }
}
