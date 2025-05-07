import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

void main() {
  runApp(const ZapLinkApp());
}

class ZapLinkApp extends StatelessWidget {
  const ZapLinkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Zap Link',
      home: const ZapLinkPage(title: 'Zap Link'),
    );
  }
}

class ZapLinkPage extends StatefulWidget {
  const ZapLinkPage({super.key, required this.title});

  final String title;

  @override
  State<ZapLinkPage> createState() => _ZapLinkPageState();
}

class _ZapLinkPageState extends State<ZapLinkPage> {
  Uri? _uri;

  final _phoneNumberController = TextEditingController();

  bool _isValidPhoneNumber(String text) {
    final regex = RegExp(r'^(\+?55)?\d{10,11}$');
    return regex.hasMatch(text);
  }

  updatePhone(String text) {
    Uri? toLaunch;

    if (_isValidPhoneNumber(text)) {
      var sanitizedPhoneNumber = text.replaceAll(RegExp(r'\D'), '');

      if (!sanitizedPhoneNumber.startsWith('55')) {
        sanitizedPhoneNumber = '55$sanitizedPhoneNumber';
      }

      toLaunch = Uri(
        scheme: 'https',
        host: 'wa.me',
        path: sanitizedPhoneNumber,
      );
    }

    setState(() {
      _uri = toLaunch;
    });
  }

  Future<void> _launchInBrowser(Uri url) async {
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF367754),
        title: Center(
          child: Text(
            widget.title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
      body: Container(
        color: Color.fromARGB(255, 223, 240, 232),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      textAlign: TextAlign.center,
                      controller: _phoneNumberController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.delete),
                          iconSize: 40,
                          onPressed: () {
                            setState(() {
                              _phoneNumberController.clear();
                              _uri = null;
                            });
                          },
                        ),
                      ),
                      style: const TextStyle(
                        fontSize: 28,
                      ), // Increased font size
                      onChanged: (text) {
                        updatePhone(text);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.qr_code),
                    iconSize: 60,
                    color: Colors.green.shade800,
                    onPressed:
                        _uri != null
                            ? () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    content: SizedBox(
                                      width: 200,
                                      height: 200,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          QrImageView(
                                            data:
                                                _uri.toString(), // URL convertida em QR Code
                                            version: QrVersions.auto,
                                            size: 200.0,
                                          ),
                                        ],
                                      ),
                                    ),
                                    // actions: [
                                    //   TextButton(
                                    //     onPressed: () {
                                    //       Navigator.of(
                                    //         context,
                                    //       ).pop(); // Fecha a modal
                                    //     },
                                    //     child: const Text('Fechar'),
                                    //   ),
                                    // ],
                                  );
                                },
                              );
                            }
                            : null,
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.share),
                    iconSize: 60,
                    color: Colors.green.shade800,
                    onPressed:
                        _uri != null
                            ? () {
                              final params = ShareParams(uri: _uri);
                              SharePlus.instance.share(params);
                            }
                            : null,
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const FaIcon(FontAwesomeIcons.whatsapp),
                    iconSize: 60,
                    color: Colors.green.shade800,
                    onPressed:
                        _uri != null ? () => _launchInBrowser(_uri!) : null,
                  ),
                ],
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _uri != null
                      ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          InkWell(
                            onTap:
                                _uri != null
                                    ? () => _launchInBrowser(_uri!)
                                    : null,
                            child: Text(
                              _uri.toString(),
                              style: TextStyle(
                                fontSize: 20,
                                decoration: TextDecoration.underline,
                                fontWeight: FontWeight.bold,
                                color: Colors.green.shade800,
                              ),
                            ),
                          ),
                          // const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.copy),
                            iconSize: 22,
                            color: Colors.green.shade800,
                            onPressed: () {
                              if (_uri != null) {
                                Clipboard.setData(
                                  ClipboardData(text: _uri.toString()),
                                );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Link copiado!'),
                                  ),
                                );
                              }
                            },
                          ),
                        ],
                      )
                      : const Text(''),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
