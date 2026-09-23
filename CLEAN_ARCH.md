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
| `CatalogRepository` | `fetchPublicArticles`, `fetchMotosForFilters`, `deleteArticle`, `fetchPublicArticle`, `fetchVerificationPricing`, `toggleFavorite` ; caches `catalog_*` | listes, détails, marque sections |
| `UneRepository` | `createArticle`, `fetchArticle`, `articleExists`, prix/jour, `createPublicite`, `updatePubliciteStatut` | `une.dart` |

### Controllers

| Fichier | Rôle |
|---------|------|
| `marque/marque_catalog_controller.dart` | fetchers + cache + état marque |
| `catalog_list_controller.dart` | fetch/cache/auto-refresh/delete listes (voitures, motos, piece) |

### Marque — extractions UI / état

| Fichier | Rôle |
|---------|------|
| `marque/marque_search_bar.dart` | barre recherche |
| `marque/marque_filter_panels.dart` | chips / localisation / budget |
| `marque/marque_pubs_carousel.dart` | carousel pubs |
| `marque/marque_catalog_sections.dart` | grilles catalogue |
| `marque/marque_seller_stats.dart` | stats vendeur |
| `marque/marque_services_summary.dart` | résumé services |
| `marque/marque_search_dialogs.dart` | dialogs recherche |
| `marque/marque_sponsored_pub.dart` | tap pub sponsorisée + nav |
| `marque/marque_flyer_preview.dart` | preview flyer |

`marque.dart` : **~702 L**. **Plus de HTTP direct**.

### Widgets catalogue partagés (`lib/widgets/`)

| Fichier | Rôle | Branché sur |
|---------|------|-------------|
| `catalog_article_grid_card.dart` | carte grille voiture/moto | voitures, motos, marque |
| `catalog_piece_grid_card.dart` | carte grille pièce | piece, marque |
| `catalog_list_chrome.dart` | search bar + tabs listes | voitures, motos, piece |
| `catalog_filter_sections.dart` | panneaux filtres | listes / marque |
| `catalog_filter_brand_logo.dart` | logo marque filtre | filtres |
| `catalog_detail_sections.dart` | sections UI détail | `cars_info`, `moto_info` |

### Détails

- `cars_info` / `moto_info` : sections UI + favoris / article via `CatalogRepository`
- `cars_info` : pricing vérif → `fetchVerificationPricing` (**plus de HTTP direct**)
- `mastervacpage` : détail → `fetchPublicArticle` (**plus de HTTP direct**)

### Listes

- `voitures` / `motos` / `piece` : orchestration via `CatalogListController`
- Filtres / alertes / grilles restent dans les écrans

### Une

- HTTP → `UneRepository`
- UI sous `lib/data/screens/une/` : labels, mode banner, car info, flyer, médias
- `une.dart` : **~1203 L** (était ~1853). Paiement / Cloudinary / create encore dans l’écran.

### Commits de référence (ordre)

```
f408f72 … 375daa8  (voir git log refactor)
(+ à committer) une UI, CLEAN_ARCH, CatalogListController, détails HTTP
```

---

## Backlog (ordre)

### Catalogue — reste optionnel

1. ~~une UI~~ / ~~list controller~~ / ~~HTTP cars_info~~ / ~~HTTP mastervacpage~~
2. **Filtres listes** encore tripliqués (voitures/motos/piece) — extraire si besoin
3. **`une.dart` reste** — `_onPayer` / Cloudinary si encore trop gras
4. **`marque.dart` (~702 L)** — slim seulement si duplication claire

### Après catalogue (prochaine branche)

| Écran | ~L | Note |
|-------|-----|------|
| `create_sell.dart` | 1644 | multipart HTTP in UI |
| `notifications.dart` | 1576 | beaucoup de HTTP inline |
| `mesfactures.dart` | 1381 | |
| `create_sell2.dart` / `create_sell_moto.dart` | ~1140 / ~1032 | twins sell |
| profils | ~637–676 | wallet/HTTP dupliqué |

---

## Journal

| Date | Action | Δ lignes / fichiers |
|------|--------|---------------------|
| 2026-09-23 | Création fichier ; snapshot post-`375daa8` | — |
| 2026-09-23 | `une` UI : labels, banner, car info, flyer, médias | ~1853 → ~1203 ; +5 sous `screens/une/` |
| 2026-09-23 | `CatalogListController` + brancher 3 listes | fetch/cache/timer unifiés |
| 2026-09-23 | `cars_info` pricing + `mastervacpage` détail → repo | plus de HTTP direct détails catalogue |
