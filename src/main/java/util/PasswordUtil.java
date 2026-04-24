package util;

import org.mindrot.jbcrypt.BCrypt;

public class PasswordUtil {

    // mã hoá password
    public static String hashPassword(String password) {
        return BCrypt.hashpw(password, BCrypt.gensalt());
    }

    // kiểm tra password
    public static boolean checkPassword(String password, String hash) {
        return BCrypt.checkpw(password, hash);
    }
}