package com.salonvala.salonmanagement.security.config;

import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;

public class SecurityUtils {

    /**
     * Returns current user id stored in Authentication details or request attribute.
     */
    public static Long getCurrentUserId() {
        try {
            Authentication auth = SecurityContextHolder.getContext().getAuthentication();
            if (auth == null) return null;

            // auth.getDetails() might be the web details object, so we check request attribute first
            Object details = auth.getDetails();
            if (details instanceof String) {
                return Long.valueOf((String) details);
            }

            // if not available, sometimes the mobile is principal; attempt to read name as mobile (not id)
            String name = auth.getName(); // this returns username (mobile)
            return null; // fallback: return null; prefer request attribute retrieval in controllers
        } catch (Exception e) {
            return null;
        }
    }

    /**
     * Try to get the userId from a HttpServletRequest attribute (if set by filter).
     * Use this in controllers when getting id from request is acceptable:
     *
     * Long userId = Long.valueOf((String) request.getAttribute("currentUserId"));
     */
}
