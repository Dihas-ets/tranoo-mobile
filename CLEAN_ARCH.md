# Clean architecture progressive — suivi

Scope actuel : **catalogue** (`marque`, listes, détails, une).  
Mettre à jour ce fichier à **chaque** extraction / branchement.

Compter les lignes : `(Get-Content path | Measure-Object -Line).Lines`

---

## Fait

### Models (`lib/data/models/`)

| Fichier | Contenu |
|---------|---------|
| `article.dart` | `Article` (pièces) |
| `article_voiture.dart` | `ArticleVoiture` |
| `pub.dart` | `Pub` |

Sortis de `marque.dart`.

### Utils

| Fichier | Contenu |
|---------|---------|
| `lib/utils/catalog_display.dart` | `formatPrice`, `isPubValid`, `formatCompactCount` |
| `lib/utils/catalog_filter_options.dart` | options filtres catalogue |

### Repositories (`lib/data/repositories/`)

| Repo | API principale | Consommateurs |
|------|----------------|---------------|
| `MarqueRepository` | fetch pièces/voitures/motos/pubs (+ stale cache), stats vendeur, pub/article by id | `marque.dart` + controller |
| `CatalogRepository` | `fetchPublicArticles`, `fetchMotosForFilters`, `deleteArticle`, `fetchPublicArticle`, `toggleFavorite` ; caches `catalog_voitures` / `catalog_motos` / `catalog_pieces` | `voitures`, `motos`, `piece`, `cars_info`, `moto_info`, marque sections |
| `UneRepository` | `createArticle`, `fetchArticle`, `articleExists`, prix/jour, `createPublicite`, `updatePubliciteStatut` | `une.dart` |

### Marque — extractions UI / état

| Fichier | Rôle |
|---------|------|
| `marque/marque_catalog_controller.dart` | fetchers + cache + état catalogue |
| `marque/marque_search_bar.dart` | barre recherche |
| `marque/marque_filter_panels.dart` | chips / localisation / budget |
| `marque/marque_pubs_carousel.dart` | carousel pubs |
| `marque/marque_catalog_sections.dart` | grilles catalogue |
| `marque/marque_seller_stats.dart` | stats vendeur |
| `marque/marque_services_summary.dart` | résumé services |
| `marque/marque_search_dialogs.dart` | dialogs recherche |
| `marque/marque_sponsored_pub.dart` | tap pub sponsorisée + nav |
| `marque/marque_flyer_preview.dart` | preview flyer |

`marque.dart` : **~702 L** (était ~1727). **Plus de HTTP direct** dans l’écran.

### Widgets catalogue partagés (`lib/widgets/`)

| Fichier | Rôle | Branché sur |
|---------|------|-------------|
| `catalog_article_grid_card.dart` | carte grille voiture/moto | voitures, motos, marque |
| `catalog_piece_grid_card.dart` | carte grille pièce | piece, marque |
| `catalog_list_chrome.dart` | search bar + tabs listes | voitures, motos, piece |
| `catalog_filter_sections.dart` | panneaux filtres | listes / marque |
| `catalog_filter_brand_logo.dart` | logo marque filtre | filtres |
| `catalog_detail_sections.dart` | sections UI détail | `cars_info`, `moto_info` |

### Détails — partiel

- `cars_info` / `moto_info` : sections UI + favoris / article public via `CatalogRepository`
- `cars_info` : **reste** 1 `http.get` (pricing vérification)
- `mastervacpage` : **reste** `http.get` `/public/articles/:id` (pas encore repo)

### Une — partiel

- HTTP → `UneRepository` (déjà)
- UI extraite sous `lib/data/screens/une/` :
  - `une_labels.dart` — constantes + labels i18n
  - `une_mode_banner.dart` — bannière mode + statut article
  - `une_car_info_section.dart` — champs véhicule (sponsorisée)
  - `une_featured_flyer.dart` — flyer « À la une »
  - `une_sponsored_media.dart` — grille images + vidéo
- `une.dart` : **~1203 L** (était ~1853). Logic paiement / Cloudinary / create encore dans l’écran.

### Commits de référence (ordre)

```
f408f72  refactor(models): Article, ArticleVoiture, Pub
8ebc15c  refactor(utils): formatPrice, isPubValid, formatCompactCount
ba0e06c  refactor(marque): état catalogue dans le State
ac5b644  refactor(marque): MarqueRepository
702293c  refactor(marque): carousel + sections catalogue
2542cd7  (réf. messages) + purge legacy / filter panels
4e7ce9d  refactor(marque): stats, services, dialogs recherche
d3976c7  refactor(marque): pub sponsorisée + flyer ; MarqueRepository HTTP
bd88b82  refactor(marque): MarqueCatalogController + search bar
575dca2  refactor(catalog): CatalogRepository + listes
375daa8  refactor(catalog): cartes, chrome, détails, UneRepository
```

---

## Backlog (ordre)

### Sprint en cours — catalogue

1. ~~**`une.dart` UI**~~ — labels + banner + car info + médias extraits (~1853 → ~1203 L)
2. **Listes `voitures` / `motos` / `piece` (~945 / ~862 / ~946 L)** — controller partagé (orchestration + filtres encore tripliqués)
3. **`cars_info`** — sortir le `http.get` pricing vers repo
4. **`mastervacpage`** — brancher `CatalogRepository.fetchPublicArticle`
5. **`une.dart` (reste)** — optionnel : media pickers / `_onPayer` helpers si encore trop gras
6. **`marque.dart` (~702 L)** — slim seulement si duplication claire avec listes

### Après catalogue

| Écran | ~L | Note |
|-------|-----|------|
| `create_sell.dart` | 1644 | multipart HTTP in UI |
| `notifications.dart` | 1576 | beaucoup de HTTP inline |
| `mesfactures.dart` | 1381 | |
| `create_sell2.dart` | 1140 | twin sell |
| `create_sell_moto.dart` | 1032 | twin sell |
| profils (`profilutilisateurpage`, `profil3`, `profil_utilisateur2`) | ~637–676 | wallet/HTTP dupliqué |

---

## Journal

| Date | Action | Δ lignes / fichiers |
|------|--------|---------------------|
| 2026-09-23 | Création de ce fichier ; snapshot post-`375daa8` | — |
| 2026-09-23 | `une` UI : labels, mode banner, car info, flyer, médias | `une.dart` ~1853 → ~1203 ; +5 fichiers `screens/une/` |
