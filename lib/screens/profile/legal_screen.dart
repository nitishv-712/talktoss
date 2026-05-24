import 'package:flutter/material.dart';

class LegalScreen extends StatelessWidget {
  const LegalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Legal',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          bottom: TabBar(
            labelColor: cs.primary,
            unselectedLabelColor: cs.onSurface.withValues(alpha: 0.6),
            indicatorColor: cs.primary,
            indicatorSize: TabBarIndicatorSize.tab,
            tabs: const [
              Tab(text: 'Terms of Service'),
              Tab(text: 'Privacy Policy'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _legalTextSection(
              context,
              'Terms of Service',
              'Last Updated: May 24, 2026',
              [
                _LegalParagraph(
                  '1. Acceptable Use',
                  'By signing into TalkToss, you agree to treat other users with respect. Hate speech, harassment, abuse, or displaying explicit content during instant voice calls is strictly prohibited. TalkToss reserves the right to terminate user accounts immediately upon violation.',
                ),
                _LegalParagraph(
                  '2. Account Eligibility',
                  'You must be at least 18 years of age (or the legal age of majority in your jurisdiction) to sign up and establish voice matches. We do not knowingly target or offer services to minors.',
                ),
                _LegalParagraph(
                  '3. Matching & Signaling Disclaimer',
                  'TalkToss provides WebRTC communication matchmaking on an "as is" and "as available" basis. We do not guarantee uninterrupted server connections, completely clear audio paths, or availability of translation handlers under all network scenarios.',
                ),
                _LegalParagraph(
                  '4. Modifications to Terms',
                  'We reserve the right to modify these Terms of Service at any time. Continued use of the application after amendments indicate full acceptance of the updated terms.',
                ),
              ],
            ),
            _legalTextSection(
              context,
              'Privacy Policy',
              'Last Updated: May 24, 2026',
              [
                _LegalParagraph(
                  '1. Data Collection',
                  'TalkToss collects your basic Google Account profile information (display name, email address, profile photo URL) to create your account and handle matchmaking sessions. We do not store transcripts or audio files of your voice conversations.',
                ),
                _LegalParagraph(
                  '2. Real-Time Call Data',
                  'Voice calls are established peer-to-peer (P2P) using WebRTC protocols. Signaling metadata (such as socket connection states and ICE candidates) is processed in-memory in our signaling servers and deleted immediately after the session ends.',
                ),
                _LegalParagraph(
                  '3. Translation Processing',
                  'If you enable translation helper services on voice calls, audio streams are transcribed and translated using temporary AI APIs. These inputs are processed in-memory and are never stored or used to train models.',
                ),
                _LegalParagraph(
                  '4. Cookies & Local Storage',
                  'TalkToss stores authentication tokens (JWT) on your local device storage (SharedPreferences) to maintain your session. You can clear this data at any time by logging out.',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _legalTextSection(
    BuildContext context,
    String title,
    String updatedDate,
    List<_LegalParagraph> paragraphs,
  ) {
    final cs = Theme.of(context).colorScheme;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: cs.onSurface,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            updatedDate,
            style: TextStyle(
              color: cs.onSurface.withValues(alpha: 0.5),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 24),
          ...paragraphs.map((p) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    p.header,
                    style: TextStyle(
                      color: cs.onSurface,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    p.body,
                    style: TextStyle(
                      color: cs.onSurface.withValues(alpha: 0.65),
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _LegalParagraph {
  final String header;
  final String body;
  _LegalParagraph(this.header, this.body);
}
