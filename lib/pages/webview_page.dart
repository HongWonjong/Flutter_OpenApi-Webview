import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class WebViewPage extends StatefulWidget {
  final String url;

  const WebViewPage({super.key, required this.url});

  @override
  _WebViewPageState createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  bool _isLoading = true;
  InAppWebViewController? _webViewController;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    String validatedUrl = widget.url;

    return Scaffold(
      appBar: AppBar(
        title: const Text('웹 페이지'),
      ),
      body: Stack(
        children: [
          Container(
            color: Colors.white, // 웹뷰 배경색 설정
            child: InAppWebView(
              initialUrlRequest: URLRequest(url: WebUri(validatedUrl)),
              onWebViewCreated: (controller) {
                _webViewController = controller;
                print('웹뷰 생성 완료');
              },
              onLoadStart: (controller, url) {
                setState(() {
                  _isLoading = true;
                  _errorMessage = null;
                });
                print('로드 시작: $url');
              },
              onLoadStop: (controller, url) {
                setState(() {
                  _isLoading = false;
                });
                print('로드 완료: $url');
              },
              onLoadError: (controller, url, code, message) {
                setState(() {
                  _isLoading = false;
                  _errorMessage = '로드 오류: $message (코드: $code)';
                });
                print('로드 오류: $message (코드: $code)');
              },
              onLoadHttpError: (controller, url, statusCode, description) {
                setState(() {
                  _isLoading = false;
                  _errorMessage = 'HTTP 오류: $description (상태 코드: $statusCode)';
                });
                print('HTTP 오류: $description (상태 코드: $statusCode)');
              },
            ),
          ),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
          if (_errorMessage != null)
            Center(
              child: Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }
}