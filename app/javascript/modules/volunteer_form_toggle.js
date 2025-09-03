// Toggle between existing user selection and creating a new user in the volunteer form
function initToggle() {
  const radios = document.querySelectorAll('input[name="volunteer_user_mode"]');
  const existing = document.getElementById('existing-user-section');
  const create = document.getElementById('new-user-section');
  if (!radios.length || !existing || !create) return;

  const setMode = (mode) => {
    if (mode === 'create') {
      create.classList.remove('hidden');
      existing.classList.add('hidden');
    } else {
      create.classList.add('hidden');
      existing.classList.remove('hidden');
    }
  };

  radios.forEach(r => r.addEventListener('change', (e) => setMode(e.target.value)));
}

document.addEventListener('turbo:load', initToggle);

export default { initToggle };
