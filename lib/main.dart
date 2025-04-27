import 'package:flutter/material.dart';
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
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.greenAccent),
      ),
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
  Uri? _toLaunch;

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
      _toLaunch = toLaunch;
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
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _phoneNumberController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Digite o número do WhatsApp',
                    ),
                    onChanged: (text) {
                      updatePhone(text);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.delete),
                  iconSize: 35,
                  onPressed: () {
                    setState(() {
                      _phoneNumberController.clear();
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            IconButton(
              icon: const FaIcon(FontAwesomeIcons.whatsapp),
              iconSize: 60,
              color: Colors.green.shade800,
              onPressed:
                  _toLaunch != null
                      ? () => setState(() {
                        _launchInBrowser(_toLaunch!);
                      })
                      : null,
            ),
          ],
        ),
      ),
    );
  }
}
