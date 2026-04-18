import createMiddleware from "next-intl/middleware";
import { routing } from "./i18n/routing";

export default createMiddleware(routing);

export const config = {
  matcher: [
    // Run on everything except Next internals, static assets, and API routes
    "/((?!api|_next|_vercel|.*\\..*).*)",
  ],
};
