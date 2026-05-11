# 🚀 AutoLife: The Cross-Platform Life Management Hub

**Vision:** A unified, modular ecosystem app designed to replace 10 different family, calendar, list, and tracking apps. It uses deep integrations so that an action in one module intelligently triggers actions in others.

---

## 🛠️ Part 1: The Tech Stack & Architecture
To avoid building separate apps and ensure seamless real-time syncing, the architecture is unified:
*   **Frontend (UI):** **Flutter**. Write once, compile natively to iOS, Android, Web, and Desktop. Perfect for complex, interactive calendars and lists.
*   **Backend & Database:** **Supabase**. Provides real-time database syncing (crucial for shared family lists), secure user authentication, and cloud storage (for receipts, PDFs, and photos). Provides seamless offline-sync caching.
*   **AI & OCR Engine:** **Google Cloud Vision API** (or similar) to read uploaded receipts, extract data (store, price, date), read nutrition labels, and parse unstructured text (like forwarding a school email to generate calendar events).
*   **Melo**: the apps should each be its own Melo folder.
*   **Unified UI** All UI's should have the same "feel" and "vibe", they should look and feel the same to use, even if they are all different/sub-repos.

---

## ✨ Part 2: Global Quality of Life (QoL) Features
These system-wide mechanics ensure the app feels premium, frictionless, and intelligent.
*   **Universal Omnibar Search:** A single search bar that queries *everything*. Typing "Apple" shows the Apple Store purchase receipt, the grocery list item, the calendar event "Apple Picking," and the task "Fix Apple Watch."
*   **Robust Offline Mode Engine:** Supabase/Flutter handles offline caching so users can check off groceries or view calendars with no cell service. It resolves conflicts seamlessly when reconnected.
*   **Smart Morning/Evening Briefings:** A daily 7:00 AM (this can be changed in settings) push notification: *"Today you have 3 meetings, 2 tasks. It’s going to rain, so your son's soccer game might be canceled."*
*   **Printability:** Export lists, calendars, and meal plans to a clean PDF format to stick on the fridge. (with multple design options to choose from)

---

## 🏗️ Part 3: Core MVP Modules

### 1. The "AutoLife" Dashboard (The Shell)
*   **Adaptive Widgets:** The home screen changes based on time. Morning = Weather, Schedule, Coffee Habit. Evening = Tomorrow's meal prep, Evening chores.
*   **Family/Role Management:** Invite family members, assign colors to each person, and set permissions.

### 2. The Smart Calendar
*   **Universal Sync:** 2-way sync with Google Calendar, Apple Calendar, and Outlook.
*   **Auto-Commute Blocks:** If an event has a location, the app pulls traffic data (from google maps or other set-able apis, which should be able to be changed in settings) and blocks out a gray "Commute" chunk prior to the event. --> this feature has to have a "turn off" setting.
*   **Weather Overlays:** Weather icons appear on upcoming days. If a scheduled "Beach Day" forecast changes to rain, it flags with a red dot. --> again this has to have a setting.
*   **Emergency Contact Sync (Babysitter Mode):** Generate a temporary "Read-Only" calendar link for babysitters that includes parents' locations and emergency numbers. (with like set able duration of how long the link works, what is shown and more settings.)

### 3. To-Do & Task Engine
*   **The "Switching" Engine (Event <--> Task):**
    *   *Event to Task:* Having the option to change the event to a "clickable" task, e.g. final in math is an event, but maybe i want to have it as a task instead...
*   **Sub-Task Dependency:** Lock tasks. You can't cross off "Bake Cake" until "Buy Ingredients" is checked. (this has to be able to be set in the event/task itself and has to have a setting)

### 4. AutoAssets (Purchase Tracker)
*   **Step 1: The Vault (Purchase):** Scan a receipt. AI logs the item, price, store, and extracts the IMEI/Serial Number.
*   **Step 2: Auto-Protection:** Sets a calendar reminder for 1-year warranty expiry and a 14-day "Return Window Ends" warning. Automatically fetches and downloads the device's PDF user manual. (this has to be set in the settings, as downloading everything might not be optimal..)
*   **Step 3: The Claim/Breakage Flow:** If something breaks the user should have the ability to add like an insurance event to that asset. or like a yearly motor checkup at the garage should be able to be linked to the asset etc. and shown as a timeline..

---

## 🌍 Part 4: The AutoLife Ecosystem (Post-MVP Expansion)

### 🍽️ AutoDine (Meal Prep, Groceries & Nutrition)
*   **Custom Recipe & Nutrition Vault:** Manually input your own recipes. Enter a food ingredient's nutritional values (macros) once, and it is saved in your personal database forever.
*   **OCR & API Store Sync (Coop / Migros):** Two ways to log food:
    *   *API:* Connect directly to local Swiss stores like Coop and Migros to automatically import product nutrition data. (more shops can be added by adding the url and then the app tries to find a way to search for products, get the favicon etc from that shop and set up another "store" that can diretly be connect to)
    *   *Camera OCR:* Snap a photo of any nutrition label. The AI extracts the macros instantly—you just review and tap "Accept" or fine-tune the numbers.
*   **Smart Store-Specific Sorting:** The grocery list doesn't just sort by aisle; it sorts by *the specific store you are visiting* (e.g., separating items you only buy at Migros vs. Coop).
*   **Live Store Inventory Checks:** Set a "Default Store" (e.g., your local neighborhood Coop). The app pings the store's online inventory database and flags an item on your list if it is currently out of stock at your local branch!
*   **Pantry/Freezer Inventory:** Track what you own. AI suggests recipes based *only* on expiring freezer items.
*   **Best Deal:** If a product has a deal ("Aktion") it notes it and shows it somehow in the app.

### 🩺 AutoHealth (Medical, Wellness & Cycle Tracker)
*   **Advanced AI Cycle Tracker:** 
    *   *Predictive Phases:* Predicts all phases (Menstrual, Follicular, Ovulation, Luteal) based on general medical data and machine-learning adapted to your personal history.
    *   *Deep Symptom Logger:* Track flow intensity (spotting, light, medium, heavy), cramps, mood, concentration, and energy levels. Includes custom pain inputs (e.g., explicitly tracking *toothaches* or *foot pain* related to cycle shifts).
    *   *Product Tracker & Smart Sync:* Track which products you used (pads, tampons, cups, period underwear). *Smart Integration:* When you log heavy usage, the app auto-adds pads/tampons to your Grocery List.
    *   *Granular Privacy Layer:* Keep the symptom and flow details completely hidden, but opt to share *only* your current cycle phase (e.g., "Menstruating" or "Luteal") with the shared Family Calendar.
*   **Smart Workout & Calorie Tracker:** Log your workouts. The app dynamically calculates estimated calories burned based specifically on the *exact exercises performed* combined with your *current logged body weight*.
*   **Medication Tracker & Refill Loop:** Track daily meds. When 3 pills are left, it pushes an "Order Prescription" task to the To-Do list.
*   **Medical Passport:** A secure vault for blood types, allergies, and vaccination PDFs.

### 🏠 AutoMaintain (Home & Vehicles)
*   **Mileage Triggers:** Enter car mileage -> automatically creates a "Change Oil" task and schedules it.
*   **Seasonal Automation:** Auto-generates "Winterize Sprinklers" events based on local weather data.
*   **Video-Note Capabilities:** Record a 30-second video of your electrician explaining the breaker box, pinned to the Home section.
*   **Home Tricks:** When repairing something and you notice it, add like a note where when the next time you have an issue you can check if you noted anything, with videos, images etc.

### 💰 AutoFinance (Budgets & Subscriptions)
*   **Free-Trial Killer:** Log a free trial. The app sets an aggressive alarm 48 hours before the card is charged, including the cancellation URL.
*   **Allowance Linked to Chores:** If a kid checks off 5 chores, AutoFinance updates their digital piggy bank.
*   **Shared Expense Splitter:** Keeps a running tab for couples or older teens ("Who paid for groceries today?").
*   **Inspire from Splitwise:** Splitwise has many functionality such as also translating currencies to this can also be done or other things. 

### 📍 AutoLocate (Family Safety)
*   **Emergency SOS Protocol:** A widget button for kids. If pressed, it sends a high-priority overriding sound notification to parents with exact GPS coordinates.
*   **Where is my?** integration, where the devices ping their location to each other so that if smth gets stolen or is lost, it can be found easily.

### 🤖 AutoMail & Messaging (AI Assistant)
*   **Email:** There is a email account which is for the whole family e.g. "smith@auto.life"

### 🐾 AutoPets
*   **Rotational Chores:** Toggle "Dog has been fed" so family members don't double-feed.
*   **Vet & Meds Tracker:** Keep rabies certificates handy and get flea/tick medication reminders.

---

## ⚙️ Part 5: Control Center & Settings Engine
A centralized master-panel to tweak the behavioral logic, privacy, and automations of the ecosystem.

### 1. Permissions & Role Matrix
*   **Custom Roles:** Templates for *Co-Parent, Teenager, Young Child, Grandparent, Guest/Babysitter, Child*. --> these might change with age...
*   **RSVP & Approval Engine:** 
    *   *Strictness toggles:* "Child accounts require Parent approval to add calendar events."
    *   *Auto-Approve rules:* "Auto-approve teen's events if the location is set to 'School'."
    *   *Turn off:* Turn off approval engine if its not necessary.
*   **Chore Enforcement:** Toggle if a kid's chore requires a "Photo Proof" upload or Parent "Verification" before granting allowance.

### 2. Privacy & Guest Configurations
*   **Cycle & Health Privacy:** Granular controls for what Family members see. (e.g., Hide all custom pains and flow data, only display cycle phase on the shared calendar).
*   **Granular Babysitter Links:** When generating a 24hr Guest Link, toggle exactly what they see. (e.g., *Toggle ON:* Wi-Fi, Emergency Contacts, Allergy List. *Toggle OFF:* Financial budgets, Parent GPS, Private events).
*   **Biometric App-Locks:** Require FaceID/Fingerprint to open sensitive modules like AutoFinance or AutoHealth, while keeping the Grocery List module public.

### 3. Automation & AI "Leash"
*   **AI Intervention Levels:** Choose if the AI is *Manual* (asks permission before creating an event from an email) or *Autonomous* (creates the event silently and just notifies you).
*   **Smart-Switching Rules:** Define deep links. (e.g., "When grocery stock drops below 10%, auto-add to Instacart" -> Toggle ON/OFF).

### 4. Notification & "Nag Mode" Tuning
*   **"Nag Mode" Calibration:** For urgent tasks, choose behavior: *Quiet Nag* (push notification every hour) vs. *Aggressive Nag* (SMS and un-dismissable banner).
*   **Notification Batching:** Instead of 5 pings when a partner adds 5 items to groceries, intercept and send 1 ping after 10 minutes: *"Partner added 5 items."*

### 5. UI & Accessibility (Per-Device Rules)
*   **Dashboard Density:** 
    *   *Command Center (Parents):* High-density UI (calendars, tight lists, complex widgets).
    *   *Kids Mode (Tablet):* Massive, easy-to-tap buttons, bright colors, emoji chore lists.
*   **Color Overrides:** Choose if Calendar colors are based on *Family Member* (Dad = Blue) or *Category* (Work = Blue).

### 6. Integration Manager & Data Backup
*   **Sync Hub:** Manage external API tokens. Choose one-way or two-way syncs (e.g., Sync *to* Google Calendar, but don't pull *from* it).
*   **Offline Conflict Resolution:** Rule setting for syncing. (e.g., "If offline sync conflict occurs, always keep the Parent's change.")
*   **"Download My Life" Vault:** A one-click export that packs all calendar history, receipt PDFs, and health charts into an encrypted zip file.