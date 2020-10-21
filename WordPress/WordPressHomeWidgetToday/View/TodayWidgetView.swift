import SwiftUI
import WidgetKit

struct TodayWidgetView: View {
    let content: TodayWidgetContent

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(content.siteTitle)
                    .font(.footnote)
                    .fontWeight(.semibold)
                    .lineLimit(Constants.siteTitleLines)
                    .foregroundColor(Color(.label))

                Text(Constants.todayTitle)
                    .font(.caption)
                    .fontWeight(.regular)
                    .foregroundColor(Color(.secondaryLabel))

                Spacer()

                Text(Constants.viewsTitle)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(Color(Constants.viewsTitleColorName))

                Text("\(content.views)")
                    .font(.largeTitle)
                    .foregroundColor(Color(.label))
            }
            Spacer()
        }
        .padding(.all, Constants.padding)
    }

    private enum Constants {
        // Titles
        static let todayTitle = NSLocalizedString("Today", comment: "Title of the Today widget.")
        static let viewsTitle = NSLocalizedString("Views", comment: "Label name for the views field in the Today widget.")
        static let visitorsTitle = NSLocalizedString("Visitors", comment: "Label name for the visitors field in the Today widget.")
        static let likesTitle = NSLocalizedString("Likes", comment: "Label name for the likes field in the Today widget.")
        static let commentsTitle = NSLocalizedString("Comments", comment: "Label name for the comments field in the Today widget.")

        // Overall Appearance
        static let padding: CGFloat = 16

        // Site Title
        static let siteTitleLines = 2

        // Views
        static let viewsTitleColorName = "Blue50"
    }
}

struct TodayWidgetView_Previews: PreviewProvider {
    static var previews: some View {
        TodayWidgetView(content: staticModel)
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}