<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="vi">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Đăng nhập | Polly Coffee</title>
<script src="https://cdn.tailwindcss.com"></script>
<link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:ital,wght@0,400;0,700;0,800;1,800&display=swap" rel="stylesheet">
<script src="https://cdnjs.cloudflare.com/ajax/libs/gsap/3.12.2/gsap.min.js"></script>
<style>
  body { font-family: 'Plus Jakarta Sans', sans-serif; background-color: #FDFCF6; overflow: hidden; }
  .login-card { opacity: 0; transform: translateY(30px); }
  .orange-shape { position: absolute; z-index: -1; filter: blur(80px); border-radius: 50%; background: #FF9F1C; opacity: 0.15; }
  .btn-ripple {
    position: absolute;
    border-radius: 9999px;
    pointer-events: none;
    transform: translate(-50%, -50%) scale(0);
    background: rgba(255, 255, 255, .45);
    mix-blend-mode: screen;
  }
</style>
</head>
<body class="flex items-center justify-center min-h-screen">

  <div class="orange-shape w-[500px] h-[500px] -top-20 -left-20"></div>
  <div class="orange-shape w-[400px] h-[400px] -bottom-20 -right-20"></div>

  <div class="login-card w-full max-w-[1000px] h-[600px] bg-white rounded-[40px] shadow-[0_30px_60px_rgba(0,0,0,0.12)] flex overflow-hidden border-8 border-white">

    <!-- Left -->
    <div class="w-1/2 bg-[#FF9F1C] flex flex-col items-center justify-center p-12 text-white relative">
      <div id="logo-container" class="w-28 h-28 bg-white rounded-[32px] flex items-center justify-center mb-8 shadow-2xl">
            <svg xmlns="http://www.w3.org/2000/svg" width="48" height="48" viewBox="0 0 24 24"
             fill="none" stroke="#FF9F1C" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
          <path d="M17 8h1a4 4 0 1 1 0 8h-1"/>
          <path d="M3 8h14v9a4 4 0 0 1-4 4H7a4 4 0 0 1-4-4Z"/>
          <line x1="6" x2="6" y1="2" y2="4"/>
          <line x1="10" x2="10" y1="2" y2="4"/>
          <line x1="14" x2="14" y1="2" y2="4"/>
        </svg>
      </div>
      <h2 id="brand-name" class="text-4xl font-black tracking-tighter italic mb-4 uppercase">POLLY COFFEE</h2>
      <p id="brand-desc" class="text-orange-100 text-center font-medium opacity-80">Hệ thống quản lý chuỗi cửa hàng<br>cà phê thông minh.</p>
    </div>

    <!-- Right -->
    <div class="w-1/2 bg-white flex items-center justify-center p-16">
      <div class="w-full max-w-sm">
        <div id="form-header">
          <h3 class="text-3xl font-black text-gray-900 mb-2">Đăng nhập</h3>
          <p class="text-gray-400 mb-10 text-sm font-medium">Chào mừng trở lại! Vui lòng nhập thông tin.</p>
        </div>

        <% String error = (String) request.getAttribute("error"); %>
        <% String rememberedUsername = (String) request.getAttribute("rememberedUsername"); %>
        <% String rememberedPassword = (String) request.getAttribute("rememberedPassword"); %>
        <% Boolean rememberChecked = (Boolean) request.getAttribute("rememberChecked"); %>
        <% if (rememberedUsername == null) rememberedUsername = ""; %>
        <% if (rememberedPassword == null) rememberedPassword = ""; %>
        <% if (rememberChecked == null) rememberChecked = false; %>
        <% if (error != null) { %>
        <div id="error-msg" class="flash-msg mb-6 p-4 bg-red-50 text-red-500 rounded-2xl text-xs font-bold border border-red-100">
          <%= error %>
        </div>
        <% } %>

        <form action="<%= request.getContextPath() %>/login/" method="post" class="space-y-5">

          <div class="input-group space-y-1">
            <label class="text-[10px] font-black text-gray-400 uppercase ml-2 tracking-widest">Tên đăng nhập</label>
            <div class="relative">
              <span class="absolute left-4 top-1/2 -translate-y-1/2 text-gray-300">
                <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M19 21v-2a4 4 0 0 0-4-4H9a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>
              </span>
              <input type="text" name="username" required
                     class="w-full pl-12 pr-4 py-4 bg-gray-50 border-2 border-transparent focus:border-orange-400 focus:bg-white rounded-2xl outline-none transition-all text-sm font-bold"
                     placeholder="username"
                     autocomplete="username"
                     value="<%= rememberedUsername %>">
            </div>
          </div>

          <div class="input-group space-y-1">
            <label class="text-[10px] font-black text-gray-400 uppercase ml-2 tracking-widest">Mật khẩu</label>
            <div class="relative">
              <span class="absolute left-4 top-1/2 -translate-y-1/2 text-gray-300">
                <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect width="18" height="11" x="3" y="11" rx="2" ry="2"/><path d="M7 11V7a5 5 0 0 1 10 0v4"/></svg>
              </span>
              <input type="password" name="password" required
                     class="w-full pl-12 pr-4 py-4 bg-gray-50 border-2 border-transparent focus:border-orange-400 focus:bg-white rounded-2xl outline-none transition-all text-sm font-bold"
                     placeholder="••••••••"
                     autocomplete="current-password"
                     value="<%= rememberedPassword %>">
            </div>
          </div>

          <label class="flex items-center gap-2 text-xs font-bold text-gray-500 select-none">
            <input type="checkbox" name="rememberMe" value="true" <%= rememberChecked ? "checked" : "" %>
                   class="w-4 h-4 rounded border-gray-300 text-orange-500 focus:ring-orange-400">
            Ghi nhớ tôi
          </label>

          <button type="submit" id="btn-submit"
                  class="relative overflow-hidden w-full bg-[#FF9F1C] text-white font-black py-4 rounded-2xl shadow-xl shadow-orange-200 flex items-center justify-center gap-3 hover:scale-[1.02] transition-transform active:scale-95 mt-6 uppercase tracking-widest text-sm">
            Đăng nhập
            <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"><path d="M5 12h14"/><path d="m12 5 7 7-7 7"/></svg>
          </button>


          <p class="text-center mt-6 text-sm font-bold text-gray-400">
            Chưa có tài khoản?
            <a href="<%= request.getContextPath() %>/register" class="text-orange-500 hover:underline">Đăng ký</a>
          </p>
        </form>
        <p class="text-center mt-6 text-sm font-bold text-gray-40">
        <a href="<%= request.getContextPath() %>/forgot-password"
           class="text-orange-500 hover:underline">
           Quên mật khẩu?
        </a>
        </p>

        <p id="footer-text" class="text-center text-[10px] text-gray-300 mt-10 font-bold uppercase tracking-widest">
          &copy; 2026 Polly Coffee Management System
        </p>
      </div>
    </div>
  </div>

  <script>
    window.addEventListener('load', () => {
      const tl = gsap.timeline();
      tl.to(".login-card",       { opacity:1, y:0, duration:1, ease:"expo.out" })
        .from("#logo-container", { scale:0, rotation:-45, duration:.8, ease:"back.out(1.7)" }, "-=0.5")
        .from("#brand-name",     { x:-30, opacity:0, duration:.6 }, "-=0.3")
        .from("#brand-desc",     { y:20, opacity:0, duration:.6 }, "-=0.4")
        .from("#form-header",    { opacity:0, y:10, duration:.4 }, "-=0.2")
        .from(".input-group",    { opacity:0, y:20, stagger:.1, duration:.5, ease:"power2.out" }, "-=0.2")
        .from("#btn-submit",     { scale:.9, opacity:0, duration:.5, ease:"back.out" }, "-=0.1")
        .from("#footer-text",    { opacity:0, duration:1 }, "-=0.1");
    });
    const btn = document.querySelector('#btn-submit');
    btn.addEventListener('mouseenter', () => gsap.to(btn, { backgroundColor:'#e68a00', duration:.3 }));
    btn.addEventListener('mouseleave', () => gsap.to(btn, { backgroundColor:'#FF9F1C', duration:.3 }));
    btn.addEventListener('click', (e) => {
      const rect = btn.getBoundingClientRect();
      const ripple = document.createElement('span');
      ripple.className = 'btn-ripple';
      const size = Math.max(rect.width, rect.height) * 1.35;
      ripple.style.width = size + 'px';
      ripple.style.height = size + 'px';
      ripple.style.left = (e.clientX - rect.left) + 'px';
      ripple.style.top = (e.clientY - rect.top) + 'px';
      btn.appendChild(ripple);

      gsap.timeline()
        .to(btn, { scale: .965, duration: .08, ease: 'power1.out' })
        .to(btn, { scale: 1.01, duration: .18, ease: 'back.out(2)' })
        .to(btn, { scale: 1, duration: .12, ease: 'power2.out' });

      gsap.to(ripple, {
        scale: 1,
        opacity: 0,
        duration: .55,
        ease: 'power2.out',
        onComplete: () => ripple.remove()
      });
    });

    const flash = document.querySelector('.flash-msg');
    if (flash) {
      gsap.fromTo(flash, { opacity: 0, y: -10, scale: .96 }, { opacity: 1, y: 0, scale: 1, duration: .45, ease: 'back.out(1.6)' });
    }
  </script>
  <script>
    window.addEventListener('pageshow', function (e) {
      if (e.persisted) {
        window.location.reload();
      }
    });
  </script>
</body>
</html>
