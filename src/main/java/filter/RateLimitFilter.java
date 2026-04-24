package filter;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.atomic.AtomicInteger;

public class RateLimitFilter implements Filter {

    private static final int  MAX_REQUESTS   = 60;
    private static final long TIME_WINDOW_MS = 10_000;

    private static class RequestCount {
        AtomicInteger count       = new AtomicInteger(0);
        long          windowStart = System.currentTimeMillis();
    }

    private final ConcurrentHashMap<String, RequestCount> ipMap = new ConcurrentHashMap<>();

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest  req  = (HttpServletRequest)  request;
        HttpServletResponse resp = (HttpServletResponse) response;
        String ip = req.getRemoteAddr();

        RequestCount rc = ipMap.computeIfAbsent(ip, k -> new RequestCount());
        long now = System.currentTimeMillis();

        synchronized (rc) {
            if (now - rc.windowStart > TIME_WINDOW_MS) {
                rc.windowStart = now;
                rc.count.set(0);
            }
            if (rc.count.incrementAndGet() > MAX_REQUESTS) {
                resp.setStatus(429);
                resp.setContentType("text/html;charset=UTF-8");
                resp.getWriter().write(
                    "<h2 style='font-family:sans-serif;text-align:center;margin-top:100px;color:#FF9F1C'>" +
                    "⚠ Quá nhiều yêu cầu. Vui lòng thử lại sau.</h2>");
                return;
            }
        }

        chain.doFilter(request, response);
    }

    @Override public void init(FilterConfig f) {}
    @Override public void destroy() {}
}
