import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../profile_selection/domain/entities/user_profile_type.dart';
import 'profile_home_content.dart';

abstract final class ProfileHomeContents {
  static const ProfileHomeContent farmer = ProfileHomeContent(
    profileType: UserProfileType.farmer,
    title: 'Bonjour agriculteur',
    subtitle: 'Que voulez-vous faire aujourd’hui ?',
    guidanceTitle: 'On avance petit à petit',
    guidanceText:
        'Ajoutez vos cultures seulement quand vous voulez vendre ou recevoir des acheteurs.',
    actions: [
      ProfileHomeAction(
        title: 'Vendre mes produits',
        description: 'Ajouter une récolte disponible',
        icon: Icons.eco_outlined,
        color: AppColors.leaf,
        backgroundColor: AppColors.greenSoft,
      ),
      ProfileHomeAction(
        title: 'Voir les prix',
        description: 'Suivre les prix du marché',
        icon: Icons.sell_outlined,
        color: AppColors.orange,
        backgroundColor: AppColors.orangeSoft,
      ),
      ProfileHomeAction(
        title: 'Trouver un acheteur',
        description: 'Recevoir des demandes simples',
        icon: Icons.groups_outlined,
        color: AppColors.blue,
        backgroundColor: AppColors.blueSoft,
      ),
    ],
  );

  static const ProfileHomeContent buyer = ProfileHomeContent(
    profileType: UserProfileType.buyer,
    title: 'Bonjour acheteur',
    subtitle: 'Trouvez rapidement des produits agricoles.',
    guidanceTitle: 'Dites ce que vous cherchez au bon moment',
    guidanceText:
        'Votre région et vos produits préférés seront demandés quand vous lancez une recherche.',
    actions: [
      ProfileHomeAction(
        title: 'Chercher un produit',
        description: 'Tomate, oignon, riz, mil...',
        icon: Icons.search,
        color: AppColors.leaf,
        backgroundColor: AppColors.greenSoft,
      ),
      ProfileHomeAction(
        title: 'Voir les producteurs',
        description: 'Consulter les offres proches',
        icon: Icons.storefront_outlined,
        color: AppColors.orange,
        backgroundColor: AppColors.orangeSoft,
      ),
      ProfileHomeAction(
        title: 'Faire une demande',
        description: 'Indiquer quantité et livraison',
        icon: Icons.assignment_outlined,
        color: AppColors.blue,
        backgroundColor: AppColors.blueSoft,
      ),
    ],
  );

  static const ProfileHomeContent provider = ProfileHomeContent(
    profileType: UserProfileType.provider,
    title: 'Bonjour prestataire',
    subtitle: 'Proposez vos services aux acteurs agricoles.',
    guidanceTitle: 'Présentez vos services quand vous êtes prêt',
    guidanceText:
        'Votre zone et vos tarifs peuvent être ajoutés plus tard, service par service.',
    actions: [
      ProfileHomeAction(
        title: 'Ajouter un service',
        description: 'Transport, matériel, conseil...',
        icon: Icons.add_business_outlined,
        color: AppColors.leaf,
        backgroundColor: AppColors.greenSoft,
        routeName: '/provider-service-form',
      ),
      ProfileHomeAction(
        title: 'Voir les demandes',
        description: 'Trouver des clients proches',
        icon: Icons.handshake_outlined,
        color: AppColors.orange,
        backgroundColor: AppColors.orangeSoft,
        routeName: '/provider-requests',
      ),
      ProfileHomeAction(
        title: 'Gérer mes contacts',
        description: 'Appels et WhatsApp clients',
        icon: Icons.phone_in_talk_outlined,
        color: AppColors.blue,
        backgroundColor: AppColors.blueSoft,
        routeName: '/provider-contacts',
      ),
    ],
  );

  static const ProfileHomeContent investor = ProfileHomeContent(
    profileType: UserProfileType.investor,
    title: 'Bonjour partenaire',
    subtitle: 'Suivez les projets et les besoins agricoles.',
    guidanceTitle: 'Commencez par explorer',
    guidanceText:
        'Les informations d’organisation seront demandées quand vous contactez un projet.',
    actions: [
      ProfileHomeAction(
        title: 'Voir les projets',
        description: 'Explorer les initiatives agricoles',
        icon: Icons.account_tree_outlined,
        color: AppColors.leaf,
        backgroundColor: AppColors.greenSoft,
        routeName: '/investor-projects',
      ),
      ProfileHomeAction(
        title: 'Soutenir une activité',
        description: 'Financement, matériel, formation',
        icon: Icons.volunteer_activism_outlined,
        color: AppColors.orange,
        backgroundColor: AppColors.orangeSoft,
        routeName: '/investor-funding',
      ),
      ProfileHomeAction(
        title: 'Suivre les impacts',
        description: 'Résultats et besoins du terrain',
        icon: Icons.insights_outlined,
        color: AppColors.blue,
        backgroundColor: AppColors.blueSoft,
        routeName: '/investor-impact',
      ),
    ],
  );

  static ProfileHomeContent byProfileType(UserProfileType type) {
    return switch (type) {
      UserProfileType.farmer => farmer,
      UserProfileType.buyer => buyer,
      UserProfileType.provider => provider,
      UserProfileType.investor => investor,
    };
  }
}
