
import SafariServices

final class AboutTrailerViewController: UIViewController {
	@IBOutlet private weak var versionNumber: UILabel!
	@IBOutlet private weak var licenseText: UITextView!

	override func viewDidLoad() {
		super.viewDidLoad()
		versionNumber.text = versionString
		navigationItem.largeTitleDisplayMode = .automatic
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		licenseText.contentOffset = CGPoint.zero
		licenseText.textContainerInset = UIEdgeInsetsMake(0, 10, 10, 10)
	}

	@IBAction private func linkSelected() {
		let s = SFSafariViewController(url: URL(string: "https://github.com/ptsochantaris/trailer")!)
		s.view.tintColor = self.view.tintColor
		present(s, animated: true)
	}

	@IBAction private func doneSelected() {
		if preferencesDirty { app.startRefresh() }
		dismiss(animated: true)
	}
}
