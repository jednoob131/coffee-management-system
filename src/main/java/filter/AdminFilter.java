package filter;

import entity.User;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import java.io.IOException;

public class AdminFilter implements Filter {

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest  req  = (HttpServletRequest)  request;
        HttpServletResponse resp = (HttpServletResponse) response;

        HttpSession session = req.getSession(false);
        if (session != null) {
            User user = (User) session.getAttribute("user");
            if (user != null && user.isRole()) {
                chain.doFilter(request, response);
                return;
            }
        }

        resp.sendRedirect(req.getContextPath() + "/index");
    }

    @Override public void init(FilterConfig f) {}
    @Override public void destroy() {}
}
