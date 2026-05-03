# FarmBridge App

Application web **Flutter** de gestion des achats de produits agricoles — caisse POS, suivi des dettes et des remboursements pour la plateforme FarmBridge en Côte d'Ivoire.

---

## Stack technique

| Couche | Technologie |
|---|---|
| Framework | Flutter 3 (Dart 3.8) |
| Navigation | go_router 14 |
| État | Provider 6 |
| HTTP | Dio 5 |
| Localisation | intl (fr_FR) |
| Cible | Web (Desktop + Tablet + Mobile) |

---

## Fonctionnalités

- **Authentification** — connexion par identifiant/mot de passe, session persistante via token Sanctum
- **Caisse POS** — sélection de produits, quantités, calcul du total FCFA, paiement espèces ou crédit
- **Limite de crédit** — blocage visuel et blocage serveur si le plafond de l'agriculteur est dépassé
- **Gestion des agriculteurs** — liste, fiche détaillée, création (avec Production Category, Specialty, limite de crédit)
- **Activité unifiée** — liste triée des achats ET des remboursements sur une seule page, avec badge du rôle de l'opérateur
- **Gestion des dettes** — encours par agriculteur, progression visuelle
- **Remboursements en nature** — saisie du produit (cacao, maïs…), quantité en kg, taux/kg, aperçu live du montant crédité
- **Paramètres** — taux d'intérêt configurable
- **RBAC** — 3 rôles avec permissions différenciées (admin, supervisor, operator)
- **Responsive** — layouts adaptés Desktop, Tablet et Mobile

---

## Rôles et permissions

| Fonctionnalité | admin | supervisor | operator |
|---|:---:|:---:|:---:|
| Ajouter un agriculteur | ✅ | ❌ | ❌ |
| Voir tous les agriculteurs | ✅ | ✅ | ✅ |
| Passer une commande POS | ✅ | ✅ | ✅ |
| Enregistrer un remboursement | ✅ | ✅ | ✅ |
| Voir toutes les transactions | ✅ | ✅ | ✅ |
| Gérer les paramètres | ✅ | ✅ | ❌ |

---

## Structure du projet

```
lib/
└── src/
    ├── commons/
    │   ├── data/models/       # Farmer, Transaction, Repayment, ActivityEntry…
    │   ├── utils/             # CurrencyUtils, DateUtils, extensions
    │   └── widgets/           # Widgets réutilisables (EmptyView, ErrorView, Shimmer…)
    ├── core/
    │   ├── network/           # ApiClient (Dio), ApiException, PagedResult
    │   ├── permissions/       # AppPermissions — logique RBAC centralisée
    │   ├── services/          # Services HTTP (FarmerService, TransactionService…)
    │   └── constants/         # ApiEndpoints
    ├── features/
    │   ├── auth/              # LoginPage
    │   ├── home/              # HomePage, HomeShell (navigation principale)
    │   ├── farmers/           # FarmersListPage, FarmerDetailPage, FarmerCreatePage…
    │   ├── products/          # ProductsPage (marketplace)
    │   ├── checkout/          # CheckoutPage, CheckoutSuccessPage
    │   ├── transactions/      # TransactionsPage (activité unifiée), TransactionDetailPage
    │   └── debts/             # DebtsPage, RepaymentPage
    ├── providers/             # AuthProvider, FarmerProvider, ActivityProvider…
    ├── router/                # AppRouter (go_router + garde de permissions)
    └── theme/                 # AppTheme (couleurs, typographie)
```

---

## Installation

### Prérequis

- Flutter 3.x (`flutter --version`)
- Dart 3.8+
- Un backend FarmBridge API accessible

### Lancer en développement

```bash
git clone <repo-url>
cd farmers_app

flutter pub get

# Configurer l'URL de l'API dans :
# lib/src/core/constants/api_endpoints.dart  (ou .env selon la config)

flutter run -d chrome
```

### Build web production

```bash
flutter build web --release
# Artefacts dans build/web/
```

---

## Configuration de l'API

Dans [lib/src/core/network/api_client.dart](lib/src/core/network/api_client.dart), renseigner l'URL de base du backend :

```dart
static const String baseUrl = 'https://votre-api.com/api';
```

---

## Architecture des providers

```
AuthProvider          — session utilisateur, token, permissions
FarmerProvider        — liste et CRUD agriculteurs
ProductProvider       — catalogue produits
CartProvider          — panier en cours (achat POS)
TransactionProvider   — transactions paginées
ActivityProvider      — flux unifié achats + remboursements (triés par date)
SettingsProvider      — paramètres (taux d'intérêt…)
UserProvider          — gestion des utilisateurs
NotificationProvider  — notifications in-app
```

---

## Navigation (go_router)

```
/login                          Page de connexion
/                               Accueil
/products                       Marketplace (catalogue)
/farmers                        Liste agriculteurs
/farmers/new                    Créer un agriculteur  [admin uniquement]
/farmers/:id                    Fiche agriculteur
/farmers/:id/edit               Modifier agriculteur
/transactions                   Activité (achats + remboursements)
/transactions/:id               Détail d'un achat
/checkout?farmer_id=X           Caisse POS
/checkout/success?tx_id=X       Confirmation d'achat
/debts                          Gestion des dettes
/debts/repay/:farmerId          Saisie d'un remboursement
```

---

## Thème

Couleurs principales définies dans `AppTheme` :

| Token | Valeur | Usage |
|---|---|---|
| `primaryGreen` | `#16A34A` | Actions, navigation active |
| `cashGreen` | `#15803D` | Transactions espèces |
| `creditRed` | `#DC2626` | Transactions à crédit, dettes |
| `background` | `#F9FAFB` | Fond général |
| `foreground` | `#111827` | Texte principal |

---

## Licence

Projet privé — FarmBridge © 2026
