
import UIKit

public class AttributedStringController: UIViewController {

    public var attributedString: NSAttributedString? {
        get {
            return textView?.attributedText
        }
        set {
            textView?.attributedText = newValue
        }
    }

    private var textView: UITextView?

    public override func loadView() {
        let view = UIView()
        view.backgroundColor = .white

        let textView = UITextView()
        textView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        textView.attributedText = attributedString
        view.addSubview(textView)
        self.textView = textView

        self.view = view
    }
}
