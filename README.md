# 🎮 Word Chain AI Game

## AI Game Title
**Word Chain AI Game**

---

## 👨‍🎓 Project Members
- **Rajsingh Ganeshsingh Thakur** [103]
- **Moizuddin Siddiqui** [140]
- **Sidram Bajrang Patil** [141]
- **Mohsin Khan** [111]

**Class:** B.Tech – CSE – A  
**Subject Incharge:** Ms. Nitu L. Pariyal

---

## 1. Introduction
The Word Chain AI Game is a vocabulary-based linguistic game where the player and an AI opponent alternately provide English words. Each new word must begin with the last letter of the previous word, forming a continuous word chain.

This game combines vocabulary skills, time-based decision-making, and AI-driven strategic responses. It is designed to be simple, engaging, and educational, making it suitable for players of all ages.

---

## 2. System Overview
The system follows a client–server architecture with a lightweight backend and an interactive frontend.

### I. Backend
- Delivers the game interface to the browser
- Provides a static highscores API endpoint
- Does not process any game logic
- Maintains a minimal, fast, and stateless structure

### II. Frontend
The entire game logic runs in the browser, including:
- UI rendering
- Word validation
- Timer control
- AI decision-making
- Level management
- Achievements
- Word Journal
- Local data persistence

The game behaves like a modern Single Page Application (SPA).

---

## 3. Cross-Device Compatibility (Fully Responsive Design)
The game is fully responsive and adapts automatically to different screen sizes.

### Mobile Phones
- Touch-friendly buttons
- Large input fields
- Auto-scaling text
- Compact layout

### Tablets
- Balanced spacing
- Smooth transitions
- Touch and pen friendly

### Laptops & Desktops
- Wide-screen layout
- Keyboard and mouse optimized

---

## 4. Gameplay Theory
1. Start Screen, Level Select, Game Screen, Achievements, Word Journal
2. Player selects level and enters a valid word
3. AI responds with a chained word
4. Game ends on invalid word, duplicate, or timeout
5. Higher levels increase difficulty

---

## 5. Word Validation Theory
- Online API validation
- Offline fallback word list
- Works without internet

---

## 6. AI Decision Theory
- Chooses words strategically
- Avoids dead ends
- Smarter AI at higher levels

---

## 7. Timer System
- Countdown timer per turn
- Faster timer at higher levels

---

## 8. Scoring System
- Rewards valid and fast entries
- Penalties for errors and delays

---

## 9. Word Journal
- Stores words and meanings
- Offline accessible

---

## 10. Offline Behavior
- Fully playable offline
- Achievements and journal available

---

## 11. UX & Visual Design
- Neon UI
- Smooth animations
- Responsive layout

---

## 12. Data Persistence
- Uses local storage
- Ensures privacy

---

## 13. Future Enhancements
- Multiplayer
- Leaderboards
- Cloud sync
- Advanced AI

---

## 14. Implementation Images
- Desktop View
- Levels View
- Mobile View

---

## 15. Conclusion
The Word Chain AI Game is a responsive, educational vocabulary game using Minimax-based AI strategy, offering smooth gameplay across all devices.
