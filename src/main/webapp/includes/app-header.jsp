<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<% String _ph = (String) request.getAttribute("pageHeading");
   String _ps = (String) request.getAttribute("pageSubheading");
   if (_ph != null && !_ph.isEmpty()) { %>
<header class="shrink-0 border-b border-orange-100/80 bg-white/70 px-6 py-4 backdrop-blur-md">
  <h1 class="text-xl font-black tracking-tight text-gray-900 md:text-2xl"><%= _ph %></h1>
  <% if (_ps != null && !_ps.isEmpty()) { %>
  <p class="mt-1 text-sm font-semibold text-gray-500"><%= _ps %></p>
  <% } %>
</header>
<% } %>
