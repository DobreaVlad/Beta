// Auth Modal Management
class AuthModal {
  constructor() {
    this.modal = null;
    this.currentView = 'login';
    this.init();
  }

  init() {
    this.createModal();
    this.attachEventListeners();
  }

  createModal() {
    const modalHTML = `
      <div id="authModal" class="auth-modal">
        <div class="auth-modal-content">
          <span class="auth-modal-close">&times;</span>
          
          <div id="loginView" class="auth-view">
            <h2>Autentificare</h2>
            <form id="loginForm">
              <div class="form-group">
                <label for="loginEmail">Email</label>
                <input type="email" id="loginEmail" name="email" required>
              </div>
              <div class="form-group">
                <label for="loginPassword">Parola</label>
                <input type="password" id="loginPassword" name="password" required>
              </div>
              <div class="auth-error" id="loginError"></div>
              <button type="submit" class="btn-primary btn-block">Autentificare</button>
            </form>
            
            <div class="auth-divider">sau</div>
            
            <button class="btn-google" id="googleLoginBtn">
              <img src="https://www.google.com/favicon.ico" alt="Google" style="width: 20px; margin-right: 10px;">
              Continua cu Google
            </button>
            
            <div class="auth-footer">
              <p>Nu ai cont? <a href="#" id="showRegister">Inregistreaza-te</a></p>
              <p><a href="#" id="showReset">Ai uitat parola?</a></p>
            </div>
          </div>

          <div id="registerView" class="auth-view" style="display: none;">
            <h2>Creare cont</h2>
            <form id="registerForm">
              <div class="form-group">
                <label for="registerName">Nume</label>
                <input type="text" id="registerName" name="name" required>
              </div>
              <div class="form-group">
                <label for="registerEmail">Email</label>
                <input type="email" id="registerEmail" name="email" required>
              </div>
              <div class="form-group">
                <label for="registerPassword">Parola</label>
                <input type="password" id="registerPassword" name="password" required minlength="6">
              </div>
              <div class="form-group">
                <label for="registerPassword2">Confirma parola</label>
                <input type="password" id="registerPassword2" name="password2" required minlength="6">
              </div>
              <div class="auth-error" id="registerError"></div>
              <button type="submit" class="btn-primary btn-block">Inregistrare</button>
            </form>
            
            <div class="auth-divider">sau</div>
            
            <button class="btn-google" id="googleRegisterBtn">
              <img src="https://www.google.com/favicon.ico" alt="Google" style="width: 20px; margin-right: 10px;">
              Inregistreaza-te cu Google
            </button>
            
            <div class="auth-footer">
              <p>Ai deja cont? <a href="#" id="showLogin">Autentifica-te</a></p>
            </div>
          </div>

          <div id="resetView" class="auth-view" style="display: none;">
            <h2>Reseteaza parola</h2>
            <p style="color: #6b7280; margin-bottom: 20px; font-size: 14px;">Introdu adresa ta de email si iti vom trimite instructiuni pentru resetarea parolei.</p>
            <form id="resetForm">
              <div class="form-group">
                <label for="resetEmail">Email</label>
                <input type="email" id="resetEmail" name="email" required>
              </div>
              <div class="auth-error" id="resetError"></div>
              <div class="auth-success" id="resetSuccess"></div>
              <button type="submit" class="btn-primary btn-block">Trimite link de resetare</button>
            </form>
            
            <div class="auth-footer">
              <p>Iti amintesti parola? <a href="#" id="backToLogin">Autentifica-te</a></p>
            </div>
          </div>
        </div>
      </div>
    `;

    document.body.insertAdjacentHTML('beforeend', modalHTML);
    this.modal = document.getElementById('authModal');
  }

  attachEventListeners() {
    // Close button
    const closeBtn = document.querySelector('.auth-modal-close');
    closeBtn.addEventListener('click', () => this.close());

    // Click outside to close
    this.modal.addEventListener('click', (e) => {
      if (e.target === this.modal) {
        this.close();
      }
    });

    // Switch views
    document.getElementById('showRegister').addEventListener('click', (e) => {
      e.preventDefault();
      this.switchView('register');
    });

    document.getElementById('showLogin').addEventListener('click', (e) => {
      e.preventDefault();
      this.switchView('login');
    });

    document.getElementById('showReset').addEventListener('click', (e) => {
      e.preventDefault();
      this.switchView('reset');
    });

    document.getElementById('backToLogin').addEventListener('click', (e) => {
      e.preventDefault();
      this.switchView('login');
    });

    // Form submissions
    document.getElementById('loginForm').addEventListener('submit', (e) => {
      e.preventDefault();
      this.handleLogin(e.target);
    });

    document.getElementById('registerForm').addEventListener('submit', (e) => {
      e.preventDefault();
      this.handleRegister(e.target);
    });

    document.getElementById('resetForm').addEventListener('submit', (e) => {
      e.preventDefault();
      this.handleReset(e.target);
    });

    // Google Sign In
    document.getElementById('googleLoginBtn').addEventListener('click', () => {
      this.handleGoogleAuth();
    });

    document.getElementById('googleRegisterBtn').addEventListener('click', () => {
      this.handleGoogleAuth();
    });
  }

  open(view = 'login') {
    this.switchView(view);
    this.modal.style.display = 'block';
    document.body.style.overflow = 'hidden';
  }

  close() {
    this.modal.style.display = 'none';
    document.body.style.overflow = 'auto';
    this.clearErrors();
  }

  switchView(view) {
    this.currentView = view;
    const loginView = document.getElementById('loginView');
    const registerView = document.getElementById('registerView');
    const resetView = document.getElementById('resetView');

    loginView.style.display = 'none';
    registerView.style.display = 'none';
    resetView.style.display = 'none';

    if (view === 'login') {
      loginView.style.display = 'block';
    } else if (view === 'register') {
      registerView.style.display = 'block';
    } else if (view === 'reset') {
      resetView.style.display = 'block';
    }
    this.clearErrors();
  }

  clearErrors() {
    document.getElementById('loginError').textContent = '';
    document.getElementById('registerError').textContent = '';
    document.getElementById('resetError').textContent = '';
    document.getElementById('resetSuccess').textContent = '';
  }

  async handleLogin(form) {
    const formData = new FormData(form);
    const data = Object.fromEntries(formData);

    try {
      const response = await fetch('/auth/login.html', {
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
        body: new URLSearchParams(data)
      });

      if (response.redirected) {
        window.location.href = response.url;
      } else {
        const text = await response.text();
        if (text.includes('error')) {
          document.getElementById('loginError').textContent = 'Email sau parola invalida';
        }
      }
    } catch (error) {
      document.getElementById('loginError').textContent = 'Eroare la autentificare';
    }
  }

  async handleRegister(form) {
    const formData = new FormData(form);
    const data = Object.fromEntries(formData);

    if (data.password !== data.password2) {
      document.getElementById('registerError').textContent = 'Parolele nu se potrivesc';
      return;
    }

    try {
      const response = await fetch('/auth/register.html', {
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
        body: new URLSearchParams(data)
      });

      const text = await response.text();
      if (text.includes('success')) {
        this.switchView('login');
        document.getElementById('loginError').innerHTML = '<span style="color: #10b981;">Cont creat cu succes! Poti sa te autentifici.</span>';
      } else if (text.includes('error')) {
        document.getElementById('registerError').textContent = 'Eroare la inregistrare. Emailul ar putea fi deja folosit.';
      }
    } catch (error) {
      document.getElementById('registerError').textContent = 'Eroare la inregistrare';
    }
  }

  async handleReset(form) {
    const formData = new FormData(form);
    const email = form.querySelector('[name="email"]').value;
    
    // Change field name from 'email' to 'identifier' to match backend
    formData.delete('email');
    formData.append('identifier', email);

    try {
      const response = await fetch('/auth/reset_request.html', {
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
        body: new URLSearchParams(formData)
      });

      const text = await response.text();
      // Backend always returns success message for security
      if (text.includes('success') || text.includes('sent') || text.includes('trimis') || text.includes('exists')) {
        document.getElementById('resetSuccess').textContent = 'Daca contul exista, un link de resetare a fost trimis pe email.';
        document.getElementById('resetError').textContent = '';
        form.reset();
      } else if (text.includes('error')) {
        document.getElementById('resetError').textContent = 'Eroare la trimiterea emailului. Incearca mai tarziu.';
        document.getElementById('resetSuccess').textContent = '';
      } else {
        // If no specific error, show success
        document.getElementById('resetSuccess').textContent = 'Daca contul exista, un link de resetare a fost trimis pe email.';
        document.getElementById('resetError').textContent = '';
        form.reset();
      }
    } catch (error) {
      document.getElementById('resetError').textContent = 'Eroare la trimiterea emailului';
      document.getElementById('resetSuccess').textContent = '';
    }
  }

  handleGoogleAuth() {
    // Initialize Google Sign-In
    google.accounts.id.initialize({
      client_id: 'YOUR_GOOGLE_CLIENT_ID.apps.googleusercontent.com',
      callback: this.handleGoogleCallback.bind(this)
    });

    google.accounts.id.prompt();
  }

  async handleGoogleCallback(response) {
    try {
      const res = await fetch('/auth/google-login.html', {
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
        body: new URLSearchParams({ credential: response.credential })
      });

      if (res.redirected || res.ok) {
        window.location.href = '/';
      } else {
        document.getElementById('loginError').textContent = 'Eroare la autentificarea cu Google';
      }
    } catch (error) {
      document.getElementById('loginError').textContent = 'Eroare la autentificarea cu Google';
    }
  }
}

// Initialize on page load
let authModal;
document.addEventListener('DOMContentLoaded', () => {
  authModal = new AuthModal();

  // Override default auth links
  document.querySelectorAll('a[href*="/auth/login.html"]').forEach(link => {
    link.addEventListener('click', (e) => {
      e.preventDefault();
      authModal.open('login');
    });
  });

  document.querySelectorAll('a[href*="/auth/register.html"]').forEach(link => {
    link.addEventListener('click', (e) => {
      e.preventDefault();
      authModal.open('register');
    });
  });
});
