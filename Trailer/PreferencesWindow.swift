
import Foundation

final class PreferencesWindow : NSWindow, NSWindowDelegate, NSTableViewDelegate, NSTableViewDataSource, NSTabViewDelegate {

	private var deferredUpdateTimer: PopTimer!
	private var serversDirty = false

	func reset() {
		preferencesDirty = true
		API.refreshesSinceLastStatusCheck.removeAll()
		API.refreshesSinceLastReactionsCheck.removeAll()
		Settings.lastSuccessfulRefresh = nil
		lastRepoCheck = .distantPast
		reloadRepositories()
		deferredUpdateTimer.push()
	}

	private var repoCache: [Repo]?

	private var repos: [Repo] {
		if let repoCache = repoCache {
			return repoCache
		}
		repoCache = ((Repo.reposFiltered(by: repoFilter.stringValue) as NSArray)
			.sortedArray(using: projectsTable.sortDescriptors) as! [Repo])
		return repoCache!
	}

	func reloadRepositories() {
		repoCache = nil
		projectsTable.reloadData()
	}

	// Preferences window
	@IBOutlet private weak var projectsTable: NSTableView!
	@IBOutlet private weak var versionNumber: NSTextField!
	@IBOutlet private weak var launchAtStartup: NSButton!
	@IBOutlet private weak var refreshDurationLabel: NSTextField!
	@IBOutlet private weak var refreshDurationStepper: NSStepper!
	@IBOutlet private weak var hideUncommentedPrs: NSButton!
	@IBOutlet private weak var repoFilter: NSTextField!
	@IBOutlet private weak var showAllComments: NSButton!
	@IBOutlet private weak var sortingOrder: NSButton!
	@IBOutlet private weak var sortModeSelect: NSPopUpButton!
	@IBOutlet private weak var includeRepositoriesInFiltering: NSButton!
	@IBOutlet private weak var groupByRepo: NSButton!
	@IBOutlet private weak var countOnlyListedItems: NSButton!
	@IBOutlet private weak var checkForUpdatesAutomatically: NSButton!
	@IBOutlet private weak var checkForUpdatesLabel: NSTextField!
	@IBOutlet private weak var checkForUpdatesSelector: NSStepper!
	@IBOutlet private weak var openPrAtFirstUnreadComment: NSButton!
	@IBOutlet private weak var logActivityToConsole: NSButton!
	@IBOutlet private weak var commentAuthorBlacklist: NSTokenField!

	// History
	@IBOutlet private weak var prMergedPolicy: NSPopUpButton!
	@IBOutlet private weak var prClosedPolicy: NSPopUpButton!
	@IBOutlet private weak var dontKeepPrsMergedByMe: NSButton!
	@IBOutlet private weak var dontConfirmRemoveAllMerged: NSButton!
	@IBOutlet private weak var dontConfirmRemoveAllClosed: NSButton!
	@IBOutlet private weak var removeNotificationsWhenItemIsRemoved: NSButton!

	// Statuses
	@IBOutlet private weak var showStatusItems: NSButton!
	@IBOutlet private weak var makeStatusItemsSelectable: NSButton!
	@IBOutlet private weak var statusItemRescanLabel: NSTextField!
	@IBOutlet private weak var statusItemRefreshCounter: NSStepper!
	@IBOutlet private weak var statusItemsRefreshNote: NSTextField!
	@IBOutlet private weak var notifyOnStatusUpdates: NSButton!
	@IBOutlet private weak var notifyOnStatusUpdatesForAllPrs: NSButton!
	@IBOutlet private weak var statusTermMenu: NSPopUpButton!
	@IBOutlet private weak var statusTermsField: NSTokenField!
	@IBOutlet private weak var hidePrsThatDontPass: NSButton!
	@IBOutlet private weak var hidePrsThatDontPassOnlyInAll: NSButton!
	@IBOutlet private weak var showStatusesForAll: NSButton!

	// Comments
	@IBOutlet private weak var disableAllCommentNotifications: NSButton!
	@IBOutlet private weak var assumeCommentsBeforeMineAreRead: NSButton!
	@IBOutlet private weak var newMentionMovePolicy: NSPopUpButton!
	@IBOutlet private weak var teamMentionMovePolicy: NSPopUpButton!
	@IBOutlet private weak var newItemInOwnedRepoMovePolicy: NSPopUpButton!
	@IBOutlet private weak var highlightItemsWithNewCommits: NSButton!

	// Display
	@IBOutlet private weak var includeLabelsInFiltering: NSButton!
	@IBOutlet private weak var includeTitlesInFiltering: NSButton!
	@IBOutlet private weak var includeMilestonesInFiltering: NSButton!
	@IBOutlet private weak var includeAssigneeNamesInFiltering: NSButton!
	@IBOutlet private weak var includeStatusesInFiltering: NSButton!
	@IBOutlet private weak var grayOutWhenRefreshing: NSButton!
	@IBOutlet private weak var assignedPrHandlingPolicy: NSPopUpButton!
	@IBOutlet private weak var includeServersInFiltering: NSButton!
	@IBOutlet private weak var includeUsersInFiltering: NSButton!
	@IBOutlet private weak var includeNumbersInFiltering: NSButton!
	@IBOutlet private weak var refreshItemsLabel: NSTextField!
	@IBOutlet private weak var showCreationDates: NSButton!
	@IBOutlet private weak var hideAvatars: NSButton!
	@IBOutlet private weak var showSeparateApiServersInMenu: NSButton!
	@IBOutlet private weak var displayRepositoryNames: NSButton!
	@IBOutlet private weak var hideCountsOnMenubar: NSButton!
	@IBOutlet private weak var showLabels: NSButton!
	@IBOutlet private weak var showRelativeDates: NSButton!
	@IBOutlet private weak var displayMilestones: NSButton!

	// Servers
	@IBOutlet private weak var serverList: NSTableView!
	@IBOutlet private weak var apiServerName: NSTextField!
	@IBOutlet private weak var apiServerApiPath: NSTextField!
	@IBOutlet private weak var apiServerWebPath: NSTextField!
	@IBOutlet private weak var apiServerAuthToken: NSTextField!
	@IBOutlet private weak var apiServerSelectedBox: NSBox!
	@IBOutlet private weak var apiServerTestButton: NSButton!
	@IBOutlet private weak var apiServerDeleteButton: NSButton!
	@IBOutlet private weak var apiServerReportError: NSButton!

	// Snoozing
	@IBOutlet private weak var snoozePresetsList: NSTableView!
	@IBOutlet private weak var snoozeTypeDuration: NSButton!
	@IBOutlet private weak var snoozeTypeDateTime: NSButton!
	@IBOutlet private weak var snoozeDurationDays: NSPopUpButton!
	@IBOutlet private weak var snoozeDurationHours: NSPopUpButton!
	@IBOutlet private weak var snoozeDurationMinutes: NSPopUpButton!
	@IBOutlet private weak var snoozeDateTimeDay: NSPopUpButton!
	@IBOutlet private weak var snoozeDateTimeHour: NSPopUpButton!
	@IBOutlet private weak var snoozeDateTimeMinute: NSPopUpButton!
	@IBOutlet private weak var snoozeDeletePreset: NSButton!
	@IBOutlet private weak var snoozeUp: NSButton!
	@IBOutlet private weak var snoozeDown: NSButton!
	@IBOutlet private weak var snoozeWakeOnComment: NSButton!
	@IBOutlet private weak var snoozeWakeOnMention: NSButton!
	@IBOutlet private weak var snoozeWakeOnStatusUpdate: NSButton!
	@IBOutlet private weak var hideSnoozedItems: NSButton!
	@IBOutlet private weak var snoozeWakeLabel: NSTextField!

	@IBOutlet private weak var autoSnoozeSelector: NSStepper!
	@IBOutlet private weak var autoSnoozeLabel: NSTextField!

	// Misc
	@IBOutlet private weak var repeatLastExportAutomatically: NSButton!
	@IBOutlet private weak var lastExportReport: NSTextField!
	@IBOutlet private weak var dumpApiResponsesToConsole: NSButton!
	@IBOutlet private weak var defaultOpenApp: NSTextField!
	@IBOutlet private weak var defaultOpenLinks: NSTextField!

	// Keyboard
	@IBOutlet private weak var hotkeyEnable: NSButton!
	@IBOutlet private weak var hotkeyCommandModifier: NSButton!
	@IBOutlet private weak var hotkeyOptionModifier: NSButton!
	@IBOutlet private weak var hotkeyShiftModifier: NSButton!
	@IBOutlet private weak var hotkeyLetter: NSPopUpButton!
	@IBOutlet private weak var hotKeyHelp: NSTextField!
	@IBOutlet private weak var hotKeyContainer: NSBox!
	@IBOutlet private weak var hotkeyControlModifier: NSButton!

	// Watchlist
	@IBOutlet private weak var allPrsSetting: NSPopUpButton!
	@IBOutlet private weak var allIssuesSetting: NSPopUpButton!
	@IBOutlet private weak var allHidingSetting: NSPopUpButton!
	@IBOutlet private weak var allNewPrsSetting: NSPopUpButton!
	@IBOutlet private weak var allNewIssuesSetting: NSPopUpButton!

	// Reviews
	@IBOutlet private weak var assignedReviewHandlingPolicy: NSPopUpButton!
	@IBOutlet private weak var notifyOnChangeRequests: NSButton!
	@IBOutlet private weak var notifyOnAcceptances: NSButton!
	@IBOutlet private weak var notifyOnReviewDismissals: NSButton!
	@IBOutlet private weak var notifyOnReviewAssignments: NSButton!
	@IBOutlet private weak var notifyOnAllChangeRequests: NSButton!
	@IBOutlet private weak var notifyOnAllAcceptances: NSButton!
	@IBOutlet private weak var notifyOnAllReviewDismissals: NSButton!
	@IBOutlet private weak var supportReviews: NSButton!

	// Reactions
	@IBOutlet private weak var notifyOnItemReactions: NSButton!
	@IBOutlet private weak var notifyOnCommentReactions: NSButton!
	@IBOutlet private weak var reactionIntervalLabel: NSTextField!
	@IBOutlet private weak var reactionIntervalStepper: NSStepper!

	// Tabs
	@IBOutlet weak var tabs: NSTabView!

	override func awakeFromNib() {
		super.awakeFromNib()
		delegate = self

		updateAllItemSettingButtons()
		fillSnoozingDropdowns()

		allNewPrsSetting.addItems(withTitles: RepoDisplayPolicy.labels)
		allNewIssuesSetting.addItems(withTitles: RepoDisplayPolicy.labels)

		addTooltips()
		reloadSettings()

		versionNumber.stringValue = versionString

		let selectedIndex = min(tabs.numberOfTabViewItems-1, Settings.lastPreferencesTabSelectedOSX)
		tabs.selectTabViewItem(tabs.tabViewItem(at: selectedIndex))

		if projectsTable.sortDescriptors.count == 0, let firstSortDescriptor = projectsTable.tableColumns.first?.sortDescriptorPrototype {
			projectsTable.sortDescriptors = [firstSortDescriptor]
		}

		let n = NotificationCenter.default
		n.addObserver(self, selector: #selector(updateApiTable), name: ApiUsageUpdateNotification, object: nil)
		n.addObserver(self, selector: #selector(updateImportExportSettings), name: SettingsExportedNotification, object: nil)

		deferredUpdateTimer = PopTimer(timeInterval: 1.0) { [weak self] in
			if let s = self, s.serversDirty {
				s.serversDirty = false
				DataManager.saveDB()
				Settings.possibleExport(nil)
				app.setupWindows()
			} else {
				DataManager.saveDB()
				app.updateAllMenus()
			}
		}
	}

	private func updateReviewOptions() {
		if !Settings.notifyOnReviewChangeRequests {
			Settings.notifyOnAllReviewChangeRequests = false
		}
		if !Settings.notifyOnReviewDismissals {
			Settings.notifyOnAllReviewDismissals = false
		}
		if !Settings.notifyOnReviewAcceptances {
			Settings.notifyOnAllReviewAcceptances = false
		}

		notifyOnAllChangeRequests.isEnabled = Settings.notifyOnReviewChangeRequests
		notifyOnAllReviewDismissals.isEnabled = Settings.notifyOnReviewDismissals
		notifyOnAllAcceptances.isEnabled = Settings.notifyOnReviewAcceptances

		notifyOnChangeRequests.integerValue = Settings.notifyOnReviewChangeRequests ? 1 : 0
		notifyOnReviewDismissals.integerValue = Settings.notifyOnReviewDismissals ? 1 : 0
		notifyOnAcceptances.integerValue = Settings.notifyOnReviewAcceptances ? 1 : 0
		notifyOnAllChangeRequests.integerValue = Settings.notifyOnAllReviewChangeRequests ? 1 : 0
		notifyOnAllReviewDismissals.integerValue = Settings.notifyOnAllReviewDismissals ? 1 : 0
		notifyOnAllAcceptances.integerValue = Settings.notifyOnAllReviewAcceptances ? 1 : 0
	}

	private func showOptionalReviewWarning(previousSync: Bool) {

		updateReviewOptions()

		if !previousSync && (API.shouldSyncReviews || API.shouldSyncReviewAssignments) {
			for p in DataItem.allItems(of: PullRequest.self, in: DataManager.main) {
				p.resetSyncState()
			}
			preferencesDirty = true

			showLongSyncWarning()
		} else {
			deferredUpdateTimer.push()
		}
	}

	@IBAction private func supportReviewsSelected(_ sender: NSButton) {
		let previousShouldSync = (API.shouldSyncReviews || API.shouldSyncReviewAssignments)
		Settings.displayReviewsOnItems = sender.integerValue == 1
		showOptionalReviewWarning(previousSync: previousShouldSync)
	}

	@IBAction private func notifyOnChangeRequestsSelected(_ sender: NSButton) {
		let previousShouldSync = (API.shouldSyncReviews || API.shouldSyncReviewAssignments)
		Settings.notifyOnReviewChangeRequests = sender.integerValue == 1
		showOptionalReviewWarning(previousSync: previousShouldSync)
	}
	@IBAction private func notifyOnAllChangeRequestsSelected(_ sender: NSButton) {
		Settings.notifyOnAllReviewChangeRequests = sender.integerValue == 1
	}

	@IBAction private func notifyOnAcceptancesSelected(_ sender: NSButton) {
		let previousShouldSync = (API.shouldSyncReviews || API.shouldSyncReviewAssignments)
		Settings.notifyOnReviewAcceptances = sender.integerValue == 1
		showOptionalReviewWarning(previousSync: previousShouldSync)
	}
	@IBAction private func notifyOnAllAcceptancesSelected(_ sender: NSButton) {
		Settings.notifyOnAllReviewAcceptances = sender.integerValue == 1
	}

	@IBAction private func notifyOnReviewDismissalsSelected(_ sender: NSButton) {
		let previousShouldSync = (API.shouldSyncReviews || API.shouldSyncReviewAssignments)
		Settings.notifyOnReviewDismissals = sender.integerValue == 1
		showOptionalReviewWarning(previousSync: previousShouldSync)
	}
	@IBAction private func notifyOnAllReviewDismissalsSelected(_ sender: NSButton) {
		Settings.notifyOnAllReviewDismissals = sender.integerValue == 1
	}

	private func showOptionalReviewAssignmentWarning(previousSync: Bool) {

		if !previousSync && (API.shouldSyncReviews || API.shouldSyncReviewAssignments) {
			for p in DataItem.allItems(of: PullRequest.self, in: DataManager.main) {
				p.resetSyncState()
			}
			preferencesDirty = true

			showLongSyncWarning()
		} else {
			deferredUpdateTimer.push()
		}
	}

	@IBAction private func notifyOnReviewAssignmentsSelected(_ sender: NSButton) {
		let previousShouldSync = (API.shouldSyncReviews || API.shouldSyncReviewAssignments)
		Settings.notifyOnReviewAssignments = sender.integerValue == 1
		showOptionalReviewAssignmentWarning(previousSync: previousShouldSync)
	}

	@IBAction private func assignedReviewHandlingPolicySelected(_ sender: NSPopUpButton) {
		let previousShouldSync = (API.shouldSyncReviews || API.shouldSyncReviewAssignments)
		Settings.assignedReviewHandlingPolicy = sender.index(of: sender.selectedItem!)
		DataManager.postProcessAllItems()
		deferredUpdateTimer.push()
		showOptionalReviewAssignmentWarning(previousSync: previousShouldSync)
	}

	private func showLongSyncWarning() {
		let a = NSAlert()
		a.messageText = "The next sync may take a while, because everything will need to be fully re-synced. This will be needed only once: Subsequent syncs will be fast again."
		a.beginSheetModal(for: self, completionHandler: nil)
	}

	@objc private func updateApiTable() {
		serverList.reloadData()
	}

	deinit {
		let n = NotificationCenter.default
		n.removeObserver(serverList)
		n.removeObserver(self)
	}

	private func addTooltips() {
		snoozePresetsList.toolTip = "The list of presets that will be displayed in the snooze context menu"
		serverList.toolTip = "The list of GitHub API servers that Trailer will attempt to sync data from. You can edit each server's details from the pane on the right. Bear in mind that some servers, like the public GitHub server for instance, have strict API volume limits, and syncing too many repos or items too often can result in API usage going over the limit. You can monitor your usage from the bar next to the server's name. If it is red, you're close to maximum. Your API usage is reset every hour."
		apiServerName.toolTip = "An internal name you want to use to refer to this server."
		apiServerApiPath.toolTip = "The full URL of the root of the API endpoints for this server. The placeholder text shows examples for GitHub and GitHub Enterprise servers, but your own custom configuration may vary."
		apiServerWebPath.toolTip = "This is the root of the web front-end of your server. It is used for constructing the paths to open your watchlist and API key management links. Other than that it is not used to sync data."
		apiServerReportError.toolTip = "If this is checked, Trailer will display a red 'X' symbol on your menubar if sync fails with this server. It is usually a good idea to keep this on, but you may want to turn it off if a specific server isn't always reacahble, for instance."
		projectsTable.toolTip = "These are all your watched repositories.\n\nTrailer scans the watchlists of all the servers you have configured and adds the repositories to this combined watchlist.\n\nYou can visit and edit the watchlist of each server from the link provided on that server's entry on the 'Servers' tab.\n\nYou can keep clutter low by editing the visibility of items from each repository with the dropdown menus on the right."
		repoFilter.toolTip = "Quickly find a repository you are looking for by typing some text in there. Productivity tip: If you use the buttons on the right to set visibility of 'all' items, those settings will apply to only the visible filtered items."
		allNewPrsSetting.toolTip = "The visibility settings you would like to apply by default for Pull Requests if a new repository is added in your watchlist."
		allNewIssuesSetting.toolTip = "The visibility settings you would like to apply by default for Pull Requests if a new repository is added in your watchlist."
		launchAtStartup.toolTip = "Automatically launch Trailer when you log in."
		allPrsSetting.toolTip = "Set the PR visibility of all (or the currently selected/filtered) repositories"
		allIssuesSetting.toolTip = "Set the issue visibility of all (or the currently selected/filtered) repositories"
		allHidingSetting.toolTip = "Set the any special hiding settings of all (or the currently selected/filtered) repositories"
		showCreationDates.toolTip = Settings.showCreatedInsteadOfUpdatedHelp
		highlightItemsWithNewCommits.toolTip = Settings.markPrsAsUnreadOnNewCommitsHelp
		countOnlyListedItems.toolTip = Settings.countOnlyListedItemsHelp
		displayRepositoryNames.toolTip = Settings.showReposInNameHelp
		hideAvatars.toolTip = Settings.hideAvatarsHelp
		showSeparateApiServersInMenu.toolTip = Settings.showSeparateApiServersInMenuHelp
		hideCountsOnMenubar.toolTip = Settings.hideMenubarCountsHelp
		sortModeSelect.toolTip = Settings.sortMethodHelp
		sortingOrder.toolTip = Settings.sortDescendingHelp
		groupByRepo.toolTip = Settings.groupByRepoHelp
		assignedPrHandlingPolicy.toolTip = Settings.assignedPrHandlingPolicyHelp
		includeTitlesInFiltering.toolTip = Settings.includeTitlesInFilterHelp
		includeMilestonesInFiltering.toolTip = Settings.includeMilestonesInFilterHelp
		includeAssigneeNamesInFiltering.toolTip = Settings.includeAssigneeInFilterHelp
		includeLabelsInFiltering.toolTip = Settings.includeLabelsInFilterHelp
		includeRepositoriesInFiltering.toolTip = Settings.includeReposInFilterHelp
		includeServersInFiltering.toolTip = Settings.includeServersInFilterHelp
		includeStatusesInFiltering.toolTip = Settings.includeStatusesInFilterHelp
		includeUsersInFiltering.toolTip = Settings.includeUsersInFilterHelp
		includeNumbersInFiltering.toolTip = Settings.includeNumbersInFilterHelp
		grayOutWhenRefreshing.toolTip = Settings.grayOutWhenRefreshingHelp
		refreshItemsLabel.toolTip = Settings.refreshPeriodHelp
		refreshDurationStepper.toolTip = Settings.refreshPeriodHelp
		prMergedPolicy.toolTip = Settings.mergeHandlingPolicyHelp
		prClosedPolicy.toolTip = Settings.closeHandlingPolicyHelp
		dontKeepPrsMergedByMe.toolTip = Settings.dontKeepPrsMergedByMeHelp
		removeNotificationsWhenItemIsRemoved.toolTip = Settings.removeNotificationsWhenItemIsRemovedHelp
		dontConfirmRemoveAllClosed.toolTip = Settings.dontAskBeforeWipingClosedHelp
		dontConfirmRemoveAllMerged.toolTip = Settings.dontAskBeforeWipingMergedHelp
		showAllComments.toolTip = Settings.showCommentsEverywhereHelp
		hideUncommentedPrs.toolTip = Settings.hideUncommentedItemsHelp
		openPrAtFirstUnreadComment.toolTip = Settings.openPrAtFirstUnreadCommentHelp
		assumeCommentsBeforeMineAreRead.toolTip = Settings.assumeReadItemIfUserHasNewerCommentsHelp
		disableAllCommentNotifications.toolTip = Settings.disableAllCommentNotificationsHelp
		showStatusItems.toolTip = Settings.showStatusItemsHelp
		statusItemRefreshCounter.toolTip = Settings.statusItemRefreshIntervalHelp
		statusItemRescanLabel.toolTip = Settings.statusItemRefreshIntervalHelp
		makeStatusItemsSelectable.toolTip = Settings.makeStatusItemsSelectableHelp
		notifyOnStatusUpdates.toolTip = Settings.notifyOnStatusUpdatesHelp
		notifyOnStatusUpdatesForAllPrs.toolTip = Settings.notifyOnStatusUpdatesForAllPrsHelp
		hidePrsThatDontPass.toolTip = Settings.hidePrsThatArentPassingHelp
		hidePrsThatDontPassOnlyInAll.toolTip = Settings.hidePrsThatDontPassOnlyInAllHelp
		showStatusesForAll.toolTip = Settings.showStatusesOnAllItemsHelp
		statusTermMenu.toolTip = Settings.statusFilteringTermsHelp
		logActivityToConsole.toolTip = Settings.logActivityToConsoleHelp
		dumpApiResponsesToConsole.toolTip = Settings.dumpAPIResponsesInConsoleHelp
		checkForUpdatesAutomatically.toolTip = Settings.checkForUpdatesAutomaticallyHelp
		snoozeWakeOnStatusUpdate.toolTip = Settings.snoozeWakeOnStatusUpdateHelp
		snoozeWakeOnMention.toolTip = Settings.snoozeWakeOnMentionHelp
		snoozeWakeOnComment.toolTip = Settings.snoozeWakeOnCommentHelp
		hideSnoozedItems.toolTip = Settings.hideSnoozedItemsHelp
		autoSnoozeSelector.toolTip = Settings.autoSnoozeDurationHelp
		autoSnoozeLabel.toolTip = Settings.autoSnoozeDurationHelp
		newMentionMovePolicy.toolTip = Settings.newMentionMovePolicyHelp
		teamMentionMovePolicy.toolTip = Settings.teamMentionMovePolicyHelp
		newItemInOwnedRepoMovePolicy.toolTip = Settings.newItemInOwnedRepoMovePolicyHelp
		notifyOnAllChangeRequests.toolTip = Settings.notifyOnAllReviewChangeRequestsHelp
		notifyOnChangeRequests.toolTip = Settings.notifyOnReviewChangeRequestsHelp
		notifyOnAllAcceptances.toolTip = Settings.notifyOnAllReviewChangeRequestsHelp
		notifyOnAcceptances.toolTip = Settings.notifyOnReviewAcceptancesHelp
		notifyOnAllAcceptances.toolTip = Settings.notifyOnAllReviewAcceptancesHelp
		notifyOnReviewDismissals.toolTip = Settings.notifyOnReviewDismissalsHelp
		notifyOnAllReviewDismissals.toolTip = Settings.notifyOnAllReviewDismissalsHelp
		notifyOnReviewAssignments.toolTip = Settings.notifyOnReviewAssignmentsHelp
		assignedReviewHandlingPolicy.toolTip = Settings.assignedReviewHandlingPolicyHelp
		supportReviews.toolTip = Settings.displayReviewsOnItemsHelp
		notifyOnItemReactions.toolTip = Settings.notifyOnItemReactionsHelp
		notifyOnCommentReactions.toolTip = Settings.notifyOnCommentReactionsHelp
		showLabels.toolTip = Settings.showLabelsHelp
		reactionIntervalLabel.toolTip = Settings.reactionScanningIntervalHelp
		reactionIntervalStepper.toolTip = Settings.reactionScanningIntervalHelp
		showRelativeDates.toolTip = Settings.showRelativeDatesHelp
		displayMilestones.toolTip = Settings.showMilestonesHelp
	}

	private func updateAllItemSettingButtons() {

		allPrsSetting.removeAllItems()
		allIssuesSetting.removeAllItems()
		allHidingSetting.removeAllItems()

		if projectsTable.selectedRowIndexes.count > 1 {
			allPrsSetting.addItem(withTitle: "Set selected PRs…")
			allIssuesSetting.addItem(withTitle: "Set selected issues…")
			allHidingSetting.addItem(withTitle: "Set selected hiding…")
		} else if !repoFilter.stringValue.isEmpty {
			allPrsSetting.addItem(withTitle: "Set filtered PRs…")
			allIssuesSetting.addItem(withTitle: "Set filtered issues…")
			allHidingSetting.addItem(withTitle: "Set filtered hiding…")
		} else {
			allPrsSetting.addItem(withTitle: "Set all PRs…")
			allIssuesSetting.addItem(withTitle: "Set all issues…")
			allHidingSetting.addItem(withTitle: "Set all hiding…")
		}

		allPrsSetting.addItems(withTitles: RepoDisplayPolicy.labels)
		allIssuesSetting.addItems(withTitles: RepoDisplayPolicy.labels)
		allHidingSetting.addItems(withTitles: RepoHidingPolicy.labels)
	}

	func reloadSettings() {
		let firstRow = IndexSet(integer: 0)
		serverList.selectRowIndexes(firstRow, byExtendingSelection: false)
		fillServerApiFormFromSelectedServer()
		fillSnoozeFormFromSelectedPreset()

		API.updateLimitsFromServer()
		updateStatusTermPreferenceControls()
		commentAuthorBlacklist.objectValue = Settings.commentAuthorBlacklist

		setupSortMethodMenu()
		sortModeSelect.selectItem(at: Settings.sortMethod)

		prMergedPolicy.selectItem(at: Settings.mergeHandlingPolicy)
		prClosedPolicy.selectItem(at: Settings.closeHandlingPolicy)

		launchAtStartup.integerValue = StartupLaunch.isAppLoginItem ? 1 : 0
		dontConfirmRemoveAllClosed.integerValue = Settings.dontAskBeforeWipingClosed ? 1 : 0
		displayRepositoryNames.integerValue = Settings.showReposInName ? 1 : 0
		includeRepositoriesInFiltering.integerValue = Settings.includeReposInFilter ? 1 : 0
		includeLabelsInFiltering.integerValue = Settings.includeLabelsInFilter ? 1 : 0
		includeTitlesInFiltering.integerValue = Settings.includeTitlesInFilter ? 1 : 0
		includeMilestonesInFiltering.integerValue = Settings.includeMilestonesInFilter ? 1 : 0
		includeAssigneeNamesInFiltering.integerValue = Settings.includeAssigneeNamesInFilter ? 1 : 0
		includeUsersInFiltering.integerValue = Settings.includeUsersInFilter ? 1 : 0
		includeNumbersInFiltering.integerValue = Settings.includeNumbersInFilter ? 1 : 0
		includeServersInFiltering.integerValue = Settings.includeServersInFilter ? 1 : 0
		includeStatusesInFiltering.integerValue = Settings.includeStatusesInFilter ? 1 : 0
		dontConfirmRemoveAllMerged.integerValue = Settings.dontAskBeforeWipingMerged ? 1 : 0
		hideUncommentedPrs.integerValue = Settings.hideUncommentedItems ? 1 : 0
		assumeCommentsBeforeMineAreRead.integerValue = Settings.assumeReadItemIfUserHasNewerComments ? 1 : 0
		hideAvatars.integerValue = Settings.hideAvatars ? 1 : 0
		hideCountsOnMenubar.integerValue = Settings.hideMenubarCounts ? 1 : 0
		showSeparateApiServersInMenu.integerValue = Settings.showSeparateApiServersInMenu ? 1 : 0
		dontKeepPrsMergedByMe.integerValue = Settings.dontKeepPrsMergedByMe ? 1 : 0
		removeNotificationsWhenItemIsRemoved.integerValue = Settings.removeNotificationsWhenItemIsRemoved ? 1 : 0
		grayOutWhenRefreshing.integerValue = Settings.grayOutWhenRefreshing ? 1 : 0
		notifyOnStatusUpdates.integerValue = Settings.notifyOnStatusUpdates ? 1 : 0
		notifyOnStatusUpdatesForAllPrs.integerValue = Settings.notifyOnStatusUpdatesForAllPrs ? 1 : 0
		disableAllCommentNotifications.integerValue = Settings.disableAllCommentNotifications ? 1 : 0
		showAllComments.integerValue = Settings.showCommentsEverywhere ? 1 : 0
		sortingOrder.integerValue = Settings.sortDescending ? 1 : 0
		showCreationDates.integerValue = Settings.showCreatedInsteadOfUpdated ? 1 : 0
		groupByRepo.integerValue = Settings.groupByRepo ? 1 : 0
		assignedPrHandlingPolicy.selectItem(at: Settings.assignedPrHandlingPolicy)
		showStatusItems.integerValue = Settings.showStatusItems ? 1 : 0
		makeStatusItemsSelectable.integerValue = Settings.makeStatusItemsSelectable ? 1 : 0
		countOnlyListedItems.integerValue = Settings.countOnlyListedItems ? 0 : 1
		openPrAtFirstUnreadComment.integerValue = Settings.openPrAtFirstUnreadComment ? 1 : 0
		logActivityToConsole.integerValue = Settings.logActivityToConsole ? 1 : 0
		dumpApiResponsesToConsole.integerValue = Settings.dumpAPIResponsesInConsole ? 1 : 0
		hidePrsThatDontPass.integerValue = Settings.hidePrsThatArentPassing ? 1 : 0
		hidePrsThatDontPassOnlyInAll.integerValue = Settings.hidePrsThatDontPassOnlyInAll ? 1 : 0
		showStatusesForAll.integerValue = Settings.showStatusesOnAllItems ? 1 : 0
		highlightItemsWithNewCommits.integerValue = Settings.markPrsAsUnreadOnNewCommits ? 1 : 0
		hideSnoozedItems.integerValue = Settings.hideSnoozedItems ? 1 : 0
		showLabels.integerValue = Settings.showLabels ? 1 : 0
		showRelativeDates.integerValue = Settings.showRelativeDates ? 1 : 0
		displayMilestones.integerValue = Settings.showMilestones ? 1 : 0

		defaultOpenApp.stringValue = Settings.defaultAppForOpeningItems
		defaultOpenLinks.stringValue = Settings.defaultAppForOpeningWeb

		notifyOnItemReactions.integerValue = Settings.notifyOnItemReactions ? 1 : 0
		notifyOnCommentReactions.integerValue = Settings.notifyOnCommentReactions ? 1 : 0

		supportReviews.integerValue = Settings.displayReviewsOnItems ? 1 : 0
		notifyOnReviewAssignments.integerValue = Settings.notifyOnReviewAssignments ? 1 : 0

		allNewPrsSetting.selectItem(at: Settings.displayPolicyForNewPrs)
		allNewIssuesSetting.selectItem(at: Settings.displayPolicyForNewIssues)

		newMentionMovePolicy.selectItem(at: Settings.newMentionMovePolicy)
		teamMentionMovePolicy.selectItem(at: Settings.teamMentionMovePolicy)
		newItemInOwnedRepoMovePolicy.selectItem(at: Settings.newItemInOwnedRepoMovePolicy)

		hotkeyEnable.integerValue = Settings.hotkeyEnable ? 1 : 0
		hotkeyControlModifier.integerValue = Settings.hotkeyControlModifier ? 1 : 0
		hotkeyCommandModifier.integerValue = Settings.hotkeyCommandModifier ? 1 : 0
		hotkeyOptionModifier.integerValue = Settings.hotkeyOptionModifier ? 1 : 0
		hotkeyShiftModifier.integerValue = Settings.hotkeyShiftModifier ? 1 : 0

		assignedReviewHandlingPolicy.select(assignedReviewHandlingPolicy.item(at: Settings.assignedReviewHandlingPolicy))

		enableHotkeySegments()

		hotkeyLetter.addItems(withTitles: ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"])
		hotkeyLetter.selectItem(withTitle: Settings.hotkeyLetter)

		refreshUpdatePreferences()
		updateStatusItemsOptions()
		updateReactionItemOptions()
		updateHistoryOptions()

		hotkeyEnable.isEnabled = true

		refreshDurationStepper.floatValue = min(Settings.refreshPeriod, 3600)
		refreshDurationChanged(nil)

		updateImportExportSettings()

		updateReviewOptions()

		updateActivity()
	}

	func updateActivity() {
		if appIsRefreshing {
			projectsTable.isEnabled = false
			allPrsSetting.isEnabled = false
			allIssuesSetting.isEnabled = false
		} else {
			projectsTable.isEnabled = true
			allPrsSetting.isEnabled = true
			allIssuesSetting.isEnabled = true
			reloadRepositories()
		}
		advancedReposWindow?.updateActivity()
	}


	@IBAction private func displayMilestonesSelected(_ sender: NSButton) {
		Settings.showMilestones = sender.integerValue == 1
		deferredUpdateTimer.push()
	}

	@IBAction private func showRelativeDatesSelected(_ sender: NSButton) {
		Settings.showRelativeDates = sender.integerValue == 1
		deferredUpdateTimer.push()
	}

	@IBAction private func notifyOnItemReactionsSelected(_ sender: NSButton) {
		Settings.notifyOnItemReactions = sender.integerValue == 1
		API.refreshesSinceLastReactionsCheck.removeAll()
		updateReactionItemOptions()
		DataManager.postProcessAllItems()
		deferredUpdateTimer.push()
	}

	@IBAction private func notifyOnCommentReactionsSelected(_ sender: NSButton) {
		Settings.notifyOnCommentReactions = sender.integerValue == 1
		API.refreshesSinceLastReactionsCheck.removeAll()
		updateReactionItemOptions()
		DataManager.postProcessAllItems()
		deferredUpdateTimer.push()
	}

	@IBAction private func newMentionMovePolicySelected(_ sender: NSPopUpButton) {
		Settings.newMentionMovePolicy = sender.indexOfSelectedItem
		DataManager.postProcessAllItems()
		deferredUpdateTimer.push()
	}
	@IBAction private func teamMentionMovePolicySelected(_ sender: NSPopUpButton) {
		Settings.teamMentionMovePolicy = sender.indexOfSelectedItem
		DataManager.postProcessAllItems()
		deferredUpdateTimer.push()
	}
	@IBAction private func newItemInOwnedRepoMovePolicySelected(_ sender: NSPopUpButton) {
		Settings.newItemInOwnedRepoMovePolicy = sender.indexOfSelectedItem
		DataManager.postProcessAllItems()
		deferredUpdateTimer.push()
	}

	@IBAction private func dontConfirmRemoveAllMergedSelected(_ sender: NSButton) {
		Settings.dontAskBeforeWipingMerged = (sender.integerValue==1)
	}

	@IBAction private func displayRepositoryNameSelected(_ sender: NSButton) {
		Settings.showReposInName = (sender.integerValue==1)
		deferredUpdateTimer.push()
	}

	@IBAction private func showLabelsSelected(_ sender: NSButton) {
		let wasOff = Settings.showLabels
		Settings.showLabels = sender.integerValue == 1
		if wasOff && Settings.showLabels {
			ApiServer.resetSyncOfEverything()
			preferencesDirty = true
			showLongSyncWarning()
		}
		deferredUpdateTimer.push()
	}

	@IBAction private func logActivityToConsoleSelected(_ sender: NSButton) {
		Settings.logActivityToConsole = (sender.integerValue==1)
		logActivityToConsole.integerValue = Settings.logActivityToConsole ? 1 : 0
		if Settings.logActivityToConsole {
			let alert = NSAlert()
			alert.messageText = "Warning"
			#if DEBUG
				alert.informativeText = "Sorry, logging is always active in development versions"
			#else
				alert.informativeText = "Logging is a feature meant for error reporting, having it constantly enabled will cause this app to be less responsive, use more power, and constitute a security risk"
			#endif
			alert.addButton(withTitle: "OK")
			alert.beginSheetModal(for: self, completionHandler: nil)
		}
	}

	@IBAction private func selectDefaultAppSelected(_ sender: NSButton) {
		let o = NSOpenPanel()
		o.title = "Select Application…"
		o.prompt = "Select"
		o.nameFieldLabel = "Application"
		o.message = "Select Application For Opening Items…"
		o.isExtensionHidden = true
		o.allowedFileTypes = ["app"]
		o.beginSheetModal(for: self) { [weak self] response in
			if response.rawValue == NSFileHandlingPanelOKButton, let url = o.url {
				Settings.defaultAppForOpeningItems = url.path
				self?.defaultOpenApp.stringValue = url.path
			}
		}
	}

	@IBAction private func selectDefaultLinkSelected(_ sender: NSButton) {
		let o = NSOpenPanel()
		o.title = "Select Application…"
		o.prompt = "Select"
		o.nameFieldLabel = "Application"
		o.message = "Select Application For Opening Web Links…"
		o.isExtensionHidden = true
		o.allowedFileTypes = ["app"]
		o.beginSheetModal(for: self) { [weak self] response in
			if response.rawValue == NSFileHandlingPanelOKButton, let url = o.url {
				Settings.defaultAppForOpeningWeb = url.path
				self?.defaultOpenLinks.stringValue = url.path
			}
		}
	}


	@IBAction private func dumpApiResponsesToConsoleSelected(_ sender: NSButton) {
		Settings.dumpAPIResponsesInConsole = (sender.integerValue==1)
		if Settings.dumpAPIResponsesInConsole {
			let alert = NSAlert()
			alert.messageText = "Warning"
			alert.informativeText = "This is a feature meant for error reporting, having it constantly enabled will cause this app to be less responsive, use more power, and constitute a security risk"
			alert.addButton(withTitle: "OK")
			alert.beginSheetModal(for: self, completionHandler: nil)
		}
	}

	@IBAction private func includeServersInFilteringSelected(_ sender: NSButton) {
		Settings.includeServersInFilter = (sender.integerValue==1)
		deferredUpdateTimer.push()
	}

	@IBAction private func includeNumbersInFilteringSelected(_ sender: NSButton) {
		Settings.includeNumbersInFilter = (sender.integerValue==1)
		deferredUpdateTimer.push()
	}

	@IBAction private func includeUsersInFilteringSelected(_ sender: NSButton) {
		Settings.includeUsersInFilter = (sender.integerValue==1)
		deferredUpdateTimer.push()
	}

	@IBAction private func includeLabelsInFilteringSelected(_ sender: NSButton) {
		Settings.includeLabelsInFilter = (sender.integerValue==1)
		deferredUpdateTimer.push()
	}

	@IBAction private func includeStatusesInFilteringSelected(_ sender: NSButton) {
		Settings.includeStatusesInFilter = (sender.integerValue==1)
		deferredUpdateTimer.push()
	}

	@IBAction private func includeTitlesInFilteringSelected(_ sender: NSButton) {
		Settings.includeTitlesInFilter = (sender.integerValue==1)
		deferredUpdateTimer.push()
	}

	@IBAction private func includeMilestonesInFilteringSelected(_ sender: NSButton) {
		Settings.includeMilestonesInFilter = (sender.integerValue==1)
		deferredUpdateTimer.push()
	}

	@IBAction private func includeAssigneeNamesInFilteringSelected(_ sender: NSButton) {
		Settings.includeAssigneeNamesInFilter = (sender.integerValue==1)
		deferredUpdateTimer.push()
	}

	@IBAction private func includeRepositoriesInfilterSelected(_ sender: NSButton) {
		Settings.includeReposInFilter = (sender.integerValue==1)
		deferredUpdateTimer.push()
	}

	@IBAction private func dontConfirmRemoveAllClosedSelected(_ sender: NSButton) {
		Settings.dontAskBeforeWipingClosed = (sender.integerValue==1)
	}

	@IBAction private func assumeAllCommentsBeforeMineAreReadSelected(_ sender: NSButton) {
		Settings.assumeReadItemIfUserHasNewerComments = (sender.integerValue==1)
		DataManager.postProcessAllItems()
		deferredUpdateTimer.push()
	}

	@IBAction private func removeNotificationsWhenItemIsRemovedSelected(_ sender: NSButton) {
		Settings.removeNotificationsWhenItemIsRemoved = (sender.integerValue==1)
	}

	@IBAction private func dontKeepMyPrsSelected(_ sender: NSButton) {
		Settings.dontKeepPrsMergedByMe = (sender.integerValue==1)
		updateHistoryOptions()
	}

	private func updateHistoryOptions() {
		dontKeepPrsMergedByMe.isEnabled = Settings.mergeHandlingPolicy != HandlingPolicy.keepNone.rawValue
	}

	@IBAction private func highlightItemsWithNewCommitsSelected(_ sender: NSButton) {
		Settings.markPrsAsUnreadOnNewCommits = (sender.integerValue==1)
	}

	@IBAction private func grayOutWhenRefreshingSelected(_ sender: NSButton) {
		Settings.grayOutWhenRefreshing = (sender.integerValue==1)
	}

	@IBAction private func disableAllCommentNotificationsSelected(_ sender: NSButton) {
		Settings.disableAllCommentNotifications = (sender.integerValue==1)
	}

	@IBAction private func notifyOnStatusUpdatesSelected(_ sender: NSButton) {
		Settings.notifyOnStatusUpdates = (sender.integerValue==1)
		updateStatusItemsOptions()
	}

	@IBAction private func notifyOnStatusUpdatesOnAllPrsSelected(_ sender: NSButton) {
		Settings.notifyOnStatusUpdatesForAllPrs = (sender.integerValue==1)
	}

	@IBAction private func hidePrsThatDontPassOnlyInAllSelected(_ sender: NSButton) {
		Settings.hidePrsThatDontPassOnlyInAll = (sender.integerValue==1)
		DataManager.postProcessAllItems()
		deferredUpdateTimer.push()
	}

	@IBAction private func showStatusesForAllSelected(_ sender: NSButton) {
		Settings.showStatusesOnAllItems = (sender.integerValue==1)
		deferredUpdateTimer.push()
		if Settings.showStatusItems {
			API.refreshesSinceLastStatusCheck.removeAll()
			preferencesDirty = true
		}
	}

	@IBAction private func hidePrsThatDontPassSelected(_ sender: NSButton) {
		Settings.hidePrsThatArentPassing = (sender.integerValue==1)
		updateStatusItemsOptions()
		DataManager.postProcessAllItems()
		deferredUpdateTimer.push()
	}

	@IBAction private func hideAvatarsSelected(_ sender: NSButton) {
		Settings.hideAvatars = (sender.integerValue==1)
		DataManager.postProcessAllItems()
		deferredUpdateTimer.push()
	}

	@IBAction private func showSeparateApiServersInMenuSelected(_ sender: NSButton) {
		Settings.showSeparateApiServersInMenu = (sender.integerValue==1)
		serversDirty = true
		deferredUpdateTimer.push()
	}

	private var affectedReposFromSelection: [Repo] {
		let selectedRows = projectsTable.selectedRowIndexes
		var affectedRepos = [Repo]()
		if selectedRows.count > 1 {
			for row in selectedRows {
				affectedRepos.append(repos[row])
			}
		} else {
			affectedRepos = repos
		}
		return affectedRepos
	}

	@IBAction private func allPrsPolicySelected(_ sender: NSPopUpButton) {
		let index = Int64(sender.indexOfSelectedItem - 1)
		if index < 0 { return }

		for r in affectedReposFromSelection {
			r.displayPolicyForPrs = index
			if index != RepoDisplayPolicy.hide.rawValue { r.resetSyncState() }
		}
		reloadRepositories()
		sender.selectItem(at: 0)
		updateDisplayIssuesSetting()
	}

	@IBAction private func allIssuesPolicySelected(_ sender: NSPopUpButton) {
		let index = Int64(sender.indexOfSelectedItem - 1)
		if index < 0 { return }

		for r in affectedReposFromSelection {
			r.displayPolicyForIssues = index
			if index != RepoDisplayPolicy.hide.rawValue { r.resetSyncState() }
		}
		reloadRepositories()
		sender.selectItem(at: 0)
		updateDisplayIssuesSetting()
	}

	@IBAction private func allHidingPolicySelected(_ sender: NSPopUpButton) {
		let index = Int64(sender.indexOfSelectedItem - 1)
		if index < 0 { return }

		for r in affectedReposFromSelection {
			r.itemHidingPolicy = index
		}
		reloadRepositories()
		sender.selectItem(at: 0)
		updateDisplayIssuesSetting()
	}

	private func updateDisplayIssuesSetting() {
		DataManager.postProcessAllItems()
		preferencesDirty = true
		serversDirty = true
		deferredUpdateTimer.push()
	}

	@IBAction private func allNewPrsPolicySelected(_ sender: NSPopUpButton) {
		Settings.displayPolicyForNewPrs = sender.indexOfSelectedItem
	}

	@IBAction private func allNewIssuesPolicySelected(_ sender: NSPopUpButton) {
		Settings.displayPolicyForNewIssues = sender.indexOfSelectedItem
	}

	@IBAction private func hideUncommentedRequestsSelected(_ sender: NSButton) {
		Settings.hideUncommentedItems = (sender.integerValue==1)
		DataManager.postProcessAllItems()
		deferredUpdateTimer.push()
	}

	@IBAction private func showAllCommentsSelected(_ sender: NSButton) {
		Settings.showCommentsEverywhere = (sender.integerValue==1)
		DataManager.postProcessAllItems()
		deferredUpdateTimer.push()
	}

	@IBAction private func sortOrderSelected(_ sender: NSButton) {
		Settings.sortDescending = (sender.integerValue==1)
		setupSortMethodMenu()
		DataManager.postProcessAllItems()
		deferredUpdateTimer.push()
	}

	@IBAction private func countOnlyListedItemsSelected(_ sender: NSButton) {
		Settings.countOnlyListedItems = (sender.integerValue==0)
		DataManager.postProcessAllItems()
		deferredUpdateTimer.push()
	}

	@IBAction private func openPrAtFirstUnreadCommentSelected(_ sender: NSButton) {
		Settings.openPrAtFirstUnreadComment = (sender.integerValue==1)
	}

	@IBAction private func sortMethodChanged(_ sender: NSMenuItem) {
		Settings.sortMethod = sortModeSelect.indexOfSelectedItem
		DataManager.postProcessAllItems()
		deferredUpdateTimer.push()
	}

	@IBAction private func showStatusItemsSelected(_ sender: NSButton) {
		Settings.showStatusItems = (sender.integerValue==1)
		deferredUpdateTimer.push()
		updateStatusItemsOptions()

		if Settings.showStatusItems {
			API.refreshesSinceLastStatusCheck.removeAll()
			preferencesDirty = true
		}
	}

	private func setupSortMethodMenu() {
		let m = NSMenu(title: "Sorting")
		for t in Settings.sortDescending ? SortingMethod.reverseTitles : SortingMethod.normalTitles {
			m.addItem(withTitle: t, action: #selector(sortMethodChanged), keyEquivalent: "")
		}
		sortModeSelect.menu = m
		sortModeSelect.selectItem(at: Settings.sortMethod)
	}

	private func updateStatusItemsOptions() {
		let enable = Settings.showStatusItems
		makeStatusItemsSelectable.isEnabled = enable
		notifyOnStatusUpdates.isEnabled = enable
		notifyOnStatusUpdatesForAllPrs.isEnabled = enable
		statusTermMenu.isEnabled = enable
		statusItemRefreshCounter.isEnabled = enable
		statusItemRescanLabel.alphaValue = enable ? 1.0 : 0.5
		statusItemsRefreshNote.alphaValue = enable ? 1.0 : 0.5
		hidePrsThatDontPass.alphaValue = enable ? 1.0 : 0.5
		hidePrsThatDontPass.isEnabled = enable
		showStatusesForAll.isEnabled = enable
		hidePrsThatDontPassOnlyInAll.isEnabled = enable && Settings.hidePrsThatArentPassing
		notifyOnStatusUpdatesForAllPrs.isEnabled = enable && Settings.notifyOnStatusUpdates

		let count = Settings.statusItemRefreshInterval
		statusItemRefreshCounter.integerValue = count
		statusItemRescanLabel.stringValue = count>1 ? "…and re-scan once every \(count) refreshes" : "…and re-scan on every refresh"

		updateStatusTermPreferenceControls()
	}

	private func updateReactionItemOptions() {
		let count = Settings.reactionScanningInterval
		reactionIntervalStepper.integerValue = count
		reactionIntervalLabel.stringValue = count>1 ? "Re-scan all reaction-related items every \(count) refreshes" : "Re-scan all reaction-related items on every refresh"
		let enabled = API.shouldSyncReactions
		reactionIntervalStepper.isEnabled = enabled
		reactionIntervalLabel.isEnabled = enabled
		reactionIntervalLabel.textColor = enabled ? NSColor.labelColor : NSColor.disabledControlTextColor
	}

	@IBAction private func reactionIntervalCountChanged(_ sender: NSStepper) {
		Settings.reactionScanningInterval = sender.integerValue
		updateReactionItemOptions()
	}

	@IBAction private func statusItemRefreshCountChanged(_ sender: NSStepper) {
		Settings.statusItemRefreshInterval = sender.integerValue
		updateStatusItemsOptions()
	}

	@IBAction private func makeStatusItemsSelectableSelected(_ sender: NSButton) {
		Settings.makeStatusItemsSelectable = (sender.integerValue==1)
		deferredUpdateTimer.push()
	}

	@IBAction private func hideCountsOnMenubarSelected(_ sender: NSButton) {
		Settings.hideMenubarCounts = (sender.integerValue==1)
		serversDirty = true
		deferredUpdateTimer.push()
	}

	@IBAction private func showCreationSelected(_ sender: NSButton) {
		Settings.showCreatedInsteadOfUpdated = (sender.integerValue==1)
		DataManager.postProcessAllItems()
		deferredUpdateTimer.push()
	}

	@IBAction private func groupbyRepoSelected(_ sender: NSButton) {
		Settings.groupByRepo = (sender.integerValue==1)
		deferredUpdateTimer.push()
	}

	@IBAction private func assignedPrHandlingPolicySelected(_ sender: NSPopUpButton) {
		Settings.assignedPrHandlingPolicy = sender.indexOfSelectedItem
		DataManager.postProcessAllItems()
		deferredUpdateTimer.push()
	}

	@IBAction private func checkForUpdatesAutomaticallySelected(_ sender: NSButton) {
		Settings.checkForUpdatesAutomatically = (sender.integerValue==1)
		refreshUpdatePreferences()
	}

	private func refreshUpdatePreferences() {
		let setting = Settings.checkForUpdatesAutomatically
		let interval = Settings.checkForUpdatesInterval

		checkForUpdatesLabel.isHidden = !setting
		checkForUpdatesSelector.isHidden = !setting

		checkForUpdatesSelector.integerValue = interval
		checkForUpdatesAutomatically.integerValue = setting ? 1 : 0
		checkForUpdatesLabel.stringValue = interval<2 ? "Check every hour" : "Check every \(interval) hours"
	}

	@IBAction private func checkForUpdatesIntervalChanged(_ sender: NSStepper) {
		Settings.checkForUpdatesInterval = sender.integerValue
		refreshUpdatePreferences()
	}

	@IBAction private func launchAtStartSelected(_ sender: NSButton) {
		StartupLaunch.setLaunchOnLogin(sender.integerValue==1)
	}

	func refreshRepos() {
		app.prepareForRefresh()

		let tempContext = DataManager.buildChildContext()
		API.fetchRepositories(to: tempContext) {

			if ApiServer.shouldReportRefreshFailure(in: tempContext) {
				var errorServers = [String]()
				for apiServer in ApiServer.allApiServers(in: tempContext) {
					if apiServer.goodToGo && !apiServer.lastSyncSucceeded {
						errorServers.append(S(apiServer.label))
					}
				}

				let serverNames = errorServers.joined(separator: ", ")

				let alert = NSAlert()
				alert.messageText = "Error"
				alert.informativeText = "Could not refresh repository list from \(serverNames), please ensure that the tokens you are using are valid"
				alert.addButton(withTitle: "OK")
				alert.runModal()
			} else {
				do {
					try tempContext.save()
				} catch {
				}
			}
			DataItem.nukeDeletedItems(in: DataManager.main)
			app.completeRefresh()
		}
	}

	private var selectedServer: ApiServer? {
		let selected = serverList.selectedRow
		if selected >= 0 {
			return ApiServer.allApiServers(in: DataManager.main)[selected]
		}
		return nil
	}

	@IBAction private func deleteSelectedServerSelected(_ sender: NSButton) {
		if let selectedServer = selectedServer, let index = ApiServer.allApiServers(in: DataManager.main).index(of: selectedServer) {
			DataManager.main.delete(selectedServer)
			serverList.reloadData()
			serverList.selectRowIndexes(IndexSet(integer: min(index, serverList.numberOfRows-1)), byExtendingSelection: false)
			fillServerApiFormFromSelectedServer()
			serversDirty = true
			deferredUpdateTimer.push()
		}
	}

	@IBAction private func apiServerReportErrorSelected(_ sender: NSButton) {
		if let apiServer = selectedServer {
			apiServer.reportRefreshFailures = (sender.integerValue != 0)
			storeApiFormToSelectedServer()
		}
	}

	@objc private func updateImportExportSettings() {
		repeatLastExportAutomatically.integerValue = Settings.autoRepeatSettingsExport ? 1 : 0
		if let lastExportDate = Settings.lastExportDate, let fileName = Settings.lastExportUrl?.absoluteString, let unescapedName = fileName.removingPercentEncoding {
			let time = itemDateFormatter.string(from: lastExportDate)
			lastExportReport.stringValue = "Last exported \(time) to \(unescapedName)"
		} else {
			lastExportReport.stringValue = ""
		}
	}

	@IBAction private func repeatLastExportSelected(_ sender: NSButton) {
		Settings.autoRepeatSettingsExport = (repeatLastExportAutomatically.integerValue==1)
	}

	@IBAction private func exportCurrentSettingsSelected(_ sender: NSButton) {
		let s = NSSavePanel()
		s.title = "Export Current Settings…"
		s.prompt = "Export"
		s.nameFieldLabel = "Settings File"
		s.message = "Export Current Settings…"
		s.isExtensionHidden = false
		s.nameFieldStringValue = "Trailer Settings"
		s.allowedFileTypes = ["trailerSettings"]
		s.beginSheetModal(for: self) { response in
			if response.rawValue == NSFileHandlingPanelOKButton, let url = s.url {
				Settings.writeToURL(url)
				DLog("Exported settings to %@", url.absoluteString)
			}
		}
	}

	@IBAction private func importSettingsSelected(_ sender: NSButton) {
		let o = NSOpenPanel()
		o.title = "Import Settings From File…"
		o.prompt = "Import"
		o.nameFieldLabel = "Settings File"
		o.message = "Import Settings From File…"
		o.isExtensionHidden = false
		o.allowedFileTypes = ["trailerSettings"]
		o.beginSheetModal(for: self) { response in
			if response.rawValue == NSFileHandlingPanelOKButton, let url = o.url {
				atNextEvent {
					app.tryLoadSettings(from: url, skipConfirm: Settings.dontConfirmSettingsImport)
				}
			}
		}
	}

	private func color(button: NSButton, withColor: NSColor) {
		let title = button.attributedTitle.mutableCopy() as! NSMutableAttributedString
		title.addAttribute(NSAttributedStringKey.foregroundColor, value: withColor, range: NSRange(location: 0, length: title.length))
		button.attributedTitle = title
	}

	private func enableHotkeySegments() {
		if Settings.hotkeyEnable {
			color(button: hotkeyCommandModifier, withColor: Settings.hotkeyCommandModifier ? .controlTextColor : .disabledControlTextColor)
			color(button: hotkeyControlModifier, withColor: Settings.hotkeyControlModifier ? .controlTextColor : .disabledControlTextColor)
			color(button: hotkeyOptionModifier, withColor: Settings.hotkeyOptionModifier ? .controlTextColor : .disabledControlTextColor)
			color(button: hotkeyShiftModifier, withColor: Settings.hotkeyShiftModifier ? .controlTextColor : .disabledControlTextColor)
		}
		hotKeyContainer.isHidden = !Settings.hotkeyEnable
		hotKeyHelp.isHidden = Settings.hotkeyEnable
	}

	@IBAction private func enableHotkeySelected(_ sender: NSButton) {
		Settings.hotkeyEnable = hotkeyEnable.integerValue != 0
		Settings.hotkeyLetter = hotkeyLetter.titleOfSelectedItem ?? "T"
		Settings.hotkeyControlModifier = hotkeyControlModifier.integerValue != 0
		Settings.hotkeyCommandModifier = hotkeyCommandModifier.integerValue != 0
		Settings.hotkeyOptionModifier = hotkeyOptionModifier.integerValue != 0
		Settings.hotkeyShiftModifier = hotkeyShiftModifier.integerValue != 0
		enableHotkeySegments()
		app.addHotKeySupport()
	}

	private func reportNeedFrontEnd() {
		let alert = NSAlert()
		alert.messageText = "Please provide a full URL for the web front end of this server first"
		alert.addButton(withTitle: "OK")
		alert.runModal()
	}

	@IBAction private func createTokenSelected(_ sender: NSButton) {
		if apiServerWebPath.stringValue.isEmpty {
			reportNeedFrontEnd()
		} else {
			let address = "\(apiServerWebPath.stringValue)/settings/tokens/new"
			openLink(URL(string: address)!)
		}
	}

	@IBAction private func viewExistingTokensSelected(_ sender: NSButton) {
		if apiServerWebPath.stringValue.isEmpty {
			reportNeedFrontEnd()
		} else {
			let address = "\(apiServerWebPath.stringValue)/settings/tokens"
			openLink(URL(string: address)!)
		}
	}

	@IBAction private func viewWatchlistSelected(_ sender: NSButton) {
		if apiServerWebPath.stringValue.isEmpty {
			reportNeedFrontEnd()
		} else {
			let address = "\(apiServerWebPath.stringValue)/watching"
			openLink(URL(string: address)!)
		}
	}

	@IBAction private func prMergePolicySelected(_ sender: NSPopUpButton) {
		Settings.mergeHandlingPolicy = sender.indexOfSelectedItem
		updateHistoryOptions()
	}

	@IBAction private func prClosePolicySelected(_ sender: NSPopUpButton) {
		Settings.closeHandlingPolicy = sender.indexOfSelectedItem
	}

	private func updateStatusTermPreferenceControls() {
		let mode = Settings.statusFilteringMode
		statusTermMenu.selectItem(at: mode)
		if mode != 0 {
			statusTermsField.isEnabled = true
			statusTermsField.alphaValue = 1.0
		}
		else
		{
			statusTermsField.isEnabled = false
			statusTermsField.alphaValue = 0.5
		}
		statusTermsField.objectValue = Settings.statusFilteringTerms
	}

	@IBAction private func statusFilterMenuChanged(_ sender: NSPopUpButton) {
		Settings.statusFilteringMode = sender.indexOfSelectedItem
		Settings.statusFilteringTerms = statusTermsField.objectValue as! [String]
		updateStatusTermPreferenceControls()
		deferredUpdateTimer.push()
	}

	@IBAction private func testApiServerSelected(_ sender: NSButton) {
		sender.isEnabled = false
		let apiServer = selectedServer!
		API.testApi(to: apiServer) { error in
			let alert = NSAlert()
			if let e = error {
				alert.messageText = "The test failed for \(S(apiServer.apiPath))"
				alert.informativeText = e.localizedDescription
			} else {
				alert.messageText = "This API server seems OK!"
			}
			alert.addButton(withTitle: "OK")
			alert.runModal()
			sender.isEnabled = true
		}
	}

	@IBAction private func apiRestoreDefaultsSelected(_ sender: NSButton)
	{
		if let apiServer = selectedServer {
			apiServer.resetToGithub()
			fillServerApiFormFromSelectedServer()
			storeApiFormToSelectedServer()
		}
	}

	private func fillServerApiFormFromSelectedServer() {
		if let apiServer = selectedServer {
			apiServerName.stringValue = S(apiServer.label)
			apiServerWebPath.stringValue = S(apiServer.webPath)
			apiServerApiPath.stringValue = S(apiServer.apiPath)
			apiServerAuthToken.stringValue = S(apiServer.authToken)
			apiServerSelectedBox.title = apiServer.label ?? "New Server"
			apiServerTestButton.isEnabled = !S(apiServer.authToken).isEmpty
			apiServerDeleteButton.isEnabled = (ApiServer.countApiServers(in: DataManager.main) > 1)
			apiServerReportError.integerValue = apiServer.reportRefreshFailures ? 1 : 0
		}
	}

	private func storeApiFormToSelectedServer() {
		if let apiServer = selectedServer {
			apiServer.label = apiServerName.stringValue
			apiServer.apiPath = apiServerApiPath.stringValue
			apiServer.webPath = apiServerWebPath.stringValue
			apiServer.authToken = apiServerAuthToken.stringValue
			apiServerTestButton.isEnabled = !S(apiServer.authToken).isEmpty
			serverList.reloadData()
			serversDirty = true
			deferredUpdateTimer.push()
		}
	}

	@IBAction private func addNewApiServerSelected(_ sender: NSButton) {
		let a = ApiServer.insertNewServer(in: DataManager.main)
		a.label = "New API Server"
		serverList.reloadData()
		if let index = ApiServer.allApiServers(in: DataManager.main).index(of: a) {
			serverList.selectRowIndexes(IndexSet(integer: index), byExtendingSelection: false)
			fillServerApiFormFromSelectedServer()
		}
		serversDirty = true
		deferredUpdateTimer.push()
	}

	@IBAction private func refreshDurationChanged(_ sender: NSStepper?) {
		Settings.refreshPeriod = refreshDurationStepper.floatValue
		refreshDurationLabel.stringValue = "Refresh items every \(refreshDurationStepper.integerValue) seconds"
	}

	func windowWillClose(_ notification: Notification) {
		advancedReposWindow?.close()
		if ApiServer.someServersHaveAuthTokens(in: DataManager.main) && preferencesDirty {
			app.startRefresh()
		} else {
			if app.refreshTimer == nil && Settings.refreshPeriod > 0.0 {
				app.startRefreshIfItIsDue()
			}
		}
		app.setUpdateCheckParameters()
		app.closedPreferencesWindow()
	}

	override func controlTextDidChange(_ n: Notification) {
		if let obj = n.object as? NSTextField {

			if obj===defaultOpenLinks {
				Settings.defaultAppForOpeningWeb = defaultOpenLinks.stringValue.trim

			} else if obj===defaultOpenApp {
				Settings.defaultAppForOpeningItems = defaultOpenApp.stringValue.trim

			} else if obj===apiServerName {
				if let apiServer = selectedServer {
					apiServer.label = apiServerName.stringValue
					storeApiFormToSelectedServer()
				}
			} else if obj===apiServerApiPath {
				if let apiServer = selectedServer {
					apiServer.apiPath = apiServerApiPath.stringValue
					storeApiFormToSelectedServer()
					apiServer.clearAllRelatedInfo()
					reset()
				}
			} else if obj===apiServerWebPath {
				if let apiServer = selectedServer {
					apiServer.webPath = apiServerWebPath.stringValue
					storeApiFormToSelectedServer()
				}
			} else if obj===apiServerAuthToken {
				if let apiServer = selectedServer {
					apiServer.authToken = apiServerAuthToken.stringValue
					storeApiFormToSelectedServer()
					apiServer.clearAllRelatedInfo()
					reset()
				}
			} else if obj===repoFilter {
				reloadRepositories()
				updateAllItemSettingButtons()

			} else if obj===statusTermsField {
				let existingTokens = Settings.statusFilteringTerms
				let newTokens = statusTermsField.objectValue as! [String]
				if existingTokens != newTokens {
					Settings.statusFilteringTerms = newTokens
					deferredUpdateTimer.push()
				}
			} else if obj===commentAuthorBlacklist {
				let existingTokens = Settings.commentAuthorBlacklist
				let newTokens = commentAuthorBlacklist.objectValue as! [String]
				if existingTokens != newTokens {
					Settings.commentAuthorBlacklist = newTokens
				}
			}
		}
	}

	///////////// Tabs

	func tabView(_ tabView: NSTabView, willSelect tabViewItem: NSTabViewItem?) {
		if let item = tabViewItem {
			let newIndex = tabView.indexOfTabViewItem(item)
			if newIndex == 1 {
				if lastRepoCheck == .distantPast && DataManager.appIsConfigured {
					refreshRepos()
				}
			}
			Settings.lastPreferencesTabSelectedOSX = newIndex
		}
	}

	///////////// Repo table

	func tableViewSelectionDidChange(_ notification: Notification) {
		if let o = notification.object as? NSTableView {
			if serverList === o {
				fillServerApiFormFromSelectedServer()
			} else if projectsTable === o {
				updateAllItemSettingButtons()
			} else if snoozePresetsList === o {
				fillSnoozeFormFromSelectedPreset()
			}
		}
	}

	func tableView(_ tv: NSTableView, willDisplayCell c: Any, for tableColumn: NSTableColumn?, row: Int) {
		guard let tid = tableColumn?.identifier.rawValue else { return }
		let cell = c as! NSCell
		if tv === projectsTable {
			if tid == "repos" {
				cell.isEnabled = true
				let r = repos[row]
				let repoName = S(r.fullName)
				let title = r.inaccessible ? "\(repoName) (inaccessible)" : repoName
				let textColor = (row == tv.selectedRow) ? .selectedControlTextColor : (r.shouldSync ? .textColor : NSColor.textColor.withAlphaComponent(0.4))
				cell.attributedStringValue = NSAttributedString(string: title, attributes: [NSAttributedStringKey.foregroundColor: textColor])
			} else if let menuCell = cell as? NSTextFieldCell {
				if tableColumn?.identifier.rawValue == "group" {
					let r = repos[row]
					menuCell.isEnabled = true
					menuCell.placeholderString = "None"
					menuCell.stringValue = S(r.groupLabel)
				}
			} else if let menuCell = cell as? NSPopUpButtonCell {
				menuCell.removeAllItems()
				let r = repos[row]
				menuCell.isEnabled = true
				menuCell.arrowPosition = .arrowAtBottom

				var count = 0
				let fontSize = NSFont.systemFontSize(for: .small)
				if tid == "hide" {
					for policy in RepoHidingPolicy.policies {
						let m = NSMenuItem()
						m.attributedTitle = NSAttributedString(string: policy.name, attributes: [
							NSAttributedStringKey.font: count==0 ? NSFont.systemFont(ofSize: fontSize) : NSFont.boldSystemFont(ofSize: fontSize),
							NSAttributedStringKey.foregroundColor: policy.color,
							])
						menuCell.menu?.addItem(m)
						count += 1
					}
					menuCell.selectItem(at: Int(r.itemHidingPolicy))
				} else {
					for policy in RepoDisplayPolicy.policies {
						let m = NSMenuItem()
						m.attributedTitle = NSAttributedString(string: policy.name, attributes: [
							NSAttributedStringKey.font: count==0 ? NSFont.systemFont(ofSize: fontSize) : NSFont.boldSystemFont(ofSize: fontSize),
							NSAttributedStringKey.foregroundColor: policy.color,
							])
						menuCell.menu?.addItem(m)
						count += 1
					}
					let selectedIndex = Int(tableColumn?.identifier.rawValue == "prs" ? r.displayPolicyForPrs : r.displayPolicyForIssues)
					menuCell.selectItem(at: selectedIndex)
				}
			} else if let forkButton = cell as? NSButtonCell {
				if tid == "fork" {
					let r = repos[row]
					forkButton.integerValue = r.fork ? 1 : 0
				}
			}
		} else if tv == serverList {
			let allServers = ApiServer.allApiServers(in: DataManager.main)
			let apiServer = allServers[row]
			if tid == "server" {
				cell.title = S(apiServer.label)
				let tc = c as! NSTextFieldCell
				if apiServer.lastSyncSucceeded {
					tc.textColor = .textColor
				} else {
					tc.textColor = .red
				}
			} else { // api usage
				let c = cell as! NSLevelIndicatorCell
				c.minValue = 0
				let rl = Double(apiServer.requestsLimit)
				c.maxValue = rl
				c.warningValue = rl*0.5
				c.criticalValue = rl*0.8
				c.doubleValue = rl - Double(apiServer.requestsRemaining)
			}
		} else if tv == snoozePresetsList {
			let allPresets = SnoozePreset.allSnoozePresets(in: DataManager.main)
			let preset = allPresets[row]
			cell.title = preset.listDescription
			let tc = c as! NSTextFieldCell
			tc.textColor = .textColor
		}
	}

	func tableView(_ tableView: NSTableView, sortDescriptorsDidChange oldDescriptors: [NSSortDescriptor]) {
		reloadRepositories()
	}

	func numberOfRows(in tableView: NSTableView) -> Int {
		if tableView === projectsTable {
			return repos.count
		} else if tableView === serverList {
			return ApiServer.countApiServers(in: DataManager.main)
		} else if tableView === snoozePresetsList {
			return SnoozePreset.allSnoozePresets(in: DataManager.main).count
		}
		return 0
	}

	func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
		return nil
	}

	func tableView(_ tv: NSTableView, setObjectValue object: Any?, for tableColumn: NSTableColumn?, row: Int) {
		if tv === projectsTable {
			let r = repos[row]
			if tableColumn?.identifier.rawValue == "group" {
				let g = S(object as? String)
				r.groupLabel = g.isEmpty ? nil : g
				serversDirty = true
				deferredUpdateTimer.push()
			} else if let index = object as? Int64 {
				if tableColumn?.identifier.rawValue == "prs" {
					r.displayPolicyForPrs = index
				} else if tableColumn?.identifier.rawValue == "issues" {
					r.displayPolicyForIssues = index
				} else if tableColumn?.identifier.rawValue == "hide" {
					r.itemHidingPolicy = index
				}
				if index != RepoDisplayPolicy.hide.rawValue {
					r.resetSyncState()
				}
				updateDisplayIssuesSetting()
			}
		}
	}

	/////////////////////////////// snoozing

	@IBAction private func snoozeWakeChanged(_ sender: NSButton) {
		if let preset = selectedSnoozePreset {
			preset.wakeOnComment = snoozeWakeOnComment.integerValue == 1
			preset.wakeOnMention = snoozeWakeOnMention.integerValue == 1
			preset.wakeOnStatusChange = snoozeWakeOnStatusUpdate.integerValue == 1
			snoozePresetsList.reloadData()
			deferredUpdateTimer.push()
		}
	}

	@IBAction private func hideSnoozedItemsChanged(_ sender: NSButton) {
		Settings.hideSnoozedItems = hideSnoozedItems.integerValue == 1
		deferredUpdateTimer.push()
	}

	private func fillSnoozingDropdowns() {
		snoozeDurationDays.addItem(withTitle: "No Days")
		snoozeDurationHours.addItem(withTitle: "No Hours")
		snoozeDurationMinutes.addItem(withTitle: "No Minutes")

		snoozeDurationDays.addItem(withTitle: "1 Day")
		snoozeDurationHours.addItem(withTitle: "1 Hour")
		snoozeDurationMinutes.addItem(withTitle: "1 Minute")

		var titles = [String]()

		for f in 2..<400 {
			titles.append("\(f) Days")
		}
		snoozeDurationDays.addItems(withTitles: titles)
		titles.removeAll()
		for f in 2..<24 {
			titles.append("\(f) Hours")
		}
		snoozeDurationHours.addItems(withTitles: titles)
		titles.removeAll()
		for f in 2..<60 {
			titles.append("\(f) Minutes")
		}
		snoozeDurationMinutes.addItems(withTitles: titles)
		titles.removeAll()

		snoozeDateTimeDay.addItems(withTitles: ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"])
		for f in 0..<24 {
			titles.append(String(format: "%02d", f))
		}
		snoozeDateTimeHour.addItems(withTitles: titles)
		titles.removeAll()
		for f in 0..<60 {
			titles.append(String(format: "%02d", f))
		}
		snoozeDateTimeMinute.addItems(withTitles: titles)

		if Settings.autoSnoozeDuration == 0 {
			autoSnoozeLabel.stringValue = "Do not auto-snooze items"
			autoSnoozeLabel.textColor = .disabledControlTextColor
		} else if Settings.autoSnoozeDuration == 1 {
			autoSnoozeLabel.stringValue = "Automatically snooze any item that has been idle for longer than a day"
			autoSnoozeLabel.textColor = .controlTextColor
		} else {
			autoSnoozeLabel.stringValue = "Automatically snooze any item that has been idle for longer than \(Settings.autoSnoozeDuration) days"
			autoSnoozeLabel.textColor = .controlTextColor
		}
		autoSnoozeSelector.integerValue = Settings.autoSnoozeDuration
	}

	@IBAction private func autoSnoozeDurationChanged(_ sender: NSStepper) {
		Settings.autoSnoozeDuration = sender.integerValue
		fillSnoozingDropdowns()
		for p in DataItem.allItems(of: PullRequest.self, in: DataManager.main) {
			p.wakeIfAutoSnoozed()
		}
		for i in DataItem.allItems(of: Issue.self, in: DataManager.main) {
			i.wakeIfAutoSnoozed()
		}
		DataManager.postProcessAllItems()
		deferredUpdateTimer.push()
	}

	var selectedSnoozePreset: SnoozePreset? {
		let selected = snoozePresetsList.selectedRow
		if selected >= 0 {
			return SnoozePreset.allSnoozePresets(in: DataManager.main)[selected]
		}
		return nil
	}

	private func fillSnoozeFormFromSelectedPreset() {
		if let s = selectedSnoozePreset {
			if s.duration {
				snoozeTypeDuration.integerValue = 1
				snoozeTypeDateTime.integerValue = 0
				snoozeDurationMinutes.isEnabled = true
				snoozeDurationHours.isEnabled = true
				snoozeDurationDays.isEnabled = true
				snoozeDurationMinutes.selectItem(at: Int(s.minute))
				snoozeDurationHours.selectItem(at: Int(s.hour))
				snoozeDurationDays.selectItem(at: Int(s.day))
				snoozeDateTimeMinute.isEnabled = false
				snoozeDateTimeMinute.selectItem(at: 0)
				snoozeDateTimeHour.isEnabled = false
				snoozeDateTimeHour.selectItem(at: 0)
				snoozeDateTimeDay.isEnabled = false
				snoozeDateTimeDay.selectItem(at: 0)
			} else {
				snoozeTypeDuration.integerValue = 0
				snoozeTypeDateTime.integerValue = 1
				snoozeDurationMinutes.isEnabled = false
				snoozeDurationMinutes.selectItem(at: 0)
				snoozeDurationHours.isEnabled = false
				snoozeDurationHours.selectItem(at: 0)
				snoozeDurationDays.isEnabled = false
				snoozeDurationDays.selectItem(at: 0)
				snoozeDateTimeMinute.isEnabled = true
				snoozeDateTimeHour.isEnabled = true
				snoozeDateTimeDay.isEnabled = true
				snoozeDateTimeMinute.selectItem(at: Int(s.minute))
				snoozeDateTimeHour.selectItem(at: Int(s.hour))
				snoozeDateTimeDay.selectItem(at: Int(s.day))
			}
			snoozeWakeOnComment.isEnabled = true
			snoozeWakeOnComment.integerValue = s.wakeOnComment ? 1 : 0
			snoozeWakeOnMention.isEnabled = true
			snoozeWakeOnMention.integerValue = s.wakeOnMention ? 1 : 0
			snoozeWakeOnStatusUpdate.isEnabled = true
			snoozeWakeOnStatusUpdate.integerValue = s.wakeOnStatusChange ? 1 : 0
			snoozeWakeLabel.textColor = .controlTextColor
			snoozeTypeDuration.isEnabled = true
			snoozeTypeDateTime.isEnabled = true
			snoozeDeletePreset.isEnabled = true
			snoozeUp.isEnabled = true
			snoozeDown.isEnabled = true
		} else {
			snoozeTypeDuration.isEnabled = false
			snoozeTypeDateTime.isEnabled = false
			snoozeDateTimeMinute.isEnabled = false
			snoozeDateTimeHour.isEnabled = false
			snoozeDateTimeDay.isEnabled = false
			snoozeDurationMinutes.isEnabled = false
			snoozeDurationHours.isEnabled = false
			snoozeDurationDays.isEnabled = false
			snoozeDeletePreset.isEnabled = false
			snoozeUp.isEnabled = false
			snoozeDown.isEnabled = false
			snoozeWakeOnComment.isEnabled = false
			snoozeWakeOnComment.integerValue = 0
			snoozeWakeOnMention.isEnabled = false
			snoozeWakeOnMention.integerValue = 0
			snoozeWakeOnStatusUpdate.isEnabled = false
			snoozeWakeOnStatusUpdate.integerValue = 0
			snoozeWakeLabel.textColor = .disabledControlTextColor
		}
	}

	private func commitSnoozeSettings() {
		snoozePresetsList.reloadData()
		deferredUpdateTimer.push()
		Settings.possibleExport(nil)
	}

	@IBAction private func createNewSnoozePresetSelected(_ sender: NSButton) {
		let s = SnoozePreset.newSnoozePreset(in: DataManager.main)
		commitSnoozeSettings()
		if let index = SnoozePreset.allSnoozePresets(in: DataManager.main).index(of: s) {
			snoozePresetsList.selectRowIndexes(IndexSet(integer: index), byExtendingSelection: false)
			fillSnoozeFormFromSelectedPreset()
		}
	}

	@IBAction private func deleteSnoozePresetSelected(_ sender: NSButton) {
		if let selectedPreset = selectedSnoozePreset, let index = SnoozePreset.allSnoozePresets(in: DataManager.main).index(of: selectedPreset) {

			let appliedCount = selectedPreset.appliedToIssues.count + selectedPreset.appliedToPullRequests.count
			if appliedCount > 0 {
				let alert = NSAlert()
				alert.messageText = "Warning"
				alert.informativeText = "You have \(appliedCount) items that have been snoozed using this preset. What would you like to do with them?"
				alert.addButton(withTitle: "Cancel")
				alert.addButton(withTitle: "Wake Them Up")
				alert.addButton(withTitle: "Keep Them Snoozed")
				alert.beginSheetModal(for: self) { response in
					switch response {
					case .alertFirstButtonReturn:
						break
					case .alertSecondButtonReturn:
						selectedPreset.wakeUpAllAssociatedItems()
						fallthrough
					case .alertThirdButtonReturn:
						self.completeSnoozeDelete(for: selectedPreset, index)
					default: break
					}
				}
			} else {
				completeSnoozeDelete(for: selectedPreset, index)
			}
		}
	}

	private func completeSnoozeDelete(for selectedPreset: SnoozePreset, _ index: Int) {
		DataManager.main.delete(selectedPreset)
		commitSnoozeSettings()
		snoozePresetsList.selectRowIndexes(IndexSet(integer: min(index, snoozePresetsList.numberOfRows-1)), byExtendingSelection: false)
		fillSnoozeFormFromSelectedPreset()
	}

	@IBAction private func snoozeTypeChanged(_ sender: NSButton) {
		if let s = selectedSnoozePreset {
			s.duration = sender == snoozeTypeDuration
			fillSnoozeFormFromSelectedPreset()
			commitSnoozeSettings()
		}
	}

	@IBAction private func snoozeOptionsChanged(_ sender: NSPopUpButton) {
		if let s = selectedSnoozePreset {
			if s.duration {
				s.day = Int64(snoozeDurationDays.indexOfSelectedItem)
				s.hour = Int64(snoozeDurationHours.indexOfSelectedItem)
				s.minute = Int64(snoozeDurationMinutes.indexOfSelectedItem)
			} else {
				s.day = Int64(snoozeDateTimeDay.indexOfSelectedItem)
				s.hour = Int64(snoozeDateTimeHour.indexOfSelectedItem)
				s.minute = Int64(snoozeDateTimeMinute.indexOfSelectedItem)
			}
			commitSnoozeSettings()
		}
	}

	@IBAction private func snoozeUpSelected(_ sender: NSButton) {
		if let this = selectedSnoozePreset {
			let all = SnoozePreset.allSnoozePresets(in: DataManager.main)
			if let index = all.index(of: this), index > 0 {
				let other = all[index-1]
				other.sortOrder = Int64(index)
				this.sortOrder = Int64(index-1)
				snoozePresetsList.selectRowIndexes(IndexSet(integer: index-1), byExtendingSelection: false)
				commitSnoozeSettings()
			}
		}
	}

	@IBAction private func snoozeDownSelected(_ sender: NSButton) {
		if let this = selectedSnoozePreset {
			let all = SnoozePreset.allSnoozePresets(in: DataManager.main)
			if let index = all.index(of: this), index < all.count-1 {
				let other = all[index+1]
				other.sortOrder = Int64(index)
				this.sortOrder = Int64(index+1)
				snoozePresetsList.selectRowIndexes(IndexSet(integer: index+1), byExtendingSelection: false)
				commitSnoozeSettings()
			}
		}
	}

	private var advancedReposWindowController: NSWindowController?
	private var advancedReposWindow: AdvancedReposWindow?
	@IBAction private func advancedSelected(_ sender: NSButton) {
		if advancedReposWindowController == nil {
			advancedReposWindowController = NSWindowController(windowNibName:NSNib.Name(rawValue: "AdvancedReposWindow"))
		}
		if let w = advancedReposWindowController?.window as? AdvancedReposWindow {
			w.prefs = self
			w.level = .floating
			w.center()
			w.makeKeyAndOrderFront(self)
			advancedReposWindow = w
		}
	}
	func closedAdvancedWindow() {
		advancedReposWindow = nil
		advancedReposWindowController = nil
	}

}
