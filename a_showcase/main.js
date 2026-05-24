// ----------------------------------------------------
// Bootstrap 5.3 Showcase Main Logic (Portable Version)
// ----------------------------------------------------

document.addEventListener('DOMContentLoaded', () => {
  
  // 1. COLOR MODE TOGGLE (LIGHT / DARK / AUTO)
  const getStoredTheme = () => localStorage.getItem('theme');
  const setStoredTheme = theme => localStorage.setItem('theme', theme);

  const getPreferredTheme = () => {
    const storedTheme = getStoredTheme();
    if (storedTheme) {
      return storedTheme;
    }
    return window.matchMedia('(prefers-color-scheme: dark)').matches ? 'dark' : 'light';
  };

  const setTheme = theme => {
    if (theme === 'auto') {
      document.documentElement.setAttribute('data-bs-theme', window.matchMedia('(prefers-color-scheme: dark)').matches ? 'dark' : 'light');
    } else {
      document.documentElement.setAttribute('data-bs-theme', theme);
    }
  };

  setTheme(getPreferredTheme());

  const showActiveTheme = (theme, focus = false) => {
    const themeSwitcher = document.querySelector('#bd-theme');
    if (!themeSwitcher) return;

    const themeSwitcherText = document.querySelector('#bd-theme-text');
    const activeThemeIcon = document.querySelector('.theme-icon-active use');
    const btnToActive = document.querySelector(`[data-bs-theme-value="${theme}"]`);
    const svgOfActiveBtn = btnToActive.querySelector('svg use').getAttribute('href');

    document.querySelectorAll('[data-bs-theme-value]').forEach(element => {
      element.classList.remove('active');
      element.setAttribute('aria-pressed', 'false');
      element.querySelector('.bi.ms-auto').classList.add('d-none');
    });

    btnToActive.classList.add('active');
    btnToActive.setAttribute('aria-pressed', 'true');
    btnToActive.querySelector('.bi.ms-auto').classList.remove('d-none');
    activeThemeIcon.setAttribute('href', svgOfActiveBtn);

    const themeNames = {
      light: 'ライト',
      dark: 'ダーク',
      auto: 'オート'
    };
    themeSwitcherText.textContent = `テーマ: ${themeNames[theme] || theme}`;

    if (focus) {
      themeSwitcher.querySelector('button').focus();
    }
  };

  window.matchMedia('(prefers-color-scheme: dark)').addEventListener('change', () => {
    const storedTheme = getStoredTheme();
    if (storedTheme !== 'light' && storedTheme !== 'dark') {
      setTheme(getPreferredTheme());
    }
  });

  // Attach click listener to theme dropdown items
  document.querySelectorAll('[data-bs-theme-value]').forEach(toggle => {
    toggle.addEventListener('click', () => {
      const theme = toggle.getAttribute('data-bs-theme-value');
      setStoredTheme(theme);
      setTheme(theme);
      showActiveTheme(theme, true);
    });
  });

  // Initial active state in UI
  showActiveTheme(getPreferredTheme());


  // 2. BOOTSTRAP PLUGINS INITIALIZATION (TOOLTIPS & POPOVERS)
  // Note: We access the global `bootstrap` object exposed by the CDN bundle script
  const tooltipTriggerList = document.querySelectorAll('[data-bs-toggle="tooltip"]');
  [...tooltipTriggerList].map(tooltipTriggerEl => new bootstrap.Tooltip(tooltipTriggerEl));

  // Initialize all popovers on page
  const popoverTriggerList = document.querySelectorAll('[data-bs-toggle="popover"]');
  [...popoverTriggerList].map(popoverTriggerEl => new bootstrap.Popover(popoverTriggerEl));


  // 3. CSS VARIABLES LIVE CONTROLLER DEMO
  const primaryHueInput = document.getElementById('primaryHue');
  const primaryHueValText = document.getElementById('primaryHueVal');
  const borderRadiusInput = document.getElementById('borderRadius');
  const borderRadiusValText = document.getElementById('borderRadiusVal');

  if (primaryHueInput && primaryHueValText) {
    primaryHueInput.addEventListener('input', (e) => {
      const val = e.target.value;
      primaryHueValText.textContent = val;
      document.documentElement.style.setProperty('--primary-hue', val);
    });
  }

  if (borderRadiusInput && borderRadiusValText) {
    borderRadiusInput.addEventListener('input', (e) => {
      const val = e.target.value;
      borderRadiusValText.textContent = `${val}rem`;
      document.documentElement.style.setProperty('--custom-border-radius', `${val}rem`);
    });
  }


  // 4. FORM VALIDATION
  const form = document.getElementById('demoForm');
  if (form) {
    form.addEventListener('submit', (event) => {
      if (!form.checkValidity()) {
        event.preventDefault();
        event.stopPropagation();
      } else {
        event.preventDefault();
        showToast('フォームが正常に送信されました！', 'success');
        form.reset();
        form.classList.remove('was-validated');
        return;
      }
      form.classList.add('was-validated');
    }, false);
  }


  // 5. DYNAMIC TOAST CREATION
  const triggerToastBtn = document.getElementById('triggerToast');
  const toastContainer = document.getElementById('toastContainer');

  const showToast = (message, type = 'info') => {
    if (!toastContainer) return;

    // Toast icons mapping
    const icons = {
      success: 'bi-check-circle-fill text-success',
      info: 'bi-info-circle-fill text-info',
      warning: 'bi-exclamation-triangle-fill text-warning',
      danger: 'bi-exclamation-octagon-fill text-danger'
    };

    const iconClass = icons[type] || icons.info;

    // Create Toast element
    const toastId = `toast-${Date.now()}`;
    const toastHtml = `
      <div id="${toastId}" class="toast align-items-center border-0 shadow-sm" role="alert" aria-live="assertive" aria-atomic="true">
        <div class="d-flex">
          <div class="toast-body d-flex align-items-center gap-2">
            <i class="bi ${iconClass} fs-5"></i>
            <span class="fw-medium">${message}</span>
          </div>
          <button type="button" class="btn-close me-2 m-auto" data-bs-dismiss="toast" aria-label="Close"></button>
        </div>
      </div>
    `;

    // Append to container
    toastContainer.insertAdjacentHTML('beforeend', toastHtml);

    // Initialize & Show Toast
    const toastEl = document.getElementById(toastId);
    const toast = new bootstrap.Toast(toastEl, {
      delay: 4000
    });
    toast.show();

    // Remove from DOM after hidden to prevent element leakage
    toastEl.addEventListener('hidden.bs.toast', () => {
      toastEl.remove();
    });
  };

  if (triggerToastBtn) {
    let clickCount = 0;
    triggerToastBtn.addEventListener('click', () => {
      clickCount++;
      const types = ['info', 'success', 'warning', 'danger'];
      const currentType = types[clickCount % types.length];
      const messages = [
        'お知らせ: Bootstrapのトースト通知です。',
        '完了しました！操作が成功しました。',
        '警告: 入力されたデータに不備がある可能性があります。',
        'エラー: サーバーとの接続に失敗しました。'
      ];
      showToast(messages[clickCount % messages.length], currentType);
    });
  }

});
