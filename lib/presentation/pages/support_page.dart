import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_theme.dart';
import '../widgets/animations/fade_in_widget.dart';
import '../widgets/animations/slide_in_widget.dart';
import '../widgets/animations/scale_tap_widget.dart';

/// Support/Contact page with FAQ integration
class SupportPage extends StatefulWidget {
  const SupportPage({super.key});

  @override
  State<SupportPage> createState() => _SupportPageState();
}

class _SupportPageState extends State<SupportPage> {
  final List<FAQItem> _faqs = [
    FAQItem(
      question: 'Comment puis-je acheter un coupon ?',
      answer: 'Vous pouvez parcourir les coupons disponibles dans la section "Coupons", sélectionner celui qui vous intéresse et suivre les instructions pour l\'acheter.',
    ),
    FAQItem(
      question: 'Comment utiliser mon coupon ?',
      answer: 'Une fois acheté, votre coupon génère un code QR. Présentez ce code QR au commerçant lors de votre visite pour utiliser votre coupon.',
    ),
    FAQItem(
      question: 'Puis-je rembourser un coupon ?',
      answer: 'Les coupons achetés ne peuvent généralement pas être remboursés. Veuillez vérifier les conditions spécifiques de chaque coupon avant l\'achat.',
    ),
    FAQItem(
      question: 'Comment recharger mon portefeuille ?',
      answer: 'Allez dans la section "Portefeuille" et sélectionnez "Nos Offres" pour voir les options de recharge disponibles.',
    ),
    FAQItem(
      question: 'Que sont les coins ?',
      answer: 'Les coins sont une monnaie virtuelle que vous pouvez utiliser pour acheter des coupons. Vous pouvez obtenir des coins en rechargeant votre portefeuille.',
    ),
    FAQItem(
      question: 'Mon coupon a expiré, que faire ?',
      answer: 'Les coupons expirés ne peuvent pas être utilisés. Assurez-vous d\'utiliser vos coupons avant leur date d\'expiration.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Support'), // Will be localized
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // FAQ Section
            SlideInWidget(
              begin: const Offset(-0.3, 0),
              child: Text(
                'FAQ', // Will be localized
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryOrange,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            const SizedBox(height: 16),
            ..._faqs.asMap().entries.map((entry) {
              final index = entry.key;
              final faq = entry.value;
              return FadeInWidget(
                delay: index * 0.1,
                child: _buildFAQCard(faq),
              );
            }),
            const SizedBox(height: 32),
            
            // Contact Section
            SlideInWidget(
              begin: const Offset(-0.3, 0),
              child: Text(
                'Nous contacter', // Will be localized
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryOrange,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            const SizedBox(height: 16),
            FadeInWidget(
              child: Text(
                'Vous avez une question ? Contactez-nous via l\'un des canaux ci-dessous :',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Email
            FadeInWidget(
              delay: 0.1,
              child: _buildContactCard(
                icon: Icons.email,
                title: 'Email',
                subtitle: 'support@rabaisci.com',
                onTap: () => _launchEmail('support@rabaisci.com'),
              ),
            ),
            const SizedBox(height: 12),
            
            // WhatsApp
            FadeInWidget(
              delay: 0.2,
              child: _buildContactCard(
                icon: Icons.chat,
                title: 'WhatsApp',
                subtitle: '+225 07 68 20 88 93',
                onTap: () => _launchWhatsApp('+2250768208893'),
              ),
            ),
            const SizedBox(height: 12),
            
            // In-app message (placeholder)
            FadeInWidget(
              delay: 0.3,
              child: _buildContactCard(
                icon: Icons.message,
                title: 'Message dans l\'app',
                subtitle: 'Envoyez-nous un message directement',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('La messagerie dans l\'app sera disponible prochainement.'),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQCard(FAQItem faq) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              Colors.white,
              AppTheme.primaryOrange.withValues(alpha: 0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          title: Text(
            faq.question,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                faq.answer,
                style: TextStyle(
                  color: Colors.grey[700],
                  height: 1.5,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ScaleTapWidget(
      onTap: onTap,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [
                Colors.white,
                AppTheme.primaryTurquoise.withValues(alpha: 0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.primaryOrange,
                        AppTheme.primaryTurquoise,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.navyBlue,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: AppTheme.primaryOrange,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _launchEmail(String email) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
      query: 'subject=Support RABAIS CI',
    );
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Impossible d\'ouvrir l\'application email.'),
          ),
        );
      }
    }
  }

  Future<void> _launchWhatsApp(String phone) async {
    // WhatsApp "wa.me" requires digits only (no '+', spaces, etc.)
    final digitsOnly = phone.replaceAll(RegExp(r'[^0-9]'), '');
    final Uri whatsappUri = Uri.https('wa.me', '/$digitsOnly');
    if (await canLaunchUrl(whatsappUri)) {
      await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Impossible d\'ouvrir WhatsApp.'),
          ),
        );
      }
    }
  }
}

class FAQItem {
  final String question;
  final String answer;

  FAQItem({required this.question, required this.answer});
}

