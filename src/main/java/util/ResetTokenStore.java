package util;

import java.time.LocalDateTime;
import java.util.concurrent.ConcurrentHashMap;

public class ResetTokenStore {

    public static class TokenInfo {

        private String email;
        private LocalDateTime expiry;

        public TokenInfo(String email, LocalDateTime expiry) {
            this.email = email;
            this.expiry = expiry;
        }

        public String getEmail() {
            return email;
        }

        public LocalDateTime getExpiry() {
            return expiry;
        }
    }

    private static ConcurrentHashMap<String, TokenInfo> tokens
            = new ConcurrentHashMap<>();


    public static void saveToken(String token, String email, int minutes) {

        LocalDateTime expiry = LocalDateTime.now().plusMinutes(minutes);

        tokens.put(token, new TokenInfo(email, expiry));
    }

    public static TokenInfo getToken(String token) {

        TokenInfo info = tokens.get(token);

        if (info == null) {
            return null;
        }

        if (LocalDateTime.now().isAfter(info.getExpiry())) {

            tokens.remove(token);
            return null;
        }

        return info;
    }

    public static void removeToken(String token) {
        tokens.remove(token);
    }

}