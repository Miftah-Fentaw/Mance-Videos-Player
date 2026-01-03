import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:share_plus/share_plus.dart';

class BrowsePage extends StatefulWidget {
  const BrowsePage({super.key});

  @override
  State<BrowsePage> createState() => _BrowsePageState();
}

class _BrowsePageState extends State<BrowsePage> {
  InAppWebViewController? _webViewController;
  PullToRefreshController? _pullToRefreshController;

  @override
  void initState() {
    super.initState();
    _pullToRefreshController = PullToRefreshController(
      onRefresh: () async {
        if (_webViewController != null) {
          _webViewController!.reload();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Better for shorts
      body: InAppWebView(
        initialUrlRequest: URLRequest(
          url: WebUri("https://www.youtube.com/shorts"),
        ),
        initialSettings: InAppWebViewSettings(
          javaScriptEnabled: true,
          mediaPlaybackRequiresUserGesture: false,
          allowsInlineMediaPlayback: true,
          preferredContentMode: UserPreferredContentMode.MOBILE,
        ),
        pullToRefreshController: _pullToRefreshController,
        onWebViewCreated: (controller) => _webViewController = controller,
        onLoadStop: (controller, url) async {
          _pullToRefreshController?.endRefreshing();
          // Inject CSS to hide YouTube's header, sidebar, and other non-shorts elements
          await controller.injectCSSCode(
            source: """
            #header-bar, #masthead-container, #guide-spacer, #guide, 
            ytd-mini-guide-renderer, ytd-masthead, .ytd-masthead,
            #page-manager { padding-top: 0 !important; }
            ytd-browse[page-subtype="home"] { display: none !important; }
            ytm-header-bar, .ytm-pivot-bar-renderer { display: none !important; }
          """,
          );
        },
      ),
    );
  }
}
