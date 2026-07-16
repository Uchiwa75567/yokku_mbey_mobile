import '../../../../core/theme/app_assets.dart';
import 'onboarding_slide.dart';

abstract final class OnboardingSlides {
  static const List<OnboardingSlide> items = [
    OnboardingSlide(
      title: 'Bienvenue sur\nYOKKU MBEY',
      description:
          'Vendez, achetez, réservez et\ndéveloppez votre activité agricole en\ntoute simplicité.',
      imageAsset: AppAssets.splashScreen1,
      imageWidthFactor: 1.62,
      imageHeightFactor: 1.18,
    ),
    OnboardingSlide(
      title:
          'Trouvez facilement les\nmeilleurs produits\nagricoles de qualité.',
      description:
          "Connectez-vous avec les producteurs de\nvotre région et d'ailleurs.",
      imageAsset: AppAssets.splashScreen2,
      imageWidthFactor: 1.04,
      imageHeightFactor: 1,
    ),
    OnboardingSlide(
      title: 'Propose vos services et\ntrouvez plus de clients\nfacilement',
      description:
          "Rejoignez des milliers d'agriculteurs qui\nont besoin de vos services chaque jour.",
      imageAsset: AppAssets.splashScreen3,
      imageWidthFactor: 1.08,
      imageHeightFactor: 1,
    ),
  ];
}
