# Leçons techniques — Librarfree

Journal des corrections. Format : `### [YYYY-MM-DD] Catégorie : titre` (ce qui a cassé, pourquoi, règle pour éviter).

### [2026-07-01] Sécurité RLS : policy `OR true` et `FOR ALL` sur tables exposées via anon

**Ce qui a cassé.** Deux familles de trous d'exposition de données, découverts via des PR de bots chasseurs de prime sur l'issue #100, puis corrigés proprement dans la PR #196.

1. `users_self_select` utilisait `USING (id = current_auth_uid() OR true)`. Le `OR true` rendait toute la table `users` (email, reader_prefs, location, stats) lisible par n'importe quel navigateur. Idem `donations` avec `OR anonymous = FALSE` (ids Stripe, messages donateurs).
2. `reading_lists`, `reading_list_books` et `annotations` étaient en une seule policy `FOR ALL` dont le `USING` autorisait les lignes publiques. Comme un `DELETE`/`UPDATE` n'évalue que la clause `USING`, n'importe qui pouvait supprimer une liste publique ou une annotation non privée d'autrui, voire en voler la propriété via `UPDATE`.

**Pourquoi c'était exploitable.** `packages/utils/src/supabase.ts` expose un `browserClient()` avec la clé anon. L'API PostgREST anon est donc ouverte côté navigateur : les policies RLS sont la seule barrière. Une policy permissive = fuite directe.

**Règles pour éviter.**

- Jamais de `OR true` ni `USING (true)` sur une table atteignable par le rôle `anon`/`authenticated`. Pour du rendu public, exposer une **vue projection** de colonnes sûres (ex. `public_user_profiles`, sans email) et garder la table brute en accès propriétaire.
- Ne pas mélanger lecture publique et écriture dans une policy `FOR ALL`. Séparer : une policy `FOR SELECT` (condition publique) + des policies `INSERT`/`UPDATE`/`DELETE` propriétaire uniquement. Se rappeler que `DELETE` ne regarde que `USING`, et qu'un `UPDATE` sans `WITH CHECK` strict permet la réassignation d'ownership.
- Toute nouvelle table interne (analytics, config, jobs) : `ENABLE ROW LEVEL SECURITY` sans policy (deny-all) ; l'accès serveur passe par `service_role` qui bypass RLS. Ne pas compter sur l'absence de policy, compter sur RLS activé.
- Épingler `search_path = public, pg_temp` sur toute fonction `SECURITY DEFINER`.
- Valider un changement RLS en simulant le rôle non privilégié (`SET ROLE` + `SET request.jwt.claim.sub`), pas seulement en tant que superuser (le propriétaire de table bypass sa propre RLS).
