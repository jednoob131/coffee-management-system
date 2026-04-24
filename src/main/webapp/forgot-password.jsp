<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="vi">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Quên mật khẩu | Polly Coffee</title>

<script src="https://cdn.tailwindcss.com"></script>
<link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;700;800&display=swap" rel="stylesheet">

<style>
body{
font-family:'Plus Jakarta Sans',sans-serif;
background:#FDFCF6;
}

.orange-shape{
position:absolute;
filter:blur(80px);
background:#FF9F1C;
opacity:0.15;
border-radius:50%;
}
</style>
</head>

<body class="flex items-center justify-center min-h-screen">

<div class="orange-shape w-[500px] h-[500px] -top-20 -left-20"></div>
<div class="orange-shape w-[400px] h-[400px] -bottom-20 -right-20"></div>

<div class="w-full max-w-[1000px] h-[550px] bg-white rounded-[40px] shadow-[0_30px_60px_rgba(0,0,0,0.12)] flex overflow-hidden border-8 border-white">

<!-- LEFT -->
<div class="w-1/2 bg-[#FF9F1C] flex flex-col items-center justify-center text-white p-12">

<h2 class="text-4xl font-black italic mb-4 uppercase">POLLY COFFEE</h2>

<p class="text-orange-100 text-center">
Khôi phục mật khẩu tài khoản của bạn
</p>

</div>

<!-- RIGHT -->
<div class="w-1/2 flex items-center justify-center p-16">

<div class="w-full max-w-sm">

<h3 class="text-3xl font-black mb-2">Quên mật khẩu</h3>
<p class="text-gray-400 mb-10 text-sm">Nhập email để nhận mật khẩu</p>

<% String msg = (String)request.getAttribute("message"); %>
<% if(msg != null){ %>
<div class="mb-4 p-3 bg-green-50 text-green-600 rounded-xl text-sm">
<%= msg %>
</div>
<% } %>

<form action="<%=request.getContextPath()%>/forgot-password" method="post" class="space-y-5">

<label class="text-xs font-bold text-gray-400 uppercase">Email</label>

<input
type="email"
name="email"
required
placeholder="example@gmail.com"
class="w-full px-4 py-4 bg-gray-50 border-2 border-transparent focus:border-orange-400 rounded-2xl outline-none font-bold"
/>

<button
type="submit"
class="w-full bg-[#FF9F1C] text-white font-black py-4 rounded-2xl mt-4 hover:scale-[1.02] transition">
Gửi mật khẩu
</button>

</form>

<p class="text-center mt-6 text-sm font-bold text-gray-400">
<a href="<%=request.getContextPath()%>/login"
class="text-orange-500 hover:underline">
Quay lại đăng nhập
</a>
</p>

</div>

</div>

</div>

<script>
  window.addEventListener('pageshow', function (e) {
    if (e.persisted) {
      window.location.reload();
    }
  });
</script>
</body>
</html>