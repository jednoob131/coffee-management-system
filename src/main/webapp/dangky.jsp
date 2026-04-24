<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="vi">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Đăng ký | Polly Coffee</title>
<script src="https://cdn.tailwindcss.com"></script>
<link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:ital,wght@0,400;0,700;0,800;1,800&display=swap" rel="stylesheet">
<script src="https://cdnjs.cloudflare.com/ajax/libs/gsap/3.12.2/gsap.min.js"></script>
<style>
  body {
    font-family: 'Plus Jakarta Sans', sans-serif;
    background-color: #FDFCF6;
  }
  .register-card { opacity: 0; transform: translateY(30px); }
  .orange-shape {
    position: fixed; z-index: -1;
    filter: blur(80px); border-radius: 50%;
    background: #FF9F1C; opacity: 0.15;
  }
  .field {
    width: 100%; padding: 11px 11px 11px 38px;
    background: #F9FAFB; border: 2px solid transparent;
    border-radius: 12px; outline: none; font-size: .8rem;
    font-weight: 700; font-family: 'Plus Jakarta Sans', sans-serif;
    transition: border-color .2s, background .2s;
  }
  .field:focus { border-color: #FF9F1C; background: #fff; }
  .field.error  { border-color: #f87171; background: #fff7f7; }
  .field.ok     { border-color: #4ade80; }
  select.field  { appearance: none; }
  .err-msg {
    font-size: .62rem; color: #f87171; font-weight: 700;
    min-height: 14px; margin-top: 2px; padding-left: 4px;
  }
  .icon-wrap {
    position: absolute; left: 11px; top: 50%; transform: translateY(-50%);
    color: #d1d5db; pointer-events: none;
  }
  .toggle-pw {
    position: absolute; right: 11px; top: 50%; transform: translateY(-50%);
    font-size: .62rem; font-weight: 800; color: #ccc;
    cursor: pointer; text-transform: uppercase; letter-spacing: .06em;
    transition: color .2s; user-select: none;
  }
  .toggle-pw:hover { color: #FF9F1C; }
  .strength-bar { height: 3px; background: #f0f0f0; border-radius: 2px; margin-top: 4px; }
  .strength-fill { height: 100%; border-radius: 2px; width: 0%; transition: width .4s, background .4s; }
  .lbl { font-size: .65rem; font-weight: 800; color: #9ca3af; text-transform: uppercase; letter-spacing: .1em; margin-bottom: 3px; padding-left: 2px; display: block; }
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
<body class="flex items-center justify-center min-h-screen p-4">

<div class="orange-shape w-[500px] h-[500px] -top-20 -left-20"></div>
<div class="orange-shape w-[400px] h-[400px] -bottom-20 -right-20"></div>

<div class="register-card w-full max-w-[960px] bg-white rounded-[36px] shadow-[0_30px_60px_rgba(0,0,0,0.12)] flex overflow-hidden border-8 border-white">

  <!-- Left: Branding -->
  <div class="w-[38%] bg-[#FF9F1C] flex flex-col items-center justify-center p-10 text-white shrink-0">
    <div id="logo-container" class="w-24 h-24 bg-white rounded-[28px] flex items-center justify-center mb-6 shadow-2xl">
      <svg xmlns="http://www.w3.org/2000/svg" width="42" height="42" viewBox="0 0 24 24"
           fill="none" stroke="#FF9F1C" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
        <path d="M17 8h1a4 4 0 1 1 0 8h-1"/>
        <path d="M3 8h14v9a4 4 0 0 1-4 4H7a4 4 0 0 1-4-4Z"/>
        <line x1="6" x2="6" y1="2" y2="4"/>
        <line x1="10" x2="10" y1="2" y2="4"/>
        <line x1="14" x2="14" y1="2" y2="4"/>
      </svg>
    </div>
    <h2 id="brand-name" class="text-3xl font-black tracking-tighter italic mb-3 uppercase text-center">POLLY COFFEE</h2>
    <p id="brand-desc" class="text-orange-100 text-center font-medium opacity-80 text-sm">
      Tạo tài khoản để quản lý<br>chuỗi cửa hàng thông minh.
    </p>
  </div>

  <!-- Right: Form -->
  <div class="flex-1 bg-white flex items-center justify-center p-8">
    <div class="w-full">
      <div id="form-header" class="mb-4">
        <h3 class="text-2xl font-black text-gray-900 mb-1">Đăng ký</h3>
        <p class="text-gray-400 text-xs font-medium">Vui lòng điền đầy đủ thông tin.</p>
      </div>

      <% String errServer = (String) request.getAttribute("error"); %>
      <% if (errServer != null) { %>
      <div class="flash-msg mb-3 p-3 bg-red-50 text-red-500 rounded-xl text-xs font-bold border border-red-100">
        ⚠ <%= errServer %>
      </div>
      <% } %>

      <form action="<%= request.getContextPath() %>/register" method="post"
            id="regForm" novalidate>

        <!-- Row 1: Họ tên + Username -->
        <div class="grid grid-cols-2 gap-3 mb-1">
          <div>
            <label class="lbl">Họ và tên</label>
            <div class="relative">
              <span class="icon-wrap"><svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/></svg></span>
              <input type="text" name="fullname" id="fullname" class="field" placeholder="Nguyễn Văn A" oninput="validate()">
            </div>
            <div class="err-msg" id="err-fullname"></div>
          </div>
          <div>
            <label class="lbl">Tên đăng nhập</label>
            <div class="relative">
              <span class="icon-wrap"><svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect width="18" height="11" x="3" y="11" rx="2"/><path d="M7 11V7a5 5 0 0 1 10 0v4"/></svg></span>
              <input type="text" name="username" id="username" class="field" placeholder="username_polly" oninput="validate()">
            </div>
            <div class="err-msg" id="err-username"></div>
          </div>
        </div>

        <!-- Row 2: Email + Phone -->
        <div class="grid grid-cols-2 gap-3 mb-1">
          <div>
            <label class="lbl">Email</label>
            <div class="relative">
              <span class="icon-wrap"><svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect width="20" height="16" x="2" y="4" rx="2"/><path d="m22 7-8.97 5.7a1.94 1.94 0 0 1-2.06 0L2 7"/></svg></span>
              <input type="email" name="email" id="email" class="field" placeholder="email@coffee.com" oninput="validate()">
            </div>
            <div class="err-msg" id="err-email"></div>
          </div>
          <div>
            <label class="lbl">Số điện thoại</label>
            <div class="relative">
              <span class="icon-wrap"><svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M22 16.92v3a2 2 0 0 1-2.18 2 19.79 19.79 0 0 1-8.63-3.07A19.5 19.5 0 0 1 4.69 12 19.79 19.79 0 0 1 1.61 3.4 2 2 0 0 1 3.6 1.22h3a2 2 0 0 1 2 1.72c.127.96.361 1.903.7 2.81a2 2 0 0 1-.45 2.11L7.91 8.96a16 16 0 0 0 6.13 6.13l.95-.95a2 2 0 0 1 2.11-.45c.907.339 1.85.573 2.81.7A2 2 0 0 1 21.73 17z"/></svg></span>
              <input type="text" name="phone" id="phone" class="field" placeholder="0901234567" oninput="validate()">
            </div>
            <div class="err-msg" id="err-phone"></div>
          </div>
        </div>

        <!-- Row 3: Password + Confirm -->
        <div class="grid grid-cols-2 gap-3 mb-1">
          <div>
            <label class="lbl">Mật khẩu</label>
            <div class="relative">
              <span class="icon-wrap"><svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect width="18" height="11" x="3" y="11" rx="2"/><path d="M7 11V7a5 5 0 0 1 10 0v4"/></svg></span>
              <input type="password" name="password" id="password" class="field" placeholder="••••••••"
                     style="padding-right:46px" oninput="checkStrength();validate()">
              <span class="toggle-pw" onclick="togglePw('password',this)">Hiện</span>
            </div>
            <div class="strength-bar"><div class="strength-fill" id="strengthFill"></div></div>
            <div style="font-size:.58rem;font-weight:700;min-height:13px;padding-left:3px;margin-top:1px" id="strengthLabel"></div>
            <div class="err-msg" id="err-password"></div>
          </div>
          <div>
            <label class="lbl">Xác nhận mật khẩu</label>
            <div class="relative">
              <span class="icon-wrap"><svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect width="18" height="11" x="3" y="11" rx="2"/><path d="M7 11V7a5 5 0 0 1 10 0v4"/></svg></span>
              <input type="password" name="confirm" id="confirm" class="field" placeholder="••••••••"
                     style="padding-right:46px" oninput="validate()">
              <span class="toggle-pw" onclick="togglePw('confirm',this)">Hiện</span>
            </div>
            <div class="err-msg" id="err-confirm"></div>
          </div>
        </div>

        <input type="hidden" name="role" value="false">

        <!-- Submit -->
        <button type="submit" id="btn-submit" disabled
                class="relative overflow-hidden w-full bg-[#FF9F1C] text-white font-black py-3 rounded-2xl shadow-lg shadow-orange-200
                       flex items-center justify-center gap-2 uppercase tracking-widest text-sm
                       disabled:opacity-40 disabled:cursor-not-allowed
                       hover:scale-[1.02] transition-transform active:scale-95">
          Tạo tài khoản
          <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"><path d="M5 12h14"/><path d="m12 5 7 7-7 7"/></svg>
        </button>

        <p class="text-center text-xs font-bold text-gray-400 mt-3">
          Đã có tài khoản?
          <a href="<%= request.getContextPath() %>/login" class="text-orange-500 hover:underline">Đăng nhập</a>
        </p>
      </form>

      <p class="text-center text-[10px] text-gray-300 mt-3 font-bold uppercase tracking-widest">
        &copy; 2026 Polly Coffee Management System
      </p>
    </div>
  </div>
</div>

<script>
function togglePw(id, btn) {
  const el = document.getElementById(id);
  el.type = el.type === 'password' ? 'text' : 'password';
  btn.textContent = el.type === 'password' ? 'Hiện' : 'Ẩn';
}

function checkStrength() {
  const val = document.getElementById('password').value;
  const fill = document.getElementById('strengthFill');
  const lbl  = document.getElementById('strengthLabel');
  let score = 0;
  if (val.length >= 8) score++;
  if (/[A-Z]/.test(val)) score++;
  if (/[0-9]/.test(val)) score++;
  if (/[^A-Za-z0-9]/.test(val)) score++;
  const levels = [
    {w:'0%',c:'transparent',t:''},
    {w:'25%',c:'#f87171',t:'Quá yếu'},
    {w:'50%',c:'#fb923c',t:'Trung bình'},
    {w:'75%',c:'#facc15',t:'Khá mạnh'},
    {w:'100%',c:'#4ade80',t:'Mạnh'},
  ];
  const lv = levels[score]||levels[0];
  fill.style.width=lv.w; fill.style.background=lv.c;
  lbl.textContent=lv.t; lbl.style.color=lv.c;
}

function setField(id, errId, ok, msg) {
  const el = document.getElementById(id);
  const em = document.getElementById(errId);
  el.classList.toggle('ok', ok);
  el.classList.toggle('error', !ok && el.value.length > 0);
  em.textContent = (!ok && el.value.length > 0) ? msg : '';
}

function validate() {
  const f = id => document.getElementById(id).value.trim();
  const pw = document.getElementById('password').value;
  const cf = document.getElementById('confirm').value;
  let ok = true;

  const o1 = f('fullname').length >= 2;
  setField('fullname','err-fullname', o1, 'Tối thiểu 2 ký tự'); if(!o1) ok=false;

  const o2 = /^[a-zA-Z0-9_]{4,20}$/.test(f('username'));
  setField('username','err-username', o2, '4–20 ký tự, chỉ chữ/số/_'); if(!o2) ok=false;

  const o3 = /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(f('email'));
  setField('email','err-email', o3, 'Email không hợp lệ'); if(!o3) ok=false;

  const o4 = /^0[0-9]{9}$/.test(f('phone'));
  setField('phone','err-phone', o4, '10 số, bắt đầu bằng 0'); if(!o4) ok=false;

  const o5 = pw.length >= 6;
  setField('password','err-password', o5, 'Tối thiểu 6 ký tự'); if(!o5) ok=false;

  const o6 = cf.length > 0 && pw === cf;
  setField('confirm','err-confirm', o6, 'Mật khẩu không khớp'); if(!o6) ok=false;

  document.getElementById('btn-submit').disabled = !ok;
  return ok;
}

document.getElementById('regForm').addEventListener('submit', e => { if(!validate()) e.preventDefault(); });

window.addEventListener('load', () => {
  const tl = gsap.timeline();
  tl.to('.register-card', { opacity:1, y:0, duration:1, ease:'expo.out' })
    .from('#logo-container', { scale:0, rotation:-45, duration:.8, ease:'back.out(1.7)' }, '-=0.5')
    .from('#brand-name',  { x:-30, opacity:0, duration:.5 }, '-=0.3')
    .from('#brand-desc',  { y:20,  opacity:0, duration:.5 }, '-=0.3')
    .from('#form-header', { opacity:0, y:10, duration:.4 }, '-=0.2')
    .from('.grid', { opacity:0, y:15, stagger:.08, duration:.4, ease:'power2.out' }, '-=0.1');
});

const btn = document.querySelector('#btn-submit');
btn.addEventListener('mouseenter', () => { if(!btn.disabled) gsap.to(btn,{backgroundColor:'#e68a00',duration:.3}); });
btn.addEventListener('mouseleave', () => { gsap.to(btn,{backgroundColor:'#FF9F1C',duration:.3}); });
btn.addEventListener('click', (e) => {
  if (btn.disabled) return;
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
