package util;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.Part;
import java.io.File;
import java.io.InputStream;
import java.io.OutputStream;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.UUID;

public class FileUtil {

    private static final String UPLOAD_DIR = "uploads";

    private static final String[] ALLOWED_TYPES = {
        "image/jpeg", "image/png", "image/gif", "image/webp", "image/jpg"
    };

    /**
     * Upload ảnh từ form field.
     * Trả về đường dẫn tương đối (vd: "uploads/abc.jpg") hoặc null nếu lỗi.
     *
     * Servlet cần có @MultipartConfig để dùng được req.getPart()
     */
    public static String uploadImage(HttpServletRequest req, String fieldName) {
        try {
            Part part = req.getPart(fieldName);
            if (part == null || part.getSize() == 0) return null;
            if (!isAllowedImageType(part.getContentType())) return null;

            String ext     = getExtension(getSubmittedFileName(part));
            String newName = UUID.randomUUID().toString() + ext;

            String uploadPath = req.getServletContext().getRealPath("")
                              + File.separator + UPLOAD_DIR;
            new File(uploadPath).mkdirs();

            try (InputStream in  = part.getInputStream();
                 OutputStream out = Files.newOutputStream(Paths.get(uploadPath + File.separator + newName))) {
                byte[] buf = new byte[4096];
                int n;
                while ((n = in.read(buf)) != -1) out.write(buf, 0, n);
            }

            return UPLOAD_DIR + "/" + newName;

        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }

    /** Xóa file khỏi thư mục uploads */
    public static boolean deleteFile(HttpServletRequest req, String relativePath) {
        if (relativePath == null || relativePath.isEmpty()) return false;
        try {
            String fullPath = req.getServletContext().getRealPath("")
                + File.separator + relativePath.replace("/", File.separator);
            File file = new File(fullPath);
            return file.exists() && file.delete();
        } catch (Exception e) { return false; }
    }

    /** Kiểm tra content type có phải ảnh hợp lệ */
    public static boolean isAllowedImageType(String contentType) {
        if (contentType == null) return false;
        for (String t : ALLOWED_TYPES)
            if (t.equalsIgnoreCase(contentType)) return true;
        return false;
    }

    /** Lấy tên file gốc từ Part */
    public static String getSubmittedFileName(Part part) {
        String header = part.getHeader("content-disposition");
        if (header == null) return "";
        for (String token : header.split(";")) {
            if (token.trim().startsWith("filename"))
                return token.substring(token.indexOf('=') + 1).trim().replace("\"", "");
        }
        return "";
    }

    /** Lấy extension (vd: ".jpg") */
    public static String getExtension(String filename) {
        if (filename == null || !filename.contains(".")) return ".jpg";
        return filename.substring(filename.lastIndexOf(".")).toLowerCase();
    }

    /** Kiểm tra Part có file không */
    public static boolean hasFile(Part part) {
        return part != null && part.getSize() > 0 && !getSubmittedFileName(part).isEmpty();
    }

    /** Format kích thước file */
    public static String formatSize(long bytes) {
        if (bytes < 1024) return bytes + " B";
        if (bytes < 1024 * 1024) return String.format("%.1f KB", bytes / 1024.0);
        return String.format("%.1f MB", bytes / (1024.0 * 1024));
    }
}
