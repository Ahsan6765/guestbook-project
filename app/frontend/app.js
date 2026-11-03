// Change this line from 'http://localhost:5000/api/posts' to:
const API_URL = '/api/posts';

const guestbookForm = document.getElementById('guestbookForm');
const postsFeed = document.getElementById('postsFeed');

// Helper function to prevent Cross-Site Scripting (XSS)
function escapeHTML(text) {
    const map = { '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#039;' };
    return text.replace(/[&<>"']/g, m => map[m]);
}

// Fetch all entry records from the backend API
async function loadGuestbookEntries() {
    try {
        const response = await fetch(API_URL);
        if (!response.ok) throw new Error('Network query was not healthy.');
        
        const entries = await response.json();
        postsFeed.innerHTML = ''; // Flush current UI views

        if (entries.length === 0) {
            postsFeed.innerHTML = '<p style="text-align:center; color:#65676b;">No entries yet. Be the first to leave a message!</p>';
            return;
        }

        entries.forEach(entry => {
            const entryCard = document.createElement('div');
            entryCard.className = 'post-card';
            
            const localTime = new Date(entry.created_at).toLocaleString();
            
            entryCard.innerHTML = `
                <div class="post-header">
                    <span class="user">${escapeHTML(entry.username)}</span>
                    <span class="date">${localTime}</span>
                </div>
                <div class="post-body">${escapeHTML(entry.message)}</div>
            `;
            postsFeed.appendChild(entryCard);
        });
    } catch (error) {
        postsFeed.innerHTML = `<p style="color: #ea4335; text-align:center;">⚠️ Error reaching API: ${error.message}</p>`;
    }
}

// Intercept form data submission profiles
guestbookForm.addEventListener('submit', async (e) => {
    e.preventDefault();

    const usernameInput = document.getElementById('username');
    const messageInput = document.getElementById('message');

    const payload = {
        username: usernameInput.value,
        message: messageInput.value
    };

    try {
        const response = await fetch(API_URL, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(payload)
        });

        if (response.ok) {
            messageInput.value = ''; // Clean message input box
            loadGuestbookEntries();   // Pull updated database content
        } else {
            const errData = await response.json();
            alert(`Error: ${errData.error}`);
        }
    } catch (error) {
        alert('Could not sync transaction with backend: ' + error.message);
    }
});

// Primary call on initial page render
loadGuestbookEntries();
