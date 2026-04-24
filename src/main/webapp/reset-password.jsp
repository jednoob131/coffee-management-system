<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="entity.User" %>

<!DOCTYPE html>
<html lang="vi">
<head>

<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">

<title>Đổi mật khẩu | Polly Coffee</title>

<script src="https://cdn.tailwindcss.com"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/gsap/3.12.2/gsap.min.js"></script>

<link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;700;800&display=swap" rel="stylesheet">

<style>

body{
font-family:'Plus Jakarta Sans',sans-serif;
background:#FDFCF6;
overflow:hidden;
}

.orange-shape{
position:absolute;
filter:blur(80px);
background:#FF9F1C;
opacity:0.15;
border-radius:50%;
z-index:-1;
}

.reset-card{
opacity:0;
transform:translateY(24px) scale(.98);
}

.glass-outline{
position:relative;
}

.glass-outline::before{
content:"";
position:absolute;
inset:-2px;
border-radius:24px;
background:linear-gradient(120deg, rgba(255,159,28,.45), rgba(255,159,28,0), rgba(255,159,28,.2));
opacity:0;
transition:opacity .3s ease;
z-index:-1;
}

.glass-outline:hover::before{
opacity:1;
}

.soft-focus{
transition:all .25s ease;
}

.soft-focus:focus{
box-shadow:0 0 0 4px rgba(255,159,28,.15);
}

.btn-ripple{
position:absolute;
border-radius:9999px;
pointer-events:none;
transform:translate(-50%, -50%) scale(0);
background:rgba(255,255,255,.45);
mix-blend-mode:screen;
}
</style>

</head>

<body class="flex items-center justify-center min-h-screen">

<div class="orange-shape w-[500px] h-[500px] -top-20 -left-20"></div>
<div class="orange-shape w-[400px] h-[400px] -bottom-20 -right-20"></div>

<div class="reset-card w-full max-w-[1000px] h-[550px] bg-white rounded-[40px] shadow-[0_30px_60px_rgba(0,0,0,0.12)] flex overflow-hidden border-8 border-white">

<!-- LEFT -->

<div class="w-1/2 bg-[#FF9F1C] flex flex-col items-center justify-center text-white p-12">

<h2 id="brand-title" class="text-4xl font-black italic mb-4 uppercase">
POLLY COFFEE
</h2>

<p id="brand-subtitle" class="text-orange-100 text-center">
Chọn tài khoản và nhập mật khẩu mới
</p>

</div>

<!-- RIGHT -->

<div class="w-1/2 flex items-center justify-center p-16">

<div class="w-full max-w-sm" id="form-panel">

<h3 id="form-title" class="text-3xl font-black mb-2">
Đặt lại mật khẩu
</h3>

<p id="form-subtitle" class="text-gray-400 mb-10 text-sm">
Chọn tài khoản cần đổi mật khẩu
</p>

<%
String msg = (String)request.getAttribute("message");
if(msg != null){
%>

<div class="flash-msg mb-4 p-3 bg-red-50 text-red-600 rounded-xl text-sm">
<%= msg %>
</div>

<% } %>

<form action="<%=request.getContextPath()%>/reset-password" method="post" class="space-y-5">

<input type="hidden" name="token" value="<%=request.getAttribute("token")%>">

<label class="text-xs font-bold text-gray-400 uppercase">
Chọn tài khoản
</label>

<div class="glass-outline rounded-2xl">
<select name="username"
class="soft-focus w-full px-4 py-4 bg-gray-50 border-2 border-transparent focus:border-orange-400 rounded-2xl outline-none font-bold">

<%
List<User> users = (List<User>)request.getAttribute("users");

if(users != null){
for(User u : users){
%>

<option value="<%=u.getUsername()%>">
<%=u.getUsername()%>
</option>

<%
}
}
%>

</select>
</div>

<label class="text-xs font-bold text-gray-400 uppercase">
Mật khẩu mới
</label>

<input
type="password"
name="password"
required
placeholder="Nhập mật khẩu mới"
class="soft-focus w-full px-4 py-4 bg-gray-50 border-2 border-transparent focus:border-orange-400 rounded-2xl outline-none font-bold"
/>

<button
type="submit"
id="btn-submit"
class="relative overflow-hidden w-full bg-[#FF9F1C] text-white font-black py-4 rounded-2xl mt-4 shadow-xl shadow-orange-200 transition-all duration-300">

Đổi mật khẩu

</button>

</form>

<p class="text-center mt-6 text-sm font-bold text-gray-400">

<a href="<%=request.getContextPath()%>/login"
class="text-orange-500 hover:underline transition-colors duration-200 hover:text-orange-600">

Quay lại đăng nhập

</a>

</p>

</div>

</div>

</div>

<script>
window.addEventListener('load', () => {
  const tl = gsap.timeline();
  tl.to(".reset-card", { opacity: 1, y: 0, scale: 1, duration: .9, ease: "expo.out" })
    .from("#brand-title", { x: -24, opacity: 0, duration: .5 }, "-=.5")
    .from("#brand-subtitle", { y: 16, opacity: 0, duration: .5 }, "-=.35")
    .from("#form-title", { y: 12, opacity: 0, duration: .4 }, "-=.3")
    .from("#form-subtitle", { y: 10, opacity: 0, duration: .4 }, "-=.25")
    .from("label, select, input, #btn-submit", { y: 14, opacity: 0, stagger: .08, duration: .35, ease: "power2.out" }, "-=.2");

  gsap.to(".orange-shape", {
    x: "+=16",
    y: "+=12",
    duration: 4.5,
    yoyo: true,
    repeat: -1,
    ease: "sine.inOut",
    stagger: .4
  });

  const btn = document.querySelector('#btn-submit');
  if (btn) {
    btn.addEventListener('mouseenter', () => {
      gsap.to(btn, {
        backgroundColor: '#e68a00',
        y: -2,
        scale: 1.02,
        boxShadow: '0 20px 30px rgba(255,159,28,.35)',
        duration: .22,
        ease: 'power2.out'
      });
    });

    btn.addEventListener('mouseleave', () => {
      gsap.to(btn, {
        backgroundColor: '#FF9F1C',
        y: 0,
        scale: 1,
        boxShadow: '0 10px 20px rgba(255,159,28,.25)',
        duration: .22,
        ease: 'power2.out'
      });
    });

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
  }

  const flash = document.querySelector('.flash-msg');
  if (flash) {
    gsap.fromTo(flash, { opacity: 0, y: -10, scale: .96 }, { opacity: 1, y: 0, scale: 1, duration: .45, ease: 'back.out(1.6)' });
  }
});
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