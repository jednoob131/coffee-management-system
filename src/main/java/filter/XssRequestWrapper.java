package filter;

import jakarta.servlet.http.*;

public class XssRequestWrapper extends HttpServletRequestWrapper {

    public XssRequestWrapper(HttpServletRequest request) {
        super(request);
    }

    @Override
    public String getParameter(String name) {
        return sanitize(super.getParameter(name));
    }

    @Override
    public String[] getParameterValues(String name) {
        String[] values = super.getParameterValues(name);
        if (values == null) return null;
        String[] sanitized = new String[values.length];
        for (int i = 0; i < values.length; i++) {
            sanitized[i] = sanitize(values[i]);
        }
        return sanitized;
    }

    private String sanitize(String input) {
        if (input == null) return null;
        return input
            .replaceAll("<",  "&lt;")
            .replaceAll(">",  "&gt;")
            .replaceAll("\"", "&quot;")
            .replaceAll("'",  "&#x27;")
            .replaceAll("javascript:", "")
            .replaceAll("on\\w+=\"[^\"]*\"", "");
    }
}
