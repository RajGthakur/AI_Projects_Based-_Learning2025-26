:- use_module(library(http/thread_httpd)).
:- use_module(library(http/http_dispatch)).
:- use_module(library(http/html_write)).
:- use_module(library(http/http_error)).
:- use_module(library(http/json)).

% ------------------------------------------------
% Word Chain AI Game (Start Screen + Minimax AI)
% ------------------------------------------------

:- http_handler(root(.), home_page, []).
:- http_handler(root(highscores), get_highscores, []).

highscores([
    _{name:"Alice", score:210},
    _{name:"Bob", score:180},
    _{name:"Carol", score:160}
]).

get_highscores(_Request) :-
    highscores(Scores),
    reply_json_dict(_{scores:Scores}).

home_page(_Request) :-
    reply_html_page(
        title('Word Chain AI Game'),
        [
            % Responsive meta tag for mobile / tablet
            meta([name='viewport', content='width=device-width, initial-scale=1, maximum-scale=1']),
            style("
                /* ------- Base / Neon Theme ------- */
                html,body{height:100%;margin:0;background:#000;color:#0ff;font-family: 'Segoe UI', Roboto, 'Courier New', monospace;}

                /* Responsive typography and sizing */
                /* Use clamp to make fonts and controls scale across devices */
                html { font-size: clamp(14px, 2.2vw, 20px); }

                :root { --max-width: 1100px; --card-padding: 14px; --radius: 14px; }

                .center{display:flex;align-items:center;justify-content:center;}
                .page{padding:12px;display:flex;flex-direction:column;align-items:center;gap:8px;}
                h1{margin:10px 0;color:#00f9ff;text-shadow:0 0 12px rgba(0,255,255,0.12),0 0 30px rgba(0,200,255,0.06);font-size:clamp(20px,3.2vw,34px);}
                /* Start screen */
                #startScreen{width:100%;min-height:100vh;display:flex;align-items:center;justify-content:center;background:radial-gradient(circle at 20% 10%, rgba(0,255,255,0.03), transparent 20%), #000;padding:clamp(12px,2.5vw,30px);box-sizing:border-box;}
                .start-box{background:linear-gradient(180deg, rgba(10,10,12,0.85), rgba(0,0,0,0.6));border-radius:var(--radius);padding:clamp(18px,3vw,34px);width:92%;max-width:720px;text-align:center;border:1px solid rgba(0,255,255,0.06);box-shadow:0 0 40px rgba(0,255,255,0.03);}
                .start-box h2{color:#0ff;margin:0 0 8px;font-size:clamp(18px,2.8vw,28px);}
                .start-buttons{display:flex;gap:12px;justify-content:center;margin-top:14px;flex-wrap:wrap;}
                .btn{padding:clamp(10px,2.2vw,16px) clamp(12px,3vw,22px);border-radius:10px;border:none;cursor:pointer;font-weight:700;font-size:clamp(14px,2vw,18px);}
                .btn-primary{background:#00f9ff;color:#000;}
                .btn-ghost{background:transparent;border:1px solid rgba(0,255,255,0.12);color:#0ff;}

                /* Game container (hidden initially) */
                #gameWrapper{display:none;width:100%;padding:18px 0;box-sizing:border-box;}
                #container{width:95%;max-width:var(--max-width);background:linear-gradient(180deg, rgba(10,10,12,0.6), rgba(0,0,0,0.6));border-radius:var(--radius);padding:var(--card-padding);border:1px solid rgba(0,255,255,0.06);box-shadow:0 0 40px rgba(0,255,255,0.03);margin-bottom:40px;position:relative;box-sizing:border-box;}
                .row{display:flex;gap:10px;align-items:center;justify-content:center;flex-wrap:wrap;}
                button.control{background:#00f9ff;color:#000;border:none;padding:clamp(8px,1.8vw,12px) clamp(10px,2.5vw,16px);border-radius:10px;font-weight:700;cursor:pointer;box-shadow:0 0 12px rgba(0,255,255,0.08);font-size:clamp(13px,2vw,18px);}
                button.ghost{background:transparent;color:#0ff;border:1px solid rgba(0,255,255,0.12);box-shadow:none;}
                input#wordInput{padding:clamp(8px,1.8vw,12px) clamp(10px,2.2vw,14px);border-radius:8px;border:2px solid rgba(0,255,255,0.12);background:#071018;color:#eaffff;width:260px;max-width:60vw;text-align:center;box-shadow:0 0 12px rgba(0,255,255,0.06);font-size:clamp(14px,2.2vw,18px);} 

                /* Make input full width on small screens */
                @media (max-width:600px){ input#wordInput{width:100%;} }

                #progress-container{width:90%;height:clamp(10px,1.2vw,14px);background:#111;border-radius:8px;overflow:hidden;margin:6px auto;border:1px solid rgba(0,255,255,0.04);}                
                #progress-bar{height:100%;width:0%;background:#00ff00;transition:all 500ms linear;}
                #progressText{color:#9ff;font-size:clamp(12px,1.8vw,14px);margin:6px 0;}
                #timer-container{width:clamp(200px,36vw,360px);height:12px;background:#101216;border-radius:12px;overflow:hidden;border:1px solid rgba(0,255,255,0.04);}                
                #timer-bar{height:100%;width:100%;background:#00ff00;transition:width 400ms linear;}
                #log{width:92%;max-width:900px;height:clamp(180px,35vh,320px);background:#07080a;border-radius:10px;padding:10px;overflow:auto;color:#dff;box-shadow:0 0 22px rgba(0,255,255,0.04);border:1px solid rgba(0,255,255,0.03);font-size:clamp(13px,1.9vw,16px);}
                .journal-entry{margin-bottom:14px;border-bottom:1px solid #222;padding-bottom:8px;}
                .journal-entry h4{color:#00ffff;margin:0 0 4px;} .journal-entry p{margin:0;color:#ccc;font-size:0.95em;}
                /* modal */
                .modal-backdrop{position:fixed;inset:0;background:rgba(0,0,0,0.7);display:flex;align-items:center;justify-content:center;z-index:9999;padding:20px;box-sizing:border-box;}
                .modal{width:100%;max-width:720px;background:#07080a;border-radius:12px;padding:16px;border:1px solid rgba(0,255,255,0.08);box-shadow:0 0 40px rgba(0,255,255,0.06);color:#eaffff;}
                /* Word Journal animated modal */
                #wordJournal{position:fixed;inset:0;display:flex;justify-content:center;align-items:center;background:rgba(0,0,0,0.6);z-index:9999;opacity:0;pointer-events:none;transition:opacity .4s;padding:20px;box-sizing:border-box;}
                #wordJournal.show{opacity:1;pointer-events:auto;}
                .journal-box{background:linear-gradient(145deg,#0d0d0d,#1a1a1a);color:#eee;border-radius:16px;width:100%;max-width:600px;max-height:80vh;overflow-y:auto;padding:20px 25px;box-shadow:0 0 20px rgba(0,255,255,0.4);transform:translateY(-40px);opacity:0;transition:all .4s;}
                #wordJournal.show .journal-box{transform:translateY(0);opacity:1;}
                .journal-box::-webkit-scrollbar{width:8px;} .journal-box::-webkit-scrollbar-thumb{background:#00ffffa0;border-radius:10px;} .journal-box::-webkit-scrollbar-track{background:#111;}
                .journal-header{display:flex;justify-content:space-between;align-items:center;margin-bottom:12px;}
                .journal-header h2{margin:0;color:#0ff;text-shadow:0 0 8px #0ff;}
                .close-btn{background:transparent;color:#0ff;font-size:1.2em;border:none;cursor:pointer;}
                /* Level select page */
                #levelSelect{display:none;width:100%;min-height:100vh;padding:24px;box-sizing:border-box;}
                #level-grid{display:flex;flex-wrap:wrap;gap:12px;justify-content:center;margin-top:28px;}
                #level-grid button{width:120px;padding:12px;border-radius:10px;border:none;cursor:pointer;font-weight:700;font-size:clamp(14px,2vw,16px);}                
                /* back button neon style */
                .back-neon{position:absolute;left:18px;top:18px;padding:8px 12px;border-radius:10px;border:none;background:transparent;color:#0ff;border:1px solid rgba(0,255,255,0.14);box-shadow:0 0 20px rgba(0,255,255,0.04);cursor:pointer;font-weight:700;}

                /* Instructions scroll area (matches journal style) */
                .instr-scroll{background:linear-gradient(145deg,#0d0d0d,#1a1a1a);color:#eee;border-radius:12px;width:100%;max-width:600px;max-height:75vh;overflow-y:auto;padding:18px 22px;box-shadow:0 0 20px rgba(0,255,255,0.25);margin-top:8px;}
                .instr-scroll h2{margin-top:0;color:#0ff;}
                .instr-scroll ul{margin-top:6px;margin-bottom:6px;padding-left:18px;}
                .instr-scroll .example{background:#07080a;border-radius:8px;padding:8px;margin-top:8px;border:1px solid rgba(0,255,255,0.04);}

                .instr-scroll::-webkit-scrollbar{width:8px;} 
                .instr-scroll::-webkit-scrollbar-thumb{background:#00ffffa0;border-radius:10px;} 
                .instr-scroll::-webkit-scrollbar-track{background:#111;}

                /* small devices adjustments */
                @media (max-width:600px){ input#wordInput{width:100%;} .start-box{padding:18px;} #level-grid button{width:44%;} h1{font-size:20px;} .instr-scroll{max-height:65vh;padding:12px;} }

                /* tablets */
                @media (min-width:600px) and (max-width:1000px){ :root { --max-width: 900px; } }

                /* large desktop */
                @media (min-width:1200px){ :root { --max-width: 1200px; } }

                /* small accessibility tweaks */
                button:focus, input:focus { outline:2px solid rgba(0,255,255,0.14); outline-offset:2px; }

            "),
            % Start page + level select + game + modals
            div([id='startScreen'], [
                div([class='start-box'], [
                    h2('Welcome to Word Chain AI Game'),
                    p([style='color:#9ff;'], 'Test your vocabulary, learn new words, and challenge an AI powered by Minimax.'),
                    div([class='start-buttons'], [
                        button([class='btn btn-primary', id='startBtn', onclick='startFromLanding()'], '🎮 Start Game'),
                        button([class='btn btn-ghost', onclick='openInstructions()'], 'ℹ️ Instructions')
                    ]),
                    p([style='color:#9ff;margin-top:12px;font-size:0.95em;'], 'Click Start Game when you are ready. Meanings are saved in the Word Journal.')
                ])
            ]),

            % LEVEL SELECTION PAGE (shown after start)
            div([id='levelSelect'], [
                button([class='back-neon', onclick='backToStart()'], '⬅ Back'),
                div([style='display:flex;flex-direction:column;align-items:center;gap:8px;margin-top:32px;'], [
                    h1('Select a Level'),
                    p([style='color:#9ff;'], 'Click a level to start. Locked levels appear dimmed until unlocked.'),
                    div([id='level-grid'], [])
                ])
            ]),

            div([id='gameWrapper'], [
                div([class='page'], [
                    % back to levels button (top-left)
                    button([class='back-neon', onclick='backToLevels()'], '⬅ Levels'),
                    h1('💡 Word Chain — Neon Levels (Minimax AI)'),
                    div([id='container'], [
                        div([class='row'], [
                            div([], [span([id='progressText'], '0 / 21 Levels Completed')]),
                            div([], [
                                button([class='control ghost', id='instructionsBtn', onclick='openInstructions()'], 'ℹ️ Instructions'),
                                button([class='control ghost', id='journalBtn', onclick='openJournal()'], '📘 Word Journal')
                            ])
                        ]),
                        div([id='progress-container'], [div([id='progress-bar'], '')]),
                        div([id='level-board', style='margin:10px;display:none;'], []), % kept for backwards compatibility but hidden
                        div([id='status', style='margin:8px;color:#9ff;'], []),
                        div([id='hint', style='margin:4px;color:#bff;'], []),
                        div([class='row'], [
                            input([id='wordInput', type=text, placeholder='Enter your word...', onkeydown='if(event.key==\'Enter\')playerMove();', disabled], []),
                            button([class='control', onclick='playerMove()'], 'Submit'),
                            button([class='control', onclick='pauseResume()'], '⏯️ Pause/Resume'),
                            button([class='control', onclick='restartGame()'], '🔁 Restart'),
                            button([class='control', onclick='resetProgress()'], '🔄 Reset Progress')
                        ]),
                        div([id='timer-container'], [div([id='timer-bar'], '')]),
                        div([id='log'], []),
                        h3([style='color:#0ff;margin-top:12px;'], '🏅 Highscores'),
                        div([id='highscores'], [])
                    ])
                ])
            ]),
            % modal root (for instructions and other popups)
            div([id='modal-root'], []),
            % animated word journal modal
            div([id='wordJournal'], [
                div([class='journal-box'], [
                    div([class='journal-header'], [
                        h2('📘 Word Journal'),
                        button([class='close-btn', onclick='toggleJournal()'], '✖')
                    ]),
                    div([id='journalEntries'], [])
                ])
            ]),
            % JS
            script(type('text/javascript'),
" (function(){
  // ---------- State ----------
  let current = '', used = [], playerScore = 0, aiScore = 0, timer = null, timeLeft = 10;
  let TURN_TIME = 10, paused = false, level = 1, unlocked = 1, consecutiveWins = 0;
  const MAX_LEVEL = 21;
  let gameStarted = false;

  // offline dictionary fallback (also used by minimax search)
  const dictionary = ['apple','elephant','tiger','rabbit','tree','eagle','egg','grape','ear','rat','table','earring','goat','top','pen','notebook','kangaroo','owl','lion','night','truck','kite','eggplant','tomato','orange','nose','engine','nest','tea','ant','toy','yak','rose','lamp','nut','pan','nail','leaf','fish','hat','tie','eye','yellow','wolf','fan','rain','nutmeg','mountain','river','cloud','piano','guitar','banana','strawberry','zebra','xylophone'];

  // sounds
  const soundCorrect = new Audio('https://www.soundjay.com/buttons/sounds/button-3.mp3');
  const soundError = new Audio('https://www.soundjay.com/buttons/sounds/button-10.mp3');
  const soundAI = new Audio('https://www.soundjay.com/buttons/sounds/button-16.mp3');
  const soundWin = new Audio('https://www.fesliyanstudios.com/play-mp3/4382');
  const soundLose = new Audio('https://www.fesliyanstudios.com/play-mp3/4384');

  // AI personality
  const aiLines = ['Hmm... interesting choice.','Not bad, human!','You\\'re making this fun.','I see you like long words.','Can you keep up?','I like that one.','Nice try!'];

  // achievements (persisted)
  const ACH_KEYS = { rookie: 'ach_rookie', speed: 'ach_speed', lexicon: 'ach_lexicon', aislayer: 'ach_aislayer' };
  let achievements = {
    rookie: localStorage.getItem(ACH_KEYS.rookie) === '1',
    speed: localStorage.getItem(ACH_KEYS.speed) === '1',
    lexicon: localStorage.getItem(ACH_KEYS.lexicon) === '1',
    aislayer: localStorage.getItem(ACH_KEYS.aislayer) === '1'
  };

  // learned words journal (both player & AI). Stored in localStorage.
  // each entry: {word:'apple', meaning:'...', who:'player'|'ai'}
  let learnedWords = [];

  // ---------- Helpers ----------
  function $(id){ return document.getElementById(id); }
  function play(s){ try{ s.currentTime=0; s.play().catch(()=>{}); }catch(e){} }
  function logMessage(html){ const l = $('log'); l.innerHTML += html + '<br>'; l.scrollTop = l.scrollHeight; }
  function setStatus(){ $('status').innerHTML = '<b>Level:</b> ' + level + ' | <b>Current:</b> ' + (current || '-') + ' | 👤 ' + playerScore + ' | 🤖 ' + aiScore; }
  function setHint(){ $('hint').textContent = current ? '💡 Next word must start with: ' + current[current.length-1].toUpperCase() : ''; }
  function updateTimerBar(){ const pct = Math.max(0,(timeLeft / TURN_TIME) * 100); $('timer-bar').style.width = pct + '%'; }
  function updateProgressBar(){ const percent = ((unlocked - 1)/MAX_LEVEL) * 100; const bar = $('progress-bar'); bar.style.width = percent + '%'; let color = '#00ff00'; if(percent > 25) color = '#ffff00'; if(percent > 50) color = '#ffa500'; if(percent > 75) color = '#ff0000'; bar.style.background = color; $('progressText').textContent = (unlocked - 1) + ' / ' + MAX_LEVEL + ' Levels Completed'; }

  function saveAchievement(key){
    if(!achievements[key]){
      achievements[key] = true;
      localStorage.setItem(ACH_KEYS[key], '1');
      const el = $('badge-' + key);
      if(el) el.classList.add('earned');
      logMessage('<span style=\\'color:#bff;\\'>🏆 Achievement unlocked: ' + key + '</span>');
    }
  }
  function refreshBadgeUI(){ for(const k of Object.keys(achievements)){ const el = $('badge-' + k); if(el){ if(achievements[k]) el.classList.add('earned'); else el.classList.remove('earned'); } } }

  // ---------- Modals ----------
  function openInstructions(){
    const root = $('modal-root'); root.innerHTML = '';
    const backdrop = document.createElement('div'); backdrop.className = 'modal-backdrop';
    const modal = document.createElement('div'); modal.className = 'modal';
    const close = document.createElement('button'); close.className = 'close-btn'; close.textContent = 'Got it!';
    close.onclick = ()=>{ root.innerHTML = ''; };
    modal.appendChild(close);

    // Use a scrollable wrapper (instr-scroll) similar to the Word Journal
    modal.innerHTML += ''
      + '<div class=\"instr-scroll\">'
      + '<h2>📘 How to Play — Quick Guide</h2>'
      + '<p>Form real English words where each new word starts with the last letter of the previous word. The game validates words with an online dictionary and saves meanings to the Word Journal.</p>'
      + '<h3>Basic Rules</h3>'
      + '<ul>'
      + '<li>The game starts with a random word (e.g., \"apple\").</li>'
      + '<li>Your word must start with the last letter of that word (e.g., \"elephant\").</li>'
      + '<li>You and the AI take turns. No repeated words in the same level.</li>'
      + '<li>Words must be valid English words; the game uses an online dictionary to verify.</li>'
      + '</ul>'
      + '<h3>Scoring</h3>'
      + '<ul>'
      + '<li>Correct word: +10 points</li>'
      + '<li>Invalid or repeated: -5 points</li>'
      + '<li>Timeout: penalty based on level</li>'
      + '</ul>'
      + '<h3>Levels & Difficulty</h3>'
      + '<ul>'
      + '<li>21 levels total. AI difficulty and speed increase with levels.</li>'
      + '<li>Win levels to unlock the next one. Refreshing the page resets to Level 1.</li>'
      + '</ul>'
      + '<h3>Achievements</h3>'
      + '<ul>'
      + '<li>🔰 Word Rookie — first correct word</li>'
      + '<li>⚡ Speed Thinker — answer under 2s</li>'
      + '<li>📚 Lexicon Master — complete 5 levels</li>'
      + '<li>💎 AI Slayer — beat AI in a final round</li>'
      + '</ul>'
      + '<h3>Word Journal (What it does)</h3>'
      + '<p>The Word Journal records words both you and the AI used during gameplay and stores short meanings (when available). Use the Journal to review words you learned, revisit meanings, and clear entries if you want to reset the journal.</p>'
      + '<p>Journal entries are stored in your browser (localStorage) so they persist across sessions on the same device and browser.</p>'
      + '<h3>Example Round</h3>'
      + '<div class=\"example\">AI: apple → You: elephant → AI: tiger → You: rabbit</div>'
      + '</div>';

    backdrop.appendChild(modal);
    backdrop.onclick = function(e){ if(e.target === backdrop) root.innerHTML = ''; };
    root.appendChild(backdrop);
  }

  // ---------- Word Journal modal (animated, scrollable) ----------
  function openJournal(){
    const root = $('wordJournal');
    const entries = $('journalEntries');
    entries.innerHTML = '';
    if(learnedWords.length === 0){
      entries.innerHTML = '<p style=\"color:#bfb;\">No words learned yet. Play to collect words and meanings!</p>';
    } else {
      for(let i = learnedWords.length - 1; i >= 0; i--){
        const e = learnedWords[i];
        const div = document.createElement('div');
        div.className = 'journal-entry';
        const whoDot = e.who === 'player' ? '<span class=\\'player-dot\\'>🟩</span>' : '<span class=\\'ai-dot\\'>🔵</span>';
        div.innerHTML = whoDot + '<h4>' + e.word + '</h4>';
        if(e.meaning && e.meaning.length > 0) div.innerHTML += '<p>' + e.meaning + '</p>';
        else div.innerHTML += '<p style=\"color:#777;\">(Meaning unavailable)</p>';
        entries.appendChild(div);
      }
    }
    const footer = document.createElement('div');
    footer.style = 'display:flex;gap:8px;justify-content:flex-end;margin-top:12px;';
    const clearBtn = document.createElement('button');
    clearBtn.textContent = 'Clear Journal';
    clearBtn.style = 'background:#ff6666;color:#000;border:none;padding:8px 10px;border-radius:8px;cursor:pointer;';
    clearBtn.onclick = function(){
      localStorage.removeItem('journal');
      learnedWords = [];
      entries.innerHTML = '<p style=\"color:#bfb;\">No words learned yet. Play to collect words and meanings!</p>';
    };
    footer.appendChild(clearBtn);
    entries.appendChild(footer);

    root.classList.add('show');
  }

  function toggleJournal(){ const root = $('wordJournal'); root.classList.toggle('show'); }

  // ---------- UI: levels ----------
  function renderLevels(){
    // Prefer the dedicated level grid (levelSelect page). Fallback to the old level-board.
    const board = $('level-grid') || $('level-board');
    board.innerHTML = '';
    for(let i=1;i<=MAX_LEVEL;i++){
      const btn = document.createElement('button');
      btn.textContent = 'Level ' + i;
      btn.className = 'control';
      btn.style.margin = '4px';
      btn.disabled = (i > unlocked);
      btn.style.background = (i <= unlocked) ? '#00f9ff' : '#333';
      // when clicking a level: hide levelSelect, show gameWrapper, start level
      btn.onclick = (function(n){ return function(){
          // switch views
          const ls = document.getElementById('levelSelect');
          if(ls) ls.style.display = 'none';
          document.getElementById('startScreen').style.display = 'none';
          document.getElementById('gameWrapper').style.display = 'block';
          // start chosen level
          startLevel(n);
        }; })(i);
      board.appendChild(btn);
    }
    updateProgressBar();
  }

  function startLevel(n){
    level = n;
    TURN_TIME = Math.max(4, 10 - Math.floor((level - 1) / 2));
    used = []; playerScore = 0; aiScore = 0;
    const starts = (level <= 5) ? ['apple','table','tree','egg','dog'] : ['apple','table','river','mountain','cloud','elephant','tiger','guitar'];
    current = starts[Math.floor(Math.random() * starts.length)];
    used.push(current);
    logMessage('🎮 Level ' + level + ' started — first word: <b>' + current + '</b>');
    $('wordInput').disabled = false;
    setStatus(); setHint(); renderLevels(); startTimer();
    gameStarted = true;
  }

  // ---------- Start / Reset ----------
  function startGame(resetProgress = false){
    if(resetProgress){
      localStorage.setItem('unlocked','1');
    }
    unlocked = parseInt(localStorage.getItem('unlocked') || '1');
    try{
      const j = localStorage.getItem('journal');
      if(j){ learnedWords = JSON.parse(j); } else { learnedWords = []; }
    }catch(e){ learnedWords = []; }
    renderLevels(); refreshBadgeUI(); /* no automatic start here anymore */ updateHighscores();
  }

  function resetProgress(){
    localStorage.removeItem('unlocked');
    unlocked = 1;
    localStorage.setItem('unlocked','1');
    renderLevels();
    logMessage('<span style=\\'color:#9ff;\\'>🔁 Progress cleared. Back to Level 1.</span>');
  }

  function pauseResume(){
    paused = !paused;
    if(paused){ clearInterval(timer); logMessage('<span style=\\'color:#ffea7f;\\'>⏸️ Paused</span>'); }
    else { logMessage('<span style=\\'color:#bff;\\'>▶️ Resumed</span>'); startTimer(); }
  }

  function restartGame(){
    startLevel(level);
    logMessage('<span style=\\'color:#9ff;\\'>🔄 Level restarted</span>');
  }

  // ---------- Dictionary lookup ----------
  async function validateWordOnline(word){
    try{
      const r = await fetch('https://api.dictionaryapi.dev/api/v2/entries/en/' + encodeURIComponent(word));
      if(!r.ok) return null;
      const data = await r.json();
      if(Array.isArray(data) && data.length > 0 && data[0].word){
        let meaning = '';
        try{
          const m = data[0].meanings && data[0].meanings[0] && data[0].meanings[0].definitions && data[0].meanings[0].definitions[0];
          if(m && m.definition) meaning = m.definition;
        }catch(e){}
        return { word: data[0].word, meaning: meaning };
      } else return null;
    }catch(e){
      return 'offline';
    }
  }

  // add to journal (avoid duplicates)
  function addToJournal(word, meaning, who){
    const found = learnedWords.find(e=>e.word === word && e.who === who);
    if(found) return;
    learnedWords.push({ word: word, meaning: meaning || '', who: who });
    try{ localStorage.setItem('journal', JSON.stringify(learnedWords)); }catch(e){}
  }


  // ---------- Minimax Implementation (JS) ----------
  function getValidMoves(prev, usedArr){
    if(!prev || prev.length===0) return [];
    const last = prev[prev.length - 1];
    return dictionary.filter(w => w[0] === last && !usedArr.includes(w));
  }
  function copyArr(a){ return a.slice(0); }

  function minimax(prev, usedArr, depth, isAIturn){
    const moves = getValidMoves(prev, usedArr);
    if(moves.length === 0){
      return isAIturn ? -1 : 1;
    }
    if(depth === 0){
      return 0;
    }
    if(isAIturn){
      let best = -Infinity;
      for(const m of moves){
        const used2 = copyArr(usedArr); used2.push(m);
        const val = minimax(m, used2, depth - 1, false);
        if(val > best) best = val;
        if(best === 1) break;
      }
      return best;
    } else {
      let best = Infinity;
      for(const m of moves){
        const used2 = copyArr(usedArr); used2.push(m);
        const val = minimax(m, used2, depth - 1, true);
        if(val < best) best = val;
        if(best === -1) break;
      }
      return best;
    }
  }

  function chooseAIMoveMinimax(currentWord, usedArr){
    const moves = getValidMoves(currentWord, usedArr);
    if(moves.length === 0) return null;
    const baseDepth = 3;
    const depth = Math.min(6, baseDepth + Math.floor(level / 5));
    let bestMoves = [];
    let bestScore = -Infinity;
    for(const m of moves){
      const used2 = copyArr(usedArr); used2.push(m);
      const score = minimax(m, used2, depth - 1, false);
      if(score > bestScore){
        bestScore = score;
        bestMoves = [m];
      } else if(score === bestScore){
        bestMoves.push(m);
      }
    }
    bestMoves.sort((a,b)=>b.length - a.length);
    return bestMoves[Math.floor(Math.random() * bestMoves.length)];
  }

  // ---------- Timer ----------
  function startTimer(){
    clearInterval(timer);
    timeLeft = TURN_TIME;
    updateTimerBar();
    timer = setInterval(()=>{
      if(paused) return;
      timeLeft--; updateTimerBar();
      if(timeLeft <= 0){
        clearInterval(timer);
        play(soundError);
        playerScore = Math.max(0, playerScore - Math.ceil(TURN_TIME/2));
        logMessage('<span style=\\'color:#ff7f7f;\\'>⏰ Time up! Penalty applied.</span>');
        setStatus(); determineWinner();
      }
    },1000);
  }

  // ---------- Player move ----------
  async function playerMove(){
    if(!gameStarted) return;
    if(paused) return;
    clearInterval(timer);
    const input = $('wordInput'); const raw = input.value.trim().toLowerCase();
    if(!raw){ startTimer(); return; }
    const last = current[current.length - 1];
    if(used.includes(raw)){ endGameInvalid('Word already used'); return; }
    if(raw[0] !== last){ endGameInvalid('Wrong starting letter (expected: ' + last.toUpperCase() + ')'); return; }

    const v = await validateWordOnline(raw);
    if(v === null){
      endGameInvalid('Not a valid English word');
      return;
    } else if(v === 'offline'){
      if(!dictionary.includes(raw)){ endGameInvalid('Could not verify word online and not in local dictionary'); return; }
      logMessage('<span style=\\'color:#ffb\\'>⚠️ Offline validation — accepted via local dictionary</span>');
      addToJournal(raw, '', 'player');
    } else {
      addToJournal(v.word, v.meaning, 'player');
    }

    if(timeLeft >= TURN_TIME - 2){ saveAchievement('speed'); }
    used.push(raw); current = raw; playerScore += 10;
    play(soundCorrect); logMessage('<span style=\\'color:#9ff;\\'>✅ Player: ' + raw + '</span>');
    saveAchievement('rookie');
    setStatus(); setHint(); input.value = '';
    const aiDelay = Math.max(200, 1100 - (level * 60));
    setTimeout(()=> aiMove(), aiDelay);
    startTimer();
  }

  // ---------- AI move (Minimax) ----------
  function aiMove(){
    const options = getValidMoves(current, used);
    if(options.length === 0){ determineWinner(); return; }
    const choice = chooseAIMoveMinimax(current, used);
    if(!choice){
      const fallback = options[Math.floor(Math.random()*options.length)];
      finishAIMove(fallback);
      return;
    }
    finishAIMove(choice);
  }

  function finishAIMove(choice){
    used.push(choice); current = choice; aiScore += 10;
    play(soundAI);
    const comment = aiLines[Math.floor(Math.random() * aiLines.length)];
    logMessage('<span style=\\'color:#9ff;\\'>🤖 AI: ' + choice + ' — <i>' + comment + '</i></span>');
    validateWordOnline(choice).then(res=>{
      if(res && res !== 'offline' && res.meaning){
        addToJournal(res.word, res.meaning, 'ai');
      } else {
        addToJournal(choice, '', 'ai');
      }
    }).catch(()=>{ addToJournal(choice, '', 'ai'); });
    setStatus(); setHint(); startTimer();
  }

  function endGameInvalid(reason){
    clearInterval(timer);
    $('wordInput').disabled = true;
    play(soundError);
    logMessage('<span style=\\'color:#ff8d8d;\\'>⛔ Game stopped: ' + reason + '</span>');
  }

  // ---------- Determine winner, unlocks, achievements ----------
  function determineWinner(){
    clearInterval(timer);
    $('wordInput').disabled = true;
    let msg = '';
    if(playerScore > aiScore){
      msg = '🎉 Player wins Level ' + level;
      play(soundWin);
      consecutiveWins++;
      if(level < MAX_LEVEL){
        unlocked = Math.max(unlocked, level + 1);
        localStorage.setItem('unlocked', String(unlocked));
      }
      if(consecutiveWins >= 5) saveAchievement('lexicon');
      if(level === MAX_LEVEL) saveAchievement('aislayer');
      renderLevels();
    } else if(aiScore > playerScore){
      msg = '🤖 AI wins';
      play(soundLose);
      consecutiveWins = 0;
    } else {
      msg = '⚖️ It\\'s a tie';
    }
    logMessage('<b style=\\'color:#bff;\\'>' + msg + '</b>');
    updateProgressBar();
    updateHighscores();
  }

  async function updateHighscores(){
    try{
      const r = await fetch('/highscores');
      const d = await r.json();
      const div = $('highscores');
      div.innerHTML = d.scores.map((s,i) => (i+1) + '. ' + s.name + ' — ' + s.score).join('<br>');
    }catch(e){}
  }

  // ---------- Start screen binding (modified) ----------
  window.startFromLanding = function(){
    // hide start screen, show level select page (do not auto-start the game)
    document.getElementById('startScreen').style.display = 'none';
    const ls = document.getElementById('levelSelect');
    if(ls) ls.style.display = 'block';
    // initialize persistent data and render level buttons
    startGame(false);
  };

  // Back buttons
  window.backToStart = function(){
    // from level select -> show start
    const ls = document.getElementById('levelSelect');
    if(ls) ls.style.display = 'none';
    document.getElementById('startScreen').style.display = 'flex';
  };
  window.backToLevels = function(){
    // from game -> show level select
    document.getElementById('gameWrapper').style.display = 'none';
    const ls = document.getElementById('levelSelect');
    if(ls) ls.style.display = 'block';
  };

  // expose important functions globally
  window.openInstructions = openInstructions;
  window.openJournal = openJournal;
  window.playerMove = playerMove;
  window.pauseResume = pauseResume;
  window.startLevel = startLevel;
  window.startGame = startGame;
  window.resetProgress = resetProgress;
  window.restartGame = restartGame;
  window.toggleJournal = toggleJournal;

  // ---------- On load ----------
  window.addEventListener('load', function(){
    refreshBadgeUI();
    try{
      const j = localStorage.getItem('journal');
      if(j) learnedWords = JSON.parse(j);
      else learnedWords = [];
    }catch(e){ learnedWords = []; }
    // show start screen; do not auto-start the game
    document.getElementById('startScreen').style.display = 'flex';
    document.getElementById('gameWrapper').style.display = 'none';
    // ensure levelSelect hidden initially
    const ls = document.getElementById('levelSelect');
    if(ls) ls.style.display = 'none';
    // pre-fill progress text from stored unlocked value
    unlocked = parseInt(localStorage.getItem('unlocked') || '1');
    $('progressText').textContent = (unlocked-1) + ' / ' + MAX_LEVEL + ' Levels Completed';
  });

})();"
            )
        ]).

% ---------------------------
% Start server
% ---------------------------
server(Port) :-
    http_server(http_dispatch, [port(Port)]).
