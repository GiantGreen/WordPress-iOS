import Foundation
import AFNetworking

/// SiteManagementServiceRemote handles REST API calls for managing a WordPress.com site.
///
open class SiteManagementServiceRemote : ServiceRemoteWordPressComREST
{
    /// Deletes the specified WordPress.com site.
    ///
    /// - Parameters:
    ///    - siteID: The WordPress.com ID of the site.
    ///    - success: Optional success block with no parameters
    ///    - failure: Optional failure block with NSError
    ///
    open func deleteSite(_ siteID: NSNumber, success: (() -> Void)?, failure: ((NSError) -> Void)?) {
        let endpoint = "sites/\(siteID)/delete"
        let path = self.path(forEndpoint: endpoint, with: .version_1_1)

        wordPressComRestApi.POST(path!,
            parameters: nil,
            success: { response, httpResponse in
                guard let results = response as? [String: AnyObject] else {
                    failure?(SiteError.deleteInvalidResponse.toNSError())
                    return
                }
                guard let status = results[ResultKey.Status] as? String else {
                    failure?(SiteError.deleteMissingStatus.toNSError())
                    return
                }
                guard status == ResultValue.Deleted else {
                    failure?(SiteError.deleteFailed.toNSError())
                    return
                }

                success?()
            },
            failure: { error, httpResponse in
                failure?(error)
            })
    }


    /// Triggers content export of the specified WordPress.com site.
    ///
    /// - Note: An email will be sent with download link when export completes.
    ///
    /// - Parameters:
    ///    - siteID: The WordPress.com ID of the site.
    ///    - success: Optional success block with no parameters
    ///    - failure: Optional failure block with NSError
    ///
    open func exportContent(_ siteID: NSNumber, success: (() -> Void)?, failure: ((NSError) -> Void)?) {
        let endpoint = "sites/\(siteID)/exports/start"
        let path = self.path(forEndpoint: endpoint, with: .version_1_1)

        wordPressComRestApi.POST(path!,
            parameters: nil,
            success: { response, httpResponse in
                guard let results = response as? [String: AnyObject] else {
                    failure?(SiteError.exportInvalidResponse.toNSError())
                    return
                }
                guard let status = results[ResultKey.Status] as? String else {
                    failure?(SiteError.exportMissingStatus.toNSError())
                    return
                }
                guard status == ResultValue.Running else {
                    failure?(SiteError.exportFailed.toNSError())
                    return
                }

                success?()
            },
            failure: { error, httpResponse in
                failure?(error)
        })
    }

    /// Gets the list of active purchases of the specified WordPress.com site.
    ///
    /// - Parameters:
    ///     - siteID: The WordPress.com ID of the site.
    ///     - success: Optional success block with array of purchases (if any)
    ///     - failure: Optional failure block with NSError
    ///
    open func getActivePurchases(_ siteID: NSNumber, success: (([SitePurchase]) -> Void)?, failure: ((NSError) -> Void)?) {
        let endpoint = "sites/\(siteID)/purchases"
        let path = self.path(forEndpoint: endpoint, with: .version_1_1)

        wordPressComRestApi.GET(path!,
            parameters: nil,
            success: { response, httpResponse in
                guard let results = response as? [SitePurchase] else {
                    failure?(SiteError.purchasesInvalidResponse.toNSError())
                    return
                }

                let actives = results.filter { $0[ResultKey.Active]?.boolValue == true }
                success?(actives)
            },
            failure: { error, httpResponse in
                failure?(error)
        })
    }

    /// Keys found in API results
    ///
    fileprivate struct ResultKey
    {
        static let Status = "status"
        static let Active = "active"
    }

    /// Values found in API results
    ///
    fileprivate struct ResultValue
    {
        static let Deleted = "deleted"
        static let Running = "running"
    }

    /// Errors generated by this class whilst parsing API results
    ///
    enum SiteError: Error, CustomStringConvertible
    {
        case deleteInvalidResponse
        case deleteMissingStatus
        case deleteFailed
        case exportInvalidResponse
        case exportMissingStatus
        case exportFailed
        case purchasesInvalidResponse

        var description: String {
            switch self {
            case .deleteInvalidResponse, .deleteMissingStatus, .deleteFailed:
                return NSLocalizedString("The site could not be deleted.", comment: "Message shown when site deletion API failed")
            case .exportInvalidResponse, .exportMissingStatus, .exportFailed:
                return NSLocalizedString("The site could not be exported.", comment: "Message shown when site export API failed")
            case .purchasesInvalidResponse:
                return NSLocalizedString("Could not check site purchases.", comment: "Message shown when site purchases API failed")
            }
        }

        func toNSError() -> NSError {
            return NSError(domain: _domain, code: _code, userInfo: [NSLocalizedDescriptionKey: String(describing: self)])
        }
    }
}

/// Returned in array from /purchases endpoint
///
public typealias SitePurchase = [String: AnyObject]
