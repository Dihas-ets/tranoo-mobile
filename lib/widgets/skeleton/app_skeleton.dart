import 'package:flutter/material.dart';

/// Couleurs et animation shimmer partagées (Tranoo acheteur).
abstract final class AppSkeletonTheme {
  static Color base(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? Colors.grey.shade800
          : Colors.grey.shade300;

  static Color highlight(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? Colors.grey.shade700
          : Colors.grey.shade100;

  static Color surface(BuildContext context) =>
      Theme.of(context).colorScheme.surface;
}

/// Enveloppe shimmer réutilisable.
class AppShimmer extends StatefulWidget {
  final Widget child;

  const AppShimmer({super.key, required this.child});

  @override
  State<AppShimmer> createState() => _AppShimmerState();
}

class _AppShimmerState extends State<AppShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment(-1.0 - _controller.value * 2, 0),
              end: Alignment(1.0 - _controller.value * 2, 0),
              colors: [
                AppSkeletonTheme.base(context),
                AppSkeletonTheme.highlight(context),
                AppSkeletonTheme.base(context),
              ],
              stops: const [0.35, 0.5, 0.65],
            ).createShader(bounds);
          },
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

class SkeletonBox extends StatelessWidget {
  final double? width;
  final double? height;
  final BorderRadius borderRadius;
  final EdgeInsetsGeometry? margin;

  const SkeletonBox({
    super.key,
    this.width,
    this.height,
    this.borderRadius = const BorderRadius.all(Radius.circular(8)),
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: Container(
        width: width,
        height: height,
        margin: margin,
        decoration: BoxDecoration(
          color: AppSkeletonTheme.base(context),
          borderRadius: borderRadius,
        ),
      ),
    );
  }
}

class SkeletonLine extends StatelessWidget {
  final double widthFactor;
  final double height;
  final EdgeInsetsGeometry? margin;

  const SkeletonLine({
    super.key,
    this.widthFactor = 1,
    this.height = 12,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth.isFinite
            ? constraints.maxWidth * widthFactor
            : 200.0 * widthFactor;
        return SkeletonBox(
          width: w,
          height: height,
          margin: margin ?? const EdgeInsets.only(bottom: 8),
          borderRadius: BorderRadius.circular(6),
        );
      },
    );
  }
}

class SkeletonCircle extends StatelessWidget {
  final double size;
  final EdgeInsetsGeometry? margin;

  const SkeletonCircle({super.key, this.size = 48, this.margin});

  @override
  Widget build(BuildContext context) {
    return SkeletonBox(
      width: size,
      height: size,
      margin: margin,
      borderRadius: BorderRadius.circular(size / 2),
    );
  }
}

/// Affiche [skeleton] pendant le chargement initial, sinon [child].
class SkeletonGate extends StatelessWidget {
  final bool loading;
  final bool showOnlyWhenEmpty;
  final int itemCount;
  final Widget skeleton;
  final Widget child;

  const SkeletonGate({
    super.key,
    required this.loading,
    required this.skeleton,
    required this.child,
    this.showOnlyWhenEmpty = true,
    this.itemCount = 0,
  });

  bool get _showSkeleton =>
      loading && (!showOnlyWhenEmpty || itemCount == 0);

  @override
  Widget build(BuildContext context) {
    if (_showSkeleton) return skeleton;
    return child;
  }
}

/// Préréglages skeleton pour les écrans Tranoo.
abstract final class SkeletonPresets {
  static Widget wrap(Widget child) => AppShimmer(child: child);

  /// Liste verticale type voitures / pièces.
  static Widget articleList({int count = 6, bool withImage = true}) {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: count,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, __) => articleListTile(withImage: withImage),
    );
  }

  static Widget articleListTile({bool withImage = true}) {
    return Builder(
      builder: (context) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (withImage)
            const SkeletonBox(
              width: 100,
              height: 80,
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
          if (withImage) const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                SkeletonLine(widthFactor: 0.85, height: 14),
                SkeletonLine(widthFactor: 0.55, height: 12),
                SkeletonLine(widthFactor: 0.4, height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Bande horizontale type accueil (véhicules / motos).
  static Widget articleHorizontalStrip({int count = 3, double cardWidth = 160}) {
    return SizedBox(
      height: 220,
      child: ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: count,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, __) => SizedBox(
          width: cardWidth,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              SkeletonBox(
                width: double.infinity,
                height: 120,
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
              SizedBox(height: 8),
              SkeletonLine(widthFactor: 0.9, height: 13),
              SkeletonLine(widthFactor: 0.55, height: 11),
            ],
          ),
        ),
      ),
    );
  }

  /// Bloc Services (4 icônes).
  static Widget servicesSummary() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SkeletonLine(widthFactor: 0.28, height: 18),
          const SizedBox(height: 12),
          Row(
            children: List.generate(
              4,
              (i) => Expanded(
                child: Padding(
                  padding: EdgeInsets.only(left: i == 0 ? 0 : 6),
                  child: Column(
                    children: const [
                      SkeletonCircle(size: 56),
                      SizedBox(height: 8),
                      SkeletonLine(widthFactor: 0.9, height: 10),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Bandeau publicités sponsorisées horizontales.
  static Widget sponsoriseStrip({int count = 3}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: SkeletonLine(widthFactor: 0.3, height: 18),
        ),
        SizedBox(
          height: 120,
          child: ListView.separated(
            physics: const NeverScrollableScrollPhysics(),
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: count,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (_, __) => const SkeletonBox(
              width: 200,
              height: 110,
              borderRadius: BorderRadius.all(Radius.circular(14)),
            ),
          ),
        ),
      ],
    );
  }

  /// Grille 2 colonnes (accueil, recommandé).
  static Widget articleGrid({int count = 4}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.78,
        ),
        itemCount: count,
        itemBuilder: (_, __) => articleGridCard(),
      ),
    );
  }

  static Widget articleGridCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        SkeletonBox(
          width: double.infinity,
          height: 120,
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        SizedBox(height: 8),
        SkeletonLine(widthFactor: 0.9, height: 13),
        SkeletonLine(widthFactor: 0.5, height: 11),
      ],
    );
  }

  /// Bandeau publicité / carousel.
  static Widget pubBanner({double height = 100}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SkeletonBox(
        width: double.infinity,
        height: height,
        borderRadius: const BorderRadius.all(Radius.circular(14)),
      ),
    );
  }

  /// Page liste plein écran (voitures, pièces, commandes…).
  static Widget fullPageList({int count = 8}) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(top: 8, bottom: 24),
      child: articleList(count: count),
    );
  }

  /// Accueil marque : pubs + 2 grilles.
  static Widget homeMarque() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          pubBanner(height: 120),
          servicesSummary(),
          sponsoriseStrip(),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SkeletonLine(widthFactor: 0.35, height: 18),
          ),
          articleHorizontalStrip(count: 3),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SkeletonLine(widthFactor: 0.3, height: 18),
          ),
          articleHorizontalStrip(count: 3),
        ],
      ),
    );
  }

  /// Profil utilisateur.
  static Widget profile() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SkeletonCircle(size: 88),
          const SizedBox(height: 16),
          const SkeletonLine(widthFactor: 0.5, height: 16),
          const SizedBox(height: 24),
          ...List.generate(
            5,
            (_) => const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: SkeletonBox(
                width: double.infinity,
                height: 52,
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Notifications.
  static Widget notificationList({int count = 8}) {
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: count,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, __) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SkeletonCircle(size: 44),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                SkeletonLine(widthFactor: 0.7, height: 13),
                SkeletonLine(widthFactor: 1, height: 11),
                SkeletonLine(widthFactor: 0.35, height: 10),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Commandes / factures.
  static Widget orderList({int count = 6}) {
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: count,
      itemBuilder: (_, __) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            SkeletonBox(
              width: double.infinity,
              height: 88,
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
          ],
        ),
      ),
    );
  }

  /// Détail article (en-tête + corps).
  static Widget articleDetail() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SkeletonBox(
            width: double.infinity,
            height: 220,
            borderRadius: BorderRadius.zero,
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                SkeletonLine(widthFactor: 0.75, height: 20),
                SizedBox(height: 8),
                SkeletonLine(widthFactor: 0.4, height: 16),
                SizedBox(height: 16),
                SkeletonLine(widthFactor: 1, height: 12),
                SkeletonLine(widthFactor: 1, height: 12),
                SkeletonLine(widthFactor: 0.85, height: 12),
                SizedBox(height: 20),
                SkeletonBox(
                  width: double.infinity,
                  height: 48,
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Formulaire (auth, profil édition).
  static Widget form({int fields = 4}) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          ...List.generate(
            fields,
            (_) => const Padding(
              padding: EdgeInsets.only(bottom: 14),
              child: SkeletonBox(
                width: double.infinity,
                height: 52,
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
            ),
          ),
          const SizedBox(height: 8),
          const SkeletonBox(
            width: double.infinity,
            height: 48,
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
        ],
      ),
    );
  }

  /// Stats / wallet (cartes).
  static Widget statsCards({int count = 3}) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: List.generate(
          count,
          (_) => const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: SkeletonBox(
              width: double.infinity,
              height: 72,
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
          ),
        ),
      ),
    );
  }

  /// Liste transitaires : carousel + onglets + lignes.
  static Widget transitairesList({int count = 4}) {
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      itemCount: count,
      separatorBuilder: (_, __) => const SizedBox(height: 14),
      itemBuilder: (_, __) => const SkeletonBox(
        height: 220,
        borderRadius: BorderRadius.all(Radius.circular(18)),
      ),
    );
  }

  /// Profil transitaire : en-tête + onglets + contenu.
  static Widget transitaireProfile() {
    return Column(
      children: [
        SizedBox(
          height: 200,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              const SkeletonBox(
                width: double.infinity,
                height: 140,
                borderRadius: BorderRadius.zero,
              ),
              const Positioned(
                top: 66,
                left: 0,
                right: 0,
                child: Center(child: SkeletonCircle(size: 88)),
              ),
              Positioned(
                top: 158,
                left: 24,
                right: 24,
                child: Column(
                  children: const [
                    SkeletonLine(widthFactor: 0.45, height: 16, margin: EdgeInsets.zero),
                    SizedBox(height: 8),
                    SkeletonLine(widthFactor: 0.35, height: 12, margin: EdgeInsets.zero),
                  ],
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              SkeletonLine(widthFactor: 0.2, height: 14, margin: EdgeInsets.zero),
              SizedBox(width: 40),
              SkeletonLine(widthFactor: 0.2, height: 14, margin: EdgeInsets.zero),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: Column(
              children: [
                const SkeletonBox(
                  width: double.infinity,
                  height: 48,
                  borderRadius: BorderRadius.all(Radius.circular(14)),
                ),
                const SizedBox(height: 16),
                const SkeletonBox(
                  width: double.infinity,
                  height: 140,
                  borderRadius: BorderRadius.all(Radius.circular(14)),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Grille galerie transitaire (2 colonnes).
  static Widget transitaireGalleryGrid({int count = 6}) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 0.72,
        ),
        itemCount: count,
        itemBuilder: (_, __) => const SkeletonBox(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),
    );
  }

  /// Discussion / chat.
  static Widget chatList({int count = 10}) {
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(12),
      itemCount: count,
      itemBuilder: (_, i) => Align(
        alignment: i.isEven ? Alignment.centerLeft : Alignment.centerRight,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: SkeletonBox(
            width: i.isEven ? 200 : 160,
            height: 40,
            borderRadius: const BorderRadius.all(Radius.circular(16)),
          ),
        ),
      ),
    );
  }
}
