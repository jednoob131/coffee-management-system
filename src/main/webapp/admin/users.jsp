<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="entity.User, java.util.List" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null || !user.isRole()) { response.sendRedirect(request.getContextPath() + "/index"); return; }
    List<User> users = (List<User>) request.getAttribute("users");
    if (users == null) users = new java.util.ArrayList<>();
%>
<!DOCTYPE html>
<html lang="vi">
<head>
<jsp:include page="/includes/head-common.jsp">
  <jsp:param name="title" value="Quản lý tài khoản | Polly Coffee"/>
</jsp:include>
</head>
<body class="flex min-h-screen">
<% request.setAttribute("activeNav", "admin_users");
   request.setAttribute("pageHeading", "Quản lý tài khoản");
   request.setAttribute("pageSubheading", "Phân quyền Admin / Staff — Tổng: " + users.size() + " tài khoản"); %>
<jsp:include page="/includes/dashboard-sidebar.jsp"/>
<div class="flex min-h-screen min-w-0 flex-1 flex-col">
<jsp:include page="/includes/app-header.jsp"/>
<main class="flex-1 overflow-auto p-8">
  <div id="page-header" class="mb-6 flex items-center justify-end">
    <input type="text" id="searchInput" placeholder="🔍 Tìm kiếm..."
           class="border-2 border-gray-200 rounded-xl px-4 py-2 text-sm font-bold outline-none focus:border-orange-400"
           oninput="filterUsers()">
  </div>

  <div class="bg-white rounded-2xl shadow-sm border border-orange-50 overflow-hidden">
    <table class="w-full">
      <thead class="bg-gray-50">
        <tr>
          <th class="text-left px-5 py-3 text-xs font-black text-gray-400 uppercase">Tài khoản</th>
          <th class="text-left px-5 py-3 text-xs font-black text-gray-400 uppercase">Họ tên</th>
          <th class="text-left px-5 py-3 text-xs font-black text-gray-400 uppercase">Email</th>
          <th class="text-left px-5 py-3 text-xs font-black text-gray-400 uppercase">SĐT</th>
          <th class="text-center px-5 py-3 text-xs font-black text-gray-400 uppercase">Vai trò</th>
          <th class="text-center px-5 py-3 text-xs font-black text-gray-400 uppercase">Thao tác</th>
        </tr>
      </thead>
      <tbody>
        <% if (!users.isEmpty()) {
            for (User u : users) { %>
        <tr class="user-row border-b border-gray-50 hover:bg-orange-50 transition"
            data-name="<%= u.getFullname().toLowerCase() %>"
            data-username="<%= u.getUsername().toLowerCase() %>">
          <td class="px-5 py-4 font-black text-sm text-gray-800"><%= u.getUsername() %></td>
          <td class="px-5 py-4 font-bold text-sm text-gray-700"><%= u.getFullname() %></td>
          <td class="px-5 py-4 text-sm text-gray-500"><%= u.getEmail() != null ? u.getEmail() : "—" %></td>
          <td class="px-5 py-4 text-sm text-gray-500"><%= u.getPhone() != null ? u.getPhone() : "—" %></td>
          <td class="px-5 py-4 text-center">
            <% if (u.isRole()) { %>
            <span class="text-xs font-black px-3 py-1 rounded-full bg-orange-100 text-orange-600">Admin</span>
            <% } else { %>
            <span class="text-xs font-black px-3 py-1 rounded-full bg-blue-100 text-blue-600">Staff</span>
            <% } %>
          </td>
          <td class="px-5 py-4 text-center">
            <div class="flex items-center justify-center gap-2">
              <form action="<%= request.getContextPath() %>/admin/users" method="post" style="display:inline">
                <input type="hidden" name="action" value="toggleRole">
                <input type="hidden" name="username" value="<%= u.getUsername() %>">
                <button type="submit"
                        onclick="return confirm('Đổi quyền tài khoản <%= u.getUsername() %>?')"
                        class="text-xs font-black px-3 py-1.5 rounded-lg border-2 border-orange-300 text-orange-500 hover:bg-orange-50 transition">
                  Đổi quyền
                </button>
              </form>
              <% if (!u.getUsername().equals(user.getUsername())) { %>
              <% } %>
            </div>
          </td>
        </tr>
        <% } } else { %>
        <tr><td colspan="6" class="px-5 py-8 text-center text-gray-400 font-bold">Chưa có tài khoản nào</td></tr>
        <% } %>
      </tbody>
    </table>
  </div>
</main>

<script>
function filterUsers() {
  const q = document.getElementById('searchInput').value.toLowerCase();
  document.querySelectorAll('.user-row').forEach(r => {
    r.style.display = (r.dataset.name.includes(q) || r.dataset.username.includes(q)) ? '' : 'none';
  });
}

window.addEventListener('DOMContentLoaded', () => {
  const tl = gsap.timeline();
  tl.from('#page-header', { y: 20, opacity: 0, duration: 0.6, ease: 'power3.out' });

  tl.from('.user-row', {
    y: 15,
    opacity: 0,
    stagger: 0.04,
    duration: 0.4,
    ease: 'power2.out',
    clearProps: "all"
  }, "-=0.2");
});
</script>
<jsp:include page="/includes/app-footer.jsp"/>
</div>
<jsp:include page="/includes/sidebar-gsap.jsp"/>
</body>
</html>
