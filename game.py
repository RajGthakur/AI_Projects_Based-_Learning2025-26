import streamlit as st

st.set_page_config(page_title="AI Detective Escape Game", layout="centered")

# --------------------------
# INITIAL STATE
# --------------------------
if "step" not in st.session_state:
    st.session_state.step = "intro"

if "clue_index" not in st.session_state:
    st.session_state.clue_index = 0

if "clues" not in st.session_state:
    st.session_state.clues = []

if "ai_score" not in st.session_state:
    st.session_state.ai_score = {"Meera": 0, "Kabir": 0, "Raghav": 0}

if "final_choice" not in st.session_state:
    st.session_state.final_choice = None


# --------------------------
# INTERNAL AI LOGIC
# --------------------------

def add_clue(key):
    if key == "perfume":
        st.session_state.clues.append("A strong jasmine perfume smell near the body.")
        st.session_state.ai_score["Meera"] += 2

    elif key == "footprints":
        st.session_state.clues.append("Mud footprints leading to the storeroom.")
        st.session_state.ai_score["Raghav"] += 2

    elif key == "phone":
        st.session_state.clues.append("Victim texted Kabir recently: 'Stop threatening me.'")
        st.session_state.ai_score["Kabir"] += 2



# --------------------------
# GAME SCENES
# --------------------------

def intro():
    st.title("🔍 AI Detective Escape Game")
    st.write("A murder has happened inside this mansion. The killer is inside. Solve the case to escape alive.")

    if st.button("Start Investigation ➤"):
        st.session_state.step = "interrogate_meera"


# --- INTERROGATIONS ---

def interrogate_meera():
    st.header("🗣 Interrogation 1: Meera")
    st.write("Meera is the victim's close friend. She appears nervous and avoids eye contact.")
    st.write("*Her Alibi:* She claims she was fixing lights in the storeroom.")
    st.write("*AI Hint:* She talks softly… and you notice a faint smell of perfume.")

    if st.button("Continue ➤"):
        st.session_state.ai_score["Meera"] += 1
        st.session_state.step = "interrogate_kabir"


def interrogate_kabir():
    st.header("🗣 Interrogation 2: Kabir")
    st.write("Kabir was seen arguing with the victim earlier in the evening.")
    st.write("*His Alibi:* He says he stepped outside to take a call.")
    st.write("*AI Hint:* His voice is firm, but his story feels rushed.")

    if st.button("Continue ➤"):
        st.session_state.ai_score["Kabir"] += 1
        st.session_state.step = "interrogate_raghav"


def interrogate_raghav():
    st.header("🗣 Interrogation 3: Raghav")
    st.write("Raghav is the mansion caretaker. Calm but unusually quiet today.")
    st.write("*His Alibi:* Claims he was checking the generator room.")
    st.write("*AI Hint:* His shoes are muddy, matching the hallway dirt.")

    if st.button("Start Clue Search ➤"):
        st.session_state.ai_score["Raghav"] += 1
        st.session_state.step = "clue_phase"


# --- CLUES ---

clue_list = [
    ("perfume", "Clue 1: A strong jasmine perfume lingers near the body."),
    ("footprints", "Clue 2: Muddy footprints lead from hall to storeroom."),
    ("phone", "Clue 3: Victim's phone shows threatening messages from Kabir.")
]


def clue_phase():
    st.header("🕵️ Evidence Collection")

    idx = st.session_state.clue_index

    if idx < len(clue_list):
        key, text = clue_list[idx]

        st.subheader(text)
        add_clue(key)

        st.write("*AI Hint:* Something about this clue contradicts someone's story…")

        st.write("\nWhat do you want to do?")
        col1, col2 = st.columns(2)

        with col1:
            if st.button("Next Clue ➤"):
                st.session_state.clue_index += 1

        with col2:
            if st.button("⚠️ Accuse Now"):
                st.session_state.step = "accuse"

    else:
        st.write("You've seen all clues.")
        if st.button("Make Final Accusation ➤"):
            st.session_state.step = "accuse"


# --- ACCUSATION ---

def accuse():
    st.header("⚠️ Final Accusation")
    st.write("Based on clues, interrogations, and AI hints — choose the killer:")

    suspect = st.radio("Your Accusation:", ["Meera", "Kabir", "Raghav"])

    if st.button("Confirm Accusation"):
        st.session_state.final_choice = suspect
        st.session_state.step = "ending"


# --- ENDING ---

def ending():
    st.header("🏁 Final Verdict")

    true_killer = "Meera"
    user_choice = st.session_state.final_choice
    scores = st.session_state.ai_score
    predicted = max(scores, key=scores.get)

    if user_choice == true_killer:
        st.success("🎉 Correct! You solved the case and escaped the mansion!")
    else:
        st.error(f"❌ Wrong. The real killer was *{true_killer}*.")

    st.write("---")
    st.subheader("🧠 AI Analysis Summary")
    st.write("The jasmine perfume being subtle but consistent was the strongest indicator.")

    if st.button("Play Again 🔄"):
        st.session_state.step = "intro"
        st.session_state.clue_index = 0
        st.session_state.clues = []
        st.session_state.ai_score = {"Meera": 0, "Kabir": 0, "Raghav": 0}
        st.session_state.final_choice = None


# ROUTING
if st.session_state.step == "intro":
    intro()
elif st.session_state.step == "interrogate_meera":
    interrogate_meera()
elif st.session_state.step == "interrogate_kabir":
    interrogate_kabir()
elif st.session_state.step == "interrogate_raghav":
    interrogate_raghav()
elif st.session_state.step == "clue_phase":
    clue_phase()
elif st.session_state.step == "accuse":
    accuse()
elif st.session_state.step == "ending":
    ending()
