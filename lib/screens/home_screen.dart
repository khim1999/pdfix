import 'dart:io';
import 'package:flutter/material.dart';
import '../services/pdf_service.dart';
import '../services/security_service.dart';
import '../theme.dart';
import '../widgets.dart';
import 'compress_screen.dart';
import 'image_to_pdf_screen.dart';
import 'merge_screen.dart';
import 'pdf_to_images_screen.dart';
import 'protect_screen.dart';
import 'rotate_screen.dart';
import 'security_screen.dart';
import 'sign_screen.dart';
import 'split_screen.dart';
import 'unlock_screen.dart';
import 'watermark_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<File> _recentFiles = [];
  bool _loadingRecent = true;

  @override
  void initState() {
    super.initState();
    _loadRecent();
  }

  Future<void> _loadRecent() async {
    final list = await PdfService.getRecentFiles();
    if (mounted) {
      setState(() {
        _recentFiles = list;
        _loadingRecent = false;
      });
    }
  }

  Future<void> _navigateAndRefresh(Widget screen) async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
    _loadRecent();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadRecent,
          color: Brand.compress,
          child: ListView(
            physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 36),
            children: [
              Row(children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(
                    'assets/app_icon.png',
                    width: 36,
                    height: 36,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 12),
                const Text('PDFix',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
                const Spacer(),
                InkWell(
                  onTap: () => _navigateAndRefresh(const SecurityScreen()),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
                    decoration: BoxDecoration(
                      color: Brand.success.withOpacity(.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.shield_rounded, size: 14, color: Brand.success),
                      SizedBox(width: 5),
                      Text('Security & Privacy',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Brand.success)),
                      SizedBox(width: 2),
                      Icon(Icons.arrow_forward_ios_rounded, size: 9, color: Brand.success),
                    ]),
                  ),
                ),
              ]),
              const SizedBox(height: 28),
              const Text('All-in-One\nPDF Powerhouse.',
                  style: TextStyle(fontSize: 34, fontWeight: FontWeight.w800, height: 1.1)),
              const SizedBox(height: 8),
              Text('Edit, convert, protect & organize. 100% on-device & private.',
                  style: TextStyle(fontSize: 14.5, color: Theme.of(context).hintColor)),
              const SizedBox(height: 28),

              // ---------------------------------------------------- CORE TOOLS
              const _CategoryLabel('CORE TOOLS'),
              _BigToolCard(
                title: 'Compress PDF',
                subtitle: 'Shrink file size for easy email & chat sharing.',
                icon: Icons.compress_rounded,
                a: Brand.compress,
                b: Brand.compressSoft,
                onTap: () => _navigateAndRefresh(const CompressScreen()),
              ),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(
                  child: _GridToolCard(
                    title: 'Split PDF',
                    subtitle: 'Extract or separate pages',
                    icon: Icons.call_split_rounded,
                    color: Brand.split,
                    onTap: () => _navigateAndRefresh(const SplitScreen()),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _GridToolCard(
                    title: 'Merge PDF',
                    subtitle: 'Combine multiple files',
                    icon: Icons.layers_rounded,
                    color: Brand.merge,
                    onTap: () => _navigateAndRefresh(const MergeScreen()),
                  ),
                ),
              ]),

              // -------------------------------------------- CONVERT & ORGANIZE
              const SizedBox(height: 24),
              const _CategoryLabel('CONVERT & ORGANIZE'),
              Row(children: [
                Expanded(
                  child: _GridToolCard(
                    title: 'Images to PDF',
                    subtitle: 'Convert photos to PDF',
                    icon: Icons.image_rounded,
                    color: Brand.image,
                    onTap: () => _navigateAndRefresh(const ImageToPdfScreen()),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _GridToolCard(
                    title: 'PDF to Images',
                    subtitle: 'Save pages as images',
                    icon: Icons.photo_library_rounded,
                    color: Brand.pdfToImg,
                    onTap: () => _navigateAndRefresh(const PdfToImagesScreen()),
                  ),
                ),
              ]),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(
                  child: _GridToolCard(
                    title: 'Rotate Pages',
                    subtitle: 'Turn sideways pages',
                    icon: Icons.rotate_right_rounded,
                    color: Brand.rotate,
                    onTap: () => _navigateAndRefresh(const RotateScreen()),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _GridToolCard(
                    title: 'Watermark',
                    subtitle: 'Add custom text stamp',
                    icon: Icons.branding_watermark_rounded,
                    color: Brand.watermark,
                    onTap: () => _navigateAndRefresh(const WatermarkScreen()),
                  ),
                ),
              ]),

              // ----------------------------------------------- SECURITY & SIGN
              const SizedBox(height: 24),
              const _CategoryLabel('SECURITY & SIGN'),
              Row(children: [
                Expanded(
                  child: _GridToolCard(
                    title: 'Protect PDF',
                    subtitle: 'Lock with password',
                    icon: Icons.lock_rounded,
                    color: Brand.protect,
                    onTap: () => _navigateAndRefresh(const ProtectScreen()),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _GridToolCard(
                    title: 'Unlock PDF',
                    subtitle: 'Remove password',
                    icon: Icons.lock_open_rounded,
                    color: Brand.unlock,
                    onTap: () => _navigateAndRefresh(const UnlockScreen()),
                  ),
                ),
              ]),
              const SizedBox(height: 12),
              _BigToolCard(
                title: 'Sign Document',
                subtitle: 'Draw signature with your finger on any page.',
                icon: Icons.draw_rounded,
                a: Brand.sign,
                b: Brand.signSoft,
                onTap: () => _navigateAndRefresh(const SignScreen()),
              ),
              const SizedBox(height: 12),
              _SecurityHubCard(
                onTap: () => _navigateAndRefresh(const SecurityScreen()),
              ),

              // -------------------------------------------------- RECENT FILES
              if (!_loadingRecent && _recentFiles.isNotEmpty) ...[
                const SizedBox(height: 28),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const _CategoryLabel('RECENT FILES'),
                    IconButton(
                      tooltip: 'Refresh recent files',
                      icon: const Icon(Icons.refresh_rounded, size: 18),
                      onPressed: _loadRecent,
                    ),
                  ],
                ),
                for (final f in _recentFiles)
                  FileResultTile(
                    name: f.uri.pathSegments.last,
                    detail: formatBytes(f.lengthSync()),
                    accent: Brand.compress,
                    path: f.path,
                    onRemove: () {
                      setState(() => _recentFiles.remove(f));
                    },
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryLabel extends StatelessWidget {
  final String text;
  const _CategoryLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.1,
          color: Theme.of(context).hintColor.withOpacity(.7),
        ),
      ),
    );
  }
}

class _BigToolCard extends StatelessWidget {
  final String title, subtitle;
  final IconData icon;
  final Color a, b;
  final VoidCallback onTap;

  const _BigToolCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.a,
    required this.b,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Ink(
          height: 128,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [a, b], begin: Alignment.topLeft, end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(color: a.withOpacity(.3), blurRadius: 18, offset: const Offset(0, 8)),
            ],
          ),
          child: Stack(children: [
            Positioned(
              right: -8,
              bottom: -16,
              child: Icon(icon, size: 90, color: Colors.white.withOpacity(.22)),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Text(subtitle, style: TextStyle(color: Colors.white.withOpacity(.9), fontSize: 13.5)),
              ],
            ),
          ]),
        ),
      ),
    );
  }
}

class _GridToolCard extends StatelessWidget {
  final String title, subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _GridToolCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: cardColor(context),
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: color, size: 26),
              ),
              const SizedBox(height: 16),
              Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: TextStyle(color: Theme.of(context).hintColor, fontSize: 12.5),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SecurityHubCard extends StatelessWidget {
  final VoidCallback onTap;

  const _SecurityHubCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final isSecured = SecurityService.instance.isAppLockEnabled;

    return Container(
      decoration: BoxDecoration(
        color: dark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isSecured
              ? const Color(0xFF10B981).withOpacity(0.35)
              : (dark ? Colors.white12 : Colors.black.withOpacity(0.06)),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(dark ? 0.2 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(22),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF059669), Color(0xFF10B981)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.security_rounded, color: Colors.white, size: 26),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text('Security & Privacy Hub',
                              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15.5)),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981).withOpacity(0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              isSecured ? 'LOCK ON' : 'ACTIVE',
                              style: const TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF059669),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'PIN App Lock, Anti-Spy, & Cache Shredder',
                        style: TextStyle(
                          color: Theme.of(context).hintColor,
                          fontSize: 12.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios_rounded, size: 14),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
