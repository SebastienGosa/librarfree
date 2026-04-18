/**
 * Supabase client factories for the three Next.js contexts.
 *
 *   - browserClient()   : client components, "use client"
 *   - serverClient(cs)  : Server Components / Route Handlers / Server Actions — needs a CookieStore
 *   - adminClient()     : privileged operations (Stripe webhooks, cron jobs) — NEVER ship to client
 *
 * Depends on `@supabase/ssr` so the same factories work in middleware, server
 * components, and route handlers.
 */
import { createBrowserClient, createServerClient, type CookieOptions } from "@supabase/ssr";
import { createClient, type SupabaseClient } from "@supabase/supabase-js";

function required(name: string): string {
  const value = process.env[name];
  if (!value) throw new Error(`[@librarfree/utils/supabase] Missing env var: ${name}`);
  return value;
}

export function browserClient(): SupabaseClient {
  return createBrowserClient(
    required("NEXT_PUBLIC_SUPABASE_URL"),
    required("NEXT_PUBLIC_SUPABASE_ANON_KEY"),
  );
}

/**
 * A CookieStore-shaped object. In Next 15, pass `await cookies()` from
 * `next/headers` — its `getAll`/`set` API matches what the adapter expects.
 */
export interface CookieStore {
  getAll(): { name: string; value: string }[];
  set?(name: string, value: string, options?: CookieOptions): void;
  delete?(name: string, options?: CookieOptions): void;
}

interface CookieToSet {
  name: string;
  value: string;
  options?: CookieOptions;
}

export function serverClient(cookieStore: CookieStore): SupabaseClient {
  return createServerClient(
    required("NEXT_PUBLIC_SUPABASE_URL"),
    required("NEXT_PUBLIC_SUPABASE_ANON_KEY"),
    {
      cookies: {
        getAll() {
          return cookieStore.getAll();
        },
        setAll(cookiesToSet: CookieToSet[]) {
          for (const { name, value, options } of cookiesToSet) {
            try {
              cookieStore.set?.(name, value, options);
            } catch {
              // Server Components can't set cookies — silently noop, middleware picks it up.
            }
          }
        },
      },
    },
  );
}

/**
 * Service-role client — full bypass of RLS. USE ONLY IN SERVER-ONLY CONTEXTS
 * (cron jobs, webhooks, seeders, admin routes). Never import from client code.
 */
export function adminClient(): SupabaseClient {
  return createClient(
    required("NEXT_PUBLIC_SUPABASE_URL"),
    required("SUPABASE_SERVICE_ROLE_KEY"),
    {
      auth: {
        autoRefreshToken: false,
        persistSession: false,
      },
    },
  );
}
