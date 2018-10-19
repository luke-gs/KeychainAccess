//
//  PersonTrafficHistoryViewController.swift
//  MPOL
//
//

import PublicSafetyKit

open class PersonTrafficHistoryViewController: EntityDetailFormViewController {

    // MARK: Private properties
    private var pointSummaryView = NumericValuesView()

    private var footerView = UIView()

    private var pointSummaryHeightConstraint: NSLayoutConstraint?

    private var pointSummaryHeight: CGFloat {

        if self.traitCollection.horizontalSizeClass == .compact {
            return 196
        }
        return 176
    }

    // MARK: - Lifecycle

    public init(viewModel: PersonTrafficHistoryViewModel) {
        super.init(viewModel: viewModel)
    }

    required convenience public init?(coder aDecoder: NSCoder) {
        MPLCodingNotSupported()
    }

    open override func viewDidLoad() {
        super.viewDidLoad()

        guard let collectionView = collectionView, let viewModel = viewModel as? PersonTrafficHistoryViewModel else {
            return
        }

        // add pointSummary view
        pointSummaryView.titleLabel.text = "Summary"
        pointSummaryView.items = viewModel.trafficHistoryOverviewItems
        view.insertSubview(pointSummaryView, belowSubview: collectionView)
        pointSummaryView.translatesAutoresizingMaskIntoConstraints = false

        // adjust collectionView inset to sit below summaryView
        collectionView.contentInset = UIEdgeInsets(top: pointSummaryHeight, left: 0, bottom: 0, right: 0)
        collectionView.translatesAutoresizingMaskIntoConstraints = false

        // add footerView
        footerView.translatesAutoresizingMaskIntoConstraints = false
        view.insertSubview(footerView, belowSubview: pointSummaryView)

        pointSummaryHeightConstraint = pointSummaryView.heightAnchor.constraint(equalToConstant: pointSummaryHeight)

        NSLayoutConstraint.activate([
            pointSummaryView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            pointSummaryView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            pointSummaryView.topAnchor.constraint(equalTo: view.safeAreaOrFallbackTopAnchor),
            pointSummaryHeightConstraint!,

            collectionView.topAnchor.constraint(equalTo: view.safeAreaOrFallbackTopAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaOrFallbackBottomAnchor),

            footerView.topAnchor.constraint(equalTo: view.centerYAnchor),
            footerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            footerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            footerView.bottomAnchor.constraint(equalTo: view.safeAreaOrFallbackBottomAnchor)
        ])

        apply(ThemeManager.shared.theme(for: .current))

    }

    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        pointSummaryHeightConstraint?.constant = pointSummaryHeight
        view.layoutIfNeeded()
        self.collectionView?.contentOffset.y = -self.pointSummaryHeight
    }

    // MARK: - Form Builder

    open override func construct(builder: FormBuilder) {
        viewModel.construct(for: self, with: builder)
    }

    // MARK: - Adjust colors as summaryView sits below collectionView
    open override func apply(_ theme: Theme) {
        super.apply(theme)

        collectionView?.backgroundColor = .clear
        view.backgroundColor = theme.color(forKey: .contentBackgroundGray)
        footerView.backgroundColor = UserInterfaceStyle.current.isDark ? .black : .white
        collectionView?.reloadData()
    }

    override open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath)
        cell.contentView.backgroundColor = UserInterfaceStyle.current.isDark ? .black : .white
        return cell
    }

    override open func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let view = super.collectionView(collectionView, viewForSupplementaryElementOfKind: kind, at: indexPath)
        view.backgroundColor = UserInterfaceStyle.current.isDark ? .black : .white
        return view
    }

    // MARK: - SummaryView Snap Animation

    open func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        scrollViewDidStopScrolling()
    }

    open func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            scrollViewDidStopScrolling()
        }
    }

    func scrollViewDidStopScrolling() {
        if collectionView!.contentOffset.y < 0 {
            let midPoint = pointSummaryHeight / 2

            if abs(collectionView!.contentOffset.y) > midPoint {
                // expand header
                UIView.animate(withDuration: 0.2, animations: {
                    self.collectionView?.contentOffset.y = -self.pointSummaryHeight
                })
            } else {
                // collapse header
                UIView.animate(withDuration: 0.2, animations: {
                    self.collectionView?.contentOffset.y = 0.0
                })
            }
        }
    }
}
