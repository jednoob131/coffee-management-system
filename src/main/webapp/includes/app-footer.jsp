<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<footer class="shrink-0 border-t border-orange-100 bg-white/85 py-3 text-center text-[11px] font-semibold text-gray-400 backdrop-blur-sm">
  <span class="text-gray-500">Polly Coffee</span>
  ·
  <a href="<%= request.getContextPath() %>/index" class="text-[#FF9F1C] hover:underline">Dashboard</a>
  ·
  <span class="tabular-nums"><%= java.time.Year.now() %></span>
</footer>
