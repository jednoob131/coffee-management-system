<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%-- Gọi: <jsp:include page="/includes/head-common.jsp"><jsp:param name="title" value="..."/></jsp:include> --%>
<% String _headTitle = request.getParameter("title");
   if (_headTitle == null || _headTitle.isEmpty()) _headTitle = "Polly Coffee"; %>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title><%= _headTitle %></title>
<script src="https://cdn.tailwindcss.com"></script>
<link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:ital,wght@0,400;0,600;0,700;0,800;1,800&display=swap" rel="stylesheet">
<script src="https://cdnjs.cloudflare.com/ajax/libs/gsap/3.12.2/gsap.min.js"></script>
<style>
  body { font-family: 'Plus Jakarta Sans', sans-serif; background: #FFF8F0; }
  .sidebar-link {
    display: flex; align-items: center; gap: 10px;
    padding: 10px 14px; border-radius: 12px;
    font-weight: 700; font-size: .85rem; color: #6b7280;
    text-decoration: none; transition: all .2s;
  }
  .sidebar-link:hover { background: rgba(255, 159, 28, 0.1); color: #FF9F1C; }
  .sidebar-link.active { background: #FF9F1C; color: #fff; }
 #dashboard-sidebar {
   width: 15rem;
   transition: box-shadow 0.2s;
 }
  #sidebarLogoBtn { transition: transform 0.2s ease, box-shadow 0.2s; }
  #sidebarLogoBtn:hover { transform: scale(1.05); }
  #sidebarLogoBtn:active { transform: scale(0.97); }
  #sidebarBrand { white-space: nowrap; overflow: hidden; }
</style>
