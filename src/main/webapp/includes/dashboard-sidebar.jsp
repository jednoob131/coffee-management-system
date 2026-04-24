<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="entity.User" %>
<%
  User _sidebarUser = (User) session.getAttribute("user");
  if (_sidebarUser == null) return;
  boolean _isAdmin = _sidebarUser.isRole();
  String _nav = (String) request.getAttribute("activeNav");
  if (_nav == null) _nav = "";
  String _ctx = request.getContextPath();
%>
<aside id="dashboard-sidebar" data-open="false" class="relative z-20 flex shrink-0 flex-col overflow-hidden border-r border-gray-100 bg-white/90 shadow-[4px_0_24px_rgba(0,0,0,0.02)] backdrop-blur-md min-h-screen py-5 px-2">
  <div class="mb-6 flex min-h-[44px] items-center gap-2 px-1">
    <button type="button" id="sidebarLogoBtn" class="flex h-11 w-11 shrink-0 cursor-pointer items-center justify-center rounded-xl bg-[#FF9F1C] shadow-lg shadow-orange-200 outline-none ring-offset-2 focus-visible:ring-2 focus-visible:ring-[#FF9F1C]" aria-expanded="false" aria-controls="sidebarNav" aria-label="Mở menu Polly Coffee">
      <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="white" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">
        <path d="M17 8h1a4 4 0 1 1 0 8h-1"/><path d="M3 8h14v9a4 4 0 0 1-4 4H7a4 4 0 0 1-4-4Z"/>
      </svg>
    </button>
    <div id="sidebarBrand" class="pointer-events-none min-w-0 font-black text-lg leading-tight text-gray-800" style="max-width: 0; opacity: 0;">
      Polly<span class="text-[#FF9F1C]">Coffee</span>
    </div>
  </div>
<nav id="sidebarNav"
 class="flex min-h-0 flex-1 flex-col gap-1 overflow-x-hidden overflow-y-auto px-1"
 aria-hidden="false">
    <p class="text-[10px] font-black uppercase tracking-widest text-gray-400 px-3 mb-1">Menu chính</p>
    <a href="<%= _ctx %>/index" class="sidebar-link <%= "dashboard".equals(_nav) ? "active" : "" %>">
      <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect width="7" height="9" x="3" y="3" rx="1"/><rect width="7" height="5" x="14" y="3" rx="1"/><rect width="7" height="9" x="14" y="12" rx="1"/><rect width="7" height="5" x="3" y="16" rx="1"/></svg>
      <%= "dashboard".equals(_nav) ? "Không gian 3D" : "Dashboard" %>
    </a>

    <% if (_isAdmin) { %>
    <p class="text-[10px] font-black uppercase tracking-widest text-gray-400 px-3 mb-1 mt-6">Quản lý</p>
    <a href="<%= _ctx %>/admin/drinks" class="sidebar-link <%= "admin_drinks".equals(_nav) ? "active" : "" %>">
      <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M17 8h1a4 4 0 1 1 0 8h-1"/><path d="M3 8h14v9a4 4 0 0 1-4 4H7a4 4 0 0 1-4-4Z"/></svg>
      Quản lý đồ uống
    </a>
    <a href="<%= _ctx %>/admin/users" class="sidebar-link <%= "admin_users".equals(_nav) ? "active" : "" %>">
      <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M16 21v-2a4 4 0 0 0-4-4H6a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/></svg>
      Quản lý tài khoản
    </a>
    <a href="<%= _ctx %>/admin/bills" class="sidebar-link <%= "admin_bills".equals(_nav) ? "active" : "" %>">
      <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/></svg>
      Danh sách hóa đơn
    </a>
    <a href="<%= _ctx %>/admin/report" class="sidebar-link <%= "admin_report".equals(_nav) ? "active" : "" %>">
      <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><line x1="18" x2="18" y1="20" y2="10"/><line x1="12" x2="12" y1="20" y2="4"/><line x1="6" x2="6" y1="20" y2="14"/></svg>
      Thống kê doanh thu
    </a>
    <% } else { %>
    <p class="text-[10px] font-black uppercase tracking-widest text-gray-400 px-3 mb-1 mt-6">Nghiệp vụ</p>
    <a href="<%= _ctx %>/staff/drinks" class="sidebar-link <%= "staff_drinks".equals(_nav) ? "active" : "" %>">
      <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M17 8h1a4 4 0 1 1 0 8h-1"/><path d="M3 8h14v9a4 4 0 0 1-4 4H7a4 4 0 0 1-4-4Z"/></svg>
      Xem đồ uống
    </a>
    <a href="<%= _ctx %>/staff/bills" class="sidebar-link <%= "staff_bills".equals(_nav) ? "active" : "" %>">
      <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/></svg>
      Tạo hóa đơn
    </a>
    <% } %>
  </nav>

<div id="sidebarUser"
 class="mt-4 rounded-xl border border-orange-100 bg-orange-50/50 p-3 px-1"
 aria-hidden="false">
    <div class="flex items-center gap-3 mb-2">
      <div class="flex h-8 w-8 shrink-0 items-center justify-center rounded-full bg-[#FF9F1C] text-sm font-black text-white shadow-sm">
        <%= _sidebarUser.getFullname().substring(0,1).toUpperCase() %>
      </div>
      <div class="min-w-0">
        <p class="truncate text-sm font-black leading-tight text-gray-800"><%= _sidebarUser.getFullname() %></p>
        <p class="text-[10px] font-bold uppercase text-[#FF9F1C]"><%= _isAdmin ? "Admin" : "Staff" %></p>
      </div>
    </div>
    <a href="<%= _ctx %>/login/logout" class="mt-2 flex items-center gap-2 text-xs font-bold text-red-400 transition-colors hover:text-red-600" onclick="return confirm('Bạn có chắc muốn đăng xuất?')">
      <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4"/><polyline points="16 17 21 12 16 7"/><line x1="21" x2="9" y1="12" y2="12"/></svg>
      Đăng xuất
    </a>
  </div>
</aside>
