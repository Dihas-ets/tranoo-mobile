import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dio/dio.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tranoo/l10n/app_localizations.dart';
import '../../services/user_service.dart';

class ParrainagePage extends StatefulWidget {
  const ParrainagePage({super.key});

  @override
  State<ParrainagePage> createState() => _ParrainagePageState();
}

class _ParrainagePageState extends State<ParrainagePage> {
  AppLocalizations get l10n => AppLocalizations.of(context)!;

  String? _referralCode;
  int _totalReferrals = 0;
  int _completedReferrals = 0;
  int _pendingReferrals = 0;
  bool _isLoading = true;
  String? _errorMessage;
  List<Map<String, dynamic>> _referrals = [];

  @override
  void initState() {
    super.initState();
    _loadReferralData();
  }

  Future<void> _loadReferralData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception(AppLocalizations.of(context)!.userNotConnected);
      }

      final token = await user.getIdToken();
      final dio = Dio(
        BaseOptions(
          baseUrl: UserService().dio.options.baseUrl,
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      // Charger les statistiques
      final statsResponse = await dio.get('/referrals/stats');
      if (statsResponse.statusCode == 200) {
        setState(() {
          _referralCode = statsResponse.data['referralCode'];
          _totalReferrals = statsResponse.data['totalReferrals'] ?? 0;
          _completedReferrals = statsResponse.data['completedReferrals'] ?? 0;
          _pendingReferrals = statsResponse.data['pendingReferrals'] ?? 0;
        });
      }

      // Charger la liste des parrainages
      final referralsResponse = await dio.get('/referrals/my-referrals');
      if (referralsResponse.statusCode == 200) {
        setState(() {
          _referrals = List<Map<String, dynamic>>.from(referralsResponse.data);
        });
      }
    } on DioException catch (e) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      _errorMessage = l10n.errorNetwork(e.message ?? '');
      if (e.response != null) {
        _errorMessage = l10n.serverError(
          e.response?.statusCode?.toString() ?? '',
          e.response?.data['message']?.toString() ??
              e.response?.data?.toString() ??
              '',
        );
      }
    } catch (e) {
      if (!mounted) return;
      _errorMessage = AppLocalizations.of(context)!.unexpectedError('$e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _copyReferralCode() async {
    if (_referralCode != null) {
      final referralLink =
          'https://play.google.com/store/apps/details?id=tech.dihas.tramoo&referral=$_referralCode';
      await Clipboard.setData(ClipboardData(text: referralLink));
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.referralLinkCopied),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  Future<void> _shareReferralCode() async {
    if (_referralCode != null) {
      // Créer le lien de parrainage personnalisé
      final referralLink =
          'https://play.google.com/store/apps/details?id=tech.dihas.tramoo&referral=$_referralCode';
      final l10n = AppLocalizations.of(context)!;
      final shareText = l10n.referralShareMessage(referralLink);

      // Afficher les options de partage
      await _showShareOptions(shareText, referralLink);
    }
  }

  Future<void> _showShareOptions(String shareText, String referralLink) async {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      builder:
          (sheetContext) => Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.referralShareTitle,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildShareButton(
                      'WhatsApp',
                      Icons.message,
                      Colors.green,
                      () => _shareToWhatsApp(shareText),
                    ),
                    _buildShareButton(
                      'Facebook',
                      Icons.facebook,
                      Colors.blue,
                      () => _shareToFacebook(referralLink),
                    ),
                    _buildShareButton(
                      l10n.others,
                      Icons.share,
                      Colors.grey,
                      () => _shareToOthers(shareText),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
    );
  }

  Widget _buildShareButton(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withOpacity(0.3)),
            ),
            child: Icon(icon, size: 32, color: color),
          ),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Future<void> _shareToWhatsApp(String text) async {
    try {
      final whatsappUrl = 'whatsapp://send?text=${Uri.encodeComponent(text)}';
      if (await canLaunchUrl(Uri.parse(whatsappUrl))) {
        await launchUrl(Uri.parse(whatsappUrl));
      } else {
        // Fallback vers le partage général
        await Share.share(text);
      }
      Navigator.pop(context);
    } catch (e) {
      print('Erreur WhatsApp: $e');
      await Share.share(text);
      Navigator.pop(context);
    }
  }

  Future<void> _shareToFacebook(String link) async {
    try {
      final facebookUrl =
          'https://www.facebook.com/sharer/sharer.php?u=${Uri.encodeComponent(link)}';
      if (await canLaunchUrl(Uri.parse(facebookUrl))) {
        await launchUrl(
          Uri.parse(facebookUrl),
          mode: LaunchMode.externalApplication,
        );
      } else {
        // Fallback vers le partage général
        await Share.share(link);
      }
      Navigator.pop(context);
    } catch (e) {
      print('Erreur Facebook: $e');
      await Share.share(link);
      Navigator.pop(context);
    }
  }

  Future<void> _shareToOthers(String text) async {
    try {
      await Share.share(text);
      Navigator.pop(context);
    } catch (e) {
      print('Erreur partage: $e');
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.referralTitle),
        backgroundColor: Colors.amber,
        foregroundColor: Colors.black,
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage != null
              ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 40,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _errorMessage!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red, fontSize: 16),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _loadReferralData,
                        child: Text(l10n.retry),
                      ),
                    ],
                  ),
                ),
              )
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Carte principale avec le code de parrainage
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.amber.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.people,
                                size: 48,
                                color: Colors.amber,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              l10n.referralLinkTitle,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey[300]!),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      _referralCode != null
                                          ? 'https://play.google.com/store/apps/details?id=tech.dihas.tramoo&referral=$_referralCode'
                                          : l10n.loading,
                                    style: const TextStyle(
                                        fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'monospace',
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: _copyReferralCode,
                                    icon: const Icon(Icons.copy),
                                    tooltip: l10n.copyLink,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: _copyReferralCode,
                                    icon: const Icon(Icons.copy),
                                    label: Text(l10n.copyLink),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue,
                                      foregroundColor: Colors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: _shareReferralCode,
                                    icon: const Icon(Icons.share),
                                    label: Text(l10n.share),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      foregroundColor: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Statistiques
                    const Text(
                      'Vos Statistiques',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            l10n.total,
                            _totalReferrals.toString(),
                            Icons.people,
                            Colors.blue,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            l10n.completed,
                            _completedReferrals.toString(),
                            Icons.check_circle,
                            Colors.green,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            l10n.pending,
                            _pendingReferrals.toString(),
                            Icons.pending,
                            Colors.orange,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Liste des parrainages
                    Text(
                      l10n.yourReferrals,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (_referrals.isEmpty)
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              const Icon(
                                Icons.people_outline,
                                size: 48,
                                color: Colors.grey,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                l10n.noReferralsYet,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                l10n.shareReferralHint,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _referrals.length,
                        itemBuilder: (context, index) {
                          final referral = _referrals[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor:
                                    referral['status'] == 'completed'
                                        ? Colors.green
                                        : Colors.orange,
                                child: Icon(
                                  referral['status'] == 'completed'
                                      ? Icons.check
                                      : Icons.pending,
                                  color: Colors.white,
                                ),
                              ),
                              title: Text(
                                '${referral['referredId']['prenoms']} ${referral['referredId']['nom']}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                referral['referredId']['email'],
                                style: const TextStyle(color: Colors.grey),
                              ),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    referral['status'] == 'completed'
                                        ? l10n.completed
                                        : l10n.pending,
                                    style: TextStyle(
                                      color:
                                          referral['status'] == 'completed'
                                              ? Colors.green
                                              : Colors.orange,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    '${referral['rewardAmount']} F',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              title,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
