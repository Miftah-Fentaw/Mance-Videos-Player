import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class BrowsePage extends StatefulWidget {
  const BrowsePage({super.key});

  @override
  State<BrowsePage> createState() => _BrowsePageState();
}

class _BrowsePageState extends State<BrowsePage> {
  final TextEditingController _searchController = TextEditingController();
  InAppWebViewController? _webViewController;
  PullToRefreshController? _pullToRefreshController;
  double _progress = 0;
  String _url = "";

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

  void _loadUrl(String url) {
    Uri uri = Uri.parse(url);
    if (!uri.isAbsolute) {
      uri = Uri.parse("https://www.youtube.com/search?q=$url");
    }
    _webViewController?.loadUrl(urlRequest: URLRequest(url: WebUri.uri(uri)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(color: Colors.black),
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  hintText: 'Search or type web address',
                  hintStyle: const TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: Colors.grey[200],
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 15,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: BorderSide.none,
                  ),
                ),
                onSubmitted: _loadUrl,
              ),
            ),
            if (_progress < 1.0)
              LinearProgressIndicator(
                value: _progress,
                backgroundColor: Colors.grey[200],
                color: Colors.black,
              ),

            Expanded(
              child: InAppWebView(
                initialUrlRequest: URLRequest(
                  url: WebUri("https://www.Youtube.com"),
                ),
                pullToRefreshController: _pullToRefreshController,
                onWebViewCreated: (controller) {
                  _webViewController = controller;
                },
                onLoadStart: (controller, url) {
                  setState(() {
                    _url = url.toString();
                    _searchController.text = _url;
                  });
                },
                onLoadStop: (controller, url) async {
                  _pullToRefreshController?.endRefreshing();
                  setState(() {
                    _url = url.toString();
                    _searchController.text = _url;
                  });
                },
                onProgressChanged: (controller, progress) {
                  if (progress == 100) {
                    _pullToRefreshController?.endRefreshing();
                  }
                  setState(() {
                    _progress = progress / 100;
                  });
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        height: 30,
        color: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              icon: const Icon(
                Icons.arrow_back_ios,
                color: Colors.black,
                size: 22,
              ),
              onPressed: () => _webViewController?.goBack(),
            ),
            IconButton(
              icon: const Icon(
                Icons.arrow_forward_ios,
                color: Colors.black,
                size: 22,
              ),
              onPressed: () => _webViewController?.goForward(),
            ),
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.black, size: 28),
              onPressed: () => _webViewController?.reload(),
            ),
            IconButton(
              icon: const Icon(
                Icons.home_outlined,
                color: Colors.black,
                size: 28,
              ),
              onPressed: () => _webViewController?.loadUrl(
                urlRequest: URLRequest(url: WebUri("https://google.com")),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
