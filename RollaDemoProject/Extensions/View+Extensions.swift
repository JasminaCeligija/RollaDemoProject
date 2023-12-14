import SwiftUI

extension View {
    var hosted: UIHostingController<Self> {
        UIHostingController(rootView: self)
    }
}
