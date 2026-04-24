package filter;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import java.io.IOException;

public class Utf8Filter implements Filter {

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest  req  = (HttpServletRequest)  request;
        HttpServletResponse resp = (HttpServletResponse) response;

        if (req.getCharacterEncoding() == null) {
            req.setCharacterEncoding("UTF-8");
        }
        resp.setCharacterEncoding("UTF-8");
        resp.setContentType("text/html; charset=UTF-8");

        chain.doFilter(request, response);
    }

    @Override public void init(FilterConfig f) {}
    @Override public void destroy() {}
}
